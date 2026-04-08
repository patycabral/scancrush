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
    q: 'Quando ele te apresenta pra alguém, como ele faz?',
    options: [
      { label: '"Essa é minha amiga [nome]" — sempre amiga, sem hesitar', value: 0 },
      { label: 'Só fala meu nome, sem rótulo', value: 1 },
      { label: '"Uma menina que eu conheço" — vago assim', value: 2 },
      { label: 'Apresenta com um orgulho que eu nem sei explicar direito', value: 3 },
    ],
  },
  {
    q: 'Ele te conta quando está afim de alguém ou saindo com outra pessoa?',
    options: [
      { label: 'Sim, conta tudo — eu sou basicamente a confidente amorosa dele', value: 0 },
      { label: 'Às vezes menciona alguma coisa', value: 1 },
      { label: 'Nunca tocou no assunto comigo', value: 2 },
      { label: 'Não, e quando eu toco nesse tema ele fica esquisito', value: 3 },
    ],
  },
  {
    q: 'Você deu uma indireta (ou não tão indireta). Como ele reagiu?',
    options: [
      { label: 'Ignorou completamente ou fingiu não entender', value: 0 },
      { label: 'Fez uma piada e mudou de assunto', value: 1 },
      { label: 'Ficou quieto, mas o clima mudou — não da forma ruim', value: 2 },
      { label: 'Ficou claramente animado ou retribuiu de algum jeito', value: 3 },
    ],
  },
  {
    q: 'Quando estão pessoalmente, o contato físico dele vai além do padrão de amigos?',
    options: [
      { label: 'Não, é igual a qualquer amigo — abraço protocolar, nada mais', value: 0 },
      { label: 'Talvez levemente diferente, mas posso estar inventando', value: 1 },
      { label: 'Sim, fica um pouco mais próximo do que precisaria estar', value: 2 },
      { label: 'Definitivamente — toque mais demorado, mais próximo que o necessário', value: 3 },
    ],
  },
  {
    q: 'Você começou a falar que tem interesse em outra pessoa. Como ele ficou?',
    options: [
      { label: 'Indiferente — até me ajudou a pensar no que fazer com a outra pessoa', value: 0 },
      { label: 'Não sei, não prestei atenção', value: 1 },
      { label: 'Parecia um pouco desconfortável, mas não disse nada', value: 2 },
      { label: 'Ficou quieto, mudou de humor — era visível que não curtiu', value: 3 },
    ],
  },
  {
    q: 'Ele cria situações para ficar a sós com você?',
    options: [
      { label: 'Não. Quando a gente sai sempre tem mais gente', value: 0 },
      { label: 'Já aconteceu mas pareceu mais coincidência', value: 1 },
      { label: 'Às vezes sugere algo só os dois', value: 2 },
      { label: 'Com frequência — sempre arruma um jeito de ser só a gente', value: 3 },
    ],
  },
  {
    q: 'Já houve algum momento em que o clima claramente "pesou" entre vocês — aquele silêncio diferente?',
    options: [
      { label: 'Nunca. É sempre leve e óbvio que é só amizade', value: 0 },
      { label: 'Não tenho certeza... talvez eu esteja inventando', value: 1 },
      { label: 'Sim, algumas vezes senti que podia acontecer algo', value: 2 },
      { label: 'Sim, claramente — aquele clima elétrico que os dois fingem ignorar', value: 3 },
    ],
  },
  {
    q: 'No privado (mensagem ou pessoalmente), o jeito dele é diferente de como é em grupo?',
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
    text: 'Com base no que você descreveu, ele te vê como amiga — de verdade, com carinho genuíno. Isso não é pouca coisa. Mas não é o que você está querendo. A decisão agora é: você consegue ficar na amizade com esse sentimento? Ou precisa de distância pra processar? Nenhuma das duas opções é errada.',
  },
  {
    min: 7, max: 13,
    label: 'A situação é ambígua — e isso é enlouquecedor',
    emoji: '🌀',
    color: '#F59E0B',
    text: 'Tem coisa que aponta pra amizade. Tem coisa que deixa dúvida. Pode ser que ele está confuso também. Pode ser que você está num momento de transição. Nesses casos, a análise da conversa ajuda muito mais do que ficar tentando decifrar cada detalhe sozinha.',
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
    text: 'Amigo não age assim. O que você descreveu tem ciúme, tem clima, tem presença diferenciada, tem momentos que os dois fingem ignorar. A pergunta real não é se ele sente algo — é quem vai ser corajosa primeiro.',
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
        <NuxtLink to="/scan" class="result-btn-main">Analisar a conversa de verdade →</NuxtLink>
        <div class="result-secondary-links">
          <button class="result-btn-ghost" @click="restart">Refazer</button>
          <NuxtLink to="/quiz" class="result-btn-ghost">Outros quizzes</NuxtLink>
          <NuxtLink to="/blog" class="result-btn-ghost">Ver artigos</NuxtLink>
        </div>
      </div>
    </div>
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
</style>
