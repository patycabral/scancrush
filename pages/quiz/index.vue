<script setup lang="ts">
useHead({
  title: 'Quizzes ScanCrush — Descubra o que está acontecendo',
  meta: [
    { name: 'description', content: 'Quizzes rápidos para entender sinais do crush, identificar padrões emocionais e saber o que fazer com a situação que você está vivendo.' },
    { rel: 'canonical', href: 'https://scancrush.com/quiz' },
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

if (import.meta.client) {
  window.addEventListener('keydown', (e) => { if (e.key === 'Escape') closePricesModal() })
}

const quizzes = [
  {
    slug: 'ele-gosta-de-mim',
    tag: '// sinais',
    title: 'Ele gosta de mim ou só está sendo educado?',
    description: 'Responda 7 perguntas sobre o comportamento dele e descubra o que os padrões estão dizendo.',
    tempo: '2 min',
  },
  {
    slug: 'estou-na-friendzone',
    tag: '// zona de amizade',
    title: 'Você está na friendzone ou é insegurança sua?',
    description: '8 perguntas para entender se o que você está sentindo é rejeição real ou só ansiedade.',
    tempo: '3 min',
  },
  {
    slug: 'devo-continuar-insistindo',
    tag: '// decisão',
    title: 'Você deve continuar insistindo ou soltar?',
    description: '6 perguntas honestas que ajudam a decidir se vale continuar investindo ou seguir em frente.',
    tempo: '2 min',
  },
]
</script>

<template>
<div class="quiz-page">
  <div class="quiz-header">
    <NuxtLink to="/" class="quiz-back">← Voltar</NuxtLink>
    <div class="quiz-header-inner">
      <p class="quiz-eyebrow">// descubra agora</p>
      <h1 class="quiz-title">Para de adivinhar.<br><span class="grad">Responde o quiz.</span></h1>
      <p class="quiz-sub">Algumas respostas você consegue em 2 minutos — se fizer as perguntas certas.</p>
    </div>
  </div>

  <div class="quiz-container">
    <div class="quiz-grid">
      <NuxtLink
        v-for="quiz in quizzes"
        :key="quiz.slug"
        :to="`/quiz/${quiz.slug}`"
        class="quiz-card"
      >
        <p class="quiz-card-tag">{{ quiz.tag }}</p>
        <h2 class="quiz-card-title">{{ quiz.title }}</h2>
        <p class="quiz-card-desc">{{ quiz.description }}</p>
        <div class="quiz-card-footer">
          <span class="quiz-card-tempo">⏱ {{ quiz.tempo }}</span>
          <span class="quiz-card-cta">Fazer quiz →</span>
        </div>
      </NuxtLink>
    </div>

    <div class="quiz-scan-cta">
      <p class="scan-cta-eyebrow">// análise aprofundada</p>
      <p class="scan-cta-title">Quiz não basta? Analise a conversa de verdade.</p>
      <p class="scan-cta-sub">Cole o print da conversa, a IA lê os padrões e te dá uma análise personalizada — não genérica.</p>
      <button class="scan-cta-btn" @click="openPricesModal()">Analisar minha conversa →</button>
    </div>
  </div>
</div>

<!-- PLANS MODAL -->
<div class="lp-modal-overlay" :class="{ open: isPricesModalOpen }" @click="handlePricesOverlayClick($event)">
  <div class="lp-modal-card">
    <button class="lp-modal-close" @click="closePricesModal()" aria-label="Fechar">×</button>

    <p class="lp-modal-eyebrow">// {{ t.pricing.tag }}</p>
    <h2 class="lp-modal-title">{{ t.pricing.title }} <span class="grad">{{ t.pricing.title_accent }}</span></h2>

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
        <p class="lp-plan-hook">{{ t.pricing.plan2_hook }}</p>
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

<style scoped>
.quiz-page { min-height: 100vh; background: var(--bg); color: var(--text); font-family: var(--font); }
.quiz-header { padding: 32px 24px 48px; max-width: 680px; margin: 0 auto; }
.quiz-back { font-size: 13px; color: var(--text-3); text-decoration: none; font-family: var(--mono); display: block; margin-bottom: 32px; }
.quiz-back:hover { color: var(--text-2); }
.quiz-eyebrow { font-size: 11px; font-family: var(--mono); color: var(--pink); letter-spacing: .1em; text-transform: uppercase; margin-bottom: 14px; }
.quiz-title { font-size: clamp(28px, 6vw, 48px); font-weight: 800; line-height: 1.1; letter-spacing: -1.5px; margin-bottom: 16px; }
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.quiz-sub { font-size: 16px; color: var(--text-2); line-height: 1.7; }
.quiz-container { max-width: 960px; margin: 0 auto; padding: 0 24px 80px; }
.quiz-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; margin-bottom: 48px; }
.quiz-card { background: var(--card); border: 1px solid var(--border); border-radius: 16px; padding: 24px; text-decoration: none; display: flex; flex-direction: column; gap: 10px; transition: border-color .2s, transform .2s; }
.quiz-card:hover { border-color: rgba(255,45,107,.3); transform: translateY(-2px); }
.quiz-card-tag { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; }
.quiz-card-title { font-size: 17px; font-weight: 700; color: var(--text); line-height: 1.35; letter-spacing: -.3px; }
.quiz-card-desc { font-size: 13px; color: var(--text-2); line-height: 1.6; flex: 1; }
.quiz-card-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 4px; }
.quiz-card-tempo { font-size: 11px; font-family: var(--mono); color: var(--text-3); }
.quiz-card-cta { font-size: 12px; color: var(--pink); font-weight: 600; }
.quiz-scan-cta { background: linear-gradient(135deg, rgba(255,45,107,.07), rgba(155,93,229,.05)); border: 1px solid rgba(255,45,107,.18); border-radius: 20px; padding: 32px 28px; text-align: center; }
.scan-cta-eyebrow { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; margin-bottom: 10px; }
.scan-cta-title { font-size: 20px; font-weight: 800; letter-spacing: -.4px; margin-bottom: 10px; }
.scan-cta-sub { font-size: 14px; color: var(--text-2); line-height: 1.7; margin-bottom: 20px; }
.scan-cta-btn { display: inline-block; background: linear-gradient(135deg, #FF2D6B, #9B5DE5); color: #fff; font-size: 14px; font-weight: 700; padding: 13px 28px; border-radius: 100px; text-decoration: none; transition: opacity .2s; border: none; cursor: pointer; font-family: var(--font); }
.scan-cta-btn:hover { opacity: .88; }
</style>
