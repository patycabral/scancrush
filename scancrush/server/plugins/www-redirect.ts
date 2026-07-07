/**
 * Redirect www → sem-www (301), como plugin do Nitro.
 * O middleware em server/middleware não alcança páginas prerenderizadas
 * (o handler de assets estáticos roda antes). O hook 'request' roda antes
 * de tudo, inclusive dos estáticos.
 */
export default defineNitroPlugin((nitroApp) => {
  nitroApp.hooks.hook('request', (event) => {
    const host = getRequestHost(event, { xForwardedHost: true })
    if (host && host.toLowerCase().startsWith('www.')) {
      const target = host.slice(4)
      return sendRedirect(event, `https://${target}${event.path}`, 301)
    }
  })
})
