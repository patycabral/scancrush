<script setup lang="ts">
useHead({
  title: 'Quiz: Devo continuar insistindo ou soltar? — ScanCrush',
  meta: [
    { name: 'description', content: '6 perguntas honestas que te ajudam a decidir se vale continuar tentando ou se é hora de seguir em frente. Sem julgamento.' },
  ],
  link: [
    { rel: 'canonical', href: 'https://scancrush.com/quiz/devo-continuar-insistindo' },
  ],
})

const questions = [
  {
    q: 'Nas últimas duas semanas, quantas vezes ele(a) apareceu por conta própria (sem você iniciar)?',
    options: [
      { label: 'Nenhuma. Toda conversa começa por mim', value: 0 },
      { label: '1 ou 2 vezes, no máximo', value: 1 },
      { label: 'Algumas vezes — às vezes ele, às vezes eu', value: 2 },
      { label: 'Bastante — ele(a) aparece com frequência', value: 3 },
    ],
  },
  {
    q: 'Você sugeriu se encontrar. O que aconteceu?',
    options: [
      { label: 'Sempre tem uma desculpa — ou fica tão vago que não rola nunca', value: 0 },
      { label: 'Às vezes topa, outras não, sem clareza nenhuma', value: 1 },
      { label: 'Geralmente topa, mesmo que demore um pouco', value: 2 },
      { label: 'Topa e às vezes sugere por conta própria também', value: 3 },
    ],
  },
  {
    q: 'Como você se sente geralmente depois de interagir com ele?',
    options: [
      { label: 'Ansiosa, confusa, mal. Mais mal do que bem', value: 0 },
      { label: 'Uma mistura — nunca totalmente bem, nunca totalmente mal', value: 1 },
      { label: 'Geralmente bem, com alguma dúvida às vezes', value: 2 },
      { label: 'Bem, segura — a situação me faz sentir boa', value: 3 },
    ],
  },
  {
    q: 'Quando você tocou no assunto do que são vocês (direta ou indiretamente), ele:',
    options: [
      { label: 'Desviou, ignorou ou deixou bem claro que não quer nada', value: 0 },
      { label: 'Ficou vago — não disse nada de concreto', value: 1 },
      { label: 'Pareceu receptivo mas não tomou posição', value: 2 },
      { label: 'Reagiu bem ou demonstrou interesse de volta', value: 3 },
    ],
  },
  {
    q: 'Há quanto tempo você está nessa situação sem mudança real?',
    options: [
      { label: 'Mais de 3 meses sem nenhum avanço claro', value: 0 },
      { label: 'Entre 1 e 3 meses em incerteza', value: 1 },
      { label: 'Menos de 1 mês — ainda é cedo', value: 2 },
      { label: 'Houve uma evolução real recente', value: 3 },
    ],
  },
  {
    q: 'Você consegue ser você mesma nessa situação, ou está se segurando o tempo todo?',
    options: [
      { label: 'Estou bem diferente de mim mesma por causa disso — filtro tudo', value: 0 },
      { label: 'Me seguro bastante, com medo de afastar', value: 1 },
      { label: 'Na maior parte do tempo sou eu mesma', value: 2 },
      { label: 'Completamente eu mesma — ele(a) me faz sentir segura', value: 3 },
    ],
  },
]

const results = [
  {
    min: 0, max: 5,
    label: 'Hora de soltar, amiga',
    emoji: '🕊️',
    color: '#60A5FA',
    text: 'Eu sei que não é fácil ler isso. Mas o que você descreveu mostra muito investimento de um lado só, tempo parado sem avanço, e uma situação que está te custando mais do que rendendo. Soltar não é desistir — é parar de gastar energia em algo que não tá correspondendo. Você merece mais que isso.',
  },
  {
    min: 6, max: 10,
    label: 'Avalie com calma antes de decidir',
    emoji: '⚖️',
    color: '#F59E0B',
    text: 'Tem coisas boas, tem coisas que preocupam. Antes de qualquer decisão radical, vale ter mais clareza sobre o que está acontecendo de verdade. Uma conversa honesta com ele(a) — ou uma análise mais profunda da situação — pode ajudar muito mais do que ficar rodando na cabeça.',
  },
  {
    min: 11, max: 15,
    label: 'Ainda tem algo aqui — não solta ainda',
    emoji: '💛',
    color: '#F59E0B',
    text: 'Há reciprocidade suficiente para justificar continuar. O que importa agora é ter clareza sobre o que você quer — e como vai saber se chegou num ponto de virada. Confia no processo, mas também cuida de você no meio disso.',
  },
  {
    min: 16, max: 18,
    label: 'Continua. Os sinais são bons',
    emoji: '💚',
    color: '#34D399',
    text: 'A situação que você descreveu tem reciprocidade, te faz sentir bem e ainda está evoluindo. Não tem por que soltar agora. Continua presente, sem ansiedade — as coisas parecem estar indo bem.',
  },
]

