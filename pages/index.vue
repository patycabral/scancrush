<script setup lang="ts">
useHead({
  title: 'ScanCrush — Seus sentimentos são válidos. A análise também.',
  meta: [
    { name: 'description', content: 'Cole a conversa com o seu crush e descubra o que realmente está escondido nas mensagens. Análise emocional clara e direta.' }
  ]
})

const { lang, t, setLang } = useAppI18n()

// ── Kiwify checkout URLs (TODO: fill in real URLs before launch) ──
const KIWIFY_URLS = {
  basic:    'https://pay.kiwify.com.br/lksicGT',
  revealed: 'https://pay.kiwify.com.br/9er8Nn9',
  raiox:    'https://pay.kiwify.com.br/ZYqerZF',
}

function goToCheckout(plan: 'basic' | 'revealed' | 'raiox') {
  if (import.meta.client) window.location.href = KIWIFY_URLS[plan]
}

// ── Plans modal (opens for paid CTAs on landing) ──
const isPricesModalOpen = ref(false)

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

// FAQ accordion
const openFaqIndex = ref<number | null>(null)
function toggleFaq(i: number) {
  openFaqIndex.value = openFaqIndex.value === i ? null : i
}

// Navbar scroll
const navScrolled = ref(false)
function onScroll() {
  navScrolled.value = window.scrollY > 30
}
onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  window.addEventListener('keydown', (e) => { if (e.key === 'Escape') closePricesModal() })

  // Scroll reveal
  const reveals = document.querySelectorAll('.reveal')
  const io = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        e.target.classList.add('visible')
        io.unobserve(e.target)
      }
    })
  }, { threshold: 0.1 })
  reveals.forEach(el => io.observe(el))
})
onUnmounted(() => {
  window.removeEventListener('scroll', onScroll)
})
</script>

<template>
<!-- Animated background blobs -->
<div class="bg-blobs" aria-hidden="true">
  <div class="blob blob-1"></div>
  <div class="blob blob-2"></div>
  <div class="blob blob-3"></div>
</div>

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
        <li><a href="#how">{{ t.nav.how }}</a></li>
        <li><a href="#report">{{ t.nav.report }}</a></li>
        <li><a href="#pricing">{{ t.nav.pricing }}</a></li>
      </ul>

      <div class="nav-right">
        <div class="lang-switch">
          <button class="lang-btn" :class="{ active: lang === 'pt' }" @click="setLang('pt')">PT</button>
          <button class="lang-btn" :class="{ active: lang === 'en' }" @click="setLang('en')">EN</button>
          <button class="lang-btn" :class="{ active: lang === 'es' }" @click="setLang('es')">ES</button>
        </div>
        <button class="btn-nav" @click="openPricesModal()">{{ t.nav.cta }}</button>
      </div>

      <button class="nav-mobile-btn" aria-label="Menu">
        <span></span><span></span><span></span>
      </button>
    </div>
  </div>
</nav>

<!-- HERO -->
<section class="hero">
  <div class="container">
    <div class="hero-grid">

      <!-- Copy -->
      <div class="hero-inner">
        <div class="hero-eyebrow">{{ t.hero.eyebrow }}</div>

        <h1>
          <span>{{ t.hero.headline }}</span>
          <span class="line2 grad">{{ t.hero.headline_accent }}</span>
        </h1>

        <p class="hero-sub">
          {{ t.hero.sub }}
        </p>

        <div class="hero-actions">
          <button class="btn-primary" @click="openPricesModal()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <span>{{ t.hero.cta_primary }}</span>
          </button>
        </div>

        <div class="hero-urgency">
          <span>{{ t.hero.cta_hint_urgent }}</span>
        </div>
      </div>


      <!-- Visual -->
      <div class="hero-visual">
        <div style="position:relative; overflow:visible; isolation:isolate">
          <div class="float-tag float-tag-1">{{ t.hero.mock_signals }}</div>

          <div class="chat-card">
            <div class="chat-scan-line"></div>

            <div class="chat-header">
              <div class="chat-avatar"></div>
              <div>
                <div class="chat-name">Lucas ✦</div>
                <div class="chat-status">{{ t.hero.mock_seen }}</div>
              </div>
            </div>

            <div class="chat-messages">
              <div class="msg them">{{ t.hero.mock_chat1 }}</div>
              <div class="msg me">{{ t.hero.mock_chat2 }}</div>
              <div class="msg them">{{ t.hero.mock_chat3 }}</div>
              <div class="msg them">{{ t.hero.mock_chat4 }}</div>
            </div>

            <div class="analysis-badge">
              <div class="ab-label">{{ t.hero.mock_label }}</div>
              <div class="ab-signals">
                <div class="ab-signal"><span class="ab-dot r"></span><span>{{ t.hero.mock_sig1 }}</span></div>
                <div class="ab-signal"><span class="ab-dot r"></span><span>{{ t.hero.mock_sig2 }}</span></div>
                <div class="ab-signal"><span class="ab-dot g"></span><span>{{ t.hero.mock_sig3 }}</span></div>
              </div>
            </div>
          </div>

          <div class="float-tag float-tag-2">{{ t.hero.mock_done }}</div>
        </div>
      </div>

    </div>
  </div>
</section>

<!-- HOW IT WORKS -->
<section class="section-pad" id="how">
  <div class="container">
    <div class="reveal" style="text-align:center; max-width:520px; margin:0 auto">
      <span class="tag">// {{ t.how.tag }}</span>
      <h2 class="section-title">
        <span>{{ t.how.title }}</span><br>
        <span class="grad">{{ t.how.title_accent }}</span>
      </h2>
    </div>

    <div class="how-grid">
      <div class="how-card reveal">
        <div class="how-num">01</div>
        <div class="how-icon">💬</div>
        <h3>{{ t.how.step1_title }}</h3>
        <p>{{ t.how.step1_desc }}</p>
      </div>
      <div class="how-card reveal" style="transition-delay:.1s">
        <div class="how-num">02</div>
        <div class="how-icon">🧠</div>
        <h3>{{ t.how.step2_title }}</h3>
        <p>{{ t.how.step2_desc }}</p>
      </div>
      <div class="how-card reveal" style="transition-delay:.2s">
        <div class="how-num">03</div>
        <div class="how-icon">✦</div>
        <h3>{{ t.how.step3_title }}</h3>
        <p>{{ t.how.step3_desc }}</p>
      </div>
    </div>
  </div>
