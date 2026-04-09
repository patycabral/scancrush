<script setup lang="ts">
useHead({
  title: 'Como Saber se o Crush Gosta de Mim? IA Analisa a Conversa | ScanCrush',
  meta: [
    { name: 'description',        content: 'Entenda o que as mensagens do seu crush realmente revelam. Nossa IA interpreta os sinais da conversa e te diz se existe interesse de verdade — sem achismo, sem talvez.' },
    { name: 'keywords',           content: 'como saber se o crush gosta de mim, meu crush gosta de mim, interpretar mensagens do crush, sinais do crush no whatsapp, analisar conversa do crush, análise de conversa com IA' },
    { property: 'og:type',        content: 'website' },
    { property: 'og:url',         content: 'https://scancrush.com/' },
    { property: 'og:title',       content: 'Como Saber se o Crush Gosta de Mim? IA Analisa a Conversa | ScanCrush' },
    { property: 'og:description', content: 'Entenda o que as mensagens do seu crush realmente revelam. Nossa IA interpreta os sinais da conversa e te diz se existe interesse de verdade.' },
    { property: 'og:image',       content: 'https://scancrush.com/og-image.png' },
    { name: 'twitter:card',       content: 'summary_large_image' },
    { name: 'twitter:title',      content: 'Como Saber se o Crush Gosta de Mim? | ScanCrush' },
    { name: 'twitter:description', content: 'IA que analisa a conversa com o crush e revela os sinais reais de interesse.' },
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
        url: 'https://scancrush.com/',
        description: 'Descubra como saber se o crush gosta de você analisando a conversa com IA. Sinais reais, score de interesse e conclusão direta — sem achismo.',
        applicationCategory: 'LifestyleApplication',
        operatingSystem: 'Web',
        inLanguage: 'pt-BR',
        offers: [
          { '@type': 'Offer', price: '0', priceCurrency: 'BRL', name: 'Primeiras Impressões — 1 print' },
          { '@type': 'Offer', price: '14.90', priceCurrency: 'BRL', name: 'Sinais Básicos — até 5 prints' },
          { '@type': 'Offer', price: '27.90', priceCurrency: 'BRL', name: 'Sinais Revelados — até 10 prints' },
          { '@type': 'Offer', price: '39.90', priceCurrency: 'BRL', name: 'Raio-X do Crush — até 20 prints' },
        ],
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
            name: 'Como saber se o crush gosta de mim pela conversa?',
            acceptedAnswer: { '@type': 'Answer', text: 'A resposta está nos padrões das mensagens: frequência de resposta, quem inicia o contato, consistência no tom e sinais de distância emocional. Nossa IA analisa esses padrões e entrega um score com sinais concretos de interesse.' },
          },
          {
            '@type': 'Question',
            name: 'Como funciona a análise de conversa do crush?',
            acceptedAnswer: { '@type': 'Answer', text: 'Você envia prints da conversa. Nossa IA identifica padrões emocionais, consistência nas mensagens e sinais que passam despercebidos no calor do momento. O resultado inclui score de interesse, sinais positivos e negativos, e uma conclusão direta.' },
          },
          {
            '@type': 'Question',
            name: 'Minha conversa fica salva em algum lugar?',
            acceptedAnswer: { '@type': 'Answer', text: 'Não. As mensagens são processadas no momento da análise e não ficam armazenadas. Sua privacidade é levada a sério.' },
          },
          {
            '@type': 'Question',
            name: 'A análise de conversa com IA é precisa?',
            acceptedAnswer: { '@type': 'Answer', text: 'É uma análise de padrões, não uma leitura da mente. Ela oferece clareza baseada no que as mensagens revelam — mas a decisão final é sempre sua.' },
          },
          {
            '@type': 'Question',
            name: 'Posso analisar conversa do WhatsApp, Instagram ou Telegram?',
            acceptedAnswer: { '@type': 'Answer', text: 'Sim — conversas de WhatsApp, Instagram DM, Telegram ou qualquer outro app. Quanto mais contexto você fornecer, mais precisa será a análise.' },
          },
          {
            '@type': 'Question',
            name: 'Quantos prints posso enviar para análise?',
            acceptedAnswer: { '@type': 'Answer', text: 'Depende do plano: Gratuito (1 print), Sinais Básicos (até 5 prints), Sinais Revelados (até 10 prints), Raio-X do Crush (até 20 prints). Mais prints permitem uma análise mais profunda e precisa.' },
          },
          {
            '@type': 'Question',
            name: 'O que fazer se não gostar do resultado da análise?',
            acceptedAnswer: { '@type': 'Answer', text: 'Então provavelmente é algo que você já sentia. Só não queria confirmar. A análise revela o que os padrões mostram — a decisão sobre o que fazer é sempre sua.' },
          },
        ],
      }),
    },
  ],
})

