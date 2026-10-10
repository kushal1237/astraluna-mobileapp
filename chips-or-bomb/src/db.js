/* =====================================================
   db.js — SQLite database setup and query functions
   ===================================================== */
const Database = require('better-sqlite3');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const db = new Database(path.join(__dirname, '..', 'chipsbomb.db'));

// Enable WAL mode for better concurrent performance
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// ---- Create tables ----
db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    token_balance INTEGER DEFAULT 1000,
    games_played INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS avatars (
    user_id TEXT PRIMARY KEY REFERENCES users(id),
    gender TEXT DEFAULT 'boy',
    skin_tone TEXT DEFAULT '#F5D0A9',
    hair_style TEXT DEFAULT 'short',
    hair_color TEXT DEFAULT '#4A3728',
    shirt_color TEXT DEFAULT '#4A90D9',
    pants_color TEXT DEFAULT '#2C3E50'
  );

  CREATE TABLE IF NOT EXISTS matches (
    id TEXT PRIMARY KEY,
    player1_id TEXT REFERENCES users(id),
    player2_id TEXT REFERENCES users(id),
    stake INTEGER NOT NULL,
    winner_id TEXT,
    player1_score INTEGER DEFAULT 0,
    player2_score INTEGER DEFAULT 0,
    status TEXT DEFAULT 'active',
    created_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS transactions (
    id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES users(id),
    amount INTEGER NOT NULL,
    type TEXT NOT NULL,
    match_id TEXT,
    description TEXT,
    created_at TEXT DEFAULT (datetime('now'))
  );

  CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id);
  CREATE INDEX IF NOT EXISTS idx_matches_players ON matches(player1_id, player2_id);
`);

// ---- Prepared statements ----
const stmts = {
  createUser: db.prepare(
    `INSERT INTO users (id, email, username, password_hash, token_balance) VALUES (?, ?, ?, ?, 1000)`
  ),
  getUserByEmail: db.prepare(`SELECT * FROM users WHERE email = ?`),
  getUserByUsername: db.prepare(`SELECT * FROM users WHERE username = ?`),
  getUserById: db.prepare(`SELECT * FROM users WHERE id = ?`),
  updateBalance: db.prepare(`UPDATE users SET token_balance = token_balance + ? WHERE id = ?`),
  setBalance: db.prepare(`UPDATE users SET token_balance = ? WHERE id = ?`),
  getBalance: db.prepare(`SELECT token_balance FROM users WHERE id = ?`),

  saveAvatar: db.prepare(
    `INSERT OR REPLACE INTO avatars (user_id, gender, skin_tone, hair_style, hair_color, shirt_color, pants_color)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  ),
  getAvatar: db.prepare(`SELECT * FROM avatars WHERE user_id = ?`),

  createMatch: db.prepare(
    `INSERT INTO matches (id, player1_id, player2_id, stake) VALUES (?, ?, ?, ?)`
  ),
  endMatch: db.prepare(
    `UPDATE matches SET winner_id = ?, player1_score = ?, player2_score = ?, status = ? WHERE id = ?`
  ),

  addTransaction: db.prepare(
    `INSERT INTO transactions (id, user_id, amount, type, match_id, description) VALUES (?, ?, ?, ?, ?, ?)`
  ),
  getTransactions: db.prepare(
    `SELECT * FROM transactions WHERE user_id = ? ORDER BY created_at DESC LIMIT ?`
  ),

  updateStatsWin: db.prepare(
    `UPDATE users SET games_played = games_played + 1, wins = wins + 1 WHERE id = ?`
  ),
  updateStatsLoss: db.prepare(
    `UPDATE users SET games_played = games_played + 1, losses = losses + 1 WHERE id = ?`
  ),
  updateStatsDraw: db.prepare(
    `UPDATE users SET games_played = games_played + 1, draws = draws + 1 WHERE id = ?`
  ),
};

// ---- Export functions ----
function generatePlayerId() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = 'CHB-';
  for (let i = 0; i < 7; i++) code += chars[Math.floor(Math.random() * chars.length)];
  return code;
}

module.exports = {
  createUser(email, username, passwordHash) {
    const id = generatePlayerId();
    stmts.createUser.run(id, email, username, passwordHash);
    stmts.saveAvatar.run(id, 'boy', '#F5D0A9', 'short', '#4A3728', '#4A90D9', '#2C3E50');
    return { id, email, username, token_balance: 1000 };
  },

  getUserByEmail(email) {
    return stmts.getUserByEmail.get(email) || null;
  },

  getUserByUsername(username) {
    return stmts.getUserByUsername.get(username) || null;
  },

  getUserById(id) {
    return stmts.getUserById.get(id) || null;
  },

  getBalance(userId) {
    const row = stmts.getBalance.get(userId);
    return row ? row.token_balance : 0;
  },

  updateTokenBalance(userId, amount) {
    stmts.updateBalance.run(amount, userId);
    return this.getBalance(userId);
  },

  saveAvatar(userId, cfg) {
    stmts.saveAvatar.run(
      userId,
      cfg.gender || 'boy',
      cfg.skinTone || '#F5D0A9',
      cfg.hairStyle || 'short',
      cfg.hairColor || '#4A3728',
      cfg.shirtColor || '#4A90D9',
      cfg.pantsColor || '#2C3E50'
    );
  },

  getAvatar(userId) {
    const row = stmts.getAvatar.get(userId);
    if (!row) return null;
    return {
      gender: row.gender,
      skinTone: row.skin_tone,
      hairStyle: row.hair_style,
      hairColor: row.hair_color,
      shirtColor: row.shirt_color,
      pantsColor: row.pants_color
    };
  },

  createMatch(matchId, p1Id, p2Id, stake) {
    stmts.createMatch.run(matchId, p1Id, p2Id, stake);
  },

  endMatch(matchId, winnerId, p1Score, p2Score, status) {
    stmts.endMatch.run(winnerId, p1Score, p2Score, status, matchId);
  },

  addTransaction(userId, amount, type, matchId, description) {
    stmts.addTransaction.run(uuidv4(), userId, amount, type, matchId, description);
  },

  getTransactions(userId, limit = 20) {
    return stmts.getTransactions.all(userId, limit);
  },

  updateStats(userId, result) {
    if (result === 'win') stmts.updateStatsWin.run(userId);
    else if (result === 'loss') stmts.updateStatsLoss.run(userId);
    else if (result === 'draw') stmts.updateStatsDraw.run(userId);
  },

  getProfile(userId) {
    const user = stmts.getUserById.get(userId);
    if (!user) return null;
    const avatar = this.getAvatar(userId);
    const transactions = this.getTransactions(userId, 10);
    return {
      id: user.id,
      username: user.username,
      email: user.email,
      token_balance: user.token_balance,
      games_played: user.games_played,
      wins: user.wins,
      losses: user.losses,
      draws: user.draws,
      created_at: user.created_at,
      avatar,
      transactions
    };
  }
};
