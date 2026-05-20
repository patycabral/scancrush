<script setup lang="ts">
useHead({
  title: 'Página não encontrada — ScanCrush',
  meta: [
    { name: 'robots', content: 'noindex' },
  ],
})
</script>

<template>
<div class="not-found-page">
  <div class="nf-inner">

    <!-- Logo -->
    <NuxtLink to="/" class="nf-logo">
      <svg width="32" height="32" viewBox="0 0 28 28" fill="none">
        <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
        <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
        <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
        <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
      </svg>
      <span class="nf-logo-word">Scan<span>Crush</span></span>
    </NuxtLink>

    <!-- Status -->
    <p class="nf-code">// erro 404</p>

    <!-- Heading -->
    <h1 class="nf-title">Essa página<br><span class="grad">sumiu sem dar visto.</span></h1>

    <p class="nf-sub">Ela não existe, foi movida ou você digitou o endereço errado.<br>Mas a conversa do seu crush ainda tem resposta.</p>

    <!-- Radar animado -->
    <div class="nf-radar" aria-hidden="true">
      <div class="radar-ring r1"></div>
      <div class="radar-ring r2"></div>
      <div class="radar-ring r3"></div>
      <div class="radar-dot"></div>
      <div class="radar-sweep"></div>
    </div>

    <!-- CTAs -->
    <div class="nf-actions">
      <NuxtLink to="/" class="nf-btn-primary">← Voltar ao início</NuxtLink>
      <NuxtLink to="/scan" class="nf-btn-secondary">Analisar conversa →</NuxtLink>
    </div>

    <!-- Links rápidos -->
    <div class="nf-links">
      <NuxtLink to="/blog" class="nf-link">Blog</NuxtLink>
      <span class="nf-sep">·</span>
      <NuxtLink to="/quiz" class="nf-link">Quizzes</NuxtLink>
      <span class="nf-sep">·</span>
      <NuxtLink to="/privacy" class="nf-link">Privacidade</NuxtLink>
    </div>

  </div>
</div>
</template>

<style scoped>
.not-found-page {
  min-height: 100vh;
  background: var(--bg);
  color: var(--text);
  font-family: var(--font);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 24px;
}
.nf-inner {
  text-align: center;
  max-width: 480px;
  width: 100%;
}
.nf-logo {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  text-decoration: none;
  margin-bottom: 36px;
}
.nf-logo-word {
  font-size: 18px;
  font-weight: 800;
  color: var(--text);
  letter-spacing: -.5px;
}
.nf-logo-word span { color: var(--pink); }
.nf-code {
  font-size: 11px;
  font-family: var(--mono);
  color: var(--pink);
  letter-spacing: .12em;
  text-transform: uppercase;
  margin-bottom: 16px;
}
.nf-title {
  font-size: clamp(28px, 7vw, 46px);
  font-weight: 800;
  line-height: 1.1;
  letter-spacing: -1.5px;
  margin-bottom: 16px;
}
.grad {
  background: linear-gradient(135deg, #FF2D6B, #9B5DE5);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.nf-sub {
  font-size: 15px;
  color: var(--text-2);
  line-height: 1.7;
  margin-bottom: 40px;
}

/* Radar */
.nf-radar {
  width: 120px;
  height: 120px;
  position: relative;
  margin: 0 auto 40px;
}
.radar-ring {
  position: absolute;
  border-radius: 50%;
  border: 1px solid rgba(255, 45, 107, 0.2);
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
}
.r1 { width: 100%; height: 100%; }
.r2 { width: 65%; height: 65%; border-color: rgba(255, 45, 107, 0.35); }
.r3 { width: 30%; height: 30%; border-color: rgba(255, 45, 107, 0.5); }
.radar-dot {
  position: absolute;
  width: 8px; height: 8px;
  background: var(--pink);
  border-radius: 50%;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  box-shadow: 0 0 10px var(--pink);
}
.radar-sweep {
  position: absolute;
  width: 50%; height: 50%;
  top: 0; left: 50%;
  transform-origin: bottom left;
  background: conic-gradient(from 0deg, transparent 270deg, rgba(255,45,107,0.15) 360deg);
  border-radius: 0 100% 0 0;
  animation: sweep 2.5s linear infinite;
}
@keyframes sweep {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.nf-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
  margin-bottom: 28px;
}
.nf-btn-primary {
  display: inline-block;
  background: linear-gradient(135deg, #FF2D6B, #9B5DE5);
  color: #fff;
  font-size: 14px;
  font-weight: 700;
  padding: 12px 24px;
  border-radius: 100px;
  text-decoration: none;
  transition: opacity .2s;
}
.nf-btn-primary:hover { opacity: .85; }
.nf-btn-secondary {
  display: inline-block;
  border: 1px solid var(--border);
  color: var(--text-2);
  font-size: 14px;
  font-weight: 600;
  padding: 12px 24px;
  border-radius: 100px;
  text-decoration: none;
  transition: border-color .2s;
}
.nf-btn-secondary:hover { border-color: rgba(255,45,107,.3); color: var(--text); }
.nf-links {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}
.nf-link {
  font-size: 13px;
  font-family: var(--mono);
  color: var(--text-3);
  text-decoration: none;
}
.nf-link:hover { color: var(--text-2); }
.nf-sep { color: var(--text-3); font-size: 12px; }
</style>