const { t } = useAppI18n()

const KIWIFY_URLS = {
  basic:    'https://pay.kiwify.com.br/lksicGT',
  revealed: 'https://pay.kiwify.com.br/9er8Nn9',
  raiox:    'https://pay.kiwify.com.br/ZYqerZF',
}

function goToCheckout(plan: 'basic' | 'revealed' | 'raiox') {
  if (import.meta.client) window.location.href = KIWIFY_URLS[plan]
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
        <li><a href="#b-pricing">Planos</a></li>
        <li><NuxtLink to="/blog">Blog</NuxtLink></li>
      </ul>

      <div class="nav-right">
        <button class="btn-nav" @click="openPricesModal()">Analisar conversa</button>
      </div>

      <button class="nav-mobile-btn" aria-label="Menu">
        <span></span><span></span><span></span>
      </button>
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
          <span>Como saber se o crush gosta de mim</span>
          <span class="line2 grad">pela conversa?</span>
        </h1>

        <p class="hero-sub">
          <b>A resposta está nos padrões das mensagens — não no que você espera ouvir.</b><br>
          Cole os prints da conversa com o seu crush e receba uma análise honesta dos sinais reais de interesse — sem julgamento, sem achismo, sem <em>"talvez"</em>.
        </p>

        <div class="hero-actions">
          <button class="btn-primary" @click="scrollToPricing()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <span>Analisar minha conversa</span>
          </button>
          <div class="hero-urgency">
            <span>⚡ Resultado em segundos · Privacidade garantida</span>
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
          <span>Admite,</span><br>
          <span class="grad">você já<br>fez isso...</span>
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
        <p>"O que ele quis dizer com isso?"</p>
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
      <span class="tag">// você já até perguntou pra IA, né?</span>
      <h2 class="section-title">
        <span>Interpretar mensagens do crush</span><br>
        <span class="grad">com IA genérica não funciona.</span>
      </h2>
      <p class="diff-sub reveal">Qualquer pessoa pode perguntar pra IA genérica o que uma mensagem significa. Mas a IA genérica não foi treinada para ler relacionamentos — foi treinada para parecer prestativa com qualquer pergunta.</p>
      <p class="diff-contrast reveal" style="margin-bottom:28px">"Talvez". "Depende". "Cada pessoa é diferente!" — sem nenhuma conclusão real sobre a conversa.</p>
    </div>
    <div class="diff-grid">
      <div class="diff-card reveal">
        <div class="diff-icon">◈</div>
        <h3 class="diff-card-title">IA genérica evita se comprometer</h3>
        <p class="diff-card-desc">Não foi treinada pra analisar relacionamentos — então sempre diz "talvez" e "depende do contexto".</p>
      </div>
      <div class="diff-card reveal" style="transition-delay:.08s">
        <div class="diff-icon">◈</div>
        <h3 class="diff-card-title">Amigos são parciais por natureza</h3>
        <p class="diff-card-desc">Querem te ver feliz. Ou te proteger. De qualquer forma, não são imparciais — e isso distorce a análise.</p>
      </div>
      <div class="diff-card reveal" style="transition-delay:.16s">
        <div class="diff-icon">◈</div>
        <h3 class="diff-card-title">ScanCrush foi treinado pra isso</h3>
        <p class="diff-card-desc">Lê padrões reais da sua conversa e entrega um score, sinais concretos e uma conclusão direta. Sem rodeios.</p>
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
        <div class="price-free-tag">{{ t.pricing.plan0_free }}</div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item1 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan0_item3 }}</span></li>
        </ul>
        <NuxtLink to="/scan" class="btn-price btn-price-free">{{ t.pricing.plan0_cta }}</NuxtLink>
      </div>

      <div class="price-card reveal" style="transition-delay:.08s">
        <div class="price-name">{{ t.pricing.plan1_name }}</div>
        <p class="price-desc">{{ t.pricing.plan1_desc }}</p>
        <div class="price-amount">
          <span class="price-curr">{{ t.pricing.plan1_price_curr }}</span>
          <span class="price-num">{{ t.pricing.plan1_price_num }}</span>
        </div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item1 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item3 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan1_item4 }}</span></li>
        </ul>
        <button class="btn-price btn-price-paid" @click="goToCheckout('basic')">{{ t.pricing.plan1_cta }}</button>
      </div>

      <div class="price-card featured reveal" style="transition-delay:.16s">
        <div class="popular-badge">{{ t.pricing.popular }}</div>
        <div class="price-name">{{ t.pricing.plan2_name }}</div>
        <p class="price-hook">{{ t.pricing.plan2_hook }}</p>
        <p class="price-desc">{{ t.pricing.plan2_desc }}</p>
        <div class="price-amount">
          <span class="price-curr" style="color:var(--text-2)">{{ t.pricing.plan2_price_curr }}</span>
          <span class="price-num">{{ t.pricing.plan2_price_num }}</span>
        </div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li class="pf-includes">+ {{ t.pricing.plan1_name }}</li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item1 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item3 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item4 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan2_item5 }}</span></li>
        </ul>
        <button class="btn-price btn-price-featured" @click="goToCheckout('revealed')">{{ t.pricing.plan2_cta }}</button>
      </div>

      <div class="price-card reveal" style="transition-delay:.24s">
        <div class="price-name">{{ t.pricing.plan3_name }}</div>
        <p class="price-desc">{{ t.pricing.plan3_desc }}</p>
        <div class="price-amount">
          <span class="price-curr">{{ t.pricing.plan3_price_curr }}</span>
          <span class="price-num">{{ t.pricing.plan3_price_num }}</span>
        </div>
        <div class="price-divider"></div>
        <ul class="price-features">
          <li class="pf-includes">+ {{ t.pricing.plan2_name }}</li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan3_item1 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan3_item2 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan3_item3 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan3_item4 }}</span></li>
          <li><span class="pf-ico">✦</span><span>{{ t.pricing.plan3_item5 }}</span></li>
        </ul>
        <button class="btn-price btn-price-paid" @click="goToCheckout('raiox')">{{ t.pricing.plan3_cta }}</button>
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
        { q: t.faq.q1, a: t.faq.a1 },
        { q: t.faq.q2, a: t.faq.a2 },
        { q: t.faq.q3, a: t.faq.a3 },
        { q: t.faq.q4, a: t.faq.a4 },
        { q: t.faq.q5, a: t.faq.a5 },
        { q: t.faq.q6, a: t.faq.a6 },
        { q: t.faq.q7, a: t.faq.a7 },
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
        <span>Você já leu essa conversa várias vezes,</span><br>
        <span class="grad">só ainda não viu do jeito certo.</span>
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
        <li><a href="#b-faq">{{ t.footer.faq }}</a></li>
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

    <div class="lp-modal-plans">
      <div class="lp-plan-card">
        <div class="lp-plan-name">{{ t.pricing.plan1_name }}</div>
        <div class="lp-plan-price"><span class="lp-curr">{{ t.pricing.plan1_price_curr }}</span>{{ t.pricing.plan1_price_num }}</div>
        <p class="lp-plan-period">pagamento único</p>
        <p class="lp-plan-desc">{{ t.pricing.plan1_desc }}</p>
        <ul class="lp-plan-items">
          <li>{{ t.pricing.plan1_item1 }}</li>
          <li>{{ t.pricing.plan1_item2 }}</li>
          <li>{{ t.pricing.plan1_item3 }}</li>
          <li>{{ t.pricing.plan1_item4 }}</li>
        </ul>
        <button class="lp-btn-plan" @click="goToCheckout('basic')">{{ t.pricing.plan1_cta }}</button>
      </div>

      <div class="lp-plan-card featured">
        <div class="lp-plan-badge">{{ t.pricing.popular }}</div>
        <div class="lp-plan-name">{{ t.pricing.plan2_name }}</div>
        <p class="lp-plan-hook">{{ t.pricing.plan2_hook }}</p>
        <div class="lp-plan-price"><span class="lp-curr">{{ t.pricing.plan2_price_curr }}</span>{{ t.pricing.plan2_price_num }}</div>
        <p class="lp-plan-period">pagamento único</p>
        <p class="lp-plan-desc">{{ t.pricing.plan2_desc }}</p>
        <ul class="lp-plan-items">
          <li class="lp-plan-item-includes">+ {{ t.pricing.plan1_name }}</li>
          <li>{{ t.pricing.plan2_item1 }}</li>
          <li>{{ t.pricing.plan2_item2 }}</li>
          <li>{{ t.pricing.plan2_item3 }}</li>
          <li>{{ t.pricing.plan2_item4 }}</li>
          <li>{{ t.pricing.plan2_item5 }}</li>
        </ul>
        <button class="lp-btn-plan primary" @click="goToCheckout('revealed')">{{ t.pricing.plan2_cta }}</button>
      </div>

      <div class="lp-plan-card">
        <div class="lp-plan-name">{{ t.pricing.plan3_name }}</div>
        <div class="lp-plan-price"><span class="lp-curr">{{ t.pricing.plan3_price_curr }}</span>{{ t.pricing.plan3_price_num }}</div>
        <p class="lp-plan-period">pagamento único</p>
        <p class="lp-plan-desc">{{ t.pricing.plan3_desc }}</p>
        <ul class="lp-plan-items">
          <li class="lp-plan-item-includes">+ {{ t.pricing.plan2_name }}</li>
          <li>{{ t.pricing.plan3_item1 }}</li>
          <li>{{ t.pricing.plan3_item2 }}</li>
          <li>{{ t.pricing.plan3_item3 }}</li>
          <li>{{ t.pricing.plan3_item4 }}</li>
          <li>{{ t.pricing.plan3_item5 }}</li>
        </ul>
        <button class="lp-btn-plan" @click="goToCheckout('raiox')">{{ t.pricing.plan3_cta }}</button>
      </div>
    </div>

    <p class="lp-modal-guarantee">🔒 Pagamento seguro · acesso imediato · uso único</p>
    <p class="lp-modal-free-hint">Quer tentar grátis? <NuxtLink to="/scan" class="lp-modal-free-link" @click="closePricesModal()">Começar com 1 imagem →</NuxtLink></p>
  </div>
</div>
</template>

<style>
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
    gap: 12px;
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
    position: static;
    transform: none;
    width: 100%;
    max-width: 360px;
    text-align: left;
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 16px;
  }
  .loop-item:hover { transform: none; }
  .loop-emoji { margin-bottom: 0; flex-shrink: 0; }
  .loop-item strong { margin-bottom: 3px; }
}
</style>
