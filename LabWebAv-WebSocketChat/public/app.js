// ==============================
// Cliente WebSocket - Chat
// ==============================

// ---------- Referencias del DOM ----------
const messagesDiv   = document.getElementById('messages');
const messageInput  = document.getElementById('messageInput');
const userLabel     = document.getElementById('userLabel');
const logoutBtn     = document.getElementById('logoutBtn');
const sendBtn       = document.getElementById('sendBtn');
const themeBtn      = document.getElementById('themeBtn');
const statusDot     = document.getElementById('statusDot');
const statusText    = document.getElementById('statusText');
const userCountSpan = document.getElementById('userCount');
const typingInd     = document.getElementById('typingIndicator');

// ---------- Estado ----------
let ws;
let connected = false;
const token = sessionStorage.getItem('chat-jwt');
let myUsername = sessionStorage.getItem('chat-username') || '';
let typingTimeout = null;
let typingHideTimeout = null;

// Constantes de validación (coinciden con el servidor)
const MAX_MESSAGE_LENGTH = 500;
const MAX_USERNAME_LENGTH = 20;

// ---------- Sesión (JWT) ----------
function logout() {
  sessionStorage.removeItem('chat-jwt');
  sessionStorage.removeItem('chat-username');
  location.replace('login.html');
}

function tokenExpired() {
  try {
    const { exp } = JSON.parse(atob(token.split('.')[1]));
    return exp * 1000 <= Date.now();
  } catch (e) {
    return true;
  }
}

// Sin JWT vigente: volver al login
if (!token || tokenExpired()) logout();

logoutBtn.addEventListener('click', logout);
userLabel.textContent = '👤 ' + myUsername;

// ---------- Tema claro / oscuro ----------
function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  themeBtn.textContent = theme === 'dark' ? '☀️ Claro' : '🌙 Oscuro';
}

function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme') || 'light';
  const next = current === 'dark' ? 'light' : 'dark';
  localStorage.setItem('chat-theme', next);
  applyTheme(next);
}

// Al cargar, leer la preferencia guardada
const savedTheme = localStorage.getItem('chat-theme') || 'light';
applyTheme(savedTheme);

themeBtn.addEventListener('click', toggleTheme);

// ---------- Conexión WebSocket ----------
function connect() {
  setStatus('reconnecting', 'Reconectando...');

  const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
  ws = new WebSocket(`${protocol}//${location.host}/?token=${encodeURIComponent(token)}`);

  ws.onopen = () => {
    connected = true;
    setStatus('connected', 'Conectado');
    sendBtn.disabled = false;

  };

  ws.onmessage = (event) => {
    const msg = JSON.parse(event.data);

    // Si el servidor no envía "type", asumimos que es un mensaje de chat
    // (por compatibilidad con versiones anteriores del servidor)
    const type = msg.type || 'chat';

    switch (type) {
      case 'chat':
        // Si el mensaje es propio, va a la derecha; si no, a la izquierda
        if (msg.username === myUsername) {
          addMessage('own', msg.username, msg.text, msg.timestamp);
        } else {
          addMessage('other', msg.username, msg.text, msg.timestamp);
        }
        break;

      case 'history':
        msg.messages.forEach((m) => {
          addMessage(m.username === myUsername ? 'own' : 'other', m.username, m.text, m.timestamp);
        });
        break;

      case 'join':
        addSystemMessage(`${msg.username} se ha unido al chat`, msg.timestamp);
        break;

      case 'leave':
        addSystemMessage(`${msg.username} ha salido del chat`, msg.timestamp);
        break;

      case 'typing':
        showTyping(msg.username);
        break;

      case 'userCount':
        userCountSpan.textContent = msg.count;
        break;

      case 'error':
        alert(msg.text);
        break;
    }
  };

  ws.onclose = (event) => {
    connected = false;
    setStatus('disconnected', 'Desconectado');
    sendBtn.disabled = true;
    // Token vencido o rechazado: volver al login; si no, reintentar en 3 s
    if (event.code === 4001 || tokenExpired()) return logout();
    setTimeout(connect, 3000);
  };

  ws.onerror = (error) => {
    console.error('Error WebSocket:', error);
  };
}

// ---------- Helpers de estado ----------
function setStatus(state, text) {
  statusDot.className = 'status-dot';
  if (state === 'connected') {
    statusDot.classList.add('connected');
  } else if (state === 'reconnecting') {
    statusDot.classList.add('reconnecting');
  }
  statusText.textContent = text;
}

// ---------- Mostrar mensajes ----------
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

function addMessage(cls, username, text, timestamp) {
  const div = document.createElement('div');
  div.className = `message ${cls}`;
  // En los mensajes propios no mostramos nuestro propio nombre (estilo WhatsApp)
  const nameHtml = cls === 'own'
    ? ''
    : `<div class="msg-username">${escapeHtml(username)}</div>`;
  div.innerHTML = `
    ${nameHtml}
    <div class="msg-text">${escapeHtml(text)}</div>
    <div class="msg-time">${escapeHtml(timestamp || '')}</div>
  `;
  messagesDiv.insertBefore(div, typingInd);
  messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

function addSystemMessage(text, timestamp) {
  const div = document.createElement('div');
  div.className = 'message system';
  div.textContent = `${text} (${timestamp || ''})`;
  messagesDiv.insertBefore(div, typingInd);
  messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

function showWelcomeMessage() {
  const div = document.createElement('div');
  div.className = 'message system';
  div.textContent = 'Bienvenido. Escribe un mensaje y presiona Enviar.';
  messagesDiv.insertBefore(div, typingInd);
}

// ---------- Indicador de escritura ----------
function showTyping(username) {
  // No mostrar nuestro propio indicador
  if (username === myUsername) return;

  typingInd.textContent = `${username} está escribiendo...`;
  typingInd.classList.add('visible');
  messagesDiv.scrollTop = messagesDiv.scrollHeight;

  // Ocultar después de 3 segundos sin nuevas notificaciones
  clearTimeout(typingHideTimeout);
  typingHideTimeout = setTimeout(() => {
    typingInd.classList.remove('visible');
  }, 3000);
}

// ---------- Enviar mensajes ----------
function sendMessage() {
  const text = messageInput.value.trim();

  if (!text) {
    messageInput.focus();
    return;
  }
  if (text.length > MAX_MESSAGE_LENGTH) {
    alert(`El mensaje no puede superar ${MAX_MESSAGE_LENGTH} caracteres.`);
    return;
  }
  if (!connected) {
    alert('No hay conexión al servidor.');
    return;
  }

  // El servidor toma el usuario del JWT
  ws.send(JSON.stringify({ type: 'chat', text }));
  messageInput.value = '';
  messageInput.focus();
}

// ---------- Event listeners ----------
sendBtn.addEventListener('click', sendMessage);

messageInput.addEventListener('keypress', (e) => {
  if (e.key === 'Enter') {
    sendMessage();
  } else if (connected && myUsername) {
    // Avisar que estamos escribiendo (con throttle de 2s)
    if (!typingTimeout) {
      ws.send(JSON.stringify({ type: 'typing', username: myUsername }));
      typingTimeout = setTimeout(() => {
        typingTimeout = null;
      }, 2000);
    }
  }
});

// ---------- Inicializar ----------
showWelcomeMessage();

connect();
messageInput.focus();
