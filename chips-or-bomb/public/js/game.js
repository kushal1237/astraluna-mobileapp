/* =====================================================
   Game.js — Gameplay, Living Room rendering, 3x3 Card Grid,
   simultaneous card selections, reveals, and animations.
   ===================================================== */
const GameScreen = {
  matchState: null,
  myCardIndex: null,
  opponentReady: false,

  init() {
    this.bindGridEvents();
  },

  /* ---- Set up new match view ---- */
  startMatch(data) {
    this.matchState = {
      matchId: data.matchId,
      round: data.round || 1,
      stake: data.stake,
      myScore: 0,
      opponentScore: 0,
      opponent: data.opponent
    };

    this.myCardIndex = null;
    this.opponentReady = false;

    // Update Player Names & Scores
    const myNameEl = document.getElementById('match-my-name');
    const oppNameEl = document.getElementById('match-opp-name');
    const myScoreEl = document.getElementById('match-my-score');
    const oppScoreEl = document.getElementById('match-opp-score');
    const stakeEl = document.getElementById('match-stake-display');

    if (myNameEl) myNameEl.textContent = App.user ? App.user.username : 'You';
    if (oppNameEl) oppNameEl.textContent = data.opponent ? data.opponent.username : 'Opponent';
    if (myScoreEl) myScoreEl.textContent = '0';
    if (oppScoreEl) oppScoreEl.textContent = '0';
    if (stakeEl) stakeEl.textContent = `Stake: ${data.stake} 🪙`;

    // Render Avatars in Living Room
    this.renderLivingRoomAvatars(data.opponent ? data.opponent.avatar : null);

    // Reset 3x3 Grid
    this.resetGrid();
    this.updateStatus('Choose a card!');

    // Show match screen
    App.showScreen('screen-match');

    // Countdown 3-2-1-GO!
    const container = document.getElementById('match-living-room');
    if (container && typeof Animations !== 'undefined') {
      Animations.countdown(container);
    }
  },

  /* ---- Render Avatars sitting on couches in Living Room ---- */
  renderLivingRoomAvatars(oppAvatar) {
    const myCanvas = document.getElementById('p1-couch-avatar');
    const oppCanvas = document.getElementById('p2-couch-avatar');

    if (myCanvas && typeof AvatarScreen !== 'undefined') {
      AvatarScreen.renderMini(myCanvas, App.avatar, 90);
    }

    if (oppCanvas && typeof AvatarScreen !== 'undefined') {
      AvatarScreen.renderMini(oppCanvas, oppAvatar, 90);
    }
  },

  /* ---- Reset 3x3 Grid ---- */
  resetGrid() {
    const gridEl = document.getElementById('chips-grid');
    if (!gridEl) return;

    gridEl.innerHTML = '';
    for (let i = 0; i < 9; i++) {
      const card = document.createElement('div');
      card.className = 'chip-card';
      card.dataset.index = i;
      card.innerHTML = `<span>?</span>`;
      gridEl.appendChild(card);
    }
  },

  /* ---- Bind Grid Click Events ---- */
  bindGridEvents() {
    const gridEl = document.getElementById('chips-grid');
    if (!gridEl) return;

    gridEl.addEventListener('click', (e) => {
      const card = e.target.closest('.chip-card');
      if (!card || card.classList.contains('disabled') || card.classList.contains('revealed-chip') || card.classList.contains('revealed-bomb')) return;

      if (this.myCardIndex !== null) return; // Already picked this round

      const idx = parseInt(card.dataset.index, 10);
      this.myCardIndex = idx;

      // Visual pick selection
      card.classList.add('selected-by-me');
      if (typeof AudioManager !== 'undefined') AudioManager.playCardFlip();

      // Send selection to server
      GameSocket.emit('match:selectCard', { cardIndex: idx });

      if (this.opponentReady) {
        this.updateStatus('Both selected! Revealing...');
      } else {
        this.updateStatus('Waiting for opponent selection...');
      }
    });
  },

  /* ---- Opponent picked a card event ---- */
  onOpponentReady() {
    this.opponentReady = true;
    if (this.myCardIndex !== null) {
      this.updateStatus('Both selected! Revealing...');
    } else {
      this.updateStatus('Opponent selected! Make your choice!');
    }
  },

  /* ---- Server Reveals both cards ---- */
  async onReveal(data) {
    const container = document.getElementById('match-living-room');
    if (container && typeof Animations !== 'undefined') {
      await Animations.showOverlayText(container, 'REVEAL!', 800);
    }

    const gridEl = document.getElementById('chips-grid');
    if (!gridEl) return;

    const cards = gridEl.querySelectorAll('.chip-card');

    // Reveal My Card
    if (data.yourCard && cards[data.yourCard.index]) {
      const myCardEl = cards[data.yourCard.index];
      const isBomb = data.yourCard.value === 'bomb';

      myCardEl.classList.remove('selected-by-me');
      if (isBomb) {
        myCardEl.classList.add('revealed-bomb', 'disabled');
        myCardEl.innerHTML = `<span>💣</span>`;
        if (typeof AudioManager !== 'undefined') AudioManager.playExplosion();
        if (typeof Animations !== 'undefined') {
          Animations.shake(myCardEl, 10, 600);
          Animations.createExplosion(container, myCardEl.getBoundingClientRect());
        }
        this.updateStatus('💣 BOOM! You hit the bomb!');
      } else {
        myCardEl.classList.add('revealed-chip', 'disabled');
        myCardEl.innerHTML = `<span>+${data.yourCard.value}</span>`;
        if (typeof AudioManager !== 'undefined') AudioManager.playCoinGain();
        if (typeof Animations !== 'undefined') {
          Animations.createChipParticles(container, myCardEl.getBoundingClientRect());
        }
      }
    }

    // Update Scores
    if (data.scores) {
      const myScoreEl = document.getElementById('match-my-score');
      const oppScoreEl = document.getElementById('match-opp-score');
      if (myScoreEl && typeof Animations !== 'undefined') {
        Animations.countTo(myScoreEl, parseInt(myScoreEl.textContent, 10) || 0, data.scores.you, 600);
      }
      if (oppScoreEl && typeof Animations !== 'undefined') {
        Animations.countTo(oppScoreEl, parseInt(oppScoreEl.textContent, 10) || 0, data.scores.opponent, 600);
      }
    }
  },

  /* ---- Start Next Round ---- */
  nextRound(round) {
    this.myCardIndex = null;
    this.opponentReady = false;
    this.updateStatus(`Round ${round} — Pick a card!`);
  },

  /* ---- Update Status Banner ---- */
  updateStatus(msg) {
    const statusEl = document.getElementById('match-status-msg');
    if (statusEl) statusEl.textContent = msg;
  }
};
