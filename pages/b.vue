<script setup lang="ts">
useHead({
  title: 'ScanCrush — Você releu aquela mensagem umas 5 vezes, né?',
  meta: [
    { name: 'description', content: 'IA que analisa conversas do crush e revela o que está escondido nas mensagens. Sem achismo, sem talvez.' },
    { property: 'og:title', content: 'ScanCrush — Para de adivinhar. Começa a saber.' },
    { property: 'og:description', content: 'Análise de conversas com IA especializada em relacionamentos.' },
  ],
})

const KIWIFY_URLS = {
  basic:    'https://pay.kiwify.com.br/lksicGT',
  revealed: 'https://pay.kiwify.com.br/9er8Nn9',
  raiox:    'https://pay.kiwify.com.br/ZYqerZF',
}

function goToCheckout(plan: 'basic' | 'revealed' | 'raiox') {
  window.open(KIWIFY_URLS[plan], '_blank')
}

function scrollToPlans() {
  document.getElementById('planos')?.scrollIntoView({ behavior: 'smooth' })
}

const openFaq = ref<number | null>(null)
function toggleFaq(i: number) {
  openFaq.value = openFaq.value === i ? null : i
}

const loopSteps = [
  { emoji: '📱', title: 'Você recebe uma mensagem', desc: 'Curta, simples. Mas algo te incomoda.' },
  { emoji: '🤔', title: 'Parece ok. Ou não?', desc: 'Você lê de novo. Com outro sentimento.' },
  { emoji: '😰', title: 'Agora parece fria', desc: 'Ou será que é você exagerando? Não dá pra saber.' },
  { emoji: '📲', title: 'Manda pro amigo', desc: '"O que você acha que ele quis dizer com isso?"' },
  { emoji: '💭', title: 'Ainda pensa quando dorme', desc: 'Adormece pensando. Acorda pensando. O mesmo loop.' },
  { emoji: '🔁', title: 'Volta na conversa mais 3x', desc: 'Nova teoria. Nova leitura. Mesma dúvida.' },
]

const howSteps = [
  { title: 'Faça prints da conversa', desc: 'WhatsApp, Instagram, Telegram — qualquer tela funciona. Quanto mais prints, mais rica a análise.' },
  { title: 'Envie pro ScanCrush', desc: 'Cole os prints, preencha o contexto e deixa a IA trabalhar.' },
  { title: 'Leia a análise completa', desc: 'Score de interesse, sinais positivos e negativos, padrões de comportamento e uma conclusão direta.' },
]

const faqs = [
  { q: 'Isso é diferente do ChatGPT?', a: 'Totalmente. O ChatGPT é generalista — não pode se comprometer com uma resposta porque foi treinado pra isso. O ScanCrush é específico para análise de conversas de relacionamento. Ele sabe o que "tô ocupado" geralmente significa.' },
  { q: 'Minha conversa fica salva?', a: 'Não. Nada é armazenado. A análise é feita em tempo real e seus dados não ficam guardados. Privacidade total.' },
  { q: 'Funciona com Instagram e Telegram?', a: 'Sim. WhatsApp, Instagram, Telegram, iMessage — qualquer print de conversa funciona.' },
  { q: 'E se eu não gostar do resultado?', a: 'Então provavelmente é algo que você já sentia. Só não queria confirmar. A análise é baseada no que foi enviado, não no que você quer ouvir.' },
  { q: 'Posso usar mais de uma vez?', a: 'Cada análise é uma compra separada. Muita gente compra mais de uma vez para conversas diferentes ou fases diferentes da mesma conversa.' },
]

const showSticky = ref(false)

onMounted(() => {
  const handleScroll = () => {
    showSticky.value = window.scrollY > 600
  }
  window.addEventListener('scroll', handleScroll, { passive: true })
  onUnmounted(() => window.removeEventListener('scroll', handleScroll))
})
</script>