</section>

<!-- REPORT PREVIEW -->
<section class="section-pad" id="report" style="background:radial-gradient(ellipse at 50% 0%, rgba(155,93,229,0.06) 0%, transparent 70%);">
  <div class="container">
    <div class="report-grid">

      <!-- Mock -->
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

          <!-- Locked preview -->
          <div class="rm-lock">
            <div class="rm-lock-inner">
              <div style="padding:14px;background:rgba(255,255,255,0.03);border-radius:10px;border:1px solid var(--border);margin-top:4px">
                <div style="font-size:10px;font-family:var(--mono);color:var(--text-2);text-transform:uppercase;letter-spacing:.1em;margin-bottom:6px">{{ t.report.mock_profile_label }}</div>
                <div style="font-size:12px;color:var(--text-2)">{{ t.report.mock_profile_text }}</div>
              </div>
            </div>
            <div class="rm-lock-overlay">
              <p>{{ t.report.mock_locked }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Copy -->
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
    <div class="disclaimer-inner">
      {{ t.disclaimer }}
    </div>
  </div>
</div>

<!-- DIFERENCIAÇÃO: Não é IA genérica -->
<section class="section-pad diff-section">
  <div class="container">
    <div class="reveal" style="text-align:center">
      <span class="tag">// {{ t.differentiator.tag }}</span>
      <h2 class="section-title">
        <span>{{ t.differentiator.title }}</span><br>
        <span class="grad">{{ t.differentiator.title_accent }}</span>
      </h2>
      <p class="diff-sub reveal">{{ t.differentiator.sub }}</p>
      <p class="diff-contrast reveal">{{ t.differentiator.contrast }}</p>
    </div>
    <div class="diff-grid">
      <div class="diff-card reveal">
        <div class="diff-icon">◈</div>
        <h3 class="diff-card-title">{{ t.differentiator.point1_title }}</h3>
        <p class="diff-card-desc">{{ t.differentiator.point1_desc }}</p>
      </div>
      <div class="diff-card reveal" style="transition-delay:.08s">
        <div class="diff-icon">◈</div>
        <h3 class="diff-card-title">{{ t.differentiator.point2_title }}</h3>
        <p class="diff-card-desc">{{ t.differentiator.point2_desc }}</p>
      </div>
      <div class="diff-card reveal" style="transition-delay:.16s">
        <div class="diff-icon">◈</div>
        <h3 class="diff-card-title">{{ t.differentiator.point3_title }}</h3>
        <p class="diff-card-desc">{{ t.differentiator.point3_desc }}</p>
      </div>
    </div>
  </div>
</section>

<!-- PRICING -->
<section class="section-pad" id="pricing" style="background:radial-gradient(ellipse at 50% 100%, rgba(255,45,107,0.05) 0%, transparent 60%);">
  <div class="container">
    <div class="reveal" style="text-align:center">
      <span class="tag">// {{ t.pricing.tag }}</span>
      <h2 class="section-title">
        <span>{{ t.pricing.title }}</span><br>
        <span class="grad">{{ t.pricing.title_accent }}</span>
      </h2>
    </div>

    <div class="pricing-grid">

      <!-- Free -->
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

      <!-- Plan 1 -->
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

      <!-- Plan 2 (featured) -->
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

      <!-- Plan 3 -->
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

<!-- FAQ -->
<section class="section-pad" id="faq">
  <div class="container">
    <div class="reveal" style="text-align:center">
      <span class="tag">// {{ t.faq.tag }}</span>
      <h2 class="section-title">{{ t.faq.title }}</h2>
    </div>

    <div class="faq-list">
      <div class="faq-item" :class="{ open: openFaqIndex === 0 }">
        <button class="faq-btn" @click="toggleFaq(0)">
          <span>{{ t.faq.q1 }}</span>
          <span class="faq-icon">+</span>
        </button>
        <div class="faq-body"><p>{{ t.faq.a1 }}</p></div>
      </div>
      <div class="faq-item" :class="{ open: openFaqIndex === 1 }">
        <button class="faq-btn" @click="toggleFaq(1)">
          <span>{{ t.faq.q2 }}</span>
          <span class="faq-icon">+</span>
        </button>
        <div class="faq-body"><p>{{ t.faq.a2 }}</p></div>
      </div>
      <div class="faq-item" :class="{ open: openFaqIndex === 2 }">
        <button class="faq-btn" @click="toggleFaq(2)">
          <span>{{ t.faq.q3 }}</span>
          <span class="faq-icon">+</span>
        </button>
        <div class="faq-body"><p>{{ t.faq.a3 }}</p></div>
      </div>
      <div class="faq-item" :class="{ open: openFaqIndex === 3 }">
        <button class="faq-btn" @click="toggleFaq(3)">
          <span>{{ t.faq.q4 }}</span>
          <span class="faq-icon">+</span>
        </button>
        <div class="faq-body"><p>{{ t.faq.a4 }}</p></div>
      </div>
      <div class="faq-item" :class="{ open: openFaqIndex === 4 }">
        <button class="faq-btn" @click="toggleFaq(4)">
          <span>{{ t.faq.q5 }}</span>
          <span class="faq-icon">+</span>
        </button>
        <div class="faq-body"><p>{{ t.faq.a5 }}</p></div>
      </div>
      <div class="faq-item" :class="{ open: openFaqIndex === 5 }">
        <button class="faq-btn" @click="toggleFaq(5)">
          <span>{{ t.faq.q6 }}</span>
          <span class="faq-icon">+</span>
        </button>
        <div class="faq-body"><p>{{ t.faq.a6 }}</p></div>
      </div>
    </div>
  </div>
</section>

<!-- FINAL CTA -->
<section class="section-pad cta-final" style="background:radial-gradient(ellipse at 50% 50%, rgba(255,45,107,0.06) 0%, transparent 65%);">
  <div class="container">
    <div class="cta-final-inner reveal">
      <h2>
        <span>{{ t.cta_final.title }}</span><br>
        <span class="grad">{{ t.cta_final.title_accent }}</span>
      </h2>
      <p>{{ t.cta_final.sub }}</p>
      <button class="btn-primary" style="font-size:17px;padding:18px 40px" @click="openPricesModal()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <span>{{ t.cta_final.btn }}</span>
      </button>
      <p class="cta-hint">{{ t.cta_final.hint }}</p>
    </div>
  </div>
</section>

<!-- FOOTER -->
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
        <li><a href="#how">{{ t.footer.how }}</a></li>
        <li><a href="#pricing">{{ t.footer.pricing }}</a></li>
        <li><a href="#faq">{{ t.footer.faq }}</a></li>
        <li><NuxtLink to="/privacy">{{ t.footer.privacy }}</NuxtLink></li>
        <li><NuxtLink to="/terms">{{ t.footer.terms }}</NuxtLink></li>
      </ul>
    </div>
    <p class="footer-copy">{{ t.footer.copy }}</p>
  </div>
</footer>

<!-- ══════════════════════════════════════════════════ -->
<!-- PLANS MODAL (landing page — paid plans only) -->
<!-- ══════════════════════════════════════════════════ -->
<div class="lp-modal-overlay" :class="{ open: isPricesModalOpen }" @click="handlePricesOverlayClick($event)">
  <div class="lp-modal-card">

    <button class="lp-modal-close" @click="closePricesModal()" aria-label="Fechar">×</button>

    <p class="lp-modal-eyebrow">// {{ t.pricing.tag }}</p>
    <h2 class="lp-modal-title">{{ t.pricing.title }} <span class="grad">{{ t.pricing.title_accent }}</span></h2>
    <p class="lp-modal-sub">{{ t.pricing.plan2_hook }}</p>

    <div class="lp-modal-plans">

      <!-- Plan: Básico -->
      <div class="lp-plan-card">
        <div class="lp-plan-name">{{ t.pricing.plan1_name }}</div>
        <div class="lp-plan-price">
          <span class="lp-curr">{{ t.pricing.plan1_price_curr }}</span>{{ t.pricing.plan1_price_num }}
        </div>
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

      <!-- Plan: Revelados (FEATURED) -->
      <div class="lp-plan-card featured">
        <div class="lp-plan-badge">{{ t.pricing.popular }}</div>
        <div class="lp-plan-name">{{ t.pricing.plan2_name }}</div>
        <div class="lp-plan-price">
          <span class="lp-curr">{{ t.pricing.plan2_price_curr }}</span>{{ t.pricing.plan2_price_num }}
        </div>
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

      <!-- Plan: Raio-X -->
      <div class="lp-plan-card">
        <div class="lp-plan-name">{{ t.pricing.plan3_name }}</div>
        <div class="lp-plan-price">
          <span class="lp-curr">{{ t.pricing.plan3_price_curr }}</span>{{ t.pricing.plan3_price_num }}
        </div>
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
/* ─── TOKENS ─────────────────────────────────────────────────── */
:root {
  --bg:          #07070D;
  --surface:     #0D0D1A;
  --card:        #111120;
  --card-hi:     #16162A;
  --border:      rgba(255,255,255,0.06);
  --border-soft: rgba(255,255,255,0.04);

  --pink:        #FF2D6B;
  --pink-glow:   rgba(255,45,107,0.18);
  --pink-border: rgba(255,45,107,0.28);
  --purple:      #9B5DE5;
  --purple-glow: rgba(155,93,229,0.15);
  --teal:        #00F5D4;
  --amber:       #FFB800;
  --danger:      #FF4D4D;
  --safe:        #00D68F;

  --text:        #EEEEF8;
  --text-2:      #9090B8;
  --text-3:      #4A4A6A;

  --font:        'Sora', sans-serif;
  --mono:        'JetBrains Mono', monospace;

  --r:           18px;
  --r-sm:        10px;
  --glow-pink:   0 0 48px rgba(255,45,107,0.35), 0 0 100px rgba(255,45,107,0.1);
}

/* ─── RESET ──────────────────────────────────────────────────── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body {
  background: var(--bg);
  color: var(--text);
  font-family: var(--font);
  font-size: 16px;
  line-height: 1.65;
  overflow-x: hidden;
  -webkit-font-smoothing: antialiased;
}
a { color: inherit; text-decoration: none; }
button { cursor: pointer; font-family: var(--font); border: none; background: none; }

/* ─── BACKGROUND TEXTURE ─────────────────────────────────────── */
body::before {
  content: '';
  position: fixed;
  inset: 0;
  background:
    radial-gradient(ellipse 80% 60% at 50% -10%, rgba(155,93,229,0.09) 0%, transparent 70%),
    radial-gradient(ellipse 60% 40% at 80% 80%, rgba(255,45,107,0.05) 0%, transparent 60%);
  pointer-events: none;
  z-index: 0;
}
body::after {
  content: '';
  position: fixed;
  inset: 0;
  background-image:
    linear-gradient(rgba(255,255,255,0.012) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.012) 1px, transparent 1px);
  background-size: 64px 64px;
  pointer-events: none;
  z-index: 0;
  mask-image: radial-gradient(ellipse 100% 70% at 50% 0%, black 0%, transparent 100%);
  -webkit-mask-image: radial-gradient(ellipse 100% 70% at 50% 0%, black 0%, transparent 100%);
}

