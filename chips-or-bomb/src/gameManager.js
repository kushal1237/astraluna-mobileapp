/* =====================================================
   gameManager.js — Server-side game state machine
   Handles matchmaking, stakes, grid generation,
   simultaneous selection, reveal, and match resolution.
   ===================================================== */
const { v4: uuidv4 } = require('uuid');
const db = require('./db');

class GameManager {
  constructor(io) {
    this.io = io;
    this.waitingQueue = [];               // [{ socketId, userId, username }]
    this.privateRooms = new Map();        // roomCode → { socketId, userId, username }
    this.adSessions = new Map();          // socketId → startTime
    this.activeMatches = new Map();       // matchId → MatchState
    this.playerToMatch = new Map();       // socketId → matchId
    this.disconnectTimers = new Map();    // socketId → timeout
  }

  /* ---------- Grid generation (SERVER-ONLY, never sent raw to client) ---------- */
  generateGrid() {
    const chipValues = [50, 100, 150, 200, 250, 300];
    const cards = [];

    // 6 chip cards
    for (let i = 0; i < 6; i++) {
      cards.push({
        value: chipValues[Math.floor(Math.random() * chipValues.length)],
        revealed: false
      });
    }
    // 3 bomb cards
    for (let i = 0; i < 3; i++) {
      cards.push({ value: 'bomb', revealed: false });
    }

    // Fisher-Yates shuffle
    for (let i = cards.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [cards[i], cards[j]] = [cards[j], cards[i]];
    }

    return cards;
  }

  /* ---------- Matchmaking ---------- */
  quickPlay(socket, userId, username) {
    // Don't allow double-queue
    if (this.waitingQueue.find(p => p.userId === userId)) return;
    // Don't allow if already in a match
    if (this.playerToMatch.has(socket.id)) return;

    this.waitingQueue.push({ socketId: socket.id, userId, username });
    socket.emit('match:searching');
    console.log(`[MATCH] ${username} joined queue (${this.waitingQueue.length} waiting)`);

    if (this.waitingQueue.length >= 2) {
      const p1 = this.waitingQueue.shift();
      const p2 = this.waitingQueue.shift();
      this.createMatch(p1, p2);
    }
  }

  cancelSearch(socket) {
    this.waitingQueue = this.waitingQueue.filter(p => p.socketId !== socket.id);
    for (const [code, room] of this.privateRooms.entries()) {
      if (room.socketId === socket.id) this.privateRooms.delete(code);
    }
    socket.emit('match:searchCancelled');
  }

  createPrivateRoom(socket, userId, username) {
    if (this.playerToMatch.has(socket.id)) return;
    const roomCode = Math.floor(100000 + Math.random() * 900000).toString();
    this.privateRooms.set(roomCode, { socketId: socket.id, userId, username });
    socket.emit('match:privateRoomCreated', { roomCode });
    console.log(`[MATCH] Private room ${roomCode} created by ${username}`);
  }

  joinPrivateRoom(socket, userId, username, roomCode) {
    if (this.playerToMatch.has(socket.id)) return;
    const host = this.privateRooms.get(roomCode);
    if (!host) {
      return socket.emit('match:error', { message: 'Private room code not found or expired.' });
    }
    if (host.userId === userId) {
      return socket.emit('match:error', { message: 'You cannot join your own room!' });
    }

    this.privateRooms.delete(roomCode);
    const guest = { socketId: socket.id, userId, username };
    this.createMatch(host, guest);
  }

