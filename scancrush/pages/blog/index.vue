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
    title: 'Ele(a) gosta de mim ou só está sendo educado?',
    description: 'Responda 7 perguntas sobre o comportamento dele(a) e descubra o que os padrões estão dizendo.',
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

// Categorias com label legível
const CATEGORY_LABELS: Record<string, string> = {
  sinais:        'Sinais',
  padrões:       'Padrões',
  análise:       'Análise',
  decisão:       'Decisão',
  whatsapp:      'WhatsApp',
  interpretação: 'Interpretação',
  tecnologia:    'Tecnologia',
}

// Artigo em destaque (primeiro da lista)
const featured = computed(() => articles.value?.[0] ?? null)

// Agrupar restantes por categoria, 1 featured + lista
const categories = computed(() => {
  const rest = articles.value?.slice(1) ?? []
  const map: Record<string, any[]> = {}
  for (const a of rest) {
    const tag = a.tag ?? 'análise'
    if (!map[tag]) map[tag] = []
    map[tag].push(a)
  }
  // Ordenar por número de artigos (maior primeiro)
  return Object.entries(map)
    .sort((a, b) => b[1].length - a[1].length)
    .map(([tag, items]) => ({ tag, label: CATEGORY_LABELS[tag] ?? tag, items }))
})
</script>

<template>
<SiteNav />

<div class="blog-page">

  <!-- HERO -->
  <div class="blog-hero">
    <div class="blog-hero-inner">
      <p class="blog-eyebrow">// por dentro das mensagens</p>
      <h1 class="blog-title">O que a conversa<br><span class="grad">já está dizendo</span></h1>
      <p class="blog-sub">Sinais, padrões e aquelas coisas que você sente mas não consegue explicar.</p>
    </div>
  </div>

  <div class="blog-container">

    <!-- DESTAQUE -->
    <NuxtLink v-if="featured" :to="featured._path" class="blog-featured">
      <div class="bf-meta">
        <span class="bf-tag">{{ CATEGORY_LABELS[featured.tag] ?? featured.tag }}</span>
        <span class="bf-badge">Em destaque</span>
      </div>
      <h2 class="bf-title">{{ featured.title }}</h2>
      <p class="bf-desc">{{ featured.description }}</p>
      <span class="bf-cta">Ler artigo →</span>
    </NuxtLink>

    <!-- DESTAQUE: A HISTÓRIA DA MARCA / A PATTY -->
    <NuxtLink to="/sobre" class="blog-featured blog-featured-story">
      <div class="bf-meta">
        <span class="bf-tag bf-tag-story">A história da marca</span>
      </div>
      <h2 class="bf-title">Por que o ScanCrush existe — e quem é a Patty</h2>
      <p class="bf-desc">A marca nasceu de uma história real: a de quem já confundiu atenção com interesse. Conheça a origem e a analista por trás das análises.</p>
      <span class="bf-cta">Ler a história →</span>
    </NuxtLink>

    <!-- CATEGORIAS -->
    <div v-for="cat in categories" :key="cat.tag" class="blog-section">
      <div class="blog-section-header">
        <span class="blog-section-tag">// {{ cat.label }}</span>
        <NuxtLink :to="`/blog?tag=${cat.tag}`" class="blog-section-more" v-if="cat.items.length > 2">Ver todos →</NuxtLink>
      </div>

      <div class="blog-section-grid">
        <!-- Card destacado da categoria -->
        <NuxtLink :to="cat.items[0]._path" class="blog-card blog-card-main">
          <p class="blog-card-tag">{{ cat.label }}</p>
          <h3 class="blog-card-title">{{ cat.items[0].title }}</h3>
          <p class="blog-card-desc">{{ cat.items[0].description }}</p>
          <span class="blog-card-cta">Ler artigo →</span>
        </NuxtLink>

        <!-- Lista dos outros da categoria -->
        <div class="blog-card-list">
          <NuxtLink
            v-for="item in cat.items.slice(1, 4)"
            :key="item._path"
            :to="item._path"
            class="blog-list-item"
          >
            <span class="blog-list-title">{{ item.title }}</span>
            <span class="blog-list-arrow">→</span>
          </NuxtLink>
        </div>
      </div>
    </div>

    <!-- QUIZZES -->
    <div class="blog-quizzes">
      <div class="blog-quizzes-header">
        <p class="blog-quizzes-eyebrow">// teste rápido</p>
        <h2 class="blog-quizzes-title">Prefere responder perguntas?</h2>
        <p class="blog-quizzes-sub">Quizzes rápidos para quando você quer uma resposta agora.</p>
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
.blog-hero { padding: 52px 24px 40px; max-width: 720px; margin: 0 auto; }
.blog-eyebrow { font-size: 11px; font-family: var(--mono); color: var(--pink); letter-spacing: .1em; text-transform: uppercase; margin-bottom: 14px; }
.blog-title { font-size: clamp(32px,7vw,52px); font-weight: 800; line-height: 1.1; letter-spacing: -1.5px; margin-bottom: 16px; }
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.blog-sub { font-size: 16px; color: var(--text-2); line-height: 1.7; }
.blog-container { max-width: 960px; margin: 0 auto; padding: 0 24px 80px; }

