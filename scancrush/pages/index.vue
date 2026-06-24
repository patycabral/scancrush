<script setup lang="ts">
useHead({
  title: 'ScanCrush — Será que o crush gosta de você?',
  meta: [
    { name: 'description',        content: 'Cole os prints da conversa e deixe a Patty observar os sinais. O ScanCrush identifica padrões, reciprocidade e pontos de atenção — com clareza, sem achismo.' },
    { name: 'keywords',           content: 'ScanCrush, Scan Crush, Crush Scan, scanner de crush, análise de crush, como saber se o crush gosta de mim, sinais do crush, interpretar mensagens do crush, análise de conversa com IA, reciprocidade em conversas, sinais de interesse' },
    { property: 'og:type',        content: 'website' },
    { property: 'og:url',         content: 'https://scancrush.com/' },
    { property: 'og:site_name',   content: 'ScanCrush' },
    { property: 'og:locale',      content: 'pt_BR' },
    { property: 'og:title',       content: 'ScanCrush — Será que o crush gosta de você?' },
    { property: 'og:description', content: 'Cole os prints e deixe a Patty observar os sinais da conversa: padrões, reciprocidade e pontos de atenção — com clareza, sem achismo.' },
    { property: 'og:image',       content: 'https://scancrush.com/logo-email.png' },
    { name: 'twitter:card',       content: 'summary_large_image' },
    { name: 'twitter:title',      content: 'ScanCrush — Será que o crush gosta de você?' },
    { name: 'twitter:description', content: 'A Patty observa os sinais da conversa com o seu crush: padrões, reciprocidade e pontos de atenção. Com clareza, sem achismo.' },
    { name: 'twitter:image',      content: 'https://scancrush.com/logo-email.png' },
  ],
  link: [
    { rel: 'canonical', href: 'https://scancrush.com/' }
  ],
  script: [
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'WebApplication',
        name: 'ScanCrush',
        alternateName: ['Scan Crush', 'Crush Scan', 'Scanner de Crush'],
        url: 'https://scancrush.com/',
        description: 'O ScanCrush é uma ferramenta de análise de conversas que identifica sinais, padrões de comportamento e reciprocidade nas mensagens, conduzida pela Patty — a analista virtual da marca. Não é vidência, oráculo nem aconselhamento profissional: ajuda a enxergar o que a conversa mostra (Score de Engajamento Observado).',
        applicationCategory: 'LifestyleApplication',
        operatingSystem: 'Web',
        inLanguage: 'pt-BR',
        offers: [
          { '@type': 'Offer', price: '6.90', priceCurrency: 'BRL', name: 'Primeiras Impressões — 1 print' },
          { '@type': 'Offer', price: '19.90', priceCurrency: 'BRL', name: 'Sinais Revelados — até 4 prints' },
          { '@type': 'Offer', price: '44.90', priceCurrency: 'BRL', name: 'Raio-X do Crush — até 10 prints' },
        ],
      }),
    },
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'Organization',
        name: 'ScanCrush',
        alternateName: ['Scan Crush', 'Crush Scan'],
        url: 'https://scancrush.com/',
        logo: 'https://scancrush.com/logo-email.png',
        description: 'Plataforma de análise de conversas que identifica sinais, padrões e reciprocidade nas mensagens. A voz pública da marca é a Patty, analista virtual.',
      }),
    },
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'WebSite',
        name: 'ScanCrush',
        alternateName: ['Scan Crush', 'Crush Scan', 'Scanner de Crush'],
        url: 'https://scancrush.com/',
        inLanguage: 'pt-BR',
        description: 'Análise de conversas com IA: identifica sinais, padrões de comportamento e reciprocidade nas mensagens. Conduzida pela Patty, analista virtual da marca (uma persona, não uma pessoa real).',
      }),
    },
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'FAQPage',
        mainEntity: [
          {
            '@type': 'Question',
            name: 'O que é o ScanCrush?',
            acceptedAnswer: { '@type': 'Answer', text: 'O ScanCrush é uma ferramenta de análise de conversas que usa IA para identificar sinais, padrões de comportamento e reciprocidade nas mensagens. Ele ajuda a enxergar o que costuma passar despercebido — não é vidência, oráculo, terapia nem aconselhamento profissional.' },
          },
          {
            '@type': 'Question',
            name: 'Quem é a Patty?',
            acceptedAnswer: { '@type': 'Answer', text: 'A Patty é a analista virtual do ScanCrush — quem conduz a leitura dos sinais. Não é vidente, psicóloga, terapeuta nem coach: faz uma leitura neutra dos padrões e sinais na conversa.' },
          },
          {
            '@type': 'Question',
            name: 'A Patty é uma pessoa real?',
            acceptedAnswer: { '@type': 'Answer', text: 'Não. A Patty é a analista virtual do ScanCrush — uma persona da marca. Não é uma pessoa real, nem psicóloga, terapeuta ou coach.' },
          },
          {
            '@type': 'Question',
            name: 'ScanCrush, Scan Crush e Crush Scan são a mesma coisa?',
            acceptedAnswer: { '@type': 'Answer', text: 'Sim. ScanCrush, Scan Crush, Crush Scan e "scanner de crush" se referem ao mesmo produto.' },
          },
          {
            '@type': 'Question',
            name: 'Como funciona a análise?',
            acceptedAnswer: { '@type': 'Answer', text: 'Você cola os prints da conversa e a Patty identifica padrões de comportamento, consistência nas mensagens e sinais que passam despercebidos. O resultado traz um Score de Engajamento Observado, sinais e pontos de atenção.' },
          },
          {
            '@type': 'Question',
            name: 'A análise é 100% precisa?',
            acceptedAnswer: { '@type': 'Answer', text: 'É uma análise de padrões, não uma leitura da mente. Ela traz mais clareza com base no que as mensagens mostram — a decisão final é sempre sua.' },
          },
          {
            '@type': 'Question',
            name: 'O ScanCrush prevê o futuro ou decide por mim?',
            acceptedAnswer: { '@type': 'Answer', text: 'Não. Ele não adivinha nem prevê relacionamento e não toma decisões por você. Observa o comportamento presente nas mensagens enviadas e te dá mais clareza para decidir.' },
          },
          {
            '@type': 'Question',
            name: 'O ScanCrush substitui aconselhamento profissional?',
            acceptedAnswer: { '@type': 'Answer', text: 'Não. É uma ferramenta de clareza sobre uma conversa — não é terapia, aconselhamento profissional nem detector de sentimentos.' },
          },
          {
            '@type': 'Question',
            name: 'Minha conversa fica salva em algum lugar?',
            acceptedAnswer: { '@type': 'Answer', text: 'As conversas enviadas são usadas para gerar a análise solicitada, conforme a Política de Privacidade, e não ficam armazenadas após o uso da sessão.' },
          },
          {
            '@type': 'Question',
            name: 'A análise é privada?',
            acceptedAnswer: { '@type': 'Answer', text: 'Sim. As conversas são usadas apenas para gerar a análise solicitada. Não vendemos suas mensagens nem usamos os prints para exposição pública.' },
          },
          {
            '@type': 'Question',
            name: 'Quantos prints posso enviar?',
            acceptedAnswer: { '@type': 'Answer', text: 'Depende do plano: Primeiras Impressões (1 print), Sinais Revelados (até 4 prints) e Raio-X do Crush (até 10 prints). Mais prints permitem uma leitura mais profunda.' },
          },
          {
            '@type': 'Question',
            name: 'Por quanto tempo tenho acesso à análise?',
            acceptedAnswer: { '@type': 'Answer', text: 'Cada compra dá direito a uma análise. Você tem até 90 dias após a compra para gerá-la. Depois de concluída, o resultado é enviado por e-mail e fica disponível para download.' },
          },
          {
            '@type': 'Question',
            name: 'E se eu não gostar do resultado?',
            acceptedAnswer: { '@type': 'Answer', text: 'A análise interpreta os sinais presentes na conversa enviada. Emoções, intenções e relações humanas sempre envolvem contexto e subjetividade — por isso a leitura é um apoio, e a decisão é sua.' },
          },
          {
            '@type': 'Question',
            name: 'Por que isso é melhor do que usar uma IA genérica?',
            acceptedAnswer: { '@type': 'Answer', text: 'A IA genérica responde perguntas, mas não analisa padrões de comportamento ao longo da conversa. Aqui você recebe uma leitura estruturada: comportamento observado, sinais presentes e interpretação do contexto das mensagens.' },
          },
          {
            '@type': 'Question',
            name: 'O que é o Score de Engajamento Observado?',
            acceptedAnswer: { '@type': 'Answer', text: 'É uma medida de 0 a 100 de quanto o comportamento observado na conversa indica engajamento — quem inicia, responde, sustenta o assunto e demonstra reciprocidade. É uma leitura dos sinais presentes nas mensagens, não uma medida de sentimento.' },
          },
        ],
      }),
    },
  ],
})