<template>
  <div class="sc-root">

    <!-- BACKGROUND BLOBS -->
    <div class="blob-wrap" aria-hidden="true">
      <div class="blob b1" />
      <div class="blob b2" />
    </div>

    <!-- NAVBAR -->
    <nav class="navbar">
      <a href="/" class="logo">
        <span class="logo-scan">Scan</span><span class="logo-crush">Crush</span>
      </a>
      <button class="btn-nav" @click="scrollToPlans">Ver planos</button>
    </nav>

    <!-- ─── HERO ─────────────────────────────────────── -->
    <section class="section hero-section">
      <span class="eyebrow">IA especializada em conversas de relacionamento</span>

      <h1 class="hero-h1">
        Você releu aquela<br>
        mensagem umas 5 vezes, né?
      </h1>

      <p class="hero-sub">
        A gente sabe o que está escondido nela.
      </p>
      <p class="hero-sub2">
        Cole os prints da conversa com o seu crush e receba uma análise honesta —<br class="hidden md:block">
        sem julgamento, sem achismo, sem <em>"talvez"</em>.
      </p>

      <button class="btn-primary hero-cta" @click="scrollToPlans">
        Analisar minha conversa →
      </button>

      <p class="hero-hint">⚡ Resultado em segundos &nbsp;·&nbsp; Privacidade garantida</p>
    </section>

    <!-- ─── QUEBRA DE CRENÇA ──────────────────────────── -->
    <section class="section">
      <div class="card belief-card">
        <p class="tag-pink">Antes de mais nada…</p>
        <h2 class="block-h2">
          Não é frescura.<br>
          <span class="pink">Texto realmente distorce emoção.</span>
        </h2>
        <p class="body-text mt-3">
          Mensagem não tem tom de voz. Não tem olhar. Não tem pausa.
        </p>
        <p class="body-text mt-2">
          Você preenche o que não está lá com o que você <em>quer</em> — ou <em>teme</em> — que seja verdade.
        </p>
        <p class="body-bold mt-4">
          É literalmente assim que o cérebro funciona. E não tem nada de errado nisso.
        </p>
      </div>
    </section>

    <!-- ─── O LOOP MENTAL ────────────────────────────── -->
    <section class="section">
      <h2 class="section-h2">O loop que <span class="pink">você conhece</span></h2>
      <p class="section-sub">Admite. Você já fez isso.</p>

      <div class="loop-list">
        <div v-for="(step, i) in loopSteps" :key="i" class="loop-item">
          <span class="loop-emoji">{{ step.emoji }}</span>
          <div>
            <p class="loop-title">{{ step.title }}</p>
            <p class="loop-desc">{{ step.desc }}</p>
          </div>
        </div>
      </div>

      <div class="alert-box mt-5">
        <p class="font-bold" style="color: var(--pink)">E no final você ainda não sabe.</p>
        <p class="body-text mt-1">Porque você está dentro da situação. É impossível ser imparcial.</p>
      </div>
    </section>

    <!-- ─── AMIGOS NÃO AJUDAM ────────────────────────── -->
    <section class="section">
      <h2 class="block-h2">
        Seus amigos querem te ajudar.<br>
        <span style="color: var(--purple)">Mas não conseguem.</span>
      </h2>
      <p class="body-text mt-3 mb-6">Não é culpa deles. É que amizade e imparcialidade não combinam.</p>

      <div class="chat-bubbles">
        <div class="bubble bubble-left">
          <p class="bubble-text">"Ai, ele claramente gosta de você! Só tá com medo."</p>
          <p class="bubble-from">Amiga que quer te ver feliz</p>
        </div>
        <div class="bubble bubble-right">
          <p class="bubble-text">"Larga esse cara, ele não presta."</p>
          <p class="bubble-from">Amigo que tá na torcida</p>
        </div>
        <div class="bubble bubble-left">
          <p class="bubble-text">"Manda mensagem! Pior que tá não fica."</p>
          <p class="bubble-from">Amiga que vive de romance</p>
        </div>
      </div>

      <div class="card mt-5">
        <p class="body-text">
          O que você precisa não é de encorajamento.<br>
          É de <strong style="color: var(--text)">análise real.</strong>
        </p>
      </div>
    </section>

    <!-- ─── VOCÊ JÁ TENTOU NO CHATGPT ────────────────── -->
    <section class="section">
      <div class="chatgpt-box">
        <!-- Header -->
        <div class="chatgpt-header">
          <p class="tag-pink">😅 Você já tentou no ChatGPT, né?</p>
          <p class="body-text mt-1" style="font-size: 13px">Todo mundo tenta. E é isso que acontece:</p>
        </div>

        <!-- Conversa falsa -->
        <div class="chatgpt-convo">
          <!-- User -->
          <div class="cg-row cg-user">
            <div class="cg-bubble cg-bubble-user">
              "Ele demorou 3h pra responder mas mandou um áudio longo. Gosta de mim ou não?"
            </div>
          </div>

          <!-- GPT -->
          <div class="cg-row cg-gpt">
            <div class="cg-avatar">G</div>
            <div class="cg-bubble cg-bubble-gpt">
              "Hmm, é difícil dizer com certeza! Pode ser que ele tenha estado ocupado, mas o áudio longo pode indicar que se importa. <span class="amber-text">Depende muito do contexto</span> e de outros fatores. Talvez valha conversar mais com ele para entender melhor as intenções. Cada pessoa é diferente! 😊"
            </div>
          </div>

          <!-- User 2 -->
          <div class="cg-row cg-user">
            <div class="cg-bubble cg-bubble-user">
              "Mas você acha que ele gosta?"
            </div>
          </div>

          <!-- GPT 2 -->
          <div class="cg-row cg-gpt">
            <div class="cg-avatar">G</div>
            <div class="cg-bubble cg-bubble-gpt">
              "Não tenho como saber com certeza! <span class="amber-text">Pode ser que sim, pode ser que não.</span> O comportamento humano é complexo e cada situação é única. O mais importante é como você se sente nessa situação! 😊"
            </div>
          </div>
        </div>

        <!-- O que está errado -->
        <div class="chatgpt-problems">
          <p class="tag-pink mb-2">O que está errado aí:</p>
          <div class="problem-list">
            <p>❌ <span>"Talvez" — não responde nada</span></p>
            <p>❌ <span>"Depende do contexto" — você acabou de dar o contexto</span></p>
            <p>❌ <span>"Cada pessoa é diferente" — óbvio, mas inútil</span></p>
            <p>❌ <span>Nenhuma análise real do comportamento</span></p>
          </div>
        </div>
      </div>

      <div class="card mt-5 text-center">
        <p class="font-bold text-lg">O problema não é você.</p>
        <p class="body-text mt-2">É a ferramenta. IA genérica não pode se comprometer com uma resposta — porque não foi treinada pra isso.</p>
      </div>
    </section>

    <!-- ─── TRANSIÇÃO + PRODUTO ──────────────────────── -->
    <section class="section text-center">
      <p class="tag-pink mb-3">A diferença</p>
      <h2 class="section-h2">
        Apresentando o<br>
        <span class="pink">ScanCrush</span>
      </h2>
      <p class="section-sub mt-2">
        IA treinada especificamente para análise de conversas de relacionamento.
      </p>
      <p class="body-text mt-2">
        Sem "talvez". Sem "depende". Com análise real baseada nos padrões da <em>sua</em> conversa.
      </p>

      <!-- Diferencial cards -->
      <div class="diff-grid mt-8">
        <div class="diff-card">
          <span class="diff-icon">🎯</span>
          <p class="diff-title">Especializado</p>
          <p class="diff-desc">Detecta sinais de interesse, distância emocional, inconsistência e padrões relacionais específicos.</p>
        </div>
        <div class="diff-card">
          <span class="diff-icon">📊</span>
          <p class="diff-title">Estruturado</p>
          <p class="diff-desc">Score, sinais positivos e negativos, padrão emocional e conclusão direta. Não é achismo.</p>
        </div>
        <div class="diff-card">
          <span class="diff-icon">💬</span>
          <p class="diff-title">Contextual</p>
          <p class="diff-desc">Entende o que "tô ocupado" geralmente significa. ChatGPT não entra nesse mérito.</p>
        </div>
      </div>
    </section>

    <!-- ─── COMO FUNCIONA ─────────────────────────────── -->
    <section class="section">
      <h2 class="section-h2 text-center">Como funciona</h2>
      <p class="section-sub text-center">Três passos. Uma verdade.</p>

      <div class="how-list mt-8">
        <div v-for="(step, i) in howSteps" :key="i" class="how-item">
          <div class="how-num">{{ i + 1 }}</div>
          <div class="card how-card">
            <p class="how-title">{{ step.title }}</p>
            <p class="how-desc">{{ step.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── PREVIEW DA ANÁLISE ───────────────────────── -->
    <section class="section">
      <p class="tag-pink text-center mb-3">Prévia do relatório</p>
      <h2 class="section-h2 text-center">É assim que parece<br>na prática</h2>

      <div class="preview-box mt-8">
        <!-- Header -->
        <div class="preview-header">
          <div>
            <p class="preview-name">Análise: Lucas</p>
            <p class="preview-meta">8 prints analisados</p>
          </div>
          <div class="text-right">
            <p class="preview-meta">Score de interesse</p>
            <p class="preview-score">72%</p>
          </div>
        </div>

        <!-- Score bar -->
        <div class="preview-bar-wrap">
          <div class="preview-bar">
            <div class="preview-bar-fill" style="width: 72%" />
          </div>
          <div class="preview-bar-labels">
            <span>Desinteresse</span>
            <span>Interesse forte</span>
          </div>
        </div>

        <!-- Sinais -->
        <div class="preview-signals">
          <p class="preview-label">SINAIS IDENTIFICADOS</p>
          <div class="signal-tags">
            <span class="stag stag-pos">✓ Inicia conversas</span>
            <span class="stag stag-pos">✓ Áudios longos</span>
            <span class="stag stag-pos">✓ Pergunta sobre seu dia</span>
            <span class="stag stag-neg">✗ Demora a responder</span>
            <span class="stag stag-neg">✗ Evita planos concretos</span>
          </div>
        </div>

        <!-- Conclusão -->
        <div class="preview-conclusion">
          <p class="preview-label">CONCLUSÃO</p>
          <p class="preview-text">
            Existe interesse, mas com reservas. Ele demonstra envolvimento emocional nas mensagens, mas evita compromisso. Padrão consistente com alguém que gosta mas não está pronto para avançar.
          </p>
          <div class="preview-locked">
            🔒 Análise completa + padrões comportamentais disponíveis no plano pago
          </div>
        </div>
      </div>
    </section>

    <!-- ─── PLANOS ─────────────────────────────────────── -->
    <section id="planos" class="section">
      <p class="tag-pink text-center mb-3">Planos</p>
      <h2 class="section-h2 text-center">Escolha o seu</h2>
      <p class="section-sub text-center mt-1 mb-10">
        Sem mensalidade. Você paga uma vez e usa agora.
      </p>

      <div class="plans-list">

        <!-- Grátis -->
        <div class="plan-card">
          <div class="plan-top">
            <div>
              <p class="plan-name">Primeiras Impressões</p>
              <p class="plan-label">Para sentir o produto</p>
            </div>
            <p class="plan-price">Grátis</p>
          </div>
          <ul class="plan-features">
            <li>✓ 1 print analisado</li>
            <li>✓ Visão geral da conversa</li>
            <li>✓ Score básico de interesse</li>
          </ul>
          <a href="/scan" class="btn-plan-secondary">Começar grátis</a>
        </div>

        <!-- Básico -->
        <div class="plan-card">
          <div class="plan-top">
            <div>
              <p class="plan-name">Sinais Básicos</p>
              <p class="plan-label">Para quem quer entender</p>
            </div>
            <div class="text-right">
              <p class="plan-price">R$ 19,90</p>
              <p class="plan-price-label">pagamento único</p>
            </div>
          </div>
          <ul class="plan-features">
            <li>✓ Até 5 prints</li>
            <li>✓ Score de interesse detalhado</li>
            <li>✓ Sinais positivos e negativos</li>
            <li>✓ Conclusão direta</li>
          </ul>
          <button class="btn-plan-secondary" @click="goToCheckout('basic')">Quero esse</button>
        </div>

        <!-- Revelado (FEATURED) -->
        <div class="plan-card plan-featured">
          <div class="plan-badge">🔥 Mais escolhido</div>
          <div class="plan-top mt-2">
            <div>
              <p class="plan-name">Sinais Revelados</p>
              <p class="plan-label">Para quem quer a verdade</p>
            </div>
            <div class="text-right">
              <p class="plan-price" style="color: var(--pink)">R$ 29,90</p>
              <p class="plan-price-label">pagamento único</p>
            </div>
          </div>
          <ul class="plan-features">
            <li>✓ Até 10 prints</li>
            <li>✓ Análise detalhada de padrões</li>
            <li>✓ Por que age de forma confusa</li>
            <li>✓ Trechos que revelam intenção real</li>
            <li>✓ Interpretação profunda</li>
          </ul>
          <button class="btn-plan-primary" @click="goToCheckout('revealed')">Quero esse →</button>
        </div>

        <!-- Raio-X -->
        <div class="plan-card">
          <div class="plan-top">
            <div>
              <p class="plan-name">Raio-X do Crush</p>
              <p class="plan-label">Diagnóstico completo</p>
            </div>
            <div class="text-right">
              <p class="plan-price">R$ 44,90</p>
              <p class="plan-price-label">pagamento único</p>
            </div>
          </div>
          <ul class="plan-features">
            <li>✓ Até 20 prints</li>
            <li>✓ Diagnóstico completo</li>
            <li>✓ Padrões emocionais identificados</li>
            <li>✓ O que realmente demonstra</li>
            <li>✓ Conclusão + direcionamento</li>
          </ul>
          <button class="btn-plan-secondary" @click="goToCheckout('raiox')">Quero esse</button>
        </div>

      </div>
    </section>

    <!-- ─── AVISO ANTI-REEMBOLSO ─────────────────────── -->
    <section class="section">
      <div class="warning-box">
        <p class="warning-title">⚠️ Aviso importante</p>
        <p class="warning-text">Por se tratar de conteúdo digital entregue imediatamente, não há reembolso após o acesso à análise. Compre com isso em mente.</p>
      </div>
    </section>

    <!-- ─── FECHAMENTO + CTA ──────────────────────────── -->
    <section class="section text-center">
      <h2 class="section-h2">
        Você já viu essa conversa<br>
        <span class="pink">várias vezes.</span>
      </h2>
      <p class="section-sub mt-2">Só ainda não viu do jeito certo.</p>
      <p class="body-text mt-2 mb-8">Enquanto você fica ruminando, a resposta já está nos prints.</p>
      <button class="btn-primary" @click="scrollToPlans">
        Ver o que isso realmente significa →
      </button>
    </section>

    <!-- ─── FAQ ──────────────────────────────────────── -->
    <section class="section">
      <h2 class="section-h2 text-center mb-8">Perguntas frequentes</h2>
      <div class="faq-list">
        <div v-for="(faq, i) in faqs" :key="i" class="faq-item">
          <button class="faq-btn" @click="toggleFaq(i)" :class="{ 'faq-btn-open': openFaq === i }">
            <span class="faq-q">{{ faq.q }}</span>
            <span class="faq-icon" :class="{ 'faq-icon-open': openFaq === i }">+</span>
          </button>
          <Transition name="faq">
            <div v-if="openFaq === i" class="faq-answer">
              {{ faq.a }}
            </div>
          </Transition>
        </div>
      </div>
    </section>

    <!-- ─── FOOTER ────────────────────────────────────── -->
    <footer class="sc-footer">
      <p class="footer-logo"><span class="pink">Scan</span>Crush</p>
      <p class="footer-tag">Seus sentimentos são válidos. A análise também.</p>
      <div class="footer-links">
        <a href="/privacy">Privacidade</a>
        <a href="/terms">Termos</a>
      </div>
      <p class="footer-copy">© 2025 ScanCrush. Análise emocional de conversas.</p>
    </footer>

    <!-- ─── STICKY CTA (mobile only) ─────────────────── -->
    <Transition name="slide-up">
      <div v-if="showSticky" class="sticky-cta">
        <button class="btn-primary w-full" @click="scrollToPlans">
          Analisar minha conversa →
        </button>
      </div>
    </Transition>

  </div>
</template>

<style scoped>
/* ── BASE ─────────────────────────────────────────────── */
.sc-root {
  min-height: 100vh;
  background: var(--bg);
  color: var(--text);
  font-family: var(--font);
  position: relative;
  overflow-x: hidden;
}

/* ── BACKGROUND BLOBS ─────────────────────────────────── */
.blob-wrap {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 0;
  overflow: hidden;
}
.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(100px);
  opacity: 0.35;
  animation: float 12s ease-in-out infinite;
}
.b1 {
  width: 520px;
  height: 520px;
  background: radial-gradient(circle, rgba(155,93,229,0.5), transparent 70%);
  top: -120px;
  right: -120px;
  animation-delay: 0s;
}
.b2 {
  width: 420px;
  height: 420px;
  background: radial-gradient(circle, rgba(255,45,107,0.4), transparent 70%);
  bottom: 20%;
  left: -100px;
  animation-delay: -5s;
}
@keyframes float {
  0%, 100% { transform: translateY(0) scale(1); }
  50% { transform: translateY(-30px) scale(1.05); }
}

/* ── SECTIONS ─────────────────────────────────────────── */
.section {
  position: relative;
  z-index: 10;
  max-width: 600px;
  margin: 0 auto;
  padding: 48px 20px;
}

/* ── NAVBAR ──────────────────────────────────────────── */
.navbar {
  position: relative;
  z-index: 50;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  max-width: 600px;
  margin: 0 auto;
}
.logo { text-decoration: none; font-size: 20px; font-weight: 700; }
.logo-scan { color: var(--pink); }
.logo-crush { color: var(--text); }
.btn-nav {
  font-size: 13px;
  font-weight: 600;
  padding: 8px 18px;
  border-radius: 999px;
  background: var(--pink);
  color: #fff;
  border: none;
  cursor: pointer;
  transition: opacity 0.2s;
}
.btn-nav:hover { opacity: 0.85; }

/* ── HERO ────────────────────────────────────────────── */
.hero-section { padding-top: 32px; padding-bottom: 64px; text-align: center; }
.eyebrow {
  display: inline-block;
  font-size: 12px;
  font-weight: 600;
  padding: 6px 14px;
  border-radius: 999px;
  background: rgba(255, 45, 107, 0.12);
  color: var(--pink);
  border: 1px solid var(--pink-border);
  margin-bottom: 24px;
}
.hero-h1 {
  font-size: clamp(28px, 7vw, 44px);
  font-weight: 800;
  line-height: 1.2;
  margin-bottom: 20px;
}
.hero-sub {
  font-size: 18px;
  font-weight: 600;
  color: var(--text);
  margin-bottom: 8px;
}
.hero-sub2 {
  font-size: 15px;
  color: var(--text-2);
  line-height: 1.6;
  margin-bottom: 32px;
}
.hero-cta { width: 100%; max-width: 340px; }
.hero-hint {
  font-size: 12px;
  color: var(--text-3);
  margin-top: 12px;
}

/* ── BUTTONS ─────────────────────────────────────────── */
.btn-primary {
  display: inline-block;
  font-size: 15px;
  font-weight: 700;
  padding: 16px 28px;
  border-radius: 16px;
  background: var(--pink);
  color: #fff;
  border: none;
  cursor: pointer;
  box-shadow: var(--glow-pink);
  transition: transform 0.2s, opacity 0.2s;
  text-align: center;
}
.btn-primary:hover { transform: scale(1.03); opacity: 0.95; }

/* ── CARDS ───────────────────────────────────────────── */
.card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--r);
  padding: 20px;
}
.belief-card { padding: 28px; }

