<script setup lang="ts">
useHead({
  title: 'Quiz: Ele gosta de mim ou é só educação? — ScanCrush',
  meta: [
    { name: 'description', content: 'Responde 7 perguntas e descobre se o interesse dele é real ou se ele só está sendo educado. Resultado na hora.' },
  ],
  link: [
    { rel: 'canonical', href: 'https://scancrush.com/quiz/ele-gosta-de-mim' },
  ],
})

const questions = [
  {
    q: 'Quem costuma mandar o primeiro "oi" nas conversas de vocês?',
    options: [
      { label: 'Eu, sempre. Ele nunca aparece por conta própria', value: 0 },
      { label: 'Geralmente sou eu, mas ele já iniciou algumas vezes', value: 1 },
      { label: 'É bem equilibrado, às vezes ele, às vezes eu', value: 2 },
      { label: 'Ele aparece do nada com frequência — meme, pergunta, qualquer coisa', value: 3 },
    ],
  },
  {
    q: 'Você contou uma coisa importante pra ele. Como ele reagiu?',
    options: [
      { label: '"haha" ou "que isso" — e mudou de assunto', value: 0 },
      { label: 'Respondeu de boa, mas não perguntou mais nada', value: 1 },
      { label: 'Perguntou mais, quis entender direito', value: 2 },
      { label: 'Lembrou do assunto dias depois e perguntou como tinha ido', value: 3 },
    ],
  },
  {
    q: 'Ele já ficou online depois de te responder, claramente esperando você continuar?',
    options: [
      { label: 'Nunca. Responde e some na hora', value: 0 },
      { label: 'Raramente, talvez uma vez ou outra', value: 1 },
      { label: 'Às vezes sim, percebo que ele fica por perto', value: 2 },
      { label: 'Quase sempre — fica esperando a conversa continuar', value: 3 },
    ],
  },
  {
    q: 'Quando você some por um tempo (não fala por alguns dias), o que acontece?',
    options: [
      { label: 'Nada. Ele não percebe ou não faz nada', value: 0 },
      { label: 'Às vezes aparece depois de um tempão com algum pretexto', value: 1 },
      { label: 'Geralmente manda uma mensagem perguntando onde você sumiu', value: 2 },
      { label: 'Logo percebe e retoma — não deixa a conversa morrer', value: 3 },
    ],
  },
  {
    q: 'Ele já criou uma situação pra ficar com você a sós?',
    options: [
      { label: 'Nunca. Se a gente sai, é sempre em grupo', value: 0 },
      { label: 'Aconteceu uma vez mas parecia coincidência', value: 1 },
      { label: 'Já sugeriu algo a dois pelo menos uma ou duas vezes', value: 2 },
      { label: 'Busca isso com frequência — sempre arruma um jeito', value: 3 },
    ],
  },
  {
    q: 'O jeito dele te escrever no privado é diferente de quando tem outras pessoas por perto?',
    options: [
      { label: 'Não, é sempre igual — educado e padrão', value: 0 },
      { label: 'Talvez levemente, mas não dá pra dizer ao certo', value: 1 },
      { label: 'No privado é mais leve, mais espontâneo', value: 2 },
      { label: 'Completamente diferente — mais próximo, mais íntimo, mais ele mesmo', value: 3 },
    ],
  },
  {
    q: 'Ele já mandou alguma coisa (meme, música, foto) com "lembrei de você" ou algo parecido?',
    options: [
      { label: 'Nunca', value: 0 },
      { label: 'Acho que uma vez, mas foi algo genérico', value: 1 },
      { label: 'Sim, já fez isso — e era algo específico pra mim', value: 2 },
      { label: 'Faz isso com frequência. Claramente pensa em mim fora da conversa', value: 3 },
    ],
  },
]