const { t } = useAppI18n()

const CHECKOUT_URLS = {
  basico:   'https://go.perfectpay.com.br/PPU38CQDB0D',
  revealed: 'https://go.perfectpay.com.br/PPU38CQC51R',
  raiox:    'https://go.perfectpay.com.br/PPU38CQC51K',
}

function goToCheckout(plan: 'basico' | 'revealed' | 'raiox') {
  if (import.meta.client) window.location.href = CHECKOUT_URLS[plan]
}

const isPricesModalOpen = ref(false)
function scrollToPricing() {
  if (import.meta.client) document.querySelector('#b-pricing')?.scrollIntoView({ behavior: 'smooth' })
}

function openPricesModal() {
  isPricesModalOpen.value = true
  if (import.meta.client) document.body.style.overflow = 'hidden'
}
function closePricesModal() {
  isPricesModalOpen.value = false
  if (import.meta.client) document.body.style.overflow = ''
}
function handlePricesOverlayClick(e: MouseEvent) {
  if ((e.target as HTMLElement).classList.contains('lp-modal-overlay')) closePricesModal()
}

const openFaqIndex = ref<number | null>(null)
function toggleFaq(i: number) {
  openFaqIndex.value = openFaqIndex.value === i ? null : i
}

const navScrolled = ref(false)
function onScroll() { navScrolled.value = window.scrollY > 30 }

const mobileMenuOpen = ref(false)
function toggleMobileMenu() { mobileMenuOpen.value = !mobileMenuOpen.value }
function closeMobileMenu() { mobileMenuOpen.value = false }
onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  window.addEventListener('keydown', (e) => { if (e.key === 'Escape') closePricesModal() })
  const reveals = document.querySelectorAll('.reveal')
  const io = new IntersectionObserver(entries => {
    entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); io.unobserve(e.target) } })
  }, { threshold: 0.1 })
  reveals.forEach(el => io.observe(el))
})
onUnmounted(() => window.removeEventListener('scroll', onScroll))
</script>