/* ─── UTILITIES ──────────────────────────────────────────────── */
.container {
  max-width: 1120px;
  margin: 0 auto;
  padding: 0 24px;
  position: relative;
  z-index: 1;
}
.grad {
  background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
.section-pad { padding: 100px 0; }
.tag {
  display: inline-block;
  font-family: var(--mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.16em;
  color: var(--pink);
  margin-bottom: 20px;
}
.section-title {
  font-size: clamp(30px, 4vw, 50px);
  font-weight: 800;
  line-height: 1.1;
  letter-spacing: -1.5px;
  margin-bottom: 16px;
}

/* ─── NAVBAR ─────────────────────────────────────────────────── */
.nav {
  position: fixed;
  top: 0; left: 0; right: 0;
  z-index: 100;
  transition: background 0.3s, border-color 0.3s;
}
.nav.scrolled {
  background: rgba(7,7,13,0.88);
  backdrop-filter: blur(28px);
  -webkit-backdrop-filter: blur(28px);
  border-bottom: 1px solid var(--border);
}
.nav-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 68px;
}
.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 20px;
  font-weight: 800;
  letter-spacing: -0.5px;
}
.logo svg { filter: drop-shadow(0 0 7px var(--pink)); }
.logo-word { color: var(--text); }
.logo-word span { color: var(--pink); }

