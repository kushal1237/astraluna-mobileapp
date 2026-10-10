/* =====================================================
   auth.js — Authentication handler (register/login/verify)
   ===================================================== */
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db');

const JWT_SECRET = process.env.JWT_SECRET || 'chips-or-bomb-secret-key-2024';
const JWT_EXPIRES = '30d';

function generateToken(userId) {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: JWT_EXPIRES });
}

function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (e) {
    return null;
  }
}

function sanitizeUser(user) {
  return {
    id: user.id,
    username: user.username,
    email: user.email,
    token_balance: user.token_balance,
    games_played: user.games_played,
    wins: user.wins,
    losses: user.losses,
    draws: user.draws
  };
}

function handleAuth(socket) {
  // ---- Register ----
  socket.on('auth:register', (data) => {
    try {
      const { email, username, password } = data;

      // Validate email
      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        return socket.emit('auth:error', { message: 'Please enter a valid email address.' });
      }

      // Validate username
      if (!username || username.length < 3 || username.length > 20) {
        return socket.emit('auth:error', { message: 'Username must be 3-20 characters long.' });
      }
      if (!/^[a-zA-Z0-9_]+$/.test(username)) {
        return socket.emit('auth:error', { message: 'Username can only contain letters, numbers, and underscores.' });
      }

      // Validate password
      if (!password || password.length < 6) {
        return socket.emit('auth:error', { message: 'Password must be at least 6 characters.' });
      }

      // Check existing email
      if (db.getUserByEmail(email.toLowerCase())) {
        return socket.emit('auth:error', { message: 'An account with this email already exists.' });
      }

      // Check existing username
      if (db.getUserByUsername(username)) {
        return socket.emit('auth:error', { message: 'That username is already taken. Please choose another.' });
      }

      // Hash password
      const passwordHash = bcrypt.hashSync(password, 10);

      // Create user
      const user = db.createUser(email.toLowerCase(), username, passwordHash);

      // Add starting bonus transaction
      db.addTransaction(user.id, 1000, 'bonus', null, 'Starting Bonus');

      // Generate token
      const token = generateToken(user.id);

      // Get avatar
      const avatar = db.getAvatar(user.id);

      socket.userId = user.id;
      socket.username = user.username;

      socket.emit('auth:success', {
        token,
        user: sanitizeUser({ ...user, games_played: 0, wins: 0, losses: 0, draws: 0 }),
        avatar
      });

      console.log(`[AUTH] New user registered: ${username} (${user.id})`);
    } catch (err) {
      console.error('[AUTH] Register error:', err.message);
      socket.emit('auth:error', { message: 'Registration failed. Please try again.' });
    }
  });

  // ---- Login ----
  socket.on('auth:login', (data) => {
    try {
      const { email, password } = data;

      if (!email || !password) {
        return socket.emit('auth:error', { message: 'Please enter email and password.' });
      }

      const user = db.getUserByEmail(email.toLowerCase());
      if (!user) {
        return socket.emit('auth:error', { message: 'Invalid email or password.' });
      }

      if (!bcrypt.compareSync(password, user.password_hash)) {
        return socket.emit('auth:error', { message: 'Invalid email or password.' });
      }

      const token = generateToken(user.id);
      const avatar = db.getAvatar(user.id);

      socket.userId = user.id;
      socket.username = user.username;

      socket.emit('auth:success', {
        token,
        user: sanitizeUser(user),
        avatar
      });

      console.log(`[AUTH] User logged in: ${user.username}`);
    } catch (err) {
      console.error('[AUTH] Login error:', err.message);
      socket.emit('auth:error', { message: 'Login failed. Please try again.' });
    }
  });

  // ---- Verify token (auto-login) ----
  socket.on('auth:verify', (data) => {
    try {
      const { token } = data;
      if (!token) {
        return socket.emit('auth:error', { message: 'No token provided.' });
      }

      const decoded = verifyToken(token);
      if (!decoded) {
        return socket.emit('auth:error', { message: 'Session expired. Please login again.' });
      }

      const user = db.getUserById(decoded.userId);
      if (!user) {
        return socket.emit('auth:error', { message: 'Account not found.' });
      }

      const avatar = db.getAvatar(user.id);

      socket.userId = user.id;
      socket.username = user.username;

      socket.emit('auth:success', {
        token,
        user: sanitizeUser(user),
        avatar
      });

      console.log(`[AUTH] Auto-login: ${user.username}`);
    } catch (err) {
      console.error('[AUTH] Verify error:', err.message);
      socket.emit('auth:error', { message: 'Authentication failed.' });
    }
  });
}

module.exports = { handleAuth, verifyToken, JWT_SECRET };