/* ── TYPOGRAPHY ──────────────────────────────────────── */
.tag-pink { font-size: 12px; font-weight: 600; color: var(--pink); margin-bottom: 8px; }
.block-h2 { font-size: clamp(22px, 5vw, 28px); font-weight: 700; line-height: 1.3; }
.section-h2 { font-size: clamp(22px, 5vw, 30px); font-weight: 800; line-height: 1.3; }
.section-sub { font-size: 15px; color: var(--text-2); }
.body-text { font-size: 15px; color: var(--text-2); line-height: 1.65; }
.body-bold { font-size: 15px; font-weight: 600; color: var(--text); }
.pink { color: var(--pink); }
.amber-text { color: var(--amber); font-weight: 600; }
.alert-box {
  background: rgba(255, 45, 107, 0.08);
  border: 1px solid var(--pink-border);
  border-radius: var(--r);
  padding: 16px 20px;
}

/* ── LOOP MENTAL ─────────────────────────────────────── */
.loop-list { display: flex; flex-direction: column; gap: 10px; margin-top: 24px; }
.loop-item {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--r);
  padding: 14px 16px;
}
.loop-emoji { font-size: 22px; flex-shrink: 0; }
.loop-title { font-weight: 600; font-size: 14px; }
.loop-desc { font-size: 13px; color: var(--text-2); margin-top: 2px; }