.nav-links {
  display: flex;
  align-items: center;
  gap: 30px;
  list-style: none;
}
.nav-links a {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-2);
  transition: color 0.2s;
}
.nav-links a:hover { color: var(--text); }

.nav-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

/* Language switcher */
.lang-switch {
  display: flex;
  align-items: center;
  background: rgba(255,255,255,0.04);
  border: 1px solid var(--border);
  border-radius: 100px;
  overflow: hidden;
}
.lang-btn {
  padding: 6px 11px;
  font-size: 11px;
  font-weight: 600;
  font-family: var(--mono);
  color: var(--text-3);
  transition: all 0.2s;
  letter-spacing: 0.05em;
  border: none;
  background: none;
  cursor: pointer;
}
.lang-btn:hover { color: var(--text-2); }
.lang-btn.active {
  background: var(--pink);
  color: white;
  border-radius: 100px;
}

.btn-nav {
  padding: 10px 22px;
  background: var(--pink);
  color: white;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 700;
  transition: all 0.2s;
  box-shadow: 0 0 18px rgba(255,45,107,0.3);
  white-space: nowrap;
}
.btn-nav:hover { transform: translateY(-1px); box-shadow: var(--glow-pink); }

.nav-mobile-btn {
  display: none;
  flex-direction: column;
  gap: 5px;
  padding: 8px;
}
.nav-mobile-btn span {
  width: 22px; height: 2px;
  background: var(--text-2);
  border-radius: 2px;
  display: block;
}

/* ─── HERO ───────────────────────────────────────────────────── */
.hero {
  min-height: 100vh;
  display: flex;
  align-items: center;
  padding: 130px 0 80px;
  position: relative;
  z-index: 1;
}
.hero-inner {
  max-width: 740px;
}
.hero-eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(155,93,229,0.1);
  border: 1px solid rgba(155,93,229,0.22);
  border-radius: 100px;
  padding: 7px 16px;
  font-size: 12px;
  font-weight: 500;
  color: var(--purple);
  margin-bottom: 32px;
  animation: fadeUp 0.5s ease both;
}
.hero-eyebrow::before {
  content: '';
  width: 5px; height: 5px;
  border-radius: 50%;
  background: var(--purple);
  animation: blink 2.5s infinite;
}
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.25} }

.hero h1 {
  font-size: clamp(28px, 6vw, 54px);
  line-height: 1.1;
  font-weight: 700;
  max-width: 650px;
  letter-spacing: -2.5px;
  margin-bottom: 26px;
  animation: fadeUp 0.5s 0.08s ease both;
  word-break: break-word;
}
.hero h1 .line2 {
  display: block;
  color: var(--text-2);
  font-weight: 700;
}
.hero-sub {
  font-size: 18px;
  color: var(--text-2);
  font-weight: 300;
  line-height: 1.75;
  max-width: 520px;
  margin-bottom: 44px;
  animation: fadeUp 0.5s 0.16s ease both;
  white-space: pre-line;
}
.hero-sub strong { color: var(--text); font-weight: 500; }

.hero-actions {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  animation: fadeUp 0.5s 0.24s ease both;
}
.btn-primary {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 17px 34px;
  background: linear-gradient(135deg, var(--pink), #D40060);
  color: white;
  border-radius: 100px;
  font-size: 16px;
  font-weight: 700;
  transition: all 0.25s;
  box-shadow: var(--glow-pink), inset 0 1px 0 rgba(255,255,255,0.12);
  position: relative;
  overflow: hidden;
}
.btn-primary::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(255,255,255,0.08), transparent);
  opacity: 0;
  transition: opacity 0.2s;
}
.btn-primary:hover { transform: translateY(-2px); box-shadow: 0 0 70px rgba(255,45,107,0.55), 0 0 140px rgba(255,45,107,0.15); }
.btn-primary:hover::after { opacity: 1; }

.btn-ghost {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 17px 28px;
  border: 1px solid var(--border);
  border-radius: 100px;
  font-size: 15px;
  font-weight: 500;
  color: var(--text-2);
  transition: all 0.2s;
}
.btn-ghost:hover {
  border-color: var(--pink-border);
  color: var(--text);
  background: var(--pink-glow);
}