const results = [
  {
    min: 0, max: 7,
    label: 'Mais educação do que interesse, bb',
    emoji: '🤍',
    color: '#94A3B8',
    text: 'Com base no que você descreveu, o comportamento dele parece mais de alguém que é simplesmente educado do que de alguém que está afim. Isso dói ouvir, mas é melhor saber agora do que investir meses numa situação unilateral. Isso não significa que vai ser assim pra sempre — mas como está agora, a iniciativa toda está vindo de você.',
  },
  {
    min: 8, max: 13,
    label: 'Hmm... os sinais são mistos, girl',
    emoji: '🤔',
    color: '#F59E0B',
    text: 'Tem coisa boa, tem coisa que deixa dúvida. Pode ser interesse em desenvolvimento, pode ser que ele é naturalmente atencioso com todo mundo. Nesses casos, o padrão das próximas semanas vai dizer mais do que qualquer análise de hoje. Mas se você quer uma resposta mais precisa agora, analisar a conversa completa ajuda muito.',
  },
  {
    min: 14, max: 18,
    label: 'Girl, ele está gostando sim',
    emoji: '💗',
    color: '#FF2D6B',
    text: 'Os sinais são bastante positivos. Ele demonstra presença que vai além de educação — aparece, lembra, cria momentos. Agora é sobre o que você quer fazer com isso. Um quiz tem limite, mas o padrão que você descreveu é bem animador.',
  },
  {
    min: 19, max: 21,
    label: 'Ele está muito afim de você 🔥',
    emoji: '🔥',
    color: '#9B5DE5',
    text: 'Desculpa, mas vai ser difícil argumentar contra. O comportamento que você descreveu vai muito além de educação — tem iniciativa, atenção, presença e criação de momentos. Isso não é acidente. Agora a pergunta é: o que você vai fazer com essa informação?',
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

    <!-- Header estático antes das perguntas -->
    <div v-if="!finished && current === 0" class="quiz-intro">
      <p class="quiz-intro-tag">// 7 perguntas · 2 min</p>
      <h1 class="quiz-intro-title">Ele gosta de mim<br><span class="grad">ou é só educado?</span></h1>
      <p class="quiz-intro-sub">Responde com honestidade — a resposta só vale se for real.</p>
    </div>

    <!-- Progress -->
    <div v-if="!finished" class="quiz-progress-wrap">
      <div class="quiz-progress-bar">
        <div class="quiz-progress-fill" :style="{ width: progress + '%' }"></div>
      </div>
      <span class="quiz-progress-label">{{ current + 1 }}/{{ questions.length }}</span>
    </div>

    <!-- Question -->
    <div v-if="!finished" class="quiz-question-block">
      <p class="quiz-q-num">pergunta {{ current + 1 }}</p>
      <h2 class="quiz-q-text">{{ questions[current].q }}</h2>
      <div class="quiz-options">
        <button
          v-for="(opt, i) in questions[current].options"
          :key="i"
          class="quiz-option"
          :class="{ selected: selected === opt.value }"
          @click="select(opt.value)"
        >
          {{ opt.label }}
        </button>
      </div>
      <button class="quiz-next-btn" :disabled="selected === null" @click="next">
        {{ current < questions.length - 1 ? 'Próxima →' : 'Ver meu resultado →' }}
      </button>
    </div>

    <!-- Result -->
    <div v-else class="quiz-result-block">
      <div class="result-card">
        <p class="result-emoji">{{ result.emoji }}</p>
        <p class="result-label" :style="{ color: result.color }">{{ result.label }}</p>
        <p class="result-text">{{ result.text }}</p>

        <div class="result-score-wrap">
          <div class="result-score-bar">
            <div class="result-score-fill" :style="{ width: (score / 21 * 100) + '%' }"></div>
          </div>
          <p class="result-score-label">seu score: {{ score }}/21</p>
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
.quiz-option {
  background: var(--card);
  border: 1.5px solid var(--border);
  border-radius: 14px;
  padding: 14px 18px;
  text-align: left;
  font-size: 14px;
  line-height: 1.45;
  color: var(--text-2);
  cursor: pointer;
  transition: border-color .15s, background .15s, color .15s;
  font-family: var(--font);
}
.quiz-option:hover { border-color: rgba(255,45,107,.3); color: var(--text); }
.quiz-option.selected { border-color: var(--pink); background: rgba(255,45,107,.07); color: var(--text); font-weight: 500; }

.quiz-next-btn {
  width: 100%;
  padding: 14px;
  background: linear-gradient(135deg, #FF2D6B, #9B5DE5);
  color: #fff;
  border: none;
  border-radius: 14px;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  transition: opacity .2s;
  font-family: var(--font);
  letter-spacing: -.2px;
}
.quiz-next-btn:disabled { opacity: .35; cursor: not-allowed; }
.quiz-next-btn:not(:disabled):hover { opacity: .88; }

/* Result */
.quiz-result-block { padding-top: 8px; }
.result-card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: 20px;
  padding: 28px 24px;
  text-align: center;
  margin-bottom: 20px;
}
.result-emoji { font-size: 48px; margin-bottom: 14px; line-height: 1; }
.result-label { font-size: 20px; font-weight: 800; margin-bottom: 14px; letter-spacing: -.4px; }
.result-text { font-size: 14px; color: var(--text-2); line-height: 1.75; margin-bottom: 22px; text-align: left; }
.result-score-wrap { text-align: left; }
.result-score-bar { height: 5px; background: var(--border); border-radius: 100px; overflow: hidden; margin-bottom: 6px; }
.result-score-fill { height: 100%; background: linear-gradient(90deg, #FF2D6B, #9B5DE5); border-radius: 100px; transition: width .6s ease; }
.result-score-label { font-size: 11px; font-family: var(--mono); color: var(--text-3); }

.result-upsell-text { font-size: 13px; color: var(--text-3); text-align: center; margin-bottom: 16px; font-style: italic; }

.result-ctas { display: flex; flex-direction: column; gap: 10px; }
.result-btn-main {
  display: block;
  text-align: center;
  background: linear-gradient(135deg, #FF2D6B, #9B5DE5);
  color: #fff;
  font-size: 15px;
  font-weight: 700;
  padding: 14px 28px;
  border-radius: 14px;
  text-decoration: none;
  transition: opacity .2s;
}
.result-btn-main:hover { opacity: .88; }
.result-secondary-links { display: flex; gap: 8px; justify-content: center; flex-wrap: wrap; }
.result-btn-ghost {
  background: none;
  border: 1px solid var(--border);
  color: var(--text-3);
  font-size: 12px;
  padding: 8px 14px;
  border-radius: 100px;
  cursor: pointer;
  font-family: var(--font);
  text-decoration: none;
  transition: border-color .15s, color .15s;
}
.result-btn-ghost:hover { border-color: rgba(255,45,107,.25); color: var(--text-2); }
</style>