/* ── CHAT BUBBLES (amigos) ───────────────────────────── */
.chat-bubbles { display: flex; flex-direction: column; gap: 10px; }
.bubble {
  max-width: 75%;
  border-radius: 18px;
  padding: 12px 16px;
}
.bubble-left {
  align-self: flex-start;
  background: var(--card-hi);
  border: 1px solid var(--border);
  border-bottom-left-radius: 4px;
}
.bubble-right {
  align-self: flex-end;
  background: rgba(155, 93, 229, 0.15);
  border: 1px solid rgba(155,93,229,0.25);
  border-bottom-right-radius: 4px;
}
.bubble-text { font-size: 14px; }
.bubble-from { font-size: 11px; color: var(--text-3); margin-top: 4px; }

/* ── CHATGPT BOX ─────────────────────────────────────── */
.chatgpt-box {
  border-radius: var(--r);
  border: 1px solid var(--border);
  overflow: hidden;
}
.chatgpt-header {
  background: var(--card-hi);
  padding: 16px 20px;
  border-bottom: 1px solid var(--border);
}
.chatgpt-convo {
  background: var(--card);
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.cg-row { display: flex; gap: 10px; }
.cg-user { justify-content: flex-end; }
.cg-gpt { justify-content: flex-start; }
.cg-bubble {
  max-width: 82%;
  border-radius: 16px;
  padding: 12px 15px;
  font-size: 13px;
  line-height: 1.55;
}
.cg-bubble-user {
  background: rgba(255,255,255,0.08);
  border: 1px solid var(--border);
  color: var(--text);
  border-top-right-radius: 4px;
}
.cg-bubble-gpt {
  background: rgba(255,255,255,0.04);
  border: 1px solid var(--border);
  color: var(--text-2);
  border-top-left-radius: 4px;
}
.cg-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: #10a37f;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 700;
  flex-shrink: 0;
}
.chatgpt-problems {
  background: rgba(255, 45, 107, 0.06);
  border-top: 1px solid var(--pink-border);
  padding: 16px 20px;
}
.problem-list { display: flex; flex-direction: column; gap: 6px; font-size: 13px; color: var(--text-2); }