<template>
<div class="bg-blobs" aria-hidden="true">
  <div class="blob blob-1"></div>
  <div class="blob blob-2"></div>
  <div class="blob blob-3"></div>
</div>
<div class="bg-grid" aria-hidden="true"></div>

<!-- NAVBAR -->
<nav class="nav" :class="{ scrolled: navScrolled }">
  <div class="container">
    <div class="nav-inner">
      <NuxtLink to="/" class="logo">
        <svg width="26" height="26" viewBox="0 0 28 28" fill="none">
          <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
          <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
          <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
          <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        </svg>
        <span class="logo-word">Scan<span>Crush</span></span>
      </NuxtLink>

      <ul class="nav-links">
        <li><a href="#b-how">Como funciona</a></li>
        <li><a href="#b-report">O relatório</a></li>
        <li><a href="#b-patty">A Patty</a></li>
        <li><a href="#b-pricing">Planos</a></li>
        <li><NuxtLink to="/blog">Blog</NuxtLink></li>
      </ul>

      <div class="nav-right">
        <button class="btn-nav" @click="openPricesModal()">Analisar conversa</button>
      </div>

      <button class="nav-mobile-btn" :class="{ active: mobileMenuOpen }" @click="toggleMobileMenu()" aria-label="Menu">
        <span></span><span></span><span></span>
      </button>
    </div>

    <!-- Menu mobile (dropdown do hamburguer) -->
    <div class="nav-mobile-menu" :class="{ open: mobileMenuOpen }">
      <a href="#b-how" @click="closeMobileMenu()">Como funciona</a>
      <a href="#b-report" @click="closeMobileMenu()">O relatório</a>
      <a href="#b-patty" @click="closeMobileMenu()">A Patty</a>
      <a href="#b-pricing" @click="closeMobileMenu()">Planos</a>
      <NuxtLink to="/blog" @click="closeMobileMenu()">Blog</NuxtLink>
      <button class="btn-nav" @click="openPricesModal(); closeMobileMenu()">Analisar conversa</button>
    </div>
  </div>
</nav>

<!-- ─── HERO ─────────────────────────────────────────────────── -->
<section class="hero">
  <div class="container">
    <div class="hero-grid">

      <div class="hero-inner">
        <div class="hero-eyebrow">IA especializada em analisar conversa do crush</div>

        <h1>
          <span>Como saber se o crush gosta de mim</span> <span class="line2 grad">pela conversa?</span>
        </h1>

        <p class="hero-sub">
          A resposta está nos padrões das mensagens — não no que você espera ouvir.<br>
          <span class="hero-sub-2"><b>Cole os prints da conversa com o seu crush e receba uma leitura dos sinais presentes na conversa</b> — sem julgamento e com menos achismo.</span>
        </p>

        <div class="hero-actions">
          <button class="btn-primary" @click="scrollToPricing()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <span>Analisar minha conversa</span>
          </button>
          <div class="hero-urgency">
            <span class="hu-time">⚡ Análise imediata</span><span class="hu-sep"> · </span><span class="hu-priv">🔒 Privacidade garantida</span>
          </div>
        </div>
      </div>

      <div class="hero-visual">
        <div style="position:relative; overflow:visible; isolation:isolate">
          <div class="float-tag float-tag-1">▶ 2 sinais detectados</div>

          <div class="chat-card">
            <div class="chat-scan-line"></div>
            <div class="chat-header">
              <div class="chat-avatar"></div>
              <div>
                <div class="chat-name">Lucas ✦</div>
                <div class="chat-status">visto há 3h</div>
              </div>
            </div>
            <div class="chat-messages">
              <div class="msg them">oi! tava pensando em vc</div>
              <div class="msg me">oi :) que coincidência</div>
              <div class="msg them">haha é</div>
              <div class="msg them">posso te chamar depois?</div>
            </div>
            <div class="analysis-badge">
              <div class="ab-label">// sinais detectados</div>
              <div class="ab-signals">
                <div class="ab-signal"><span class="ab-dot r"></span><span>resposta curta após iniciativa</span></div>
                <div class="ab-signal"><span class="ab-dot r"></span><span>não definiu horário</span></div>
                <div class="ab-signal"><span class="ab-dot g"></span><span>iniciou contato por conta própria</span></div>
              </div>
            </div>
          </div>

          <div class="float-tag float-tag-2">✅ análise concluída</div>
        </div>
      </div>

    </div>
  </div>
</section>