  createMatch(p1Info, p2Info) {
    const matchId = uuidv4();
    const p1Avatar = db.getAvatar(p1Info.userId);
    const p2Avatar = db.getAvatar(p2Info.userId);
    const p1Balance = db.getBalance(p1Info.userId);
    const p2Balance = db.getBalance(p2Info.userId);

    const match = {
      id: matchId,
      players: {
        p1: { ...p1Info, avatar: p1Avatar, balance: p1Balance },
        p2: { ...p2Info, avatar: p2Avatar, balance: p2Balance }
      },
      stake: null,
      stakeChoices: { p1: null, p2: null },
      grids: { p1: null, p2: null },
      selections: { p1: null, p2: null },
      scores: { p1: 0, p2: 0 },
      round: 0,
      maxRounds: 6,
      status: 'stake_selection',
      bombHit: { p1: false, p2: false }
    };

    this.activeMatches.set(matchId, match);
    this.playerToMatch.set(p1Info.socketId, matchId);
    this.playerToMatch.set(p2Info.socketId, matchId);

    const s1 = this.io.sockets.sockets.get(p1Info.socketId);
    const s2 = this.io.sockets.sockets.get(p2Info.socketId);

    if (s1) {
      s1.emit('match:found', {
        matchId,
        opponent: { username: p2Info.username, avatar: p2Avatar }
      });
    }
    if (s2) {
      s2.emit('match:found', {
        matchId,
        opponent: { username: p1Info.username, avatar: p1Avatar }
      });
    }

    // After a short delay, prompt stake selection
    setTimeout(() => {
      if (s1) s1.emit('match:stakeSelect', { balance: p1Balance });
      if (s2) s2.emit('match:stakeSelect', { balance: p2Balance });
    }, 2000);

    console.log(`[MATCH] Created: ${p1Info.username} vs ${p2Info.username} (${matchId})`);
  }

  /* ---------- Stake selection ---------- */
  selectStake(socket, stake) {
    const matchId = this.playerToMatch.get(socket.id);
    if (!matchId) return;
    const match = this.activeMatches.get(matchId);
    if (!match || match.status !== 'stake_selection') return;

    const validStakes = [100, 250, 500];
    if (!validStakes.includes(stake)) {
      return socket.emit('match:error', { message: 'Invalid stake amount.' });
    }

    const side = this.getPlayerSide(socket.id, match);
    if (!side) return;

    // Validate balance
    const balance = db.getBalance(match.players[side].userId);
    if (balance < stake) {
      return socket.emit('match:error', { message: 'Not enough tokens for this stake.' });
    }

    match.stakeChoices[side] = stake;

    const otherSide = side === 'p1' ? 'p2' : 'p1';
    const otherSocket = this.io.sockets.sockets.get(match.players[otherSide].socketId);

    // Check if both have chosen
    if (match.stakeChoices.p1 !== null && match.stakeChoices.p2 !== null) {
      if (match.stakeChoices.p1 === match.stakeChoices.p2) {
        // Both agree — lock stake and start
        match.stake = stake;
        match.status = 'playing';
        match.round = 1;
        match.grids.p1 = this.generateGrid();
        match.grids.p2 = this.generateGrid();

        // Record match in DB
        db.createMatch(matchId, match.players.p1.userId, match.players.p2.userId, stake);

        const s1 = this.io.sockets.sockets.get(match.players.p1.socketId);
        const s2 = this.io.sockets.sockets.get(match.players.p2.socketId);

        const startData = {
          matchId,
          round: 1,
          totalCards: 9,
          bombCount: 3,
          stake
        };

        if (s1) {
          s1.emit('match:stakeConfirmed', { stake });
          setTimeout(() => s1.emit('match:start', {
            ...startData,
            opponent: { username: match.players.p2.username, avatar: match.players.p2.avatar }
          }), 1500);
        }
        if (s2) {
          s2.emit('match:stakeConfirmed', { stake });
          setTimeout(() => s2.emit('match:start', {
            ...startData,
            opponent: { username: match.players.p1.username, avatar: match.players.p1.avatar }
          }), 1500);
        }

        console.log(`[MATCH] Stake agreed: ${stake} tokens (${matchId})`);
      } else {
        // Mismatch — notify both, reset
        const s1 = this.io.sockets.sockets.get(match.players.p1.socketId);
        const s2 = this.io.sockets.sockets.get(match.players.p2.socketId);

        if (s1) s1.emit('match:stakeMismatch', { yourChoice: match.stakeChoices.p1, opponentChoice: match.stakeChoices.p2 });
        if (s2) s2.emit('match:stakeMismatch', { yourChoice: match.stakeChoices.p2, opponentChoice: match.stakeChoices.p1 });

        match.stakeChoices = { p1: null, p2: null };
      }
    } else {
      // Waiting for other player
      socket.emit('match:stakeWaiting', { yourChoice: stake });
      if (otherSocket) {
        otherSocket.emit('match:opponentStakeReady');
      }
    }
  }