/* hero visual — floating card */
.hero-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 64px;
  align-items: center;
}
.hero-visual {
  display: flex;
  justify-content: center;
  animation: fadeUp 0.6s 0.18s ease both;
}
.chat-card {
  width: 320px;
  border-radius: 22px;
  background: rgba(16, 16, 32, 0.92);
  border: 1px solid rgba(155,93,229,0.18);
  padding: 24px;
  box-shadow: 0 24px 80px rgba(0,0,0,0.55), 0 0 0 1px rgba(155,93,229,0.06);
  position: relative;
  overflow: hidden;
}
.chat-card::before {
  content: '';
  position: absolute;
  top: -1px; left: -1px; right: -1px;
  height: 2px;
  background: linear-gradient(90deg, transparent, var(--purple), var(--pink), transparent);
}
.chat-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--border);
}
.chat-avatar {
  width: 36px; height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--pink), var(--purple));
  flex-shrink: 0;
}
.chat-name { font-size: 13px; font-weight: 600; }
.chat-status { font-size: 11px; color: var(--text-3); }
.chat-messages { display: flex; flex-direction: column; gap: 10px; margin-bottom: 20px; }
.msg {
  padding: 10px 14px;
  border-radius: 14px;
  font-size: 12px;
  line-height: 1.5;
  max-width: 85%;
}
.msg.them {
  background: rgba(255,255,255,0.06);
  align-self: flex-start;
  border-bottom-left-radius: 4px;
  color: var(--text-2);
}
.msg.me {
  background: rgba(155,93,229,0.18);
  align-self: flex-end;
  border-bottom-right-radius: 4px;
  color: var(--text);
}
.analysis-badge {
  background: rgba(255,45,107,0.08);
  border: 1px solid var(--pink-border);
  border-radius: 10px;
  padding: 12px;
}
.ab-label {
  font-size: 10px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--pink);
  margin-bottom: 8px;
}
.ab-signals { display: flex; flex-direction: column; gap: 6px; }
.ab-signal {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 11px;
  color: var(--text-2);
}
.ab-dot { width: 6px; height: 6px; border-radius: 50%; flex-shrink: 0; }
.ab-dot.r { background: var(--danger); }
.ab-dot.g { background: var(--safe); }
/* scan line */
.chat-scan-line {
  position: absolute;
  left: 0; right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--teal), transparent);
  top: 0;
  animation: scanDown 4s ease-in-out infinite;
  opacity: 0.5;
}
@keyframes scanDown {
  0% { top: 0; opacity: 0; }
  5% { opacity: 0.5; }
  95% { opacity: 0.5; }
  100% { top: 100%; opacity: 0; }
}
/* float accents */
.float-tag {
  position: absolute;
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 9px 14px;
  font-size: 11px;
  font-family: var(--mono);
  box-shadow: 0 8px 28px rgba(0,0,0,0.4);
}
.float-tag-1 {
  top: -12px; right: -18px;
  color: var(--danger);
  border-color: rgba(255,77,77,0.2);
  animation: floatA 3.5s ease-in-out infinite;
}
.float-tag-2 {
  bottom: 0px; left: -16px;
  color: var(--safe);
  border-color: rgba(0,214,143,0.2);
  animation: floatB 4s ease-in-out infinite;
}
@keyframes floatA { 0%,100%{transform:translateY(0) rotate(-1deg)} 50%{transform:translateY(-9px) rotate(1deg)} }
@keyframes floatB { 0%,100%{transform:translateY(0) rotate(1deg)} 50%{transform:translateY(7px) rotate(-1deg)} }

/* ─── HOW IT WORKS ───────────────────────────────────────────── */
.how-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-top: 56px;
}
.how-card {
  padding: 32px 26px;
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--r);
  transition: border-color 0.3s, transform 0.3s, background 0.3s;
  position: relative;
  overflow: hidden;
}
.how-card::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, var(--purple-glow), transparent 60%);
  opacity: 0;
  transition: opacity 0.3s;
}
.how-card:hover { border-color: rgba(155,93,229,0.25); transform: translateY(-4px); background: var(--card-hi); }
.how-card:hover::before { opacity: 1; }
.how-num {
  font-family: var(--mono);
  font-size: 11px;
  color: var(--text-3);
  letter-spacing: 0.12em;
  margin-bottom: 20px;
  text-transform: uppercase;
}
.how-icon {
  width: 52px; height: 52px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  margin-bottom: 22px;
}
.how-card:nth-child(1) .how-icon { background: rgba(255,45,107,0.1); border: 1px solid rgba(255,45,107,0.18); }
.how-card:nth-child(2) .how-icon { background: rgba(155,93,229,0.1); border: 1px solid rgba(155,93,229,0.18); }
.how-card:nth-child(3) .how-icon { background: rgba(0,245,212,0.08); border: 1px solid rgba(0,245,212,0.15); }
.how-card h3 {
  font-size: 17px;
  font-weight: 700;
  margin-bottom: 10px;
  letter-spacing: -0.3px;
}
.how-card p {
  font-size: 14px;
  color: var(--text-2);
  font-weight: 300;
  line-height: 1.75;
}

/* ─── REPORT SECTION ─────────────────────────────────────────── */
.report-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 56px;
  align-items: center;
  margin-top: 56px;
}
.report-mock {
  border-radius: 22px;
  padding: 28px;
  background: rgba(14, 14, 28, 0.94);
  border: 1px solid rgba(255,45,107,0.18);
  position: relative;
  overflow: hidden;
}
.report-mock::before {
  content: '';
  position: absolute;
  top: -1px; left: -1px; right: -1px;
  height: 2px;
  background: linear-gradient(90deg, transparent, var(--pink), var(--purple), transparent);
}
.rm-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 22px;
  padding-bottom: 18px;
  border-bottom: 1px solid var(--border);
}
.rm-title { font-size: 14px; font-weight: 700; }
.rm-date { font-size: 10px; font-family: var(--mono); color: var(--text-3); }

.rm-score-row {
  display: flex;
  align-items: center;
  gap: 18px;
  margin-bottom: 20px;
}
.rm-big-score {
  font-size: 58px;
  font-weight: 800;
  line-height: 1;
  color: var(--pink);
  text-shadow: 0 0 48px rgba(255,45,107,0.4);
  letter-spacing: -2px;
}
.rm-big-score sup { font-size: 22px; letter-spacing: 0; }
.rm-score-right { flex: 1; }
.rm-bar-track {
  height: 8px;
  background: rgba(255,255,255,0.05);
  border-radius: 100px;
  overflow: hidden;
  margin-bottom: 6px;
}
.rm-bar-fill {
  height: 100%;
  width: 73%;
  border-radius: 100px;
  background: linear-gradient(90deg, var(--safe), var(--amber) 50%, var(--pink) 80%, var(--danger));
}
.rm-bar-labels {
  display: flex;
  justify-content: space-between;
  font-size: 9px;
  font-family: var(--mono);
  color: var(--text-3);
}
.rm-verdict {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px;
  border-radius: 10px;
  background: rgba(255,184,0,0.07);
  border: 1px solid rgba(255,184,0,0.2);
  font-weight: 700;
  font-size: 14px;
  color: var(--amber);
  margin-bottom: 18px;
  letter-spacing: 0.01em;
}

