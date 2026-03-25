<script setup lang="ts">
useHead({ title: 'ScanCrush — Termos de Uso' })
</script>

<template>
<nav class="nav">
  <NuxtLink to="/" class="logo">
    <svg width="20" height="20" viewBox="0 0 28 28" fill="none">
      <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
      <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
      <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
    </svg>
    Scan<span>Crush</span>
  </NuxtLink>
  <NuxtLink to="/" class="back-link">← Voltar ao início</NuxtLink>
</nav>

<div class="page-wrap">
  <span class="page-tag">// Termos</span>
  <h1>Termos de Uso</h1>
  <p class="page-date">Última atualização: março de 2025</p>

  <div class="notice-box">
    ⚠️ Ao utilizar o ScanCrush, você concorda com os termos descritos nesta página. Leia com atenção antes de prosseguir.
  </div>

  <h2>Natureza da ferramenta</h2>
  <p>O ScanCrush é uma ferramenta de <strong>análise informativa</strong> baseada em padrões de comunicação. Não se trata de conselho profissional, diagnóstico psicológico ou terapia.</p>
  <p>Os resultados gerados são baseados em reconhecimento de padrões e devem ser interpretados como uma perspectiva complementar, <strong>não como verdade absoluta</strong>.</p>

  <h2>Uso adequado</h2>
  <p>Ao usar o ScanCrush, você concorda em:</p>
  <ul>
    <li>Utilizar a ferramenta apenas para análise de conversas às quais você tem acesso legítimo</li>
    <li>Não usar os resultados para assédio, perseguição ou qualquer forma de dano a terceiros</li>
    <li>Compreender que a análise é automatizada e pode conter imprecisões</li>
    <li>Tomar decisões com responsabilidade, sem se basear exclusivamente neste relatório</li>
  </ul>

  <h2>Acesso único ao relatório</h2>
  <p>O relatório gerado é de <strong>acesso único e temporário</strong>. Após fechar a página, o resultado não estará mais disponível. Não nos responsabilizamos pela perda de acesso ao relatório após o encerramento da sessão.</p>

  <h2>Limitação de responsabilidade</h2>
  <p>O ScanCrush não se responsabiliza por:</p>
  <ul>
    <li>Decisões tomadas com base nos resultados da análise</li>
    <li>Imprecisões ou interpretações equivocadas do relatório</li>
    <li>Danos emocionais, relacionais ou de qualquer outra natureza decorrentes do uso da ferramenta</li>
  </ul>

  <h2>Propriedade intelectual</h2>
  <p>Todo o conteúdo, design, código e marca ScanCrush são de propriedade exclusiva dos seus criadores. É proibida a reprodução, cópia ou distribuição sem autorização prévia.</p>

  <h2>Alterações nos termos</h2>
  <p>Podemos atualizar estes termos a qualquer momento. O uso continuado da plataforma após alterações constitui aceitação dos novos termos.</p>

  <h2>Contato</h2>
  <p>Para dúvidas sobre estes termos: <strong>contato@scancrush.app</strong></p>
</div>

<footer>
  <p>
    <NuxtLink to="/">Início</NuxtLink>
    <NuxtLink to="/privacy">Privacidade</NuxtLink>
    <NuxtLink to="/terms">Termos</NuxtLink>
  </p>
  <p style="margin-top:16px">© 2025 ScanCrush. Análise emocional de conversas.</p>
</footer>
</template>

<style>
:root {
  --bg: #07070D; --surface: #0D0D1A; --card: #111120;
  --border: rgba(255,255,255,0.06);
  --pink: #FF2D6B; --purple: #9B5DE5;
  --text: #EEEEF8; --text-2: #9090B8; --text-3: #4A4A6A;
  --font: 'Sora', sans-serif; --mono: 'JetBrains Mono', monospace;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body {
  background: var(--bg); color: var(--text);
  font-family: var(--font); font-size: 16px; line-height: 1.7;
  -webkit-font-smoothing: antialiased;
}
body::before {
  content: '';
  position: fixed; inset: 0;
  background: radial-gradient(ellipse 70% 50% at 50% 0%, rgba(255,45,107,0.04) 0%, transparent 70%);
  pointer-events: none; z-index: 0;
}
.nav {
  display: flex; align-items: center; justify-content: space-between;
  padding: 20px 24px; border-bottom: 1px solid var(--border);
  background: rgba(7,7,13,0.8); backdrop-filter: blur(20px);
  position: sticky; top: 0; z-index: 10;
}
.logo {
  display: flex; align-items: center; gap: 8px;
  font-size: 18px; font-weight: 800; letter-spacing: -0.5px;
  text-decoration: none; color: var(--text);
}
.logo svg { filter: drop-shadow(0 0 6px var(--pink)); }
.logo span { color: var(--pink); }
.back-link {
  font-size: 13px; font-weight: 500; color: var(--text-2);
  text-decoration: none; transition: color 0.2s;
}
.back-link:hover { color: var(--text); }
.page-wrap {
  max-width: 680px; margin: 0 auto;
  padding: 56px 24px 80px;
  position: relative; z-index: 1;
}
.page-tag {
  font-family: var(--mono); font-size: 11px;
  text-transform: uppercase; letter-spacing: 0.16em;
  color: var(--pink); margin-bottom: 16px; display: block;
}
h1 {
  font-size: clamp(28px, 5vw, 40px); font-weight: 800;
  letter-spacing: -1.2px; margin-bottom: 8px; line-height: 1.1;
}
.page-date {
  font-size: 12px; font-family: var(--mono);
  color: var(--text-3); margin-bottom: 48px;
}
h2 {
  font-size: 18px; font-weight: 700;
  margin: 40px 0 14px; letter-spacing: -0.3px;
  padding-top: 40px; border-top: 1px solid var(--border);
}
h2:first-of-type { border-top: none; padding-top: 0; margin-top: 0; }
p { font-size: 15px; color: var(--text-2); font-weight: 300; margin-bottom: 16px; line-height: 1.8; }
strong { color: var(--text); font-weight: 600; }
ul { list-style: none; display: flex; flex-direction: column; gap: 10px; margin-bottom: 20px; }
li {
  display: flex; align-items: flex-start; gap: 10px;
  font-size: 14px; color: var(--text-2); font-weight: 300; line-height: 1.65;
}
li::before {
  content: '✦'; color: var(--pink); font-size: 10px;
  margin-top: 4px; flex-shrink: 0;
}
.notice-box {
  background: rgba(255,184,0,0.05);
  border: 1px solid rgba(255,184,0,0.15);
  border-radius: 14px;
  padding: 18px 22px;
  font-size: 14px;
  color: rgba(255,184,0,0.8);
  font-weight: 300;
  line-height: 1.7;
  margin-bottom: 32px;
}
footer {
  border-top: 1px solid var(--border);
  padding: 32px 24px; text-align: center;
  font-size: 12px; color: var(--text-3);
}
footer a { color: var(--text-2); text-decoration: none; margin: 0 12px; }
footer a:hover { color: var(--text); }
</style>
