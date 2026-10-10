/* =====================================================
   Socket.js — Socket.IO client connection wrapper
   ===================================================== */
const GameSocket = {
  socket: null,
  connected: false,

  init() {
    if (typeof io === 'undefined') {
      console.error('Socket.IO client library not loaded.');
      return;
    }

    this.socket = io();

    this.socket.on('connect', () => {
      this.connected = true;
      console.log('[SOCKET] Connected to server');
      
      // Auto-reconnect auth token if available
      const token = localStorage.getItem('chips_bomb_token');
      if (token) {
        this.emit('auth:verify', { token });
      }
    });

    this.socket.on('disconnect', () => {
      this.connected = false;
      console.warn('[SOCKET] Disconnected from server');
    });

    this.socket.on('connect_error', (err) => {
      console.error('[SOCKET] Connection error:', err.message);
    });
  },

  emit(event, data) {
    if (this.socket && this.connected) {
      this.socket.emit(event, data);
    } else if (this.socket) {
      // Retry once connected
      this.socket.once('connect', () => this.socket.emit(event, data));
    }
  },

  on(event, callback) {
    if (this.socket) {
      this.socket.on(event, callback);
    }
  }
};