.rm-flags { margin-bottom: 16px; }
.rm-flags-label {
  font-size: 10px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-bottom: 10px;
}
.rm-flags-label.r { color: var(--danger); }
.rm-flags-label.g { color: var(--safe); }
.rm-tag {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 5px 11px;
  border-radius: 100px;
  font-size: 11px;
  margin: 0 5px 7px 0;
}
.rm-tag.r { background: rgba(255,77,77,0.09); border: 1px solid rgba(255,77,77,0.2); color: #FF7777; }
.rm-tag.g { background: rgba(0,214,143,0.09); border: 1px solid rgba(0,214,143,0.2); color: var(--safe); }

/* blur lock */
.rm-lock {
  position: relative;
  margin-top: 14px;
}
.rm-lock-inner {
  filter: blur(5px);
  opacity: 0.45;
  user-select: none;
  pointer-events: none;
}
.rm-lock-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to bottom, transparent, rgba(10,10,22,0.88) 45%, rgba(10,10,22,0.98));
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  padding-bottom: 16px;
  gap: 10px;
  text-align: center;
}
.rm-lock-overlay p { font-size: 12px; color: var(--text-2); }

.report-copy h3 {
  font-size: clamp(26px, 3.5vw, 40px);
  font-weight: 800;
  letter-spacing: -1.2px;
  margin-bottom: 14px;
  line-height: 1.1;
}
.report-copy .lead {
  font-size: 16px;
  color: var(--text-2);
  font-weight: 300;
  line-height: 1.8;
  margin-bottom: 28px;
}
.feature-list { list-style: none; display: flex; flex-direction: column; gap: 13px; margin-bottom: 32px; }
.feature-list li {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  font-size: 14px;
  color: var(--text-2);
  font-weight: 300;
}
.feat-check {
  width: 20px; height: 20px;
  border-radius: 50%;
  background: rgba(0,214,143,0.1);
  border: 1px solid rgba(0,214,143,0.25);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  color: var(--safe);
  flex-shrink: 0;
  margin-top: 2px;
}

/* ─── DISCLAIMER ─────────────────────────────────────────────── */
.disclaimer-bar {
  position: relative;
  z-index: 1;
  padding: 0 0 20px;
  display: flex;
  justify-content: center;
  margin-top: 40px;
}
.disclaimer-inner {
  background: rgba(255,184,0,0.05);
  border-radius: var(--r);
  padding: 18px 24px;
  font-weight: 300;
  line-height: 1.6;
  max-width: 760px;
  margin: 0 auto;
  text-align: center;
  max-width: 600px;
  background: rgba(255, 184, 0, 0.05);
  border: 1px solid rgba(255, 184, 0, 0.2);
  color: #FFB800;
  font-size: 14px;
}

/* ─── PRICING ────────────────────────────────────────────────── */
.pricing-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-top: 56px;
}
.price-card {
  padding: 28px 22px;
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--r);
  display: flex;
  flex-direction: column;
  transition: border-color 0.3s, transform 0.3s;
  position: relative;
}
.price-card:hover { border-color: rgba(255,255,255,0.1); transform: translateY(-3px); }
.price-card.featured {
  background: linear-gradient(160deg, rgba(22, 12, 38, 0.98), rgba(14, 8, 28, 0.98));
  border: 1px solid var(--pink-border);
  box-shadow: 0 0 50px rgba(255,45,107,0.1), 0 20px 48px rgba(0,0,0,0.4);
}
.price-card.featured::before {
  content: '';
  position: absolute;
  top: -1px; left: -1px; right: -1px;
  height: 2px;
  background: linear-gradient(90deg, transparent, var(--pink), var(--purple), transparent);
}
.popular-badge {
  position: absolute;
  top: -11px;
  left: 50%;
  transform: translateX(-50%);
  background: linear-gradient(135deg, var(--pink), var(--purple));
  border-radius: 100px;
  padding: 4px 14px;
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  white-space: nowrap;
}
.price-name {
  font-size: 15px;
  font-weight: 700;
  margin-bottom: 8px;
  letter-spacing: -0.3px;
}
.price-card.featured .price-name { color: var(--pink); }
.price-hook {
  font-size: 11px;
  font-weight: 600;
  color: var(--pink);
  line-height: 1.45;
  margin-bottom: 8px;
  letter-spacing: -0.1px;
}
.price-desc {
  font-size: 12px;
  color: var(--text-2);
  font-weight: 300;
  font-style: italic;
  line-height: 1.6;
  margin-bottom: 20px;
  flex: 0;
}
.price-amount {
  display: flex;
  align-items: baseline;
  gap: 3px;
  margin-bottom: 20px;
}
.price-curr { font-size: 15px; font-weight: 600; color: var(--text-2); }
.price-num {
  font-size: 36px;
  font-weight: 800;
  letter-spacing: -1.5px;
  line-height: 1;
}
.price-card.featured .price-num { color: var(--pink); }
.price-free-tag {
  font-size: 32px;
  font-weight: 800;
  letter-spacing: -1px;
  color: var(--text-2);
  margin-bottom: 20px;
}
.price-divider { height: 1px; background: var(--border); margin-bottom: 20px; }
.price-features { list-style: none; display: flex; flex-direction: column; gap: 9px; margin-bottom: 24px; flex: 1; }
.price-features li {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: 12px;
  color: var(--text-2);
  font-weight: 300;
  line-height: 1.5;
}
.pf-ico { flex-shrink: 0; font-size: 12px; margin-top: 1px; }
.pf-includes {
  font-size: 11px;
  color: var(--pink);
  opacity: 0.8;
  padding-bottom: 5px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  margin-bottom: 2px;
}

