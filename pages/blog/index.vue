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
</script>

<template>
<div class="blog-page">
  <div class="blog-header">
    <NuxtLink to="/" class="blog-back">← Voltar</NuxtLink>
    <div class="blog-header-inner">
      <p class="blog-eyebrow">// por dentro das mensagens</p>
      <h1 class="blog-title">O que a conversa<br><span class="grad">já está dizendo</span></h1>
      <p class="blog-sub">Artigos sobre sinais, padrões e aquelas coisas que você sente mas não consegue explicar.</p>
    </div>
  </div>

  <div class="blog-container">
    <!-- Quiz CTA -->
    <div class="blog-quiz-banner">
      <p class="blog-quiz-eyebrow">// teste rápido</p>
      <p class="blog-quiz-text">Ele gosta de você ou só está sendo educado?</p>
      <NuxtLink to="/quiz" class="blog-quiz-btn">Fazer o teste →</NuxtLink>
    </div>

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
  </div>
</div>
</template>

<style scoped>
.blog-page { min-height: 100vh; background: var(--bg); color: var(--text); font-family: var(--font); }
.blog-header { padding: 32px 24px 48px; max-width: 680px; margin: 0 auto; }
.blog-back { font-size: 13px; color: var(--text-3); text-decoration: none; font-family: var(--mono); display: block; margin-bottom: 32px; }
.blog-back:hover { color: var(--text-2); }
.blog-eyebrow { font-size: 11px; font-family: var(--mono); color: var(--pink); letter-spacing: .1em; text-transform: uppercase; margin-bottom: 14px; }
.blog-title { font-size: clamp(32px,7vw,52px); font-weight: 800; line-height: 1.1; letter-spacing: -1.5px; margin-bottom: 16px; }
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.blog-sub { font-size: 16px; color: var(--text-2); line-height: 1.7; }
.blog-container { max-width: 960px; margin: 0 auto; padding: 0 24px 80px; }
.blog-quiz-banner { background: linear-gradient(135deg,rgba(255,45,107,.08),rgba(155,93,229,.06)); border: 1px solid rgba(255,45,107,.18); border-radius: 16px; padding: 20px 24px; display: flex; align-items: center; gap: 16px; margin-bottom: 40px; flex-wrap: wrap; }
.blog-quiz-eyebrow { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; white-space: nowrap; }
.blog-quiz-text { flex: 1; font-size: 15px; font-weight: 600; }
.blog-quiz-btn { font-size: 13px; font-weight: 700; color: var(--pink); text-decoration: none; white-space: nowrap; }
.blog-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
.blog-card { background: var(--card); border: 1px solid var(--border); border-radius: 16px; padding: 24px; text-decoration: none; display: flex; flex-direction: column; gap: 10px; transition: border-color .2s, transform .2s; }
.blog-card:hover { border-color: rgba(255,45,107,.3); transform: translateY(-2px); }
.blog-card-tag { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; }
.blog-card-title { font-size: 17px; font-weight: 700; color: var(--text); line-height: 1.35; letter-spacing: -.3px; }
.blog-card-desc { font-size: 13px; color: var(--text-2); line-height: 1.6; flex: 1; }
.blog-card-cta { font-size: 12px; color: var(--pink); font-weight: 600; margin-top: 4px; }
</style>
