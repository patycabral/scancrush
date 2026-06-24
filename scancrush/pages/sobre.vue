<script setup lang="ts">
useHead({
  title: 'A história por trás do ScanCrush e da Patty | Sobre',
  meta: [
    { name: 'description', content: 'O ScanCrush nasceu de uma história real: a de quem passou anos interpretando sinais errados. Conheça a origem da marca e da Patty, a analista que ajuda a enxergar a conversa com mais clareza.' },
    { property: 'og:type', content: 'article' },
    { property: 'og:url', content: 'https://scancrush.com/sobre' },
    { property: 'og:title', content: 'A história por trás do ScanCrush e da Patty' },
    { property: 'og:description', content: 'A origem da marca e da Patty — a analista que ajuda a enxergar a conversa com mais clareza, sem achismo.' },
  ],
  link: [{ rel: 'canonical', href: 'https://scancrush.com/sobre' }],
})

const plansModal = ref()
</script>

<template>
<SiteNav />

<main class="about-page">
  <div class="container about-wrap">
    <NuxtLink to="/" class="about-back">← Início</NuxtLink>

    <header class="about-head">
      <span class="tag">// A história por trás do ScanCrush</span>
      <h1 class="about-title">Por que o ScanCrush <span class="grad">existe?</span></h1>
      <p class="about-lead" style="color:var(--text-2);font-weight:600">
        Ele não nasceu para ser só mais uma IA que lê mensagens. Nasceu de uma história real.
      </p>
    </header>

    <article class="about-body">
      <p>A fundadora do ScanCrush passou boa parte da adolescência interpretando sinais errados. Por não se enxergar dentro dos padrões de beleza da época, muitas vezes achava que ninguém poderia se interessar por ela.</p>

      <p>Então, quando alguém demonstrava atenção, gentileza ou proximidade, aquilo frequentemente ganhava um significado maior do que realmente tinha. Vieram expectativas criadas, frustrações e decepções que talvez pudessem ter sido evitadas se existisse uma forma mais neutra de olhar a situação.</p>

      <p>Com o tempo, ficou claro que isso não acontece só na adolescência. Adultos continuam interpretando sinais, criando expectativas, tentando entender conversas ambíguas e ignorando padrões de comportamento — porque, quando a gente está envolvido, é quase impossível ler a própria conversa com calma.</p>

      <p>O ScanCrush nasceu exatamente para ajudar nisso: <strong>enxergar com mais clareza</strong>. Não para decidir por você, não para prever o futuro, não para dizer quem você deve amar — mas para mostrar sinais, padrões e comportamentos que muitas vezes passam despercebidos quando a emoção fala mais alto.</p>

      <h2 class="about-h2">E a Patty?</h2>

      <p>A <strong>Patty</strong> é a analista virtual do ScanCrush — quem conduz a leitura dos sinais. Ela é uma homenagem a essa história: representa a ajuda que a fundadora gostaria de ter tido naquela época. Alguém capaz de olhar uma conversa sem ansiedade, sem expectativa e sem envolvimento emocional.</p>

      <p>Enquanto você está emocionalmente envolvido na situação, a Patty observa os fatos: quem inicia, quem sustenta, o que se repete, o que ficou no ar. Ela identifica sinais, padrões e reciprocidade — para reduzir o achismo e transformar dúvida em clareza.</p>

      <div class="about-not">
        <p class="about-not-label">Para deixar claro, a Patty <strong>não é</strong></p>
        <div class="about-not-chips">
          <span class="about-not-chip">vidência</span>
          <span class="about-not-chip">oráculo</span>
          <span class="about-not-chip">terapia</span>
          <span class="about-not-chip">aconselhamento profissional</span>
          <span class="about-not-chip">detector de sentimentos</span>
          <span class="about-not-chip">promessa de relacionamento</span>
          <span class="about-not-chip">uma pessoa real</span>
        </div>
        <p class="about-not-foot">Ela faz uma leitura neutra de padrões e sinais — nada além, nada a mais.</p>
      </div>

      <p class="about-closing">No fim, o ScanCrush existe para que você não precise ler a conversa sozinha, no meio da ansiedade. A Patty olha junto — com calma.</p>
    </article>

    <div class="about-cta">
      <button class="btn-primary" @click="plansModal?.open()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <span>Deixa a Patty observar sua conversa</span>
      </button>
    </div>
  </div>
</main>

<PlansModal ref="plansModal" />
</template>

<style scoped>
.about-page { background: var(--bg); color: var(--text); min-height: 100vh; padding: 96px 0 80px; }
.about-wrap { max-width: 680px; }
.about-back { font-size: 13px; color: var(--text-3); text-decoration: none; font-family: var(--mono); display: inline-block; margin-bottom: 28px; }
.about-back:hover { color: var(--text-2); }
.about-head { margin-bottom: 32px; }
.about-title { font-size: clamp(32px, 6vw, 48px); font-weight: 800; letter-spacing: -1.5px; line-height: 1.1; margin: 12px 0 14px; }
.about-lead { font-size: 18px; color: var(--text-2); font-weight: 300; line-height: 1.6; }
.about-body p { font-size: 16px; color: var(--text-2); font-weight: 300; line-height: 1.85; margin-bottom: 20px; }
.about-body strong { color: var(--text); font-weight: 600; }
.about-h2 { font-size: 24px; font-weight: 800; letter-spacing: -0.5px; margin: 36px 0 16px; }
.about-not {
  background: linear-gradient(160deg, rgba(155,93,229,0.08), rgba(255,45,107,0.04));
  border: 1px solid rgba(155,93,229,0.22);
  border-radius: var(--r);
  padding: 28px 26px;
  margin: 10px 0 26px;
  text-align: center;
}
.about-not-label { font-size: 13px; font-family: var(--mono); text-transform: uppercase; letter-spacing: 0.08em; color: var(--text-3); margin-bottom: 14px; }
.about-not-label strong { color: var(--text); }
.about-not-chips { display: flex; flex-wrap: wrap; gap: 8px; justify-content: center; margin-bottom: 16px; }
.about-not-chip {
  font-size: 12.5px;
  color: var(--text-2);
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 100px;
  padding: 6px 14px;
  white-space: nowrap;
}
.about-not-foot { font-size: 13.5px; color: var(--text-3); font-style: italic; margin: 0; line-height: 1.6; max-width: 460px; margin: 0 auto; }
.about-closing { font-size: 17px; color: var(--text); font-weight: 400; line-height: 1.7; border-left: 2px solid var(--purple); padding-left: 16px; }
.about-cta { margin-top: 36px; }
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
</style>
