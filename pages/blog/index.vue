<script setup lang="ts">
useHead({
  title: 'Blog ScanCrush — Relacionamentos, Crush e Sinais Emocionais',
  meta: [
    { name: 'description', content: 'Artigos sobre sinais do crush, como interpretar mensagens e padrões de comportamento em relacionamentos. Leia, se identifique e pare de adivinhar.' },
    { rel: 'canonical', href: 'https://scancrush.com/blog' },
  ],
})

const { data: articles } = await useAsyncData('blog-list', () =>
  queryContent('blog').sort({ date: -1 }).find()
)

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
<SiteNav />

<div class="blog-page">
  <div class="blog-hero">
    <div class="blog-hero-inner">
      <p class="blog-eyebrow">// por dentro das mensagens</p>
      <h1 class="blog-title">O que a conversa<br><span class="grad">já está dizendo</span></h1>
      <p class="blog-sub">Artigos sobre sinais, padrões e aquelas coisas que você sente mas não consegue explicar.</p>
    </div>
  </div>

  <div class="blog-container">
    <!-- Articles -->
    <div class="blog-grid">
      <NuxtLink
        v-for="article in articles"
        :key="article._path"
        :to="article._path"
        class="blog-card"
      >
        <p class="blog-card-tag">{{ article.tag ?? 'análise' }}</p>
        <h2 class="blog-card-title">{{ article.title }}</h2>
        <p class="blog-card-desc">{{ article.description }}</p>
        <span class="blog-card-cta">Ler artigo →</span>
      </NuxtLink>
    </div>

    <!-- Quiz section -->
    <div class="blog-quizzes">
      <div class="blog-quizzes-header">
        <p class="blog-quizzes-eyebrow">// teste rápido</p>
        <h2 class="blog-quizzes-title">Prefere responder perguntas?</h2>
        <p class="blog-quizzes-sub">Quizzes rápidos para quando você quer uma resposta agora — sem ler artigo.</p>
      </div>
      <div class="blog-quiz-grid">
        <NuxtLink
          v-for="quiz in quizzes"
          :key="quiz.slug"
          :to="`/quiz/${quiz.slug}`"
          class="blog-quiz-card"
        >
          <p class="bqc-tag">{{ quiz.tag }}</p>
          <h3 class="bqc-title">{{ quiz.title }}</h3>
          <p class="bqc-desc">{{ quiz.description }}</p>
          <div class="bqc-footer">
            <span class="bqc-tempo">⏱ {{ quiz.tempo }}</span>
            <span class="bqc-cta">Fazer quiz →</span>
          </div>
        </NuxtLink>
      </div>
    </div>
  </div>
</div>
</template>

<style scoped>
.blog-page { min-height: 100vh; background: var(--bg); color: var(--text); font-family: var(--font); padding-top: 68px; }
.blog-hero { padding: 52px 24px 44px; max-width: 680px; margin: 0 auto; }
.blog-hero-inner {}
.blog-eyebrow { font-size: 11px; font-family: var(--mono); color: var(--pink); letter-spacing: .1em; text-transform: uppercase; margin-bottom: 14px; }
.blog-title { font-size: clamp(32px,7vw,52px); font-weight: 800; line-height: 1.1; letter-spacing: -1.5px; margin-bottom: 16px; }
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.blog-sub { font-size: 16px; color: var(--text-2); line-height: 1.7; }
.blog-container { max-width: 960px; margin: 0 auto; padding: 0 24px 80px; }
.blog-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; margin-bottom: 64px; }
.blog-card { background: var(--card); border: 1px solid var(--border); border-radius: 16px; padding: 24px; text-decoration: none; display: flex; flex-direction: column; gap: 10px; transition: border-color .2s, transform .2s; }
.blog-card:hover { border-color: rgba(255,45,107,.3); transform: translateY(-2px); }
.blog-card-tag { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; }
.blog-card-title { font-size: 17px; font-weight: 700; color: var(--text); line-height: 1.35; letter-spacing: -.3px; }
.blog-card-desc { font-size: 13px; color: var(--text-2); line-height: 1.6; flex: 1; }
.blog-card-cta { font-size: 12px; color: var(--pink); font-weight: 600; margin-top: 4px; }

/* Quiz section */
.blog-quizzes { border-top: 1px solid var(--border); padding-top: 48px; }
.blog-quizzes-header { margin-bottom: 28px; }
.blog-quizzes-eyebrow { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .12em; margin-bottom: 10px; }
.blog-quizzes-title { font-size: clamp(22px,5vw,32px); font-weight: 800; line-height: 1.1; letter-spacing: -1px; margin-bottom: 10px; }
.blog-quizzes-sub { font-size: 15px; color: var(--text-2); line-height: 1.6; }
.blog-quiz-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 16px; }
.blog-quiz-card { background: var(--card); border: 1px solid var(--border); border-radius: 14px; padding: 20px; text-decoration: none; display: flex; flex-direction: column; gap: 8px; transition: border-color .2s, transform .2s; }
.blog-quiz-card:hover { border-color: rgba(255,45,107,.3); transform: translateY(-2px); }
.bqc-tag { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; }
.bqc-title { font-size: 15px; font-weight: 700; color: var(--text); line-height: 1.35; letter-spacing: -.3px; }
.bqc-desc { font-size: 12px; color: var(--text-2); line-height: 1.55; flex: 1; }
.bqc-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 4px; }
.bqc-tempo { font-size: 11px; font-family: var(--mono); color: var(--text-3); }
.bqc-cta { font-size: 12px; color: var(--pink); font-weight: 600; }
</style>
