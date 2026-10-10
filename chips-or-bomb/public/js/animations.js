/* =====================================================
   Animations.js — Animation helpers for Chips or Bomb
   ===================================================== */
const Animations = {

  /* ---- Easing functions ---- */
  easeOutCubic(t) { return 1 - Math.pow(1 - t, 3); },
  easeInOutCubic(t) { return t < 0.5 ? 4*t*t*t : 1 - Math.pow(-2*t+2,3)/2; },
  easeOutBack(t) { const c1=1.70158; const c3=c1+1; return 1+c3*Math.pow(t-1,3)+c1*Math.pow(t-1,2); },
  easeOutElastic(t) {
    if(t===0||t===1) return t;
    return Math.pow(2,-10*t)*Math.sin((t*10-0.75)*(2*Math.PI)/3)+1;
  },

  /* ---- Count a number from→to inside an element ---- */
  countTo(element, from, to, duration = 1000) {
    const start = performance.now();
    const update = (now) => {
      const p = Math.min((now - start) / duration, 1);
      const cur = Math.round(from + (to - from) * this.easeOutCubic(p));
      element.textContent = cur.toLocaleString();
      if (p < 1) requestAnimationFrame(update);
    };
    requestAnimationFrame(update);
  },

  /* ---- Screen shake ---- */
  shake(element, intensity = 6, duration = 500) {
    const start = performance.now();
    const update = (now) => {
      const elapsed = now - start;
      if (elapsed > duration) { element.style.transform = ''; return; }
      const decay = 1 - elapsed / duration;
      const x = (Math.random() - 0.5) * intensity * decay * 2;
      const y = (Math.random() - 0.5) * intensity * decay * 2;
      element.style.transform = `translate(${x}px, ${y}px)`;
      requestAnimationFrame(update);
    };
    requestAnimationFrame(update);
  },

  /* ---- Float an element upward and fade out ---- */
  floatUp(element, distance = 80, duration = 1000) {
    element.style.transition = `transform ${duration}ms ease-out, opacity ${duration}ms ease-out`;
    element.style.transform = `translateY(-${distance}px)`;
    element.style.opacity = '0';
    setTimeout(() => element.remove(), duration);
  },

  /* ---- Pop-in (scale from 0) ---- */
  popIn(element, duration = 350) {
    element.style.transform = 'scale(0)';
    element.style.transition = `transform ${duration}ms cubic-bezier(0.175,0.885,0.32,1.275)`;
    requestAnimationFrame(() => { element.style.transform = 'scale(1)'; });
  },

  /* ---- Pulse glow ---- */
  pulseGlow(element, color = '#f4d03f', times = 3) {
    element.style.setProperty('--glow-color', color);
    element.style.animation = `glow 0.5s ease-in-out ${times}`;
    setTimeout(() => { element.style.animation = ''; }, 500 * times);
  },

  /* ---- Create explosion particles around an element ---- */
  createExplosion(parent, rect) {
    const colors = ['#e74c3c','#f39c12','#e67e22','#f1c40f','#ff6b6b'];
    for (let i = 0; i < 12; i++) {
      const p = document.createElement('div');
      p.className = 'explosion-particle';
      const angle = (Math.PI * 2 * i) / 12;
      const dist = 40 + Math.random() * 60;
      p.style.setProperty('--tx', `${Math.cos(angle) * dist}px`);
      p.style.setProperty('--ty', `${Math.sin(angle) * dist}px`);
      p.style.left = `${rect.left + rect.width / 2}px`;
      p.style.top = `${rect.top + rect.height / 2}px`;
      p.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
      p.style.width = p.style.height = `${6 + Math.random() * 8}px`;
      parent.appendChild(p);
      setTimeout(() => p.remove(), 700);
    }
  },

  /* ---- Create chip particles floating up ---- */
  createChipParticles(parent, rect) {
    for (let i = 0; i < 6; i++) {
      const p = document.createElement('div');
      p.className = 'chip-particle';
      p.textContent = '🪙';
      p.style.left = `${rect.left + Math.random() * rect.width}px`;
      p.style.top = `${rect.top}px`;
      p.style.animationDelay = `${i * 80}ms`;
      parent.appendChild(p);
      setTimeout(() => p.remove(), 1200);
    }
  },

  /* ---- Show big centered text overlay (REVEAL!, GO!, etc.) ---- */
  showOverlayText(container, text, duration = 1000) {
    return new Promise(resolve => {
      let overlay = container.querySelector('.game-overlay-text');
      if (!overlay) {
        overlay = document.createElement('div');
        overlay.className = 'game-overlay-text';
        container.appendChild(overlay);
      }
      overlay.textContent = text;
      overlay.classList.add('active');
      setTimeout(() => {
        overlay.classList.remove('active');
        resolve();
      }, duration);
    });
  },

  /* ---- Countdown 3-2-1-GO! ---- */
  async countdown(container) {
    for (let i = 3; i >= 1; i--) {
      await this.showOverlayText(container, i, 800);
      if (typeof AudioManager !== 'undefined') AudioManager.playCountdown();
      await new Promise(r => setTimeout(r, 200));
    }
    await this.showOverlayText(container, 'GO!', 800);
    if (typeof AudioManager !== 'undefined') AudioManager.playMatchFound();
  }
};