/* ── DIFFERENCIAL GRID ───────────────────────────────── */
.diff-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 12px;
}
@media (min-width: 520px) {
  .diff-grid { grid-template-columns: repeat(3, 1fr); }
}
.diff-card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--r);
  padding: 20px 16px;
  text-align: left;
}
.diff-icon { font-size: 24px; }
.diff-title { font-weight: 700; font-size: 14px; margin-top: 10px; }
.diff-desc { font-size: 13px; color: var(--text-2); margin-top: 6px; line-height: 1.5; }

/* ── COMO FUNCIONA ───────────────────────────────────── */
.how-list { display: flex; flex-direction: column; gap: 12px; }
.how-item { display: flex; gap: 14px; align-items: flex-start; }
.how-num {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background: rgba(255, 45, 107, 0.12);
  color: var(--pink);
  border: 1px solid var(--pink-border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 14px;
  flex-shrink: 0;
}
.how-card { flex: 1; }
.how-title { font-weight: 600; font-size: 14px; }
.how-desc { font-size: 13px; color: var(--text-2); margin-top: 4px; line-height: 1.5; }

/* ── PREVIEW ─────────────────────────────────────────── */
.preview-box {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--r);
  overflow: hidden;
}
.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid var(--border);
}
.preview-name { font-weight: 600; font-size: 15px; }
.preview-meta { font-size: 11px; color: var(--text-3); }
.preview-score { font-size: 26px; font-weight: 800; color: var(--safe); }
.preview-bar-wrap { padding: 16px 20px; border-bottom: 1px solid var(--border); }
.preview-bar {
  height: 10px;
  border-radius: 999px;
  background: rgba(255,255,255,0.08);
  overflow: hidden;
}
.preview-bar-fill {
  height: 100%;
  border-radius: 999px;
  background: linear-gradient(90deg, var(--purple), var(--safe));
  transition: width 1s ease;
}
.preview-bar-labels {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: var(--text-3);
  margin-top: 6px;
}
.preview-signals { padding: 16px 20px; border-bottom: 1px solid var(--border); }
.preview-label { font-size: 10px; font-weight: 700; letter-spacing: 0.08em; color: var(--text-3); margin-bottom: 10px; }
.signal-tags { display: flex; flex-wrap: wrap; gap: 7px; }
.stag {
  font-size: 12px;
  font-weight: 500;
  padding: 5px 10px;
  border-radius: 999px;
}
.stag-pos { background: rgba(0,214,143,0.12); color: var(--safe); border: 1px solid rgba(0,214,143,0.25); }
.stag-neg { background: rgba(255,77,77,0.1); color: var(--danger); border: 1px solid rgba(255,77,77,0.2); }
.preview-conclusion { padding: 16px 20px; }
.preview-text { font-size: 14px; color: var(--text-2); line-height: 1.6; }
.preview-locked {
  margin-top: 12px;
  background: rgba(255,45,107,0.1);
  border: 1px solid var(--pink-border);
  border-radius: 10px;
  padding: 10px 14px;
  font-size: 13px;
  font-weight: 600;
  color: var(--pink);
  filter: blur(3px);
  user-select: none;
  cursor: not-allowed;
}

