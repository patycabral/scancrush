/**
 * POST /api/research
 * Proxy para o webhook n8n que salva as respostas da pesquisa de satisfação.
 */
export default defineEventHandler(async (event) => {
  const base = useRuntimeConfig(event).n8nBase
  const body = await readBody(event).catch(() => ({}))
  try {
    const res = await fetch(`${base}/webhook/research`, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(body ?? {}),
    })
    const data = await res.json().catch(() => null)
    setResponseStatus(event, res.status)
    return data ?? { status: 'ok' }
  } catch {
    setResponseStatus(event, 502)
    return { status: 'error' }
  }
})
