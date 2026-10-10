/* =====================================================
   App.js — Main application controller
   ===================================================== */
const App = {
  user: null,
  avatar: null,
  selectedStake: 100,

  init() {
    GameSocket.init();
    this.bindEvents();
    this.bindSocketListeners();

    // Init Avatar Screen
    if (typeof AvatarScreen !== 'undefined') AvatarScreen.init();
    if (typeof GameScreen !== 'undefined') GameScreen.init();

    // Check saved token auto-login
    const savedToken = localStorage.getItem('chips_bomb_token');
    if (!savedToken) {
      this.showScreen('screen-auth');
    }
  },

  /* ---- Show Target Screen ---- */
  showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    const target = document.getElementById(screenId);
    if (target) target.classList.add('active');
  },

  /* ---- Show Toast Message ---- */
  showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `<span>${type === 'error' ? '⚠️' : type === 'success' ? '🎉' : 'ℹ️'}</span> ${message}`;
    container.appendChild(toast);

    setTimeout(() => toast.remove(), 3500);
  },

  /* ---- Update Token Balance UI ---- */
  updateTokenDisplay(balance) {
    if (this.user) this.user.token_balance = balance;
    document.querySelectorAll('.user-token-balance').forEach(el => {
      if (typeof Animations !== 'undefined') {
        const from = parseInt(el.textContent.replace(/,/g, ''), 10) || 0;
        Animations.countTo(el, from, balance, 800);
      } else {
        el.textContent = balance.toLocaleString();
      }
    });

    // Check if zero tokens for rewarded ad popup
    if (balance === 0) {
      setTimeout(() => this.showZeroTokensModal(), 1000);
    }
  },

  /* ---- Show Zero Tokens Modal ---- */
  showZeroTokensModal() {
    const modal = document.getElementById('modal-zero-tokens');
    if (modal) modal.classList.add('active');
  },

  /* ---- Bind DOM UI Button Events ---- */
  bindEvents() {
    // Auth Tabs
    const loginTab = document.getElementById('tab-login');
    const regTab = document.getElementById('tab-register');
    const loginForm = document.getElementById('form-login');
    const regForm = document.getElementById('form-register');

    if (loginTab && regTab) {
      loginTab.addEventListener('click', () => {
        loginTab.classList.add('active');
        regTab.classList.remove('active');
        loginForm.style.display = 'block';
        regForm.style.display = 'none';
      });
      regTab.addEventListener('click', () => {
        regTab.classList.add('active');
        loginTab.classList.remove('active');
        regForm.style.display = 'block';
        loginForm.style.display = 'none';
      });
    }

    // Auth Forms Submit
    if (loginForm) {
      loginForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const email = document.getElementById('login-email').value.trim();
        const password = document.getElementById('login-password').value;
        if (typeof AudioManager !== 'undefined') AudioManager.playClick();
        GameSocket.emit('auth:login', { email, password });
      });
    }

    if (regForm) {
      regForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const email = document.getElementById('reg-email').value.trim();
        const username = document.getElementById('reg-username').value.trim();
        const password = document.getElementById('reg-password').value;
        if (typeof AudioManager !== 'undefined') AudioManager.playClick();
        GameSocket.emit('auth:register', { email, username, password });
      });
    }

    // Lobby Buttons
    const btnPlayOnline = document.getElementById('btn-play-online');
    if (btnPlayOnline) {
      btnPlayOnline.addEventListener('click', () => {
        if (typeof AudioManager !== 'undefined') AudioManager.playClick();
        if (this.user.token_balance < 100) {
          this.showZeroTokensModal();
          return;
        }
        GameSocket.emit('match:quickPlay');
      });
    }

    const btnPlayFriend = document.getElementById('btn-play-friend');
    if (btnPlayFriend) {
      btnPlayFriend.addEventListener('click', () => {
        if (typeof AudioManager !== 'undefined') AudioManager.playClick();
        if (this.user.token_balance < 100) {
          this.showZeroTokensModal();
          return;
        }
        document.getElementById('modal-friend').classList.add('active');
      });
    }

    const btnAvatar = document.getElementById('btn-avatar');
    if (btnAvatar) {
      btnAvatar.addEventListener('click', () => {
        if (typeof AudioManager !== 'undefined') AudioManager.playClick();
        this.showScreen('screen-avatar');
      });
    }

    const btnProfile = document.getElementById('btn-profile');
    if (btnProfile) {
      btnProfile.addEventListener('click', () => {
        if (typeof AudioManager !== 'undefined') AudioManager.playClick();
        GameSocket.emit('profile:get');
      });
    }

    const btnSettings = document.getElementById('btn-settings');
    if (btnSettings) {
      btnSettings.addEventListener('click', () => {
        if (typeof AudioManager !== 'undefined') AudioManager.playClick();
        document.getElementById('modal-settings').classList.add('active');
      });
    }

    // Friend Modal Buttons
    const btnCreateRoom = document.getElementById('btn-create-room');
    if (btnCreateRoom) {
      btnCreateRoom.addEventListener('click', () => {
        GameSocket.emit('match:createPrivateRoom');
      });
    }

    const btnJoinRoom = document.getElementById('btn-join-room');
    if (btnJoinRoom) {
      btnJoinRoom.addEventListener('click', () => {
        const code = document.getElementById('input-room-code').value.trim();
        if (!code) return this.showToast('Please enter a room code.', 'error');
        GameSocket.emit('match:joinPrivateRoom', { roomCode: code });
      });
    }

    const btnCloseFriendModal = document.getElementById('btn-close-friend-modal');
    if (btnCloseFriendModal) {
      btnCloseFriendModal.addEventListener('click', () => {
        document.getElementById('modal-friend').classList.remove('active');
        GameSocket.emit('match:cancelSearch');
      });
    }

    // Stake Selection Buttons
    document.querySelectorAll('.stake-card').forEach(card => {
      card.addEventListener('click', () => {
        document.querySelectorAll('.stake-card').forEach(c => c.classList.remove('selected'));
        card.classList.add('selected');
        this.selectedStake = parseInt(card.dataset.stake, 10);
        if (typeof AudioManager !== 'undefined') AudioManager.playClick();
      });
    });

    const btnConfirmStake = document.getElementById('btn-confirm-stake');
    if (btnConfirmStake) {
      btnConfirmStake.addEventListener('click', () => {
        if (typeof AudioManager !== 'undefined') AudioManager.playClick();
        GameSocket.emit('match:selectStake', { stake: this.selectedStake });
        document.getElementById('stake-status-msg').textContent = 'Waiting for opponent to confirm stake...';
      });
    }

    // Out of Tokens & Rewarded Ad
    const btnWatchAd = document.getElementById('btn-watch-ad');
    if (btnWatchAd) {
      btnWatchAd.addEventListener('click', () => {
        document.getElementById('modal-zero-tokens').classList.remove('active');
        RewardedAdProvider.showRewardedAd(
          document.getElementById('modal-ad'),
          () => {
            // Success handler: claim from server
            GameSocket.emit('ad:claimReward');
          },
          () => {
            // Skipped / Closed early handler
            this.showToast('Ad was closed early. No tokens awarded.', 'error');
          }
        );
      });
    }

    // Settings Modal
    const btnLogout = document.getElementById('btn-logout');
    if (btnLogout) {
      btnLogout.addEventListener('click', () => {
        localStorage.removeItem('chips_bomb_token');
        location.reload();
      });
    }

    const btnCloseSettings = document.getElementById('btn-close-settings');
    if (btnCloseSettings) {
      btnCloseSettings.addEventListener('click', () => {
        document.getElementById('modal-settings').classList.remove('active');
      });
    }

    // Profile Close
    const btnCloseProfile = document.getElementById('btn-close-profile');
    if (btnCloseProfile) {
      btnCloseProfile.addEventListener('click', () => {
        document.getElementById('modal-profile').classList.remove('active');
      });
    }
  },

  /* ---- Bind Socket.IO Event Listeners ---- */
  bindSocketListeners() {
    // Auth Success
    GameSocket.on('auth:success', (data) => {
      this.user = data.user;
      this.avatar = data.avatar;
      localStorage.setItem('chips_bomb_token', data.token);

      document.querySelectorAll('.username-display').forEach(el => el.textContent = this.user.username);
      this.updateTokenDisplay(this.user.token_balance);

      if (typeof AvatarScreen !== 'undefined' && this.avatar) {
        AvatarScreen.load(this.avatar);
      }

      this.showScreen('screen-lobby');
      GameSocket.emit('auth:success:ack');
    });

    // Auth Error
    GameSocket.on('auth:error', (data) => {
      this.showToast(data.message, 'error');
    });

    // Searching Match
    GameSocket.on('match:searching', () => {
      this.showToast('Searching for an online opponent...', 'info');
    });

    // Private Room Created
    GameSocket.on('match:privateRoomCreated', (data) => {
      const display = document.getElementById('friend-room-code-display');
      if (display) display.textContent = `ROOM CODE: ${data.roomCode}`;
      this.showToast(`Private room created: ${data.roomCode}`, 'success');
    });

    // Match Found
    GameSocket.on('match:found', (data) => {
      document.getElementById('modal-friend').classList.remove('active');
      this.showToast(`Match found vs ${data.opponent.username}!`, 'success');
      if (typeof AudioManager !== 'undefined') AudioManager.playMatchFound();
    });

    // Prompt Stake Select
    GameSocket.on('match:stakeSelect', (data) => {
      document.getElementById('stake-status-msg').textContent = 'Both players must select the same stake.';
      this.showScreen('screen-stake');
    });

    // Stake Confirmed
    GameSocket.on('match:stakeConfirmed', (data) => {
      document.getElementById('stake-status-msg').textContent = `Stake confirmed: ${data.stake} 🪙! Starting match...`;
    });

    // Stake Mismatch
    GameSocket.on('match:stakeMismatch', (data) => {
      this.showToast(`Stake mismatch (You: ${data.yourChoice}, Opponent: ${data.opponentChoice}). Please agree!`, 'error');
      document.getElementById('stake-status-msg').textContent = 'Stakes did not match. Choose again!';
    });

    // Match Start
    GameSocket.on('match:start', (data) => {
      if (typeof GameScreen !== 'undefined') {
        GameScreen.startMatch(data);
      }
    });

    // Opponent Selected Card
    GameSocket.on('match:opponentReady', () => {
      if (typeof GameScreen !== 'undefined') GameScreen.onOpponentReady();
    });

    // Reveal Cards
    GameSocket.on('match:reveal', (data) => {
      if (typeof GameScreen !== 'undefined') GameScreen.onReveal(data);
    });

    // Next Round
    GameSocket.on('match:nextRound', (data) => {
      if (typeof GameScreen !== 'undefined') GameScreen.nextRound(data.round);
    });

    // Match End
    GameSocket.on('match:end', (data) => {
      setTimeout(() => this.showMatchEndModal(data), 1500);
    });

    // Ad Reward Claimed
    GameSocket.on('ad:rewardClaimed', (data) => {
      this.updateTokenDisplay(data.newBalance);
      this.showToast(`🎉 REWARD CLAIMED! +${data.amount} 🪙 Tokens!`, 'success');
    });

    // Ad Error
    GameSocket.on('ad:error', (data) => {
      this.showToast(data.message, 'error');
    });

    // Profile Data Received
    GameSocket.on('profile:data', (profile) => {
      const modal = document.getElementById('modal-profile');
      if (!modal) return;

      document.getElementById('prof-played').textContent = profile.games_played;
      document.getElementById('prof-wins').textContent = profile.wins;
      document.getElementById('prof-losses').textContent = profile.losses;
      document.getElementById('prof-draws').textContent = profile.draws;

      const txList = document.getElementById('prof-transactions');
      if (txList && profile.transactions) {
        txList.innerHTML = profile.transactions.map(t => `
          <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid #334155;">
            <span>${t.description}</span>
            <strong style="color:${t.amount >= 0 ? '#10b981' : '#ef4444'}">${t.amount >= 0 ? '+' : ''}${t.amount} 🪙</strong>
          </div>
        `).join('');
      }

      modal.classList.add('active');
    });
  },

  /* ---- Show Match End Result Modal ---- */
  showMatchEndModal(data) {
    const modal = document.getElementById('modal-match-end');
    const titleEl = document.getElementById('end-title');
    const changeEl = document.getElementById('end-token-change');
    const balanceEl = document.getElementById('end-final-balance');

    this.updateTokenDisplay(data.newBalance);

    if (data.result === 'win') {
      titleEl.textContent = '🏆 YOU WIN!';
      titleEl.style.color = '#fbbf24';
      changeEl.textContent = `+${data.tokenChange} 🪙`;
      changeEl.style.color = '#10b981';
      if (typeof AudioManager !== 'undefined') AudioManager.playWin();
    } else if (data.result === 'lose') {
      titleEl.textContent = '💣 YOU LOST';
      titleEl.style.color = '#ef4444';
      changeEl.textContent = `${data.tokenChange} 🪙`;
      changeEl.style.color = '#ef4444';
      if (typeof AudioManager !== 'undefined') AudioManager.playLose();
    } else {
      titleEl.textContent = '🤝 DRAW!';
      titleEl.style.color = '#3b82f6';
      changeEl.textContent = '+0 🪙';
      changeEl.style.color = '#94a3b8';
    }

    balanceEl.textContent = `${data.newBalance.toLocaleString()} 🪙`;

    const btnPlayAgain = document.getElementById('btn-play-again');
    const btnLobby = document.getElementById('btn-return-lobby');

    btnPlayAgain.onclick = () => {
      modal.classList.remove('active');
      GameSocket.emit('match:playAgain');
    };

    btnLobby.onclick = () => {
      modal.classList.remove('active');
      this.showScreen('screen-lobby');
      GameSocket.emit('match:returnToLobby');
    };

    modal.classList.add('active');
  }
};

window.addEventListener('DOMContentLoaded', () => App.init());