<!-- ─── O LOOP MENTAL ─────────────────────────────────────────── -->
<section class="section-pad" id="b-how">
  <div class="container">
    <div class="reveal" style="text-align:center; max-width:520px; margin:0 auto 0">
      <span class="tag">// o loop que você conhece</span>
    </div>

    <!-- círculo com título no centro -->
    <div class="loop-wrap reveal">

      <!-- trilha circular tracejada + seta de rotação -->
      <svg class="loop-track" viewBox="0 0 640 640" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="320" cy="320" r="220" stroke="url(#loopGrad)" stroke-width="1.5"
                stroke-dasharray="6 5" opacity="0.35"/>
        <!-- seta no topo indicando sentido horário -->
        <path d="M320 98 L326 112 L314 112 Z" fill="#FF2D6B" opacity="0.5"/>
        <defs>
          <linearGradient id="loopGrad" x1="0" y1="0" x2="640" y2="640" gradientUnits="userSpaceOnUse">
            <stop offset="0%" stop-color="#9B5DE5"/>
            <stop offset="100%" stop-color="#FF2D6B"/>
          </linearGradient>
        </defs>
      </svg>

      <!-- centro: título -->
      <div class="loop-center">
        <h2 class="loop-center-title">
          <span>Admite,</span><br class="br-m-hide"> <span class="grad">você já<br class="br-m-hide"> fez isso...</span>
        </h2>
        <div class="loop-center-pulse"></div>
      </div>

      <!-- 6 itens em volta -->
      <div class="loop-item loop-item-0">
        <div class="loop-emoji">📱</div>
        <strong>Você recebe uma mensagem</strong>
        <p>Curta, simples. Mas algo te incomoda.</p>
      </div>
      <div class="loop-item loop-item-1">
        <div class="loop-emoji">🔄</div>
        <strong>Relê mais de uma vez</strong>
        <p>Na primeira parece ok. Na terceira já parece outra coisa...</p>
      </div>
      <div class="loop-item loop-item-2">
        <div class="loop-emoji">📲</div>
        <strong>Manda pro grupo</strong>
        <p>"O que ele(a) quis dizer com isso?"</p>
      </div>
      <div class="loop-item loop-item-3">
        <div class="loop-emoji">🤔</div>
        <strong>Cada amigo diz uma coisa</strong>
        <p>"Gosta!" / "Não presta" / "Manda mensagem!"</p>
      </div>
      <div class="loop-item loop-item-4">
        <div class="loop-emoji">💭</div>
        <strong>Ainda pensa quando dorme</strong>
        <p>Adormece pensando. Acorda pensando.</p>
      </div>
      <div class="loop-item loop-item-5">
        <div class="loop-emoji">❓</div>
        <strong>E ainda não sabe</strong>
        <p>Porque você está dentro. É impossível ser imparcial.</p>
      </div>

    </div>
  </div>
</section>

<!-- ─── DIFERENCIAL: não é IA genérica ─────────────────────── -->
<section class="section-pad diff-section">
  <div class="container">
    <div class="reveal" style="text-align:center">
      <span class="tag">// você já até perguntou para IA, né?</span>
      <h2 class="section-title">
        <span>Interpretar mensagens do crush</span><br class="br-m-hide"> <span class="grad">com IA genérica não funciona.</span>
      </h2>
      <p class="diff-sub reveal">Qualquer pessoa pode perguntar para IA genérica o que uma mensagem significa. Mas a IA genérica não foi treinada para ler relacionamentos — foi treinada para parecer prestativa com qualquer pergunta.</p>
      <p class="diff-contrast reveal" style="margin-bottom:28px">"Talvez". "Depende". "Cada pessoa é diferente!" — sem nenhuma conclusão real sobre a conversa.</p>
    </div>
    <div class="diff-grid">
      <div class="diff-card reveal">
        <div class="diff-icon">◈</div>
        <h3 class="diff-card-title">IA genérica evita se comprometer</h3>
        <p class="diff-card-desc">Não foi treinada para analisar relacionamentos — então sempre diz "talvez" e "depende do contexto".</p>
      </div>
      <div class="diff-card reveal" style="transition-delay:.08s">
        <div class="diff-icon">◈</div>
        <h3 class="diff-card-title">Amigos são parciais por natureza</h3>
        <p class="diff-card-desc">Querem te ver feliz. Ou te proteger. De qualquer forma, não são imparciais — e isso distorce a análise.</p>
      </div>
      <div class="diff-card reveal" style="transition-delay:.16s">
        <div class="diff-icon">◈</div>
        <h3 class="diff-card-title">ScanCrush foi treinado para isso</h3>
        <p class="diff-card-desc">Observa os padrões presentes na conversa e entrega uma leitura estruturada: score de engajamento observado, sinais e pontos de atenção.</p>
      </div>
    </div>
  </div>
</section>