const current = ref(0)
const answers = ref<number[]>([])
const selected = ref<number | null>(null)
const finished = ref(false)

const score = computed(() => answers.value.reduce((a, b) => a + b, 0))
const result = computed(() => results.find(r => score.value >= r.min && score.value <= r.max) ?? results[results.length - 1])
const progress = computed(() => Math.round((current.value / questions.length) * 100))

function select(value: number) { selected.value = value }
function next() {
  if (selected.value === null) return
  answers.value.push(selected.value)
  selected.value = null
  if (current.value < questions.length - 1) { current.value++ } else { finished.value = true }
}
function restart() { current.value = 0; answers.value = []; selected.value = null; finished.value = false }

const CHECKOUT_URLS = { basico: '#', revealed: '#', raiox: '#' }
function goToCheckout(plan: 'basico' | 'revealed' | 'raiox') { if (import.meta.client) window.location.href = CHECKOUT_URLS[plan] }
const isModalOpen = ref(false)
function openModal() { isModalOpen.value = true; if (import.meta.client) document.body.style.overflow = 'hidden' }
function closeModal() { isModalOpen.value = false; if (import.meta.client) document.body.style.overflow = '' }
function handleOverlayClick(e: MouseEvent) { if ((e.target as HTMLElement).classList.contains('lp-modal-overlay')) closeModal() }
if (import.meta.client) window.addEventListener('keydown', (e) => { if (e.key === 'Escape') closeModal() })
</script>

<template>
<div class="quiz-run-page">
  <div class="quiz-run-wrap">
    <NuxtLink to="/quiz" class="quiz-run-back">← Quizzes</NuxtLink>

    <div v-if="!finished && current === 0" class="quiz-intro">
      <p class="quiz-intro-tag">// 6 perguntas · 2 min</p>
      <h1 class="quiz-intro-title">Continua insistindo<br><span class="grad">ou solta de vez?</span></h1>
      <p class="quiz-intro-sub">Responde com honestidade — a resposta pode doer, mas vai valer.</p>
    </div>

    <div v-if="!finished" class="quiz-progress-wrap">
      <div class="quiz-progress-bar"><div class="quiz-progress-fill" :style="{ width: progress + '%' }"></div></div>
      <span class="quiz-progress-label">{{ current + 1 }}/{{ questions.length }}</span>
    </div>

    <div v-if="!finished" class="quiz-question-block">
      <p class="quiz-q-num">pergunta {{ current + 1 }}</p>
      <h2 class="quiz-q-text">{{ questions[current].q }}</h2>
      <div class="quiz-options">
        <button v-for="(opt, i) in questions[current].options" :key="i" class="quiz-option" :class="{ selected: selected === opt.value }" @click="select(opt.value)">
          {{ opt.label }}
        </button>
      </div>
      <button class="quiz-next-btn" :disabled="selected === null" @click="next">
        {{ current < questions.length - 1 ? 'Próxima →' : 'Ver meu resultado →' }}
      </button>
    </div>

    <div v-else class="quiz-result-block">
      <div class="result-card">
        <p class="result-emoji">{{ result.emoji }}</p>
        <p class="result-label" :style="{ color: result.color }">{{ result.label }}</p>
        <p class="result-text">{{ result.text }}</p>
        <div class="result-score-wrap">
          <div class="result-score-bar"><div class="result-score-fill" :style="{ width: (score / 18 * 100) + '%' }"></div></div>
          <p class="result-score-label">seu score: {{ score }}/18</p>
        </div>
      </div>
      <p class="result-upsell-text">Quiz tem limite. A análise da conversa completa não.</p>
      <div class="result-ctas">
        <button class="result-btn-main" @click="openModal()">Analisar a conversa de verdade →</button>
        <div class="result-secondary-links">
          <button class="result-btn-ghost" @click="restart">Refazer</button>
          <NuxtLink to="/quiz" class="result-btn-ghost">Outros quizzes</NuxtLink>
          <NuxtLink to="/blog" class="result-btn-ghost">Ver artigos</NuxtLink>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- PLANS MODAL -->
