/* =====================================================
   server.js — Express + Socket.IO entry point
   ===================================================== */
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');
const cors = require('cors');

const { handleAuth } = require('./src/auth');
const GameManager = require('./src/gameManager');
const db = require('./src/db');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
  pingInterval: 10000,
  pingTimeout: 5000
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Game manager
const gameManager = new GameManager(io);

// Track online users
let onlineCount = 0;

// ---- Socket.IO connection ----
io.on('connection', (socket) => {
  onlineCount++;
  console.log(`[SOCKET] Connected: ${socket.id} (${onlineCount} online)`);

  // ---- Auth events ----
  handleAuth(socket);

  // After auth success, attempt reconnection to active match
  socket.on('auth:success:ack', () => {
    if (socket.userId) {
      gameManager.handleReconnect(socket, socket.userId);
    }
  });

  // ---- Avatar events ----
  socket.on('avatar:save', (config) => {
    gameManager.saveAvatar(socket, config);
  });

  socket.on('avatar:get', () => {
    gameManager.getAvatar(socket);
  });

  // ---- Matchmaking events ----
  socket.on('match:quickPlay', () => {
    if (!socket.userId) return socket.emit('auth:error', { message: 'Please login first.' });
    gameManager.quickPlay(socket, socket.userId, socket.username);
  });

  socket.on('match:createPrivateRoom', () => {
    if (!socket.userId) return socket.emit('auth:error', { message: 'Please login first.' });
    gameManager.createPrivateRoom(socket, socket.userId, socket.username);
  });

  socket.on('match:joinPrivateRoom', (data) => {
    if (!socket.userId) return socket.emit('auth:error', { message: 'Please login first.' });
    if (!data || !data.roomCode) return socket.emit('match:error', { message: 'Room code required.' });
    gameManager.joinPrivateRoom(socket, socket.userId, socket.username, data.roomCode);
  });

  socket.on('match:cancelSearch', () => {
    gameManager.cancelSearch(socket);
  });

  // ---- Stake events ----
  socket.on('match:selectStake', (data) => {
    if (!socket.userId) return;
    gameManager.selectStake(socket, data.stake);
  });

  // ---- Game events ----
  socket.on('match:selectCard', (data) => {
    if (!socket.userId) return;
    gameManager.selectCard(socket, data.cardIndex);
  });

  // ---- Post-match events ----
  socket.on('match:playAgain', () => {
    gameManager.playAgain(socket);
  });

  socket.on('match:returnToLobby', () => {
    // Just acknowledge — client handles screen change
    if (socket.userId) {
      const user = db.getUserById(socket.userId);
      if (user) {
        socket.emit('lobby:update', { token_balance: user.token_balance });
      }
    }
  });

  // ---- Ad reward ----
  socket.on('ad:start', () => {
    if (!socket.userId) return;
    gameManager.startAd(socket);
  });

  socket.on('ad:claimReward', () => {
    if (!socket.userId) return;
    gameManager.claimAdReward(socket);
  });

  // ---- Profile ----
  socket.on('profile:get', () => {
    gameManager.getProfile(socket);
  });

  // ---- Disconnect ----
  socket.on('disconnect', () => {
    onlineCount--;
    gameManager.handleDisconnect(socket);
    console.log(`[SOCKET] Disconnected: ${socket.id} (${onlineCount} online)`);
  });
});

// ---- Health endpoint ----
app.get('/health', (req, res) => {
  res.json({ status: 'ok', online: onlineCount });
});

// ---- SPA fallback ----
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// ---- Start server ----
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`\n🎮 CHIPS OR BOMB server running on http://localhost:${PORT}\n`);
});