<!-- ─── REPORT PREVIEW ───────────────────────────────────────── -->
<section class="section-pad" id="b-report" style="background:radial-gradient(ellipse at 50% 0%, rgba(155,93,229,0.06) 0%, transparent 70%);">
  <div class="container">
    <div class="report-grid">

      <div class="reveal">
        <div class="report-mock">
          <div class="rm-header">
            <span class="rm-title">{{ t.report.mock_title }}</span>
            <span class="rm-date">{{ t.report.mock_confidential }}</span>
          </div>
          <div class="rm-score-row">
            <div class="rm-big-score">73<sup>/100</sup></div>
            <div class="rm-score-right">
              <div style="font-size:10px;font-family:var(--mono);color:var(--text-2);text-transform:uppercase;letter-spacing:.1em;margin-bottom:7px">{{ t.report.mock_score_label }}</div>
              <div class="rm-bar-track"><div class="rm-bar-fill"></div></div>
              <div class="rm-bar-labels">
                <span>{{ t.report.mock_bar_low }}</span>
                <span>{{ t.report.mock_bar_mid }}</span>
                <span>{{ t.report.mock_bar_high }}</span>
              </div>
            </div>
          </div>
          <div class="rm-verdict">{{ t.report.mock_verdict }}</div>
          <div class="rm-flags">
            <div class="rm-flags-label r">{{ t.report.mock_neg_label }}</div>
            <span class="rm-tag r">{{ t.report.mock_neg1 }}</span>
            <span class="rm-tag r">{{ t.report.mock_neg2 }}</span>
          </div>
          <div class="rm-flags">
            <div class="rm-flags-label g">{{ t.report.mock_pos_label }}</div>
            <span class="rm-tag g">{{ t.report.mock_pos1 }}</span>
            <span class="rm-tag g">{{ t.report.mock_pos2 }}</span>
          </div>
          <div class="rm-lock">
            <div class="rm-lock-inner">
              <div style="padding:14px;background:rgba(255,255,255,0.03);border-radius:10px;border:1px solid var(--border);margin-top:4px">
                <div style="font-size:10px;font-family:var(--mono);color:var(--text-2);text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px">{{ t.report.mock_profile_label }}</div>
                <div style="font-size:12px;color:var(--text-2)">{{ t.report.mock_profile_text }}</div>
              </div>
            </div>
            <div class="rm-lock-overlay"><p>{{ t.report.mock_locked }}</p></div>
          </div>
        </div>
      </div>

      <div class="reveal report-copy" style="transition-delay:.12s">
        <span class="tag">// {{ t.report.tag }}</span>
        <h3>
          <span>{{ t.report.title }}</span><br>
          <span class="grad">{{ t.report.title_accent }}</span>
        </h3>
        <p class="lead">{{ t.report.sub }}</p>
        <ul class="feature-list">
          <li><span class="feat-check">✓</span><span>{{ t.report.item1 }}</span></li>
          <li><span class="feat-check">✓</span><span>{{ t.report.item2 }}</span></li>
          <li><span class="feat-check">✓</span><span>{{ t.report.item3 }}</span></li>
          <li><span class="feat-check">✓</span><span>{{ t.report.item4 }}</span></li>
          <li><span class="feat-check">✓</span><span>{{ t.report.item5 }}</span></li>
        </ul>
        <button class="btn-primary" @click="openPricesModal()">{{ t.report.unlock }}</button>
      </div>
    </div>
  </div>
</section>

<!-- DISCLAIMER -->
<div class="disclaimer-bar">
  <div class="container">
    <div class="disclaimer-inner">{{ t.disclaimer }}</div>
  </div>
</div>

<!-- ─── CONHEÇA A PATTY ──────────────────────────────────────── -->
<section class="section-pad" id="b-patty" style="background:radial-gradient(ellipse at 50% 0%, rgba(155,93,229,0.07) 0%, transparent 70%);">
  <div class="container">
    <div class="reveal" style="max-width:760px;margin:0 auto;text-align:center">
      <span class="tag">// Quem lê a sua conversa</span>
      <h2 class="section-title">Conheça a <span class="grad">Patty</span></h2>
      <p style="font-size:17px;color:var(--text-2);font-weight:300;line-height:1.7;max-width:620px;margin:14px auto 0">
        A Patty olha para os sinais quando a emoção confunde.
      </p>
    </div>

    <div class="reveal patty-layout">
      <div class="patty-photo-wrap">
        <img src="/brand/patty.webp" alt="Patty — a analista virtual do ScanCrush" class="patty-photo" width="440" height="660" loading="lazy" />
      </div>

      <div class="patty-card">
        <p class="patty-p">Quando a gente gosta de alguém, fica difícil ler uma conversa com calma. Um "kkk", uma demora para responder ou um "qualquer dia a gente marca" pode ganhar um peso maior do que realmente tem.</p>
        <p class="patty-p"><strong>A Patty existe para olhar os fatos.</strong></p>
        <p class="patty-p">Ela observa quem inicia, quem sustenta, o que se repete, o que fica no ar e quais sinais aparecem na conversa.</p>
        <p class="patty-p">Identifica padrões, sinais de reciprocidade e pontos de atenção — sem drama, sem julgamento e sem prometer o que ninguém pode garantir.</p>
        <p class="patty-origin">A Patty nasceu de uma história real: a de quem já confundiu atenção com interesse e queria ter tido alguém para olhar a conversa com calma. <NuxtLink to="/sobre">a história por trás do ScanCrush →</NuxtLink></p>

        <div class="patty-not-wrap">
          <p class="patty-not-intro">Para ser bem claro: a Patty não tenta adivinhar sentimentos nem decidir por você.</p>
          <p class="patty-not-label">A Patty não é</p>
          <div class="patty-not-row">
            <span class="patty-not">vidência</span>
            <span class="patty-not">oráculo</span>
            <span class="patty-not">terapia</span>
            <span class="patty-not">aconselhamento profissional</span>
            <span class="patty-not">detector de sentimentos</span>
            <span class="patty-not">promessa de relacionamento</span>
          </div>
        </div>

        <button class="btn-primary patty-cta" @click="scrollToPricing()">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <span>Ver os sinais com a Patty</span>
        </button>
      </div>
    </div>
  </div>
</section>

