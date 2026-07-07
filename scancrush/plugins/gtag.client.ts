// Google Analytics (gtag) carregado fora do caminho crítico.
// O script só entra depois que a página pinta, então não custa FCP/LCP
// nem aparece como "JS não usado" no carregamento inicial.
export default defineNuxtPlugin(() => {
  const GA_ID = 'G-CFLFJK84RL'

  window.dataLayer = window.dataLayer || []
  function gtag(...args: unknown[]) {
    window.dataLayer.push(args)
  }
  // @ts-expect-error — API global do GA
  window.gtag = gtag
  gtag('js', new Date())
  gtag('config', GA_ID)

  let loaded = false
  const load = () => {
    if (loaded) return
    loaded = true
    const s = document.createElement('script')
    s.src = `https://www.googletagmanager.com/gtag/js?id=${GA_ID}`
    s.async = true
    document.head.appendChild(s)
  }

  // Carrega no idle após o load (ou na primeira interação, o que vier antes)
  if (document.readyState === 'complete') {
    setTimeout(load, 0)
  } else {
    window.addEventListener('load', () => {
      if ('requestIdleCallback' in window) requestIdleCallback(load, { timeout: 3000 })
      else setTimeout(load, 1500)
    })
  }
  for (const evt of ['pointerdown', 'keydown', 'touchstart', 'scroll'] as const) {
    window.addEventListener(evt, load, { once: true, passive: true })
  }
})

declare global {
  interface Window {
    dataLayer: unknown[]
  }
}