/* ── PLANOS ──────────────────────────────────────────── */
.plans-list { display: flex; flex-direction: column; gap: 14px; }
.plan-card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--r);
  padding: 20px;
  position: relative;
}
.plan-featured {
  border: 2px solid var(--pink);
}
.plan-badge {
  position: absolute;
  top: -13px;
  left: 50%;
  transform: translateX(-50%);
  background: var(--pink);
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  padding: 4px 14px;
  border-radius: 999px;
  white-space: nowrap;
}
.plan-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}
.plan-name { font-weight: 700; font-size: 15px; }
.plan-label { font-size: 12px; color: var(--text-3); margin-top: 2px; }
.plan-price { font-size: 22px; font-weight: 800; }
.plan-price-label { font-size: 11px; color: var(--text-3); text-align: right; }
.plan-features {
  list-style: none;
  padding: 0;
  margin: 0 0 16px;
  display: flex;
  flex-direction: column;
  gap: 7px;
  font-size: 13px;
  color: var(--text-2);
}
.btn-plan-primary {
  width: 100%;
  padding: 14px;
  border-radius: 14px;
  background: var(--pink);
  color: #fff;
  font-weight: 700;
  font-size: 14px;
  border: none;
  cursor: pointer;
  box-shadow: var(--glow-pink);
  transition: transform 0.2s;
}
.btn-plan-primary:hover { transform: scale(1.02); }
.btn-plan-secondary {
  display: block;
  width: 100%;
  padding: 13px;
  border-radius: 14px;
  background: var(--surface);
  color: var(--text-2);
  font-weight: 600;
  font-size: 14px;
  border: 1px solid var(--border);
  cursor: pointer;
  text-align: center;
  text-decoration: none;
  transition: opacity 0.2s;
}
.btn-plan-secondary:hover { opacity: 0.8; }