  /* ---------- Card selection ---------- */
  selectCard(socket, cardIndex) {
    const matchId = this.playerToMatch.get(socket.id);
    if (!matchId) return;
    const match = this.activeMatches.get(matchId);
    if (!match || match.status !== 'playing') return;

    const side = this.getPlayerSide(socket.id, match);
    if (!side) return;

    // Validate index
    if (cardIndex < 0 || cardIndex > 8) return;

    // Validate card not already revealed
    if (match.grids[side][cardIndex].revealed) {
      return socket.emit('match:error', { message: 'That card is already revealed.' });
    }

    // Validate not already selected this round
    if (match.selections[side] !== null) return;

    match.selections[side] = cardIndex;

    // Notify other player that this player is ready
    const otherSide = side === 'p1' ? 'p2' : 'p1';
    const otherSocket = this.io.sockets.sockets.get(match.players[otherSide].socketId);
    if (otherSocket) {
      otherSocket.emit('match:opponentReady');
    }

    console.log(`[MATCH] ${match.players[side].username} selected card ${cardIndex} (round ${match.round})`);

    // Check if both have selected
    if (match.selections.p1 !== null && match.selections.p2 !== null) {
      this.revealCards(matchId);
    }
  }

  /* ---------- Reveal both cards ---------- */
  revealCards(matchId) {
    const match = this.activeMatches.get(matchId);
    if (!match) return;

    match.status = 'revealing';

    const p1Card = match.grids.p1[match.selections.p1];
    const p2Card = match.grids.p2[match.selections.p2];

    // Mark as revealed
    p1Card.revealed = true;
    p2Card.revealed = true;

    // Check for bombs
    const p1Bomb = p1Card.value === 'bomb';
    const p2Bomb = p2Card.value === 'bomb';

    // Add chip values to scores (bombs don't add)
    if (!p1Bomb) match.scores.p1 += p1Card.value;
    if (!p2Bomb) match.scores.p2 += p2Card.value;

    if (p1Bomb) match.bombHit.p1 = true;
    if (p2Bomb) match.bombHit.p2 = true;

    const s1 = this.io.sockets.sockets.get(match.players.p1.socketId);
    const s2 = this.io.sockets.sockets.get(match.players.p2.socketId);

    // Send reveal data to both players
    if (s1) {
      s1.emit('match:reveal', {
        yourCard: { index: match.selections.p1, value: p1Card.value },
        opponentCard: { index: match.selections.p2, value: p2Card.value },
        scores: { you: match.scores.p1, opponent: match.scores.p2 },
        round: match.round
      });
    }
    if (s2) {
      s2.emit('match:reveal', {
        yourCard: { index: match.selections.p2, value: p2Card.value },
        opponentCard: { index: match.selections.p1, value: p1Card.value },
        scores: { you: match.scores.p2, opponent: match.scores.p1 },
        round: match.round
      });
    }

    // Determine what happens next
    setTimeout(() => {
      if (p1Bomb && p2Bomb) {
        // Both hit bomb — draw
        this.endMatch(matchId, { isDraw: true });
      } else if (p1Bomb) {
        // P1 hit bomb — P2 wins
        this.endMatch(matchId, {
          winnerId: match.players.p2.userId,
          loserId: match.players.p1.userId,
          isDraw: false
        });
      } else if (p2Bomb) {
        // P2 hit bomb — P1 wins
        this.endMatch(matchId, {
          winnerId: match.players.p1.userId,
          loserId: match.players.p2.userId,
          isDraw: false
        });
      } else if (match.round >= match.maxRounds) {
        // All safe cards picked — compare scores
        if (match.scores.p1 > match.scores.p2) {
          this.endMatch(matchId, {
            winnerId: match.players.p1.userId,
            loserId: match.players.p2.userId,
            isDraw: false
          });
        } else if (match.scores.p2 > match.scores.p1) {
          this.endMatch(matchId, {
            winnerId: match.players.p2.userId,
            loserId: match.players.p1.userId,
            isDraw: false
          });
        } else {
          this.endMatch(matchId, { isDraw: true });
        }
      } else {
        // Next round
        match.round++;
        match.selections = { p1: null, p2: null };
        match.status = 'playing';

        if (s1) s1.emit('match:nextRound', { round: match.round });
        if (s2) s2.emit('match:nextRound', { round: match.round });
      }
    }, 2500);
  }