<!-- ─── PRICING ───────────────────────────────────────────────── -->
<section class="section-pad" id="b-pricing" style="background:radial-gradient(ellipse at 50% 100%, rgba(255,45,107,0.05) 0%, transparent 60%);">
  <div class="container">
    <div class="reveal" style="text-align:center">
      <span class="tag">// {{ t.pricing.tag }}</span>
      <h2 class="section-title">
        <span>{{ t.pricing.title }}</span><br>
        <span class="grad">{{ t.pricing.title_accent }}</span>
      </h2>
    </div>

    <div class="pricing-grid">
      <div class="price-card reveal">
        <div class="price-name">{{ t.pricing.plan0_name }}</div>
        <p class="price-desc">{{ t.pricing.plan0_desc }}</p>
        <div class="price-amount">
          <span class="price-curr" style="color:var(--text-2)">{{ t.pricing.plan0_price_curr }}</span>
          <span class="price-num">{{ t.pricing.plan0_price_num }}</span>
        </div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item1 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item3 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item4 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item5 }}</span></li>
        </ul>
        <button class="btn-price btn-price-paid" @click="goToCheckout('basico')">{{ t.pricing.plan0_cta }}</button>
      </div>

      <div class="price-card featured reveal" style="transition-delay:.08s">
        <div class="popular-badge">{{ t.pricing.popular }}</div>
        <div class="price-name">{{ t.pricing.plan1_name }}</div>
        <p class="price-desc">{{ t.pricing.plan1_desc }}</p>
        <div class="price-amount">
          <span class="price-curr" style="color:var(--text-2)">{{ t.pricing.plan1_price_curr }}</span>
          <span class="price-num">{{ t.pricing.plan1_price_num }}</span>
        </div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item1 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item3 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item4 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item5 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item6 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item7 }}</span></li>
        </ul>
        <button class="btn-price btn-price-featured" @click="goToCheckout('revealed')">{{ t.pricing.plan1_cta }}</button>
      </div>

      <div class="price-card reveal" style="transition-delay:.16s">
        <div class="price-name">{{ t.pricing.plan2_name }}</div>
        <p class="price-desc">{{ t.pricing.plan2_desc }}</p>
        <div class="price-amount">
          <span class="price-curr">{{ t.pricing.plan2_price_curr }}</span>
          <span class="price-num">{{ t.pricing.plan2_price_num }}</span>
        </div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li class="pf-includes">+ {{ t.pricing.plan1_name }}</li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item3 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item4 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item5 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item6 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item7 }}</span></li>
        </ul>
        <button class="btn-price btn-price-paid" @click="goToCheckout('raiox')">{{ t.pricing.plan2_cta }}</button>
      </div>
    </div>
  </div>
</section>

<!-- ─── FAQ ──────────────────────────────────────────────────── -->
<section class="section-pad" id="b-faq">
  <div class="container">
    <div class="reveal" style="text-align:center">
      <span class="tag">// {{ t.faq.tag }}</span>
      <h2 class="section-title">{{ t.faq.title }}</h2>
    </div>

    <div class="faq-list">
      <div v-for="(item, i) in [
        { q: t.faq.q9,  a: t.faq.a9 },
        { q: t.faq.q10, a: t.faq.a10 },
        { q: t.faq.q14, a: t.faq.a14 },
        { q: t.faq.q11, a: t.faq.a11 },
        { q: t.faq.q1,  a: t.faq.a1 },
        { q: t.faq.q3,  a: t.faq.a3 },
        { q: t.faq.q12, a: t.faq.a12 },
        { q: t.faq.q13, a: t.faq.a13 },
        { q: t.faq.q2,  a: t.faq.a2 },
        { q: t.faq.q15, a: t.faq.a15 },
        { q: t.faq.q6,  a: t.faq.a6 },
        { q: t.faq.q8,  a: t.faq.a8 },
        { q: t.faq.q7,  a: t.faq.a7 },
        { q: t.faq.q5,  a: t.faq.a5 },
        { q: t.faq.q16, a: t.faq.a16 },
      ]" :key="i" class="faq-item" :class="{ open: openFaqIndex === i }">
        <button class="faq-btn" @click="toggleFaq(i)">
          <span>{{ item.q }}</span>
          <span class="faq-icon">+</span>
        </button>
        <div class="faq-body"><p>{{ item.a }}</p></div>
      </div>
    </div>
  </div>
</section>

<!-- ─── CTA FINAL ─────────────────────────────────────────────── -->
<section class="section-pad cta-final" style="background:radial-gradient(ellipse at 50% 50%, rgba(255,45,107,0.06) 0%, transparent 65%);">
  <div class="container">
    <div class="cta-final-inner reveal">
      <h2>
        <span>Você já leu essa conversa várias vezes,</span> <span class="grad cta-line2">só ainda não viu do jeito certo.</span>
      </h2>
      <p>Enquanto você fica ruminando, a resposta já está nos prints.</p>
      <button class="btn-primary" style="font-size:17px;padding:18px 40px" @click="scrollToPricing()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <span>Ver o que isso realmente significa</span>
      </button>
      <p class="cta-hint">{{ t.cta_final.hint }}</p>
    </div>
  </div>
</section>

<!-- ─── FOOTER ────────────────────────────────────────────────── -->
<footer>
  <div class="container">
    <div class="footer-row">
      <div>
        <div class="logo">
          <svg width="20" height="20" viewBox="0 0 28 28" fill="none">
            <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
            <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
          </svg>
          <span class="logo-word">Scan<span>Crush</span></span>
        </div>
        <p class="footer-tagline">{{ t.footer.tagline }}</p>
      </div>
      <ul class="footer-links">
        <li><a href="#b-how">{{ t.footer.how }}</a></li>
        <li><a href="#b-pricing">{{ t.footer.pricing }}</a></li>
        <li class="footer-hide-m"><NuxtLink to="/sobre">Sobre</NuxtLink></li>
        <li class="footer-hide-m"><a href="#b-faq">{{ t.footer.faq }}</a></li>
        <li><NuxtLink to="/privacy">{{ t.footer.privacy }}</NuxtLink></li>
        <li><NuxtLink to="/terms">{{ t.footer.terms }}</NuxtLink></li>
      </ul>
    </div>
    <p class="footer-copy">{{ t.footer.copy }}</p>
  </div>
