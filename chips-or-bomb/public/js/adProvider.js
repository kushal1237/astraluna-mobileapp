/* =====================================================
   adProvider.js — Rewarded Advertisement Provider SDK Simulator
   Simulates Google AdMob / Unity Ads rewarded video SDK.
   Enforces full video watch (5s countdown) before sending
   completion confirmation to the server.
   ===================================================== */
const RewardedAdProvider = {
  isLoaded: true,
  isShowing: false,
  timerInterval: null,
  elapsed: 0,
  targetDuration: 5,
  onCompletedCallback: null,
  onClosedEarlyCallback: null,

  showRewardedAd(containerEl, onCompleted, onClosedEarly) {
    if (this.isShowing) return;
    this.isShowing = true;
    this.elapsed = 0;
    this.onCompletedCallback = onCompleted;
    this.onClosedEarlyCallback = onClosedEarly;

    // Tell server we started watching an ad
    GameSocket.emit('ad:start');

    // Create / Show Ad UI Overlay
    const modal = document.getElementById('modal-ad');
    const adBox = document.getElementById('ad-player-box');
    const timerTag = document.getElementById('ad-timer-tag');
    const progressBar = document.getElementById('ad-progress-bar');
    const closeBtn = document.getElementById('ad-close-btn');

    modal.classList.add('active');
    closeBtn.textContent = 'Skip / Close (No Reward)';
    closeBtn.classList.remove('btn-primary');
    closeBtn.classList.add('btn-outline');

    this.timerInterval = setInterval(() => {
      this.elapsed += 0.1;
      const progress = Math.min((this.elapsed / this.targetDuration) * 100, 100);
      const remaining = Math.max(0, Math.ceil(this.targetDuration - this.elapsed));

      if (progressBar) progressBar.style.width = `${progress}%`;
      if (timerTag) timerTag.textContent = remaining > 0 ? `Reward in ${remaining}s` : 'Reward Ready!';

      if (this.elapsed >= this.targetDuration) {
        clearInterval(this.timerInterval);
        this.timerInterval = null;

        // Upgrade button to Claim
        closeBtn.textContent = 'Claim 50 🪙 Reward!';
        closeBtn.classList.remove('btn-outline');
        closeBtn.classList.add('btn-primary');
        if (typeof AudioManager !== 'undefined') AudioManager.playCoinGain();
      }
    }, 100);

    // Bind Close / Claim Button
    closeBtn.onclick = () => {
      if (this.timerInterval) {
        clearInterval(this.timerInterval);
        this.timerInterval = null;
      }

      modal.classList.remove('active');
      this.isShowing = false;

      if (this.elapsed >= this.targetDuration) {
        if (typeof this.onCompletedCallback === 'function') {
          this.onCompletedCallback();
        }
      } else {
        if (typeof this.onClosedEarlyCallback === 'function') {
          this.onClosedEarlyCallback();
        }
      }
    };
  }
};