  /* ---------- End match ---------- */
  endMatch(matchId, result) {
    const match = this.activeMatches.get(matchId);
    if (!match) return;

    match.status = 'ended';
    const stake = match.stake;

    const s1 = this.io.sockets.sockets.get(match.players.p1.socketId);
    const s2 = this.io.sockets.sockets.get(match.players.p2.socketId);

    if (result.isDraw) {
      // Draw — return stakes
      db.updateStats(match.players.p1.userId, 'draw');
      db.updateStats(match.players.p2.userId, 'draw');
      db.endMatch(matchId, null, match.scores.p1, match.scores.p2, 'draw');

      const p1Bal = db.getBalance(match.players.p1.userId);
      const p2Bal = db.getBalance(match.players.p2.userId);

      if (s1) s1.emit('match:end', {
        result: 'draw', tokenChange: 0, newBalance: p1Bal,
        finalScores: { you: match.scores.p1, opponent: match.scores.p2 },
        opponentName: match.players.p2.username
      });
      if (s2) s2.emit('match:end', {
        result: 'draw', tokenChange: 0, newBalance: p2Bal,
        finalScores: { you: match.scores.p2, opponent: match.scores.p1 },
        opponentName: match.players.p1.username
      });
      console.log(`[MATCH] Draw (${matchId})`);
    } else {
      const winnerSide = result.winnerId === match.players.p1.userId ? 'p1' : 'p2';
      const loserSide = winnerSide === 'p1' ? 'p2' : 'p1';

      // Update balances
      db.updateTokenBalance(result.winnerId, stake);
      db.updateTokenBalance(result.loserId, -stake);

      // Update stats
      db.updateStats(result.winnerId, 'win');
      db.updateStats(result.loserId, 'loss');

      // Record transactions
      db.addTransaction(result.winnerId, stake, 'match_win', matchId, `Match Win (+${stake})`);
      db.addTransaction(result.loserId, -stake, 'match_loss', matchId, `Match Loss (-${stake})`);

      // Record match
      db.endMatch(matchId, result.winnerId, match.scores.p1, match.scores.p2, 'completed');

      const winnerBal = db.getBalance(result.winnerId);
      const loserBal = db.getBalance(result.loserId);

      const winnerSocket = this.io.sockets.sockets.get(match.players[winnerSide].socketId);
      const loserSocket = this.io.sockets.sockets.get(match.players[loserSide].socketId);

      if (winnerSocket) winnerSocket.emit('match:end', {
        result: 'win', tokenChange: stake, newBalance: winnerBal,
        finalScores: { you: match.scores[winnerSide], opponent: match.scores[loserSide] },
        opponentName: match.players[loserSide].username
      });
      if (loserSocket) loserSocket.emit('match:end', {
        result: 'lose', tokenChange: -stake, newBalance: loserBal,
        finalScores: { you: match.scores[loserSide], opponent: match.scores[winnerSide] },
        opponentName: match.players[winnerSide].username
      });

      console.log(`[MATCH] ${match.players[winnerSide].username} wins ${stake} tokens (${matchId})`);
    }

    // Cleanup
    this.playerToMatch.delete(match.players.p1.socketId);
    this.playerToMatch.delete(match.players.p2.socketId);
    this.activeMatches.delete(matchId);
  }

  /* ---------- Ad reward ---------- */
  startAd(socket) {
    if (!socket.userId) return;
    this.adSessions.set(socket.id, Date.now());
    socket.emit('ad:started', { duration: 5 });
  }

  claimAdReward(socket) {
    if (!socket.userId) return;
    const startTime = this.adSessions.get(socket.id);
    if (!startTime) {
      return socket.emit('ad:error', { message: 'No ad session found. Please watch the advertisement.' });
    }

    const elapsedSeconds = (Date.now() - startTime) / 1000;
    this.adSessions.delete(socket.id);

    if (elapsedSeconds < 4.5) {
      return socket.emit('ad:error', { message: 'Advertisement was closed early. Reward forfeited.' });
    }

    const balance = db.getBalance(socket.userId);
    if (balance >= 100) {
      return socket.emit('match:error', { message: 'You have enough tokens to play!' });
    }

    db.updateTokenBalance(socket.userId, 50);
    db.addTransaction(socket.userId, 50, 'ad_reward', null, 'Rewarded Ad (+50)');
    const newBalance = db.getBalance(socket.userId);

    socket.emit('ad:rewardClaimed', { amount: 50, newBalance });
    console.log(`[AD] ${socket.username} claimed 50 tokens (balance: ${newBalance})`);
  }