</footer>

<!-- ─── MODAL ─────────────────────────────────────────────────── -->
<div class="lp-modal-overlay" :class="{ open: isPricesModalOpen }" @click="handlePricesOverlayClick($event)">
  <div class="lp-modal-card">
    <button class="lp-modal-close" @click="closePricesModal()" aria-label="Fechar">×</button>
    <p class="lp-modal-eyebrow">// {{ t.pricing.tag }}</p>
    <h2 class="lp-modal-title">{{ t.pricing.title }} <span class="grad">{{ t.pricing.title_accent }}</span></h2>

    <!-- Espelho exato da seção de planos (#b-pricing) -->
    <div class="lp-modal-plans" style="margin-top:20px">

      <!-- Plan 0: Primeiras Impressões (Free) -->
      <div class="price-card">
        <div class="price-name">{{ t.pricing.plan0_name }}</div>
        <p class="price-desc">{{ t.pricing.plan0_desc }}</p>
        <div class="price-amount">
          <span class="price-curr" style="color:var(--text-2)">{{ t.pricing.plan0_price_curr }}</span>
          <span class="price-num">{{ t.pricing.plan0_price_num }}</span>
        </div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item1 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item3 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item4 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item5 }}</span></li>
        </ul>
        <button class="btn-price btn-price-paid" @click="goToCheckout('basico'); closePricesModal()">{{ t.pricing.plan0_cta }}</button>
      </div>

      <!-- Plan 1: Sinais Revelados (FEATURED) -->
      <div class="price-card featured">
        <div class="popular-badge">{{ t.pricing.popular }}</div>
        <div class="price-name">{{ t.pricing.plan1_name }}</div>
        <p class="price-desc">{{ t.pricing.plan1_desc }}</p>
        <div class="price-amount">
          <span class="price-curr" style="color:var(--text-2)">{{ t.pricing.plan1_price_curr }}</span>
          <span class="price-num">{{ t.pricing.plan1_price_num }}</span>
        </div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item1 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item3 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item4 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item5 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item6 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item7 }}</span></li>
        </ul>
        <button class="btn-price btn-price-featured" @click="goToCheckout('revealed')">{{ t.pricing.plan1_cta }}</button>
      </div>

      <!-- Plan 2: Raio-X do Crush -->
      <div class="price-card">
        <div class="price-name">{{ t.pricing.plan2_name }}</div>
        <p class="price-desc">{{ t.pricing.plan2_desc }}</p>
        <div class="price-amount">
          <span class="price-curr">{{ t.pricing.plan2_price_curr }}</span>
          <span class="price-num">{{ t.pricing.plan2_price_num }}</span>
        </div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li class="pf-includes">+ {{ t.pricing.plan1_name }}</li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item3 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item4 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item5 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item6 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item7 }}</span></li>
        </ul>
        <button class="btn-price btn-price-paid" @click="goToCheckout('raiox')">{{ t.pricing.plan2_cta }}</button>
      </div>

    </div>

    <p class="lp-modal-guarantee">🔒 Pagamento seguro · acesso imediato · uso único</p>
  </div>
</div>
</template>

<style>
/* ─── CONHEÇA A PATTY ─────────────────────────────────────────── */
.patty-layout {
  display: flex;
  align-items: center;
  gap: 38px;
  max-width: 900px;
  margin: 34px auto 0;
}
.patty-photo-wrap {
  flex-shrink: 0;
  position: relative;
  width: 270px;
}
.patty-photo-wrap::after {
  content: '';
  position: absolute;
  inset: -24px;
  background: radial-gradient(ellipse at center, rgba(255,45,107,0.22), transparent 68%);
  z-index: -1;
}
.patty-photo {
  width: 100%;
  height: auto;
  display: block;
  border-radius: 18px;
  border: 1px solid rgba(255,45,107,0.25);
  box-shadow: 0 24px 60px rgba(0,0,0,0.45);
}
.patty-card {
  flex: 1;
  background: var(--card);
  border: 1px solid rgba(155,93,229,0.20);
  border-radius: var(--r);
  padding: 28px 26px;
}
.patty-p { font-size: 15px; color: var(--text-2); font-weight: 300; line-height: 1.8; margin-bottom: 16px; }
.patty-p strong { color: var(--text); font-weight: 600; }
.patty-origin { font-size: 13.5px; color: var(--text-3); font-style: italic; line-height: 1.7; margin-bottom: 20px; }
.patty-origin a { color: var(--purple); text-decoration: none; font-style: normal; font-weight: 600; }
.patty-not-wrap { margin-top: 20px; background: rgba(155,93,229,0.05); border: 1px solid rgba(155,93,229,0.16); border-radius: 14px; padding: 16px 18px; }
.patty-not-intro { font-size: 13.5px; color: var(--text-2); line-height: 1.6; margin-bottom: 12px; }
.patty-not-label { font-size: 10.5px; font-family: var(--mono); text-transform: uppercase; letter-spacing: 0.08em; color: var(--text-3); margin-bottom: 9px; }
.patty-not-row { display: flex; flex-wrap: wrap; gap: 8px; }
.patty-cta { width: 100%; justify-content: center; margin-top: 22px; }
.patty-not {
  font-size: 12px;
  color: var(--text-2);
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 100px;
  padding: 5px 13px;
  white-space: nowrap;
}
@media (max-width: 760px) {
  .patty-layout { flex-direction: column; gap: 24px; }
  .patty-photo-wrap { width: 200px; }
  .patty-not-row { justify-content: center; }
  .patty-card { text-align: center; }
  .patty-not-wrap { text-align: center; }
}

