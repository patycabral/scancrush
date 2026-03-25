<script setup lang="ts">
useHead({
  title: 'ScanCrush — Seus sentimentos são válidos. A análise também.',
  meta: [
    { name: 'description', content: 'Cole a conversa com o seu crush e descubra o que realmente está escondido nas mensagens. Análise emocional clara e direta.' }
  ]
})

const { t } = useAppI18n()

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
        <li><a href="#how">{{ t.nav.how }}</a></li>
        <li><a href="#report">{{ t.nav.report }}</a></li>
        <li><a href="#pricing">{{ t.nav.pricing }}</a></li>
      </ul>

      <div class="nav-right">
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
          <div class="hero-urgency">
            <span>{{ t.hero.cta_hint_urgent }}</span>
          </div>
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