/* ── WARNING ─────────────────────────────────────────── */
.warning-box {
  background: rgba(255, 184, 0, 0.08);
  border: 1px solid rgba(255, 184, 0, 0.2);
  border-radius: var(--r);
  padding: 16px 20px;
}
.warning-title { font-size: 13px; font-weight: 700; color: var(--amber); margin-bottom: 6px; }
.warning-text { font-size: 13px; color: var(--text-2); line-height: 1.55; }

/* ── FAQ ─────────────────────────────────────────────── */
.faq-list { display: flex; flex-direction: column; gap: 10px; }
.faq-item {
  border: 1px solid var(--border);
  border-radius: var(--r);
  overflow: hidden;
}
.faq-btn {
  width: 100%;
  text-align: left;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  background: var(--card);
  border: none;
  cursor: pointer;
  color: var(--text);
  transition: background 0.2s;
}
.faq-btn-open { background: var(--card-hi); }
.faq-q { font-weight: 600; font-size: 14px; }
.faq-icon {
  color: var(--pink);
  font-size: 20px;
  flex-shrink: 0;
  transition: transform 0.25s ease;
  display: inline-block;
}
.faq-icon-open { transform: rotate(45deg); }
.faq-answer {
  padding: 14px 20px;
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.6;
  background: var(--card);
  border-top: 1px solid var(--border);
}
.faq-enter-active, .faq-leave-active { transition: all 0.25s ease; max-height: 300px; }
.faq-enter-from, .faq-leave-to { max-height: 0; opacity: 0; padding: 0 20px; }

