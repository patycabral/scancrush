/**
 * POST /api/validate-access-token
 * Proxy para o webhook n8n de validação do token de acesso (pós-compra).
 * A URL do n8n fica só no servidor (não vai pro bundle do cliente).
 */
export default defineEventHandler(async (event) => {
  const base = useRuntimeConfig(event).n8nBase
  const body = await readBody(event).catch(() => ({}))
  try {
    const res = await fetch(`${base}/webhook/validate-access-token`, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ token: body?.token, email: body?.email ?? '' }),
    })
    const data = await res.json().catch(() => null)
    setResponseStatus(event, res.status)
    return data ?? { success: false }
  } catch {
    setResponseStatus(event, 502)
    return { success: false, error: { message: 'Não foi possível validar seu acesso.' } }
  }
})
