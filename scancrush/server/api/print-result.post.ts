/**
 * POST /api/print-result
 * Proxy para o webhook n8n que devolve o resultado salvo (por token), já cortado
 * por plano. Usado para reabrir/recuperar o resultado. URL do n8n fica no servidor.
 */
export default defineEventHandler(async (event) => {
  const base = useRuntimeConfig(event).n8nBase
  const body = await readBody(event).catch(() => ({}))
  try {
    const res = await fetch(`${base}/webhook/print-result`, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ token: body?.token, protocolo: body?.protocolo ?? '', email: body?.email ?? '' }),
    })
    const data = await res.json().catch(() => null)
    setResponseStatus(event, res.status)
    return data ?? { success: false }
  } catch {
    setResponseStatus(event, 502)
    return { success: false, error: { message: 'Não foi possível carregar o resultado.' } }
  }
})