<div class="lp-modal-overlay" :class="{ open: isModalOpen }" @click="handleOverlayClick($event)">
  <div class="lp-modal-card">
    <button class="lp-modal-close" @click="closeModal()" aria-label="Fechar">×</button>
    <p class="lp-modal-eyebrow">// planos</p>
    <h2 class="lp-modal-title">Escolha sua análise <span class="grad">agora</span></h2>
    <div class="lp-modal-plans">
      <!-- Plan 0: Primeiras Impressões (Free) -->
      <div class="lp-plan-card">
        <div class="lp-plan-name">{{ t.pricing.plan0_name }}</div>
        <p class="lp-plan-desc">{{ t.pricing.plan0_desc }}</p>
        <div class="lp-plan-price">
          <span class="lp-curr">{{ t.pricing.plan0_price_curr }}</span>{{ t.pricing.plan0_price_num }}
        </div>
        <p class="lp-plan-period">pagamento único</p>
        <ul class="lp-plan-items">
          <li>{{ t.pricing.plan0_item1 }}</li>
          <li>{{ t.pricing.plan0_item2 }}</li>
          <li>{{ t.pricing.plan0_item3 }}</li>
          <li>{{ t.pricing.plan0_item4 }}</li>
          <li>{{ t.pricing.plan0_item5 }}</li>
        </ul>
        <button class="lp-btn-plan" @click="goToCheckout('basico'); closeModal()">{{ t.pricing.plan0_cta }}</button>
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
.quiz-run-page { min-height: 100vh; background: var(--bg); color: var(--text); font-family: var(--font); display: flex; align-items: flex-start; justify-content: center; padding: 32px 24px 80px; }
.quiz-run-wrap { width: 100%; max-width: 580px; }
.quiz-run-back { font-size: 13px; color: var(--text-3); text-decoration: none; font-family: var(--mono); display: block; margin-bottom: 28px; }
.quiz-run-back:hover { color: var(--text-2); }
.quiz-intro { margin-bottom: 28px; }
.quiz-intro-tag { font-size: 11px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; margin-bottom: 10px; }
.quiz-intro-title { font-size: clamp(26px, 6vw, 38px); font-weight: 800; line-height: 1.1; letter-spacing: -1px; margin-bottom: 10px; }
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.quiz-intro-sub { font-size: 14px; color: var(--text-3); font-style: italic; }
.quiz-progress-wrap { display: flex; align-items: center; gap: 12px; margin-bottom: 28px; }
.quiz-progress-bar { flex: 1; height: 3px; background: var(--border); border-radius: 100px; overflow: hidden; }
.quiz-progress-fill { height: 100%; background: linear-gradient(90deg, #FF2D6B, #9B5DE5); border-radius: 100px; transition: width .35s ease; }
.quiz-progress-label { font-size: 11px; font-family: var(--mono); color: var(--text-3); white-space: nowrap; }
.quiz-q-num { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .12em; margin-bottom: 10px; }
.quiz-q-text { font-size: clamp(17px, 4vw, 22px); font-weight: 700; line-height: 1.4; letter-spacing: -.3px; margin-bottom: 20px; }
.quiz-options { display: flex; flex-direction: column; gap: 10px; margin-bottom: 22px; }
.quiz-option { background: var(--card); border: 1.5px solid var(--border); border-radius: 14px; padding: 14px 18px; text-align: left; font-size: 14px; line-height: 1.45; color: var(--text-2); cursor: pointer; transition: border-color .15s, background .15s, color .15s; font-family: var(--font); }
.quiz-option:hover { border-color: rgba(255,45,107,.3); color: var(--text); }
.quiz-option.selected { border-color: var(--pink); background: rgba(255,45,107,.07); color: var(--text); font-weight: 500; }
.quiz-next-btn { width: 100%; padding: 14px; background: linear-gradient(135deg, #FF2D6B, #9B5DE5); color: #fff; border: none; border-radius: 14px; font-size: 15px; font-weight: 700; cursor: pointer; transition: opacity .2s; font-family: var(--font); letter-spacing: -.2px; }
.quiz-next-btn:disabled { opacity: .35; cursor: not-allowed; }
.quiz-next-btn:not(:disabled):hover { opacity: .88; }
.quiz-result-block { padding-top: 8px; }
.result-card { background: var(--card); border: 1px solid var(--border); border-radius: 20px; padding: 28px 24px; text-align: center; margin-bottom: 20px; }
.result-emoji { font-size: 48px; margin-bottom: 14px; line-height: 1; }
.result-label { font-size: 20px; font-weight: 800; margin-bottom: 14px; letter-spacing: -.4px; }
.result-text { font-size: 14px; color: var(--text-2); line-height: 1.75; margin-bottom: 22px; text-align: left; }
.result-score-wrap { text-align: left; }
.result-score-bar { height: 5px; background: var(--border); border-radius: 100px; overflow: hidden; margin-bottom: 6px; }
.result-score-fill { height: 100%; background: linear-gradient(90deg, #FF2D6B, #9B5DE5); border-radius: 100px; transition: width .6s ease; }
.result-score-label { font-size: 11px; font-family: var(--mono); color: var(--text-3); }
.result-upsell-text { font-size: 13px; color: var(--text-3); text-align: center; margin-bottom: 16px; font-style: italic; }
.result-ctas { display: flex; flex-direction: column; gap: 10px; }
.result-btn-main { display: block; text-align: center; background: linear-gradient(135deg, #FF2D6B, #9B5DE5); color: #fff; font-size: 15px; font-weight: 700; padding: 14px 28px; border-radius: 14px; text-decoration: none; transition: opacity .2s; }
.result-btn-main:hover { opacity: .88; }
.result-secondary-links { display: flex; gap: 8px; justify-content: center; flex-wrap: wrap; }
.result-btn-ghost { background: none; border: 1px solid var(--border); color: var(--text-3); font-size: 12px; padding: 8px 14px; border-radius: 100px; cursor: pointer; font-family: var(--font); text-decoration: none; transition: border-color .15s, color .15s; }
.result-btn-ghost:hover { border-color: rgba(255,45,107,.25); color: var(--text-2); }
.result-btn-main { border: none; cursor: pointer; width: 100%; }

/* ── MODAL ── */
.lp-modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.75); z-index: 1000; display: flex; align-items: center; justify-content: center; padding: 20px; opacity: 0; pointer-events: none; transition: opacity .25s; }
.lp-modal-overlay.open { opacity: 1; pointer-events: all; backdrop-filter: blur(4px); }
.lp-modal-card { background: var(--card); border: 1px solid var(--border); border-radius: 24px; padding: 32px 28px; max-width: 860px; width: 100%; max-height: 90vh; overflow-y: auto; position: relative; }
.lp-modal-close { position: absolute; top: 16px; right: 20px; background: none; border: none; color: var(--text-3); font-size: 22px; cursor: pointer; line-height: 1; padding: 4px; transition: color .15s; }
.lp-modal-close:hover { color: var(--text); }
.lp-modal-eyebrow { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .12em; margin-bottom: 8px; }
.lp-modal-title { font-size: clamp(20px,4vw,28px); font-weight: 800; letter-spacing: -1px; line-height: 1.15; margin-bottom: 24px; }
.lp-modal-plans { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; margin-bottom: 20px; }
.lp-plan-card { background: var(--bg); border: 1px solid var(--border); border-radius: 16px; padding: 20px; position: relative; display: flex; flex-direction: column; gap: 6px; }
.lp-plan-card.featured { border-color: var(--pink); background: rgba(255,45,107,.04); }
.lp-plan-badge { position: absolute; top: -11px; left: 50%; transform: translateX(-50%); background: var(--pink); color: #fff; font-size: 10px; font-weight: 700; padding: 3px 12px; border-radius: 100px; white-space: nowrap; font-family: var(--mono); letter-spacing: .06em; }
.lp-plan-name { font-size: 15px; font-weight: 800; color: var(--text); letter-spacing: -.3px; }
.lp-plan-hook { font-size: 11px; color: var(--text-3); font-style: italic; line-height: 1.4; }
.lp-plan-price { font-size: 36px; font-weight: 900; color: var(--text); line-height: 1; letter-spacing: -2px; margin-top: 4px; }
.lp-curr { font-size: 16px; font-weight: 700; vertical-align: super; letter-spacing: 0; }
.lp-plan-period { font-size: 11px; color: var(--text-3); font-family: var(--mono); margin-top: 2px; }
.lp-plan-desc { font-size: 12px; color: var(--text-2); line-height: 1.55; margin-top: 4px; }
.lp-plan-items { list-style: none; padding: 0; margin: 8px 0 12px; display: flex; flex-direction: column; gap: 5px; flex: 1; }
.lp-plan-items li { font-size: 12px; color: var(--text-2); padding-left: 16px; position: relative; line-height: 1.45; }
.lp-plan-items li::before { content: '✓'; position: absolute; left: 0; color: var(--pink); font-size: 11px; font-weight: 700; }
.lp-plan-item-includes { color: var(--pink) !important; font-weight: 600 !important; }
.lp-plan-item-includes::before { content: '' !important; }
.lp-btn-plan { width: 100%; padding: 12px; border: 1px solid var(--border); background: var(--card); color: var(--text); font-size: 13px; font-weight: 700; border-radius: 12px; cursor: pointer; font-family: var(--font); transition: border-color .2s, background .2s; margin-top: auto; }
.lp-btn-plan:hover { border-color: var(--pink); background: rgba(255,45,107,.06); }
.lp-btn-plan.primary { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); color: #fff; border: none; }
.lp-btn-plan.primary:hover { opacity: .88; }
.lp-modal-guarantee { font-size: 11px; color: var(--text-3); text-align: center; font-family: var(--mono); }
.lp-modal-free-hint { font-size: 12px; color: var(--text-3); text-align: center; margin-top: 8px; }
.lp-modal-free-link { color: var(--pink); text-decoration: none; font-weight: 600; }
</style>
