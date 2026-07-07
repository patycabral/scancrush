export default defineNuxtConfig({
  devtools: { enabled: true },

  // Base do n8n fica SÓ no servidor (não vai pro bundle do cliente).
  // Em produção, defina NUXT_N8N_BASE no EasyPanel; sem isso, usa o fallback.
  runtimeConfig: {
    n8nBase: process.env.NUXT_N8N_BASE || 'https://scancrush-n8n.xpsbu9.easypanel.host',
  },

  modules: ['@nuxtjs/tailwindcss', '@nuxt/content'],

  css: ['~/assets/css/main.css'],

  typescript: {
    strict: true,
  },

  app: {
    head: {
      htmlAttrs: { lang: 'pt-BR' },
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1',
      title: 'ScanCrush — Análise emocional de conversas',
      meta: [
        { name: 'description', content: 'Descubra o que realmente está por trás das mensagens.' },
        { property: 'og:title', content: 'ScanCrush' },
        { property: 'og:description', content: 'Análise emocional de conversas com IA.' },
      ],
      // gtag carrega via plugins/gtag.client.ts (não bloqueia a primeira pintura)
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
        // Fontes self-hosted (variáveis): sem ida ao Google Fonts
        { rel: 'preload', as: 'font', type: 'font/woff2', href: '/fonts/sora-latin.woff2', crossorigin: '' },
        { rel: 'preload', as: 'font', type: 'font/woff2', href: '/fonts/jetbrains-mono-latin.woff2', crossorigin: '' },
      ],
    },
  },

  // Tailwind config via @nuxtjs/tailwindcss
  tailwindcss: {
    configPath: '~/tailwind.config.ts',
  },

  // Páginas públicas: prerenderizadas no build (HTML estático + gzip/brotli).
  // Páginas privadas: client-only (sem indexação).
  routeRules: {
    '/':           { prerender: true },
    '/lp':         { redirect: { to: '/', statusCode: 301 } },
    '/sobre':      { prerender: true },
    '/blog':       { prerender: true },
    '/blog/**':    { prerender: true },
    '/quiz':       { prerender: true },
    '/quiz/**':    { prerender: true },
    '/scan':       { ssr: false },
    '/tack':       { ssr: false },
    '/privacy':    { ssr: false },
    '/terms':      { ssr: false },
  },

  content: {
    highlight: false,
  },

  nitro: {
    compressPublicAssets: true,
    prerender: {
      crawlLinks: true,
      routes: ['/', '/blog', '/quiz', '/sobre'],
      ignore: ['/scan', '/acesso', '/analise', '/obrigada', '/tack', '/pesquisa', '/privacy', '/terms', '/api'],
    },
    routeRules: {
      '/_nuxt/**': { headers: { 'cache-control': 'public, max-age=31536000, immutable' } },
      '/fonts/**': { headers: { 'cache-control': 'public, max-age=31536000, immutable' } },
    },
  },

  compatibilityDate: '2024-11-01',
})