/* ─── CTA FINAL — fonte menor que o padrão global ────────────── */
.cta-final h2 {
  font-size: clamp(26px, 3.8vw, 44px);
}

/* ─── LOOP MENTAL CIRCLE ─────────────────────────────────────── */
.loop-wrap {
  position: relative;
  width: 640px;
  height: 640px;
  margin: 0 auto;
}

/* trilha SVG de fundo */
.loop-track {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

/* centro */
.loop-center {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  width: 200px;
  z-index: 2;
}
.loop-center-tag {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.14em;
  color: var(--pink);
  text-transform: uppercase;
  margin-bottom: 10px;
  opacity: 0.7;
}
.loop-center-title {
  font-size: 32px;
  font-weight: 800;
  line-height: 1.15;
  letter-spacing: -1px;
}
.loop-center-pulse {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--pink);
  margin: 14px auto 0;
  animation: loopPulse 2s ease-in-out infinite;
  box-shadow: 0 0 0 0 rgba(255,45,107,0.5);
}
@keyframes loopPulse {
  0%   { box-shadow: 0 0 0 0 rgba(255,45,107,0.5); }
  70%  { box-shadow: 0 0 0 10px rgba(255,45,107,0); }
  100% { box-shadow: 0 0 0 0 rgba(255,45,107,0); }
}

/* itens ao redor — posicionados por CSS custom properties */
.loop-item {
  position: absolute;
  width: 148px;
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 14px 14px 12px;
  text-align: center;
  transition: border-color 0.25s, transform 0.25s, background 0.25s;
  /* centraliza o item no ponto do círculo */
  transform: translate(-50%, -50%);
  top: var(--ly);
  left: var(--lx);
}
.loop-item:hover {
  border-color: rgba(255,45,107,0.35);
  background: var(--card-hi);
  transform: translate(-50%, -50%) scale(1.05);
  z-index: 3;
}
.loop-emoji {
  font-size: 22px;
  margin-bottom: 8px;
  line-height: 1;
}
.loop-item strong {
  display: block;
  font-size: 12px;
  font-weight: 700;
  color: var(--text);
  margin-bottom: 5px;
  line-height: 1.35;
}
.loop-item p {
  font-size: 11px;
  color: var(--text-2);
  line-height: 1.5;
  font-weight: 300;
}

/*
  6 itens a 60° de intervalo, começando do topo (270° = -90°).
  raio = 225px, centro = 50% (320px)
  fórmula: x = 50% + r*cos(angle), y = 50% + r*sin(angle)
  angles (em graus, 0 = direita, sentido horário):
    item 0: 270° → topo     → cos=-ε,  sin=-1   → x=50%,       y=50%-225
    item 1: 330° → top-dir  → cos=0.87, sin=-0.5 → x=50%+195,  y=50%-112
    item 2:  30° → bot-dir  → cos=0.87, sin=0.5  → x=50%+195,  y=50%+112
    item 3:  90° → baixo    → cos=0,   sin=1     → x=50%,       y=50%+225
    item 4: 150° → bot-esq  → cos=-0.87,sin=0.5  → x=50%-195,  y=50%+112
    item 5: 210° → top-esq  → cos=-0.87,sin=-0.5 → x=50%-195,  y=50%-112
*/
.loop-item-0 { --lx: 50%;       --ly: calc(50% - 225px); }
.loop-item-1 { --lx: calc(50% + 195px); --ly: calc(50% - 112px); }
.loop-item-2 { --lx: calc(50% + 195px); --ly: calc(50% + 112px); }
.loop-item-3 { --lx: 50%;       --ly: calc(50% + 225px); }
.loop-item-4 { --lx: calc(50% - 195px); --ly: calc(50% + 112px); }
.loop-item-5 { --lx: calc(50% - 195px); --ly: calc(50% - 112px); }

/* ─── RESPONSIVO ─────────────────────────────────────────────── */
@media (max-width: 700px) {
  .loop-wrap {
    width: 100%;
    height: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 34px;            /* espaço maior p/ ver a linha de conexão */
    padding-top: 0;
  }
  .loop-track { display: none; }
  .loop-center {
    position: static;
    transform: none;
    width: auto;
    margin: 0 auto 16px;
  }
  .loop-center-pulse { display: none; }
  .loop-item {
    position: relative;   /* p/ ancorar o conector pontilhado */
    /* zera o posicionamento absoluto do desktop (top/left vinham das vars) */
    top: auto;
    left: auto;
    right: auto;
    bottom: auto;
    transform: none;
    margin: 0 auto;       /* coluna única centralizada na tela */
    width: 100%;
    max-width: 360px;
    text-align: left;
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 16px;
  }
  /* Linha pontilhada vertical centralizada ligando um card ao próximo */
  .loop-item:not(:last-child)::after {
    content: '';
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    width: 0;
    height: 34px;
    border-left: 2px dashed var(--pink);
    opacity: 0.45;
  }
  .loop-item:hover { transform: none; }
  .loop-emoji { margin-bottom: 0; flex-shrink: 0; }
  .loop-item strong { margin-bottom: 3px; }
}
</style>