.btn-price {
  width: 100%;
  padding: 13px;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 700;
  transition: all 0.2s;
  margin-top: auto;
}
.btn-price-free {
  display: block;
  text-align: center;
  border: 1px solid var(--border);
  color: var(--text-2);
}
.btn-price-free:hover { border-color: var(--purple); color: var(--text); background: var(--purple-glow); }
.btn-price-paid {
  border: 1px solid var(--border);
  color: var(--text-2);
}
.btn-price-paid:hover { border-color: rgba(255,255,255,0.12); color: var(--text); background: rgba(255,255,255,0.04); }
.btn-price-featured {
  background: linear-gradient(135deg, var(--pink), #C0004D);
  color: white;
  box-shadow: 0 0 24px rgba(255,45,107,0.28);
}
.btn-price-featured:hover { transform: translateY(-1px); box-shadow: 0 0 44px rgba(255,45,107,0.5); }

/* ─── DIFFERENTIATOR ─────────────────────────────────────────── */
.diff-section { background: radial-gradient(ellipse at 50% 0%, rgba(155,93,229,0.07) 0%, transparent 60%); }
.hero-urgency {
  margin-top: 12px;
  font-size: 12px;
  font-family: var(--mono);
  color: var(--text-3);
  letter-spacing: 0.04em;
}
.diff-sub {
  max-width: 620px;
  margin: 0 auto 20px;
  color: var(--text-2);
  font-size: 16px;
  line-height: 1.7;
  text-align: center;
}
.diff-contrast {
  text-align: center;
  font-size: 18px;
  font-weight: 700;
  color: var(--text);
  letter-spacing: -0.3px;
  margin-bottom: 52px;
}
.diff-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}
@media (max-width: 768px) { .diff-grid { grid-template-columns: 1fr; } }
.diff-card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--r);
  padding: 32px 28px;
  transition: border-color .2s, transform .2s;
}
.diff-card:hover { border-color: rgba(155,93,229,0.3); transform: translateY(-3px); }
.diff-icon {
  font-size: 26px;
  color: var(--purple);
  margin-bottom: 16px;
  line-height: 1;
}
.diff-card-title {
  font-size: 17px;
  font-weight: 700;
  color: var(--text);
  margin-bottom: 10px;
  letter-spacing: -0.3px;
}
.diff-card-desc {
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.65;
}

/* ─── FAQ ────────────────────────────────────────────────────── */
.faq-list {
  max-width: 680px;
  margin: 56px auto 0;
}
.faq-item { border-bottom: 1px solid var(--border); }
.faq-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 22px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--text);
  text-align: left;
  gap: 16px;
  transition: color 0.2s;
}
.faq-btn:hover { color: var(--pink); }
.faq-icon {
  width: 22px; height: 22px;
  border-radius: 50%;
  border: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  flex-shrink: 0;
  color: var(--text-2);
  transition: all 0.2s;
}
.faq-item.open .faq-icon { border-color: var(--pink); color: var(--pink); transform: rotate(45deg); }
.faq-body { max-height: 0; overflow: hidden; transition: max-height 0.4s ease, padding 0.3s; }
.faq-item.open .faq-body { max-height: 320px; padding-bottom: 22px; }
.faq-body p { font-size: 14px; color: var(--text-2); font-weight: 300; line-height: 1.8; white-space: pre-line; }
.faq-body p strong { color: var(--text); font-weight: 500; }

/* ─── FINAL CTA ──────────────────────────────────────────────── */
.cta-final {
  text-align: center;
  position: relative;
  z-index: 1;
}
.cta-final-inner {
  max-width: 560px;
  margin: 0 auto;
}
.cta-final h2 {
  font-size: clamp(34px, 5vw, 58px);
  font-weight: 800;
  letter-spacing: -2px;
  line-height: 1.08;
  margin-bottom: 18px;
}
.cta-final p {
  font-size: 17px;
  color: var(--text-2);
  font-weight: 300;
  margin-bottom: 40px;
}
.cta-hint { margin-top: 16px; font-size: 12px; color: var(--text-3); }

/* ─── FOOTER ─────────────────────────────────────────────────── */
footer {
  border-top: 1px solid var(--border);
  padding: 52px 0;
  position: relative;
  z-index: 1;
}
.footer-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 32px;
  flex-wrap: wrap;
}
.footer-tagline { font-size: 12px; color: var(--text-3); margin-top: 6px; font-style: italic; }
.footer-links { display: flex; gap: 24px; list-style: none; }
.footer-links a { font-size: 13px; color: var(--text-2); transition: color 0.2s; }
.footer-links a:hover { color: var(--text); }
.footer-copy { font-size: 11px; color: var(--text-3); margin-top: 28px; text-align: center; }

/* ─── BACKGROUND BLOBS ───────────────────────────────────────── */
.bg-blobs {
  position: fixed;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  overflow: hidden;
}
.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(90px);
}
.blob-1 {
  width: 600px; height: 600px;
  background: var(--purple);
  top: -20%; left: -12%;
  opacity: 0.08;
  animation: blobFloat 20s ease-in-out infinite;
}
.blob-2 {
  width: 420px; height: 420px;
  background: var(--pink);
  bottom: 8%; right: -8%;
  opacity: 0.06;
  animation: blobFloat 26s ease-in-out infinite reverse;
  animation-delay: -4s;
}
.blob-3 {
  width: 320px; height: 320px;
  background: var(--teal);
  top: 42%; left: 52%;
  opacity: 0.04;
  animation: blobFloat 32s ease-in-out infinite;
  animation-delay: -10s;
}
@keyframes blobFloat {
  0%,100% { transform: translate(0,0) scale(1); }
  25%  { transform: translate(45px,-55px) scale(1.08); }
  50%  { transform: translate(-30px,25px) scale(0.93); }
  75%  { transform: translate(55px,40px) scale(1.04); }
}

