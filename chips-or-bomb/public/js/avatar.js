/* =====================================================
   Avatar.js — Avatar creator and renderer
   ===================================================== */
const AvatarScreen = {
  config: {
    gender: 'boy',
    skinTone: '#F5D0A9',
    hairStyle: 'short',
    hairColor: '#4A3728',
    shirtColor: '#4A90D9',
    pantsColor: '#2C3E50'
  },

  options: {
    skinTones: ['#FDEBD0','#F5D0A9','#D4A574','#C68642','#8D5524','#5C3317'],
    hairStyles: ['short','long','curly','spiky','ponytail','bun'],
    hairColors: ['#4A3728','#2C1B0E','#D4A017','#C0392B','#2980B9','#8E44AD'],
    shirtColors: ['#4A90D9','#E74C3C','#2ECC71','#F39C12','#9B59B6','#1ABC9C','#E91E63','#FF5722'],
    pantsColors: ['#2C3E50','#34495E','#4A6FA5','#7B4F2C','#2E4053','#1C2833']
  },

  canvas: null,
  ctx: null,

  init() {
    this.canvas = document.getElementById('avatar-canvas');
    if (this.canvas) {
      this.ctx = this.canvas.getContext('2d');
      this.canvas.width = 200;
      this.canvas.height = 260;
    }
    this.buildControls();
    this.bindButtons();
    this.draw();
  },

  buildControls() {
    const container = document.getElementById('avatar-controls');
    if (!container) return;

    container.innerHTML = `
      <div class="avatar-section">
        <label>Character</label>
        <div class="avatar-option-row" data-prop="gender">
          <button class="avatar-opt ${this.config.gender==='boy'?'active':''}" data-val="boy">👦 Boy</button>
          <button class="avatar-opt ${this.config.gender==='girl'?'active':''}" data-val="girl">👧 Girl</button>
        </div>
      </div>
      <div class="avatar-section">
        <label>Skin Tone</label>
        <div class="avatar-option-row color-row" data-prop="skinTone">
          ${this.options.skinTones.map(c => `<button class="avatar-color ${this.config.skinTone===c?'active':''}" data-val="${c}" style="background:${c}"></button>`).join('')}
        </div>
      </div>
      <div class="avatar-section">
        <label>Hair Style</label>
        <div class="avatar-option-row" data-prop="hairStyle">
          ${this.options.hairStyles.map(h => `<button class="avatar-opt ${this.config.hairStyle===h?'active':''}" data-val="${h}">${h}</button>`).join('')}
        </div>
      </div>
      <div class="avatar-section">
        <label>Hair Color</label>
        <div class="avatar-option-row color-row" data-prop="hairColor">
          ${this.options.hairColors.map(c => `<button class="avatar-color ${this.config.hairColor===c?'active':''}" data-val="${c}" style="background:${c}"></button>`).join('')}
        </div>
      </div>
      <div class="avatar-section">
        <label>Shirt</label>
        <div class="avatar-option-row color-row" data-prop="shirtColor">
          ${this.options.shirtColors.map(c => `<button class="avatar-color ${this.config.shirtColor===c?'active':''}" data-val="${c}" style="background:${c}"></button>`).join('')}
        </div>
      </div>
      <div class="avatar-section">
        <label>Pants</label>
        <div class="avatar-option-row color-row" data-prop="pantsColor">
          ${this.options.pantsColors.map(c => `<button class="avatar-color ${this.config.pantsColor===c?'active':''}" data-val="${c}" style="background:${c}"></button>`).join('')}
        </div>
      </div>
    `;

    container.addEventListener('click', (e) => {
      const btn = e.target.closest('[data-val]');
      if (!btn) return;
      const row = btn.closest('[data-prop]');
      if (!row) return;
      const prop = row.dataset.prop;
      const val = btn.dataset.val;
      this.config[prop] = val;
      row.querySelectorAll('.active').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      this.draw();
      if (typeof AudioManager !== 'undefined') AudioManager.playClick();
    });
  },

  bindButtons() {
    const saveBtn = document.getElementById('avatar-save-btn');
    if (saveBtn) saveBtn.addEventListener('click', () => this.save());
    const backBtn = document.getElementById('avatar-back-btn');
    if (backBtn) backBtn.addEventListener('click', () => {
      if (typeof App !== 'undefined') App.showScreen('screen-lobby');
    });
  },

  draw() {
    if (!this.ctx) return;
    const c = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;
    c.clearRect(0, 0, w, h);

    const cx = w / 2;
    const baseY = h - 30;
    const cfg = this.config;
    const isGirl = cfg.gender === 'girl';

    // ---- Legs (sitting, bent forward) ----
    c.fillStyle = cfg.pantsColor;
    // left leg
    c.beginPath();
    c.roundRect(cx - 32, baseY - 50, 26, 50, 6);
    c.fill();
    // right leg
    c.beginPath();
    c.roundRect(cx + 6, baseY - 50, 26, 50, 6);
    c.fill();
    // shoes
    c.fillStyle = '#2d2d2d';
    c.beginPath();
    c.roundRect(cx - 34, baseY - 6, 30, 12, 4);
    c.fill();
    c.beginPath();
    c.roundRect(cx + 4, baseY - 6, 30, 12, 4);
    c.fill();

    // ---- Body / Torso ----
    c.fillStyle = cfg.shirtColor;
    const torsoY = baseY - 115;
    if (isGirl) {
      // slightly narrower torso, flared bottom
      c.beginPath();
      c.moveTo(cx - 28, torsoY);
      c.lineTo(cx + 28, torsoY);
      c.lineTo(cx + 34, torsoY + 65);
      c.lineTo(cx - 34, torsoY + 65);
      c.closePath();
      c.fill();
    } else {
      c.beginPath();
      c.roundRect(cx - 30, torsoY, 60, 65, 8);
      c.fill();
    }

    // Collar detail
    c.fillStyle = this._darken(cfg.shirtColor, 20);
    c.beginPath();
    c.moveTo(cx - 10, torsoY);
    c.lineTo(cx, torsoY + 14);
    c.lineTo(cx + 10, torsoY);
    c.closePath();
    c.fill();

    // ---- Arms ----
    c.fillStyle = cfg.shirtColor;
    // Left arm
    c.beginPath();
    c.roundRect(cx - 44, torsoY + 5, 16, 45, 6);
    c.fill();
    // Right arm
    c.beginPath();
    c.roundRect(cx + 28, torsoY + 5, 16, 45, 6);
    c.fill();
    // Hands
    c.fillStyle = cfg.skinTone;
    c.beginPath();
    c.arc(cx - 36, torsoY + 53, 8, 0, Math.PI * 2);
    c.fill();
    c.beginPath();
    c.arc(cx + 36, torsoY + 53, 8, 0, Math.PI * 2);
    c.fill();

    // ---- Neck ----
    c.fillStyle = cfg.skinTone;
    c.beginPath();
    c.roundRect(cx - 7, torsoY - 10, 14, 14, 3);
    c.fill();

    // ---- Head ----
    const headY = torsoY - 52;
    c.fillStyle = cfg.skinTone;
    c.beginPath();
    c.ellipse(cx, headY, 30, 36, 0, 0, Math.PI * 2);
    c.fill();

    // ---- Hair ----
    this._drawHair(c, cx, headY, cfg);

    // ---- Face ----
    // Eyes
    c.fillStyle = '#fff';
    c.beginPath();
    c.ellipse(cx - 11, headY - 2, 7, 8, 0, 0, Math.PI * 2);
    c.fill();
    c.beginPath();
    c.ellipse(cx + 11, headY - 2, 7, 8, 0, 0, Math.PI * 2);
    c.fill();
    // Pupils
    c.fillStyle = '#2c3e50';
    c.beginPath();
    c.arc(cx - 9, headY - 1, 4, 0, Math.PI * 2);
    c.fill();
    c.beginPath();
    c.arc(cx + 13, headY - 1, 4, 0, Math.PI * 2);
    c.fill();
    // Eye shine
    c.fillStyle = '#fff';
    c.beginPath();
    c.arc(cx - 8, headY - 3, 1.5, 0, Math.PI * 2);
    c.fill();
    c.beginPath();
    c.arc(cx + 14, headY - 3, 1.5, 0, Math.PI * 2);
    c.fill();

    // Eyebrows
    c.strokeStyle = this._darken(cfg.hairColor, 20);
    c.lineWidth = 2;
    c.beginPath();
    c.moveTo(cx - 17, headY - 13);
    c.quadraticCurveTo(cx - 11, headY - 16, cx - 5, headY - 12);
    c.stroke();
    c.beginPath();
    c.moveTo(cx + 5, headY - 12);
    c.quadraticCurveTo(cx + 11, headY - 16, cx + 17, headY - 13);
    c.stroke();

    // Mouth (smile)
    c.strokeStyle = '#c0392b';
    c.lineWidth = 2;
    c.beginPath();
    c.arc(cx, headY + 10, 8, 0.1 * Math.PI, 0.9 * Math.PI);
    c.stroke();

    // Blush
    c.fillStyle = 'rgba(255,150,150,0.3)';
    c.beginPath();
    c.ellipse(cx - 20, headY + 6, 7, 4, 0, 0, Math.PI * 2);
    c.fill();
    c.beginPath();
    c.ellipse(cx + 20, headY + 6, 7, 4, 0, 0, Math.PI * 2);
    c.fill();
  },

  _drawHair(c, cx, headY, cfg) {
    c.fillStyle = cfg.hairColor;
    const style = cfg.hairStyle;

    switch (style) {
      case 'short':
        c.beginPath();
        c.ellipse(cx, headY - 16, 32, 26, 0, Math.PI, 2 * Math.PI);
        c.fill();
        break;
      case 'long':
        c.beginPath();
        c.ellipse(cx, headY - 14, 34, 28, 0, Math.PI, 2 * Math.PI);
        c.fill();
        // Side hair
        c.beginPath();
        c.roundRect(cx - 34, headY - 10, 12, 60, 6);
        c.fill();
        c.beginPath();
        c.roundRect(cx + 22, headY - 10, 12, 60, 6);
        c.fill();
        break;
      case 'curly':
        for (let i = 0; i < 8; i++) {
          const angle = Math.PI + (Math.PI * i) / 7;
          const r = 32;
          c.beginPath();
          c.arc(cx + Math.cos(angle) * r * 0.8, headY - 12 + Math.sin(angle) * r * 0.6, 14, 0, Math.PI * 2);
          c.fill();
        }
        break;
      case 'spiky':
        for (let i = 0; i < 7; i++) {
          const angle = Math.PI + (Math.PI * i) / 6;
          const px = cx + Math.cos(angle) * 22;
          const py = headY - 18 + Math.sin(angle) * 16;
          c.beginPath();
          c.moveTo(px - 8, headY - 8);
          c.lineTo(px, py - 20);
          c.lineTo(px + 8, headY - 8);
          c.closePath();
          c.fill();
        }
        c.beginPath();
        c.ellipse(cx, headY - 16, 30, 20, 0, Math.PI, 2 * Math.PI);
        c.fill();
        break;
      case 'ponytail':
        c.beginPath();
        c.ellipse(cx, headY - 16, 32, 24, 0, Math.PI, 2 * Math.PI);
        c.fill();
        // Ponytail
        c.beginPath();
        c.moveTo(cx + 20, headY - 20);
        c.quadraticCurveTo(cx + 48, headY - 10, cx + 38, headY + 30);
        c.quadraticCurveTo(cx + 30, headY + 10, cx + 22, headY - 10);
        c.closePath();
        c.fill();
        // Hair tie
        c.fillStyle = '#e74c3c';
        c.beginPath();
        c.arc(cx + 24, headY - 14, 4, 0, Math.PI * 2);
        c.fill();
        c.fillStyle = cfg.hairColor;
        break;
      case 'bun':
        c.beginPath();
        c.ellipse(cx, headY - 16, 32, 24, 0, Math.PI, 2 * Math.PI);
        c.fill();
        // Bun on top
        c.beginPath();
        c.arc(cx, headY - 42, 14, 0, Math.PI * 2);
        c.fill();
        break;
    }
  },

  _darken(hex, amount) {
    let r = parseInt(hex.slice(1,3),16);
    let g = parseInt(hex.slice(3,5),16);
    let b = parseInt(hex.slice(5,7),16);
    r = Math.max(0, r - amount);
    g = Math.max(0, g - amount);
    b = Math.max(0, b - amount);
    return `rgb(${r},${g},${b})`;
  },

  save() {
    GameSocket.emit('avatar:save', this.config);
    if (typeof App !== 'undefined') {
      App.showToast('Avatar saved!', 'success');
      App.showScreen('screen-lobby');
    }
  },

  load(avatarData) {
    if (avatarData) {
      Object.assign(this.config, avatarData);
      this.buildControls();
      this.draw();
    }
  },

  /* ---- Render a mini avatar onto any canvas ---- */
  renderMini(canvas, config, size = 80) {
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    canvas.width = size;
    canvas.height = Math.round(size * 1.3);

    ctx.save();
    const scale = size / 200;
    ctx.scale(scale, scale);

    const origCtx = this.ctx;
    const origCanvas = this.canvas;
    const origConfig = { ...this.config };

    this.ctx = ctx;
    this.canvas = { width: 200, height: 260 };
    if (config) Object.assign(this.config, config);
    this.draw();

    this.ctx = origCtx;
    this.canvas = origCanvas;
    this.config = origConfig;
    ctx.restore();
  }
};