/* ── DESTAQUE ── */
.blog-featured {
  display: block;
  text-decoration: none;
  background: linear-gradient(135deg, rgba(255,45,107,.06), rgba(155,93,229,.04));
  border: 1px solid rgba(255,45,107,.2);
  border-radius: 20px;
  padding: 32px;
  margin-bottom: 56px;
  transition: border-color .2s, transform .2s;
}
.blog-featured:hover { border-color: rgba(255,45,107,.4); transform: translateY(-2px); }
.bf-meta { display: flex; align-items: center; gap: 10px; margin-bottom: 14px; }
.bf-tag { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .12em; }
.bf-badge { font-size: 10px; font-family: var(--mono); color: rgba(255,255,255,.35); background: rgba(255,255,255,.06); border-radius: 100px; padding: 3px 10px; letter-spacing: .08em; }
.bf-title { font-size: clamp(20px,3.5vw,28px); font-weight: 800; color: var(--text); line-height: 1.2; letter-spacing: -.5px; margin-bottom: 12px; }
.bf-desc { font-size: 15px; color: var(--text-2); line-height: 1.65; margin-bottom: 20px; max-width: 560px; }
.bf-cta { font-size: 13px; color: var(--pink); font-weight: 700; }
/* Destaque da história (acento roxo, diferencia do destaque principal) */
.blog-featured-story { background: linear-gradient(135deg, rgba(155,93,229,.09), rgba(255,45,107,.03)); border-color: rgba(155,93,229,.28); margin-top: -32px; }
.blog-featured-story:hover { border-color: rgba(155,93,229,.5); }
.bf-tag-story { color: var(--purple); }
.blog-featured-story .bf-cta { color: var(--purple); }

/* ── SEÇÕES POR CATEGORIA ── */
.blog-section { margin-bottom: 52px; }
.blog-section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.blog-section-tag { font-size: 11px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .12em; }
.blog-section-more { font-size: 12px; color: var(--text-3); text-decoration: none; transition: color .2s; }
.blog-section-more:hover { color: var(--pink); }

.blog-section-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
@media (max-width: 620px) { .blog-section-grid { grid-template-columns: 1fr; } }

.blog-card {
  background: var(--card); border: 1px solid var(--border); border-radius: 16px;
  padding: 22px; text-decoration: none; display: flex; flex-direction: column; gap: 9px;
  transition: border-color .2s, transform .2s;
}
.blog-card:hover { border-color: rgba(255,45,107,.3); transform: translateY(-2px); }
.blog-card-tag { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; }
.blog-card-title { font-size: 16px; font-weight: 700; color: var(--text); line-height: 1.35; letter-spacing: -.3px; }
.blog-card-desc { font-size: 13px; color: var(--text-2); line-height: 1.6; flex: 1; }
.blog-card-cta { font-size: 12px; color: var(--pink); font-weight: 600; margin-top: 4px; }

/* Lista de artigos da categoria */
.blog-card-list { display: flex; flex-direction: column; gap: 4px; }
.blog-list-item {
  display: flex; align-items: center; justify-content: space-between; gap: 12px;
  padding: 14px 16px;
  background: var(--card); border: 1px solid var(--border); border-radius: 12px;
  text-decoration: none; transition: border-color .2s, background .2s;
}
.blog-list-item:hover { border-color: rgba(255,45,107,.25); background: var(--card-hi); }
.blog-list-title { font-size: 13px; font-weight: 500; color: var(--text-2); line-height: 1.45; flex: 1; }
.blog-list-arrow { font-size: 13px; color: var(--text-3); flex-shrink: 0; transition: color .2s; }
.blog-list-item:hover .blog-list-arrow { color: var(--pink); }

/* ── QUIZZES ── */
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