/* ─── ANIMATIONS ─────────────────────────────────────────────── */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
.reveal {
  opacity: 0;
  transform: translateY(28px);
  transition: opacity 0.65s ease, transform 0.65s ease;
}
.reveal.visible { opacity: 1; transform: none; }

/* ─── FLOAT TAGS Z-INDEX FIX ─────────────────────────────────── */
.float-tag { z-index: 10; }
.chat-card { z-index: 1; }

/* ─── RESPONSIVE ─────────────────────────────────────────────── */
@media (max-width: 960px) {
  .hero-grid { grid-template-columns: 1fr; gap: 44px; }
  /* TEXT FIRST on mobile — image after */
  .hero-inner { order: 1; }
  .hero-visual { order: 2; max-width: 380px; margin: 0 auto; width: 100%; }
  .chat-card { width: 100%; max-width: 320px; margin: 0 auto; }
  .how-grid { grid-template-columns: 1fr; }
  .report-grid { grid-template-columns: 1fr; }
  .pricing-grid { grid-template-columns: 1fr 1fr; }
  .nav-links { display: none; }
  .nav-mobile-btn { display: flex; }
}
@media (max-width: 560px) {
  .pricing-grid { grid-template-columns: 1fr; max-width: 360px; margin-left: auto; margin-right: auto; }
  .hero-actions { flex-direction: column; align-items: stretch; width: 100%; }
  .btn-primary { justify-content: center; }
  .float-tag { display: none; }
  .hero h1 { letter-spacing: -1.8px; }
  .nav-right .btn-nav { display: none; }
  .container { padding: 0 18px; }
  .section-pad { padding: 72px 0; }
  .hero-visual { max-width: 300px; }
}

/* ─── PLANS MODAL (landing page) ─────────────────────────── */
.lp-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(7,7,13,0.88);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.25s;
}
.lp-modal-overlay.open {
  opacity: 1;
  pointer-events: auto;
}
.lp-modal-card {
  background: var(--surface);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 24px;
  padding: 28px 32px;
  width: 100%;
  max-width: 1080px;
  max-height: 92vh;
  overflow-y: auto;
  position: relative;
  box-shadow: 0 40px 100px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,45,107,0.08);
}
.lp-modal-close {
  position: absolute;
  top: 16px; right: 20px;
  font-size: 26px;
  color: var(--text-3);
  background: none;
  border: none;
  cursor: pointer;
  line-height: 1;
  transition: color 0.2s;
}
.lp-modal-close:hover { color: var(--text); }
.lp-modal-eyebrow {
  font-size: 11px;
  font-family: var(--mono);
  color: var(--pink);
  letter-spacing: .12em;
  margin-bottom: 10px;
}
.lp-modal-title {
  font-size: 22px;
  font-weight: 800;
  color: var(--text);
  margin-bottom: 8px;
  line-height: 1.25;
}
.lp-modal-sub {
  font-size: 13px;
  color: var(--text-2);
  margin-bottom: 20px;
}
.lp-modal-plans {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}
@media (max-width: 680px) {
  .lp-modal-plans { grid-template-columns: 1fr; }
  .lp-modal-card { padding: 28px 20px; }
}
.lp-plan-card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 18px 16px;
  position: relative;
  transition: border-color 0.2s;
}
.lp-plan-card.featured {
  border-color: var(--pink-border);
  background: linear-gradient(135deg, rgba(255,45,107,0.06) 0%, var(--card) 60%);
}
.lp-plan-badge {
  display: inline-block;
  background: var(--pink);
  color: white;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: .06em;
  padding: 3px 10px;
  border-radius: 100px;
  margin-bottom: 10px;
  text-transform: uppercase;
}
.lp-plan-name {
  font-size: 15px;
  font-weight: 700;
  color: var(--text);
  margin-bottom: 6px;
}
.lp-plan-price {
  font-size: 26px;
  font-weight: 800;
  color: var(--text);
  margin-bottom: 2px;
  line-height: 1;
}
.lp-curr {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-2);
  vertical-align: super;
  margin-right: 2px;
}
.lp-plan-period {
  font-size: 10px;
  font-family: var(--mono);
  color: var(--text-3);
  letter-spacing: .06em;
  text-transform: uppercase;
  margin-bottom: 10px;
}
.lp-plan-desc {
  font-size: 12px;
  color: var(--text-2);
  line-height: 1.5;
  margin-bottom: 14px;
}
.lp-plan-items {
  list-style: none;
  margin-bottom: 18px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.lp-plan-items li {
  font-size: 12px;
  color: var(--text-2);
  padding-left: 16px;
  position: relative;
}
.lp-plan-items li::before {
  content: '✦';
  position: absolute;
  left: 0;
  color: var(--pink);
  font-size: 9px;
}
.lp-plan-item-includes {
  font-size: 11px;
  color: var(--pink);
  opacity: 0.8;
  padding-bottom: 5px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  margin-bottom: 2px;
}
.lp-plan-item-includes::before { display: none; }
.lp-btn-plan {
  width: 100%;
  padding: 12px;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 700;
  font-family: var(--font);
  cursor: pointer;
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(255,255,255,0.05);
  color: var(--text);
  transition: all 0.2s;
}
.lp-btn-plan:hover { background: rgba(255,255,255,0.09); }
.lp-btn-plan.primary {
  background: var(--pink);
  border-color: transparent;
  color: white;
  box-shadow: 0 0 20px rgba(255,45,107,0.3);
}
.lp-btn-plan.primary:hover { box-shadow: var(--glow-pink); transform: translateY(-1px); }
.lp-modal-guarantee {
  text-align: center;
  font-size: 12px;
  font-family: var(--mono);
  color: var(--text-3);
  letter-spacing: .05em;
  margin-bottom: 10px;
}
.lp-modal-free-hint {
  text-align: center;
  font-size: 12px;
  color: var(--text-3);
}
.lp-modal-free-link {
  color: var(--text-2);
  text-decoration: underline;
  text-underline-offset: 3px;
  transition: color 0.2s;
}
.lp-modal-free-link:hover { color: var(--text); }
</style>