  /* ---------- Avatar ---------- */
  saveAvatar(socket, config) {
    if (!socket.userId) return;
    db.saveAvatar(socket.userId, config);
    socket.emit('avatar:saved');
  }

  getAvatar(socket) {
    if (!socket.userId) return;
    const avatar = db.getAvatar(socket.userId);
    socket.emit('avatar:data', avatar);
  }

  /* ---------- Profile ---------- */
  getProfile(socket) {
    if (!socket.userId) return;
    const profile = db.getProfile(socket.userId);
    socket.emit('profile:data', profile);
  }

  /* ---------- Play again ---------- */
  playAgain(socket) {
    if (!socket.userId) return;
    // Put back in queue
    this.quickPlay(socket, socket.userId, socket.username);
  }

  /* ---------- Disconnect handling ---------- */
  handleDisconnect(socket) {
    // Remove from queue
    this.waitingQueue = this.waitingQueue.filter(p => p.socketId !== socket.id);

    // Check if in active match
    const matchId = this.playerToMatch.get(socket.id);
    if (!matchId) return;

    const match = this.activeMatches.get(matchId);
    if (!match || match.status === 'ended') return;

    const side = this.getPlayerSide(socket.id, match);
    if (!side) return;

    const otherSide = side === 'p1' ? 'p2' : 'p1';
    const otherSocket = this.io.sockets.sockets.get(match.players[otherSide].socketId);

    if (otherSocket) {
      otherSocket.emit('match:opponentDisconnected');
    }

    // Give 15 seconds to reconnect
    this.disconnectTimers.set(socket.id, setTimeout(() => {
      // Forfeit — other player wins
      if (match.status !== 'ended') {
        this.endMatch(matchId, {
          winnerId: match.players[otherSide].userId,
          loserId: match.players[side].userId,
          isDraw: false
        });
        if (otherSocket) {
          otherSocket.emit('match:opponentLeft');
        }
      }
      this.disconnectTimers.delete(socket.id);
    }, 15000));

    console.log(`[MATCH] ${match.players[side].username} disconnected, 15s to reconnect`);
  }

  /* ---------- Reconnect ---------- */
  handleReconnect(socket, userId) {
    // Find match by checking all active matches
    for (const [matchId, match] of this.activeMatches) {
      let side = null;
      if (match.players.p1.userId === userId) side = 'p1';
      else if (match.players.p2.userId === userId) side = 'p2';

      if (side && match.status !== 'ended') {
        // Clear disconnect timer
        const oldSocketId = match.players[side].socketId;
        if (this.disconnectTimers.has(oldSocketId)) {
          clearTimeout(this.disconnectTimers.get(oldSocketId));
          this.disconnectTimers.delete(oldSocketId);
        }

        // Update socket ID
        this.playerToMatch.delete(oldSocketId);
        match.players[side].socketId = socket.id;
        this.playerToMatch.set(socket.id, matchId);

        // Notify opponent
        const otherSide = side === 'p1' ? 'p2' : 'p1';
        const otherSocket = this.io.sockets.sockets.get(match.players[otherSide].socketId);
        if (otherSocket) otherSocket.emit('match:opponentReconnected');

        // Send current game state
        const revealedCards = [];
        match.grids[side].forEach((card, i) => {
          if (card.revealed) {
            revealedCards.push({ index: i, value: card.value });
          }
        });

        socket.emit('match:reconnected', {
          matchId,
          round: match.round,
          scores: {
            you: match.scores[side],
            opponent: match.scores[otherSide]
          },
          revealedCards,
          stake: match.stake,
          opponent: {
            username: match.players[otherSide].username,
            avatar: match.players[otherSide].avatar
          },
          status: match.status
        });

        console.log(`[MATCH] ${match.players[side].username} reconnected`);
        return;
      }
    }
  }

  /* ---------- Helpers ---------- */
  getPlayerSide(socketId, match) {
    if (match.players.p1.socketId === socketId) return 'p1';
    if (match.players.p2.socketId === socketId) return 'p2';
    return null;
  }
}

module.exports = GameManager;
