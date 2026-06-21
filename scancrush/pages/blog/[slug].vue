<script setup lang="ts">
const route = useRoute()
const { data: article } = await useAsyncData(`blog-${route.params.slug}`, () =>
  queryContent('blog', route.params.slug as string).findOne()
)

if (!article.value) {
  throw createError({ statusCode: 404, statusMessage: 'Artigo não encontrado' })
}

useHead({
  title: `${article.value.title} — ScanCrush`,
  meta: [
    { name: 'description', content: article.value.description },
    { rel: 'canonical', href: `https://scancrush.com/blog/${route.params.slug}` },
    { property: 'og:title', content: article.value.title },
    { property: 'og:description', content: article.value.description },
    { property: 'og:type', content: 'article' },
  ],
  script: [
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'Article',
        headline: article.value.title,
        description: article.value.description,
        datePublished: article.value.date,
        author: { '@type': 'Organization', name: 'ScanCrush' },
        publisher: { '@type': 'Organization', name: 'ScanCrush', url: 'https://scancrush.com' },
        mainEntityOfPage: { '@type': 'WebPage', '@id': `https://scancrush.com/blog/${route.params.slug}` },
        ...(article.value.faq && {
          '@context': 'https://schema.org',
          mainEntity: article.value.faq.map((item: { q: string; a: string }) => ({
            '@type': 'Question',
            name: item.q,
            acceptedAnswer: { '@type': 'Answer', text: item.a },
          })),
        }),
      }),
    },
  ],
})
</script>

<template>
<SiteNav />

<div class="article-page" v-if="article">
  <div class="article-header">
    <NuxtLink to="/blog" class="article-back">← Blog</NuxtLink>
    <div class="article-header-inner">
      <p class="article-tag">{{ article.tag ?? 'análise' }}</p>
      <h1 class="article-title">{{ article.title }}</h1>
      <p class="article-desc">{{ article.description }}</p>
    </div>
  </div>

  <!-- Mid CTA -->
  <div class="article-cta-bar">
    <span class="article-cta-text">Quer entender o que ele(a) realmente sente?</span>
    <NuxtLink to="/#b-pricing" class="article-cta-btn">Analisar conversa →</NuxtLink>
  </div>

  <div class="article-body-wrap">
    <div class="article-body">
      <ContentRenderer :value="article" />
    </div>

    <!-- FAQ Section -->
    <div v-if="article.faq && article.faq.length" class="article-faq">
      <h2 class="faq-title">Perguntas frequentes</h2>
      <div v-for="(item, i) in article.faq" :key="i" class="faq-item">
        <p class="faq-q">{{ item.q }}</p>
        <p class="faq-a">{{ item.a }}</p>
      </div>
    </div>

    <!-- Final CTA -->
    <div class="article-final-cta">
      <p class="final-cta-eyebrow">// chega de adivinhar</p>
      <p class="final-cta-title">Você merece uma resposta de verdade</p>
      <p class="final-cta-sub">Cole a conversa, a IA analisa os padrões e te diz o que está acontecendo — em segundos.</p>
      <NuxtLink to="/#b-pricing" class="final-cta-btn">Analisar minha conversa agora →</NuxtLink>
    </div>

    <!-- Related -->
    <div class="article-back-footer">
      <NuxtLink to="/blog" class="article-back-link">← Ver todos os artigos</NuxtLink>
    </div>
  </div>
</div>
</template>

<style scoped>
.article-page { min-height: 100vh; background: var(--bg); color: var(--text); font-family: var(--font); padding-top: 68px; }
.article-header { padding: 32px 24px 40px; max-width: 720px; margin: 0 auto; }
.article-back { font-size: 13px; color: var(--text-3); text-decoration: none; font-family: var(--mono); display: block; margin-bottom: 28px; }
.article-back:hover { color: var(--text-2); }
.article-tag { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; margin-bottom: 12px; }
.article-title { font-size: clamp(26px, 5vw, 44px); font-weight: 800; line-height: 1.15; letter-spacing: -1px; margin-bottom: 14px; }
.article-desc { font-size: 16px; color: var(--text-2); line-height: 1.7; margin-bottom: 10px; }
.article-date { font-size: 12px; font-family: var(--mono); color: var(--text-3); }
.article-cta-bar { background: linear-gradient(135deg, rgba(255,45,107,.08), rgba(155,93,229,.06)); border-top: 1px solid rgba(255,45,107,.12); border-bottom: 1px solid rgba(255,45,107,.12); padding: 14px 24px; display: flex; align-items: center; justify-content: center; gap: 20px; flex-wrap: wrap; }
.article-cta-text { font-size: 14px; font-weight: 600; }
.article-cta-btn { font-size: 13px; font-weight: 700; color: var(--pink); text-decoration: none; white-space: nowrap; }
.article-body-wrap { max-width: 720px; margin: 0 auto; padding: 40px 24px 80px; }
.article-body { font-size: 16px; line-height: 1.8; color: var(--text-2); }
.article-body :deep(h2) { font-size: 22px; font-weight: 700; color: var(--text); margin: 36px 0 12px; letter-spacing: -.4px; }
.article-body :deep(h3) { font-size: 18px; font-weight: 600; color: var(--text); margin: 28px 0 10px; }
.article-body :deep(p) { margin-bottom: 18px; }
.article-body :deep(ul), .article-body :deep(ol) { padding-left: 20px; margin-bottom: 18px; }
.article-body :deep(li) { margin-bottom: 8px; }
.article-body :deep(strong) { color: var(--text); font-weight: 600; }
.article-body :deep(blockquote) { border-left: 3px solid var(--pink); padding-left: 16px; color: var(--text-3); font-style: italic; margin: 24px 0; }
.article-faq { margin-top: 48px; border-top: 1px solid var(--border); padding-top: 36px; }
.faq-title { font-size: 20px; font-weight: 700; margin-bottom: 24px; }
.faq-item { margin-bottom: 24px; }
.faq-q { font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 6px; }
.faq-a { font-size: 14px; color: var(--text-2); line-height: 1.7; }
.article-final-cta { margin-top: 48px; background: linear-gradient(135deg, rgba(255,45,107,.07), rgba(155,93,229,.05)); border: 1px solid rgba(255,45,107,.18); border-radius: 20px; padding: 32px 28px; text-align: center; }
.final-cta-eyebrow { font-size: 10px; font-family: var(--mono); color: var(--pink); text-transform: uppercase; letter-spacing: .1em; margin-bottom: 10px; }
.final-cta-title { font-size: 22px; font-weight: 800; letter-spacing: -.5px; margin-bottom: 10px; }
.final-cta-sub { font-size: 14px; color: var(--text-2); line-height: 1.7; margin-bottom: 20px; }
.final-cta-btn { display: inline-block; background: linear-gradient(135deg, #FF2D6B, #9B5DE5); color: #fff; font-size: 14px; font-weight: 700; padding: 13px 28px; border-radius: 100px; text-decoration: none; transition: opacity .2s; }
.final-cta-btn:hover { opacity: .88; }
.article-back-footer { margin-top: 36px; text-align: center; }
.article-back-link { font-size: 13px; color: var(--text-3); text-decoration: none; font-family: var(--mono); }
.article-back-link:hover { color: var(--text-2); }
</style>
