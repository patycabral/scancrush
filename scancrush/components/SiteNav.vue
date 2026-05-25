<script setup lang="ts">
const { t } = useAppI18n()

const CHECKOUT_URLS = {
  revealed: '#',
  raiox:    '#',
}

function goToCheckout(plan: 'revealed' | 'raiox') {
  if (import.meta.client) window.location.href = CHECKOUT_URLS[plan]
}

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

const navScrolled = ref(false)
function onScroll() { navScrolled.value = window.scrollY > 30 }
onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  window.addEventListener('keydown', (e) => { if (e.key === 'Escape') closePricesModal() })
})
onUnmounted(() => window.removeEventListener('scroll', onScroll))
</script>

<template>
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
        <li><a href="/#b-how">Como funciona</a></li>
        <li><a href="/#b-report">O relatório</a></li>
        <li><a href="/#b-pricing">Planos</a></li>
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

<!-- PLANS MODAL -->
<div class="lp-modal-overlay" :class="{ open: isPricesModalOpen }" @click="handlePricesOverlayClick($event)">
  <div class="lp-modal-card">
    <button class="lp-modal-close" @click="closePricesModal()" aria-label="Fechar">×</button>
    <p class="lp-modal-eyebrow">// {{ t.pricing.tag }}</p>
    <h2 class="lp-modal-title">{{ t.pricing.title }} <span class="grad">{{ t.pricing.title_accent }}</span></h2>
    <div class="lp-modal-plans">

      <!-- Plan 0: Primeiras Impressões (Free) -->
      <div class="lp-plan-card">
        <div class="lp-plan-name">{{ t.pricing.plan0_name }}</div>
        <p class="lp-plan-desc">{{ t.pricing.plan0_desc }}</p>
        <div class="lp-plan-free-tag">{{ t.pricing.plan0_free }}</div>
        <ul class="lp-plan-items">
          <li>{{ t.pricing.plan0_item1 }}</li>
          <li>{{ t.pricing.plan0_item2 }}</li>
          <li>{{ t.pricing.plan0_item3 }}</li>
          <li>{{ t.pricing.plan0_item4 }}</li>
          <li>{{ t.pricing.plan0_item5 }}</li>
        </ul>
        <NuxtLink to="/scan" class="lp-btn-plan" style="text-align:center; display:block;" @click="closePricesModal()">{{ t.pricing.plan0_cta }}</NuxtLink>
      </div>

      <!-- Plan 1: Sinais Revelados (FEATURED) -->
      <div class="lp-plan-card featured">
        <div class="lp-plan-badge">{{ t.pricing.popular }}</div>
        <div class="lp-plan-name">{{ t.pricing.plan1_name }}</div>
        <p class="lp-plan-desc">{{ t.pricing.plan1_desc }}</p>
        <div class="lp-plan-price"><span class="lp-curr">{{ t.pricing.plan1_price_curr }}</span>{{ t.pricing.plan1_price_num }}</div>
        <p class="lp-plan-period">pagamento único</p>
        <ul class="lp-plan-items">
          <li>{{ t.pricing.plan1_item1 }}</li>
          <li>{{ t.pricing.plan1_item2 }}</li>
          <li>{{ t.pricing.plan1_item3 }}</li>
          <li>{{ t.pricing.plan1_item4 }}</li>
          <li>{{ t.pricing.plan1_item5 }}</li>
          <li>{{ t.pricing.plan1_item6 }}</li>
          <li>{{ t.pricing.plan1_item7 }}</li>
        </ul>
        <button class="lp-btn-plan primary" @click="goToCheckout('revealed')">{{ t.pricing.plan1_cta }}</button>
      </div>

      <!-- Plan 2: Raio-X do Crush -->
      <div class="lp-plan-card">
        <div class="lp-plan-name">{{ t.pricing.plan2_name }}</div>
        <p class="lp-plan-desc">{{ t.pricing.plan2_desc }}</p>
        <div class="lp-plan-price"><span class="lp-curr">{{ t.pricing.plan2_price_curr }}</span>{{ t.pricing.plan2_price_num }}</div>
        <p class="lp-plan-period">pagamento único</p>
        <ul class="lp-plan-items">
          <li class="lp-plan-item-includes">{{ t.pricing.plan2_item1 }}</li>
          <li>{{ t.pricing.plan2_item2 }}</li>
          <li>{{ t.pricing.plan2_item3 }}</li>
          <li>{{ t.pricing.plan2_item4 }}</li>
          <li>{{ t.pricing.plan2_item5 }}</li>
          <li>{{ t.pricing.plan2_item6 }}</li>
          <li>{{ t.pricing.plan2_item7 }}</li>
        </ul>
        <button class="lp-btn-plan" @click="goToCheckout('raiox')">{{ t.pricing.plan2_cta }}</button>
      </div>

    </div>
    <p class="lp-modal-guarantee">🔒 Pagamento seguro · acesso imediato · uso único</p>
  </div>
</div>
</template>

<style scoped>
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
</style>
