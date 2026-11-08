// ==============================
// Servidor de chat WebSocket
// Express + ws + Firebase (Auth + Firestore) + JWT
// ==============================
require('dotenv').config(); // Lee las variables desde el archivo .env

const express = require('express');
const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

// ---------- Configuración desde .env ----------
const REQUIRED_VARS = [
  'JWT_SECRET',
  'ALLOWED_ORIGINS',
  'FIREBASE_PROJECT_ID',
  'FIREBASE_CLIENT_EMAIL',
  'FIREBASE_PRIVATE_KEY',
  'FIREBASE_API_KEY',
  'FIREBASE_AUTH_DOMAIN',
  'FIREBASE_APP_ID'
];
const missing = REQUIRED_VARS.filter((name) => !process.env[name]);
if (missing.length) {
  console.error('❌ Faltan variables en el archivo .env:', missing.join(', '));
  process.exit(1);
}

const PORT = Number(process.env.PORT) || 3000;
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '1h';
const HISTORY_LIMIT = Number(process.env.HISTORY_LIMIT) || 50;
const ALLOWED_ORIGINS = process.env.ALLOWED_ORIGINS
  .split(',')
  .map((o) => o.trim().replace(/\/$/, ''))
  .filter(Boolean);

const MAX_MESSAGE_LENGTH = 500;

// ---------- Firebase Admin (Auth + Firestore) ----------
initializeApp({
  credential: cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    // En .env los saltos de línea de la clave van escritos como \n
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
  })
});
const db = getFirestore();
const messagesCol = db.collection('messages');

// ---------- Utilidades ----------
function isOriginAllowed(origin) {
  return !!origin && ALLOWED_ORIGINS.includes(origin.replace(/\/$/, ''));
}

function formatTime(date) {
  return date.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' });
}

// ---------- Express ----------
const app = express();
app.use(express.json({ limit: '10kb' }));

// Solo aceptar peticiones de la API desde el dominio permitido
function checkOrigin(req, res, next) {
  if (!isOriginAllowed(req.headers.origin)) {
    return res.status(403).json({ error: 'Origen no permitido.' });
  }
  res.setHeader('Access-Control-Allow-Origin', req.headers.origin);
  res.setHeader('Vary', 'Origin');
  next();
}

// Configuración pública de Firebase para el cliente (viene del .env)
app.get('/firebase-config', (req, res) => {
  res.json({
    apiKey: process.env.FIREBASE_API_KEY,
    authDomain: process.env.FIREBASE_AUTH_DOMAIN,
    projectId: process.env.FIREBASE_PROJECT_ID,
    appId: process.env.FIREBASE_APP_ID
  });
});

// Login: valida el ID token de Firebase y devuelve un JWT propio
app.post('/auth/login', checkOrigin, async (req, res) => {
  const { idToken } = req.body || {};
  if (!idToken || typeof idToken !== 'string') {
    return res.status(400).json({ error: 'Falta el idToken.' });
  }
  try {
    const decoded = await getAuth().verifyIdToken(idToken);
    const username = decoded.name || (decoded.email || 'usuario').split('@')[0];
    const token = jwt.sign(
      { uid: decoded.uid, email: decoded.email, username },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );
    res.json({ token, username });
  } catch (error) {
    console.error('Login rechazado:', error.code || error.message);
    res.status(401).json({ error: 'Credenciales inválidas.' });
  }
});

app.use(express.static('public'));

const server = app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
  console.log('🔒 Orígenes permitidos:', ALLOWED_ORIGINS.join(', '));
});

// ---------- WebSocket ----------
const wss = new WebSocket.Server({
  server,
  // Se ejecuta antes de aceptar la conexión: valida dominio y JWT
  verifyClient: (info, done) => {
    if (!isOriginAllowed(info.origin)) {
      console.warn('WS rechazado, origen no permitido:', info.origin);
      return done(false, 403, 'Origen no permitido');
    }
    try {
      const url = new URL(info.req.url, 'http://localhost');
      const token = url.searchParams.get('token');
      info.req.user = jwt.verify(token, JWT_SECRET);
      done(true);
    } catch (error) {
      console.warn('WS rechazado, JWT inválido:', error.message);
      done(false, 401, 'Token inválido o expirado');
    }
  }
});

const clients = new Map(); // ws -> { uid, username }

function broadcast(data) {
  const payload = JSON.stringify(data);
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) client.send(payload);
  });
}

function broadcastUserCount() {
  broadcast({ type: 'userCount', count: clients.size });
}

// Últimos mensajes guardados en Firestore (orden cronológico)
async function loadHistory() {
  const snap = await messagesCol.orderBy('createdAt', 'desc').limit(HISTORY_LIMIT).get();
  return snap.docs
    .map((doc) => {
      const d = doc.data();
      return {
        type: 'chat',
        username: d.username,
        text: d.text,
        timestamp: d.createdAt ? formatTime(d.createdAt.toDate()) : ''
      };
    })
    .reverse();
}

wss.on('connection', async (ws, req) => {
  const { uid, username } = req.user; // Identidad tomada del JWT, no del cliente
  clients.set(ws, { uid, username });
  console.log(`Cliente conectado: ${username}. Total: ${clients.size}`);

  // Cerrar la conexión cuando el JWT expire
  const msLeft = req.user.exp * 1000 - Date.now();
  const expiryTimer = setTimeout(() => ws.close(4001, 'Token expirado'), Math.max(msLeft, 0));

  // Enviar historial desde Firestore
  try {
    ws.send(JSON.stringify({ type: 'history', messages: await loadHistory() }));
  } catch (error) {
    console.error('No se pudo cargar el historial:', error.message);
  }

  broadcast({ type: 'join', username, timestamp: formatTime(new Date()) });
  broadcastUserCount();

  ws.on('message', async (data) => {
    let message;
    try {
      message = JSON.parse(data);
    } catch (error) {
      return;
    }

    if (message.type === 'typing') {
      broadcast({ type: 'typing', username });
      return;
    }

    if (message.type === 'chat') {
      const text = (message.text || '').trim();
      if (!text) {
        ws.send(JSON.stringify({ type: 'error', text: 'El mensaje no puede estar vacío.' }));
        return;
      }
      if (text.length > MAX_MESSAGE_LENGTH) {
        ws.send(JSON.stringify({
          type: 'error',
          text: `El mensaje supera el máximo de ${MAX_MESSAGE_LENGTH} caracteres.`
        }));
        return;
      }

      // Guardar en Firestore y reenviar a todos
      try {
        await messagesCol.add({
          uid,
          username,
          text,
          createdAt: FieldValue.serverTimestamp()
        });
      } catch (error) {
        console.error('Error al guardar en Firestore:', error.message);
        ws.send(JSON.stringify({ type: 'error', text: 'No se pudo guardar el mensaje.' }));
        return;
      }
      broadcast({ type: 'chat', username, text, timestamp: formatTime(new Date()) });
    }
  });

  ws.on('close', () => {
    clearTimeout(expiryTimer);
    clients.delete(ws);
    console.log(`Cliente desconectado: ${username}. Total: ${clients.size}`);
    broadcast({ type: 'leave', username, timestamp: formatTime(new Date()) });
    broadcastUserCount();
  });

  ws.on('error', (error) => {
    console.error('Error WebSocket:', error.message);
  });
});
