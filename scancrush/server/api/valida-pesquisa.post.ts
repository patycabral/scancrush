/**
 * POST /api/valida-pesquisa
 * Proxy para o webhook n8n que valida o link da pesquisa (token/validade/status).
 */
export default defineEventHandler(async (event) => {
  const base = useRuntimeConfig(event).n8nBase
  const body = await readBody(event).catch(() => ({}))
  try {
    const res = await fetch(`${base}/webhook/valida-pesquisa`, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(body ?? {}),
    })
    const data = await res.json().catch(() => null)
    setResponseStatus(event, res.status)
    return data ?? {}
  } catch {
    setResponseStatus(event, 502)
    return { status: 'invalida', message: 'Não foi possível validar a pesquisa.' }
  }
})
