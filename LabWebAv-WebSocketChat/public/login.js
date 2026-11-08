// Login con Firebase Authentication + intercambio por JWT del servidor
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.14.1/firebase-app.js';
import {
  getAuth,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword
} from 'https://www.gstatic.com/firebasejs/10.14.1/firebase-auth.js';

const form = document.getElementById('loginForm');
const emailInput = document.getElementById('email');
const passwordInput = document.getElementById('password');
const errorDiv = document.getElementById('loginError');
const loginBtn = document.getElementById('loginBtn');
const registerBtn = document.getElementById('registerBtn');

// Si ya hay un JWT vigente, ir directo al chat
const existing = sessionStorage.getItem('chat-jwt');
if (existing) {
  try {
    const { exp } = JSON.parse(atob(existing.split('.')[1]));
    if (exp * 1000 > Date.now()) location.replace('index.html');
  } catch (e) { /* token inválido: seguir en login */ }
}

const ERRORES = {
  'auth/invalid-credential': 'Correo o contraseña incorrectos.',
  'auth/invalid-email': 'Correo inválido.',
  'auth/email-already-in-use': 'Ese correo ya está registrado.',
  'auth/weak-password': 'La contraseña debe tener al menos 6 caracteres.',
  'auth/too-many-requests': 'Demasiados intentos. Intenta más tarde.',
  'auth/operation-not-allowed': 'Habilita Email/Password en Firebase Authentication.'
};

let auth;
async function getFirebaseAuth() {
  if (!auth) {
    const config = await (await fetch('/firebase-config')).json();
    auth = getAuth(initializeApp(config));
  }
  return auth;
}

async function authenticate(action) {
  errorDiv.textContent = '';
  loginBtn.disabled = registerBtn.disabled = true;
  try {
    const a = await getFirebaseAuth();
    const cred = await action(a, emailInput.value.trim(), passwordInput.value);
    const idToken = await cred.user.getIdToken();

    // Intercambiar el ID token de Firebase por el JWT del servidor
    const res = await fetch('/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idToken })
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'No se pudo iniciar sesión.');

    sessionStorage.setItem('chat-jwt', data.token);
    sessionStorage.setItem('chat-username', data.username);
    location.replace('index.html');
  } catch (err) {
    errorDiv.textContent = ERRORES[err.code] || err.message;
    loginBtn.disabled = registerBtn.disabled = false;
  }
}

form.addEventListener('submit', (e) => {
  e.preventDefault();
  authenticate(signInWithEmailAndPassword);
});
registerBtn.addEventListener('click', () => {
  if (form.reportValidity()) authenticate(createUserWithEmailAndPassword);
});
