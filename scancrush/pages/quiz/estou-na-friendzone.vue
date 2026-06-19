<script setup lang="ts">
useHead({
  title: 'Quiz: Você está na friendzone? — ScanCrush',
  meta: [
    { name: 'description', content: '8 perguntas para descobrir se você está mesmo na zona de amizade ou se é insegurança sua. Resultado honesto e sem enrolação.' },
  ],
  link: [
    { rel: 'canonical', href: 'https://scancrush.com/quiz/estou-na-friendzone' },
  ],
})

const questions = [
  {
    q: 'Quando ele(a) te apresenta para alguém, como ele(a) faz?',
    options: [
      { label: '"Essa é minha amiga [nome]" — sempre amiga, sem hesitar', value: 0 },
      { label: 'Só fala meu nome, sem rótulo', value: 1 },
      { label: '"Uma menina que eu conheço" — vago assim', value: 2 },
      { label: 'Apresenta com um orgulho que eu nem sei explicar direito', value: 3 },
    ],
  },
  {
    q: 'Ele(a) te conta quando está afim de alguém ou saindo com outra pessoa?',
    options: [
      { label: 'Sim, conta tudo — eu sou basicamente a confidente amorosa dele', value: 0 },
      { label: 'Às vezes menciona alguma coisa', value: 1 },
      { label: 'Nunca tocou no assunto comigo', value: 2 },
      { label: 'Não, e quando eu toco nesse tema ele(a) fica esquisito', value: 3 },
    ],
  },
  {
    q: 'Você deu uma indireta (ou não tão indireta). Como ele(a) reagiu?',
    options: [
      { label: 'Ignorou completamente ou fingiu não entender', value: 0 },
      { label: 'Fez uma piada e mudou de assunto', value: 1 },
      { label: 'Ficou quieto, mas o clima mudou — não da forma ruim', value: 2 },
      { label: 'Ficou claramente animado ou retribuiu de algum jeito', value: 3 },
    ],
  },
  {
    q: 'Quando estão pessoalmente, o contato físico dele(a) vai além do padrão de amigos?',
    options: [
      { label: 'Não, é igual a qualquer amigo — abraço protocolar, nada mais', value: 0 },
      { label: 'Talvez levemente diferente, mas posso estar inventando', value: 1 },
      { label: 'Sim, fica um pouco mais próximo do que precisaria estar', value: 2 },
      { label: 'Definitivamente — toque mais demorado, mais próximo que o necessário', value: 3 },
    ],
  },
  {
    q: 'Você começou a falar que tem interesse em outra pessoa. Como ele(a) ficou?',
    options: [
      { label: 'Indiferente — até me ajudou a pensar no que fazer com a outra pessoa', value: 0 },
      { label: 'Não sei, não prestei atenção', value: 1 },
      { label: 'Parecia um pouco desconfortável, mas não disse nada', value: 2 },
      { label: 'Ficou quieto, mudou de humor — era visível que não curtiu', value: 3 },
    ],
  },
  {
    q: 'Ele(a) cria situações para ficar a sós com você?',
    options: [
      { label: 'Não. Quando a gente sai sempre tem mais gente', value: 0 },
      { label: 'Já aconteceu mas pareceu mais coincidência', value: 1 },
      { label: 'Às vezes sugere algo só os dois', value: 2 },
      { label: 'Com frequência — sempre arruma um jeito de ser só a gente', value: 3 },
    ],
  },
  {
    q: 'Já houve algum momento em que o clima claramente "pesou" entre vocês — aquele(a) silêncio diferente?',
    options: [
      { label: 'Nunca. É sempre leve e óbvio que é só amizade', value: 0 },
      { label: 'Não tenho certeza... talvez eu esteja inventando', value: 1 },
      { label: 'Sim, algumas vezes senti que podia acontecer algo', value: 2 },
      { label: 'Sim, claramente — aquele(a) clima elétrico que os dois fingem ignorar', value: 3 },
    ],
  },
  {
    q: 'No privado (mensagem ou pessoalmente), o jeito dele(a) é diferente de como é em grupo?',
    options: [
      { label: 'Não, é igual — o mesmo amigão de sempre', value: 0 },
      { label: 'Talvez um pouco mais leve, mas mínimo', value: 1 },
      { label: 'Sim, fica mais próximo, mais pessoal', value: 2 },
      { label: 'Completamente diferente — é como se fosse outro espaço entre a gente', value: 3 },
    ],
  },
]

const results = [
  {
    min: 0, max: 6,
    label: 'Tô te poupando: é friendzone',
    emoji: '💙',
    color: '#60A5FA',
    text: 'Com base no que você descreveu, ele(a) te vê como amiga — de verdade, com carinho genuíno. Isso não é pouca coisa. Mas não é o que você está querendo. A decisão agora é: você consegue ficar na amizade com esse sentimento? Ou precisa de distância para processar? Nenhuma das duas opções é errada.',
  },
  {
    min: 7, max: 13,
    label: 'A situação é ambígua — e isso é enlouquecedor',
    emoji: '🌀',
    color: '#F59E0B',
    text: 'Tem coisa que aponta para amizade. Tem coisa que deixa dúvida. Pode ser que ele(a) está confuso também. Pode ser que você está num momento de transição. Nesses casos, a análise da conversa ajuda muito mais do que ficar tentando decifrar cada detalhe sozinha.',
  },
  {
    min: 14, max: 18,
    label: 'Friendzone? Não parece muito não',
    emoji: '💗',
    color: '#FF2D6B',
    text: 'Os sinais que você descreveu não combinam com alguém que só te vê como amiga. Tem ciúme, tem clima, tem diferença de comportamento. Isso não é amizade padrão. Pode ser insegurança sua — ou pode ser que vocês dois estão esperando o outro se mexer primeiro.',
  },
  {
    min: 19, max: 24,
    label: 'Isso definitivamente não é friendzone',
    emoji: '🔥',
    color: '#9B5DE5',
    text: 'Amigo não age assim. O que você descreveu tem ciúme, tem clima, tem presença diferenciada, tem momentos que os dois fingem ignorar. A pergunta real não é se ele(a) sente algo — é quem vai ser corajosa primeiro.',
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

const CHECKOUT_URLS = { basico: 'https://go.perfectpay.com.br/PPU38CQDB0D', revealed: 'https://go.perfectpay.com.br/PPU38CQC51R', raiox: 'https://go.perfectpay.com.br/PPU38CQC51K' }
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
      <p class="quiz-intro-tag">// 8 perguntas · 3 min</p>
      <h1 class="quiz-intro-title">Você está na<br><span class="grad">friendzone?</span></h1>
      <p class="quiz-intro-sub">Ou é insegurança sua? Vamos descobrir agora.</p>
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
          <div class="result-score-bar"><div class="result-score-fill" :style="{ width: (score / 24 * 100) + '%' }"></div></div>
          <p class="result-score-label">seu score: {{ score }}/24</p>
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