/* ── FOOTER ──────────────────────────────────────────── */
.sc-footer {
  position: relative;
  z-index: 10;
  text-align: center;
  padding: 40px 20px 80px;
  border-top: 1px solid var(--border);
}
.footer-logo { font-size: 18px; font-weight: 700; margin-bottom: 6px; }
.footer-tag { font-size: 13px; color: var(--text-3); }
.footer-links { display: flex; gap: 20px; justify-content: center; margin-top: 16px; }
.footer-links a { font-size: 12px; color: var(--text-3); text-decoration: none; }
.footer-links a:hover { color: var(--text-2); }
.footer-copy { font-size: 11px; color: var(--text-3); margin-top: 12px; }

/* ── STICKY CTA ──────────────────────────────────────── */
.sticky-cta {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 50;
  padding: 12px 16px 20px;
  background: linear-gradient(to top, var(--bg) 65%, transparent);
}
@media (min-width: 768px) { .sticky-cta { display: none; } }

/* ── STICKY TRANSITION ───────────────────────────────── */
.slide-up-enter-active, .slide-up-leave-active { transition: transform 0.3s ease, opacity 0.3s; }
.slide-up-enter-from, .slide-up-leave-to { transform: translateY(100%); opacity: 0; }

/* ── UTILITIES ───────────────────────────────────────── */
.text-center { text-align: center; }
.mt-1 { margin-top: 4px; }
.mt-2 { margin-top: 8px; }
.mt-3 { margin-top: 12px; }
.mt-4 { margin-top: 16px; }
.mt-5 { margin-top: 20px; }
.mt-8 { margin-top: 32px; }
.mb-1 { margin-bottom: 4px; }
.mb-2 { margin-bottom: 8px; }
.mb-3 { margin-bottom: 12px; }
.mb-5 { margin-bottom: 20px; }
.mb-6 { margin-bottom: 24px; }
.mb-8 { margin-bottom: 32px; }
.mb-10 { margin-bottom: 40px; }
.font-bold { font-weight: 700; }
.text-lg { font-size: 18px; }
.w-full { width: 100%; }
</style>
