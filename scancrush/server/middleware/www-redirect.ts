/**
 * Redirect www → sem-www (301).
 * Hoje www.scancrush.com responde a página (status 200), duplicando o site.
 * O canonical já resolve pro Google, mas o 301 deixa uma URL só, 100% limpo.
 */
export default defineEventHandler((event) => {
  const host = getRequestHost(event, { xForwardedHost: true })
  if (host && host.toLowerCase().startsWith('www.')) {
    const target = host.slice(4) // remove "www."
    return sendRedirect(event, `https://${target}${event.path}`, 301)
  }
})
