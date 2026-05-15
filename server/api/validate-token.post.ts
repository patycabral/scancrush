/**
 * POST /api/validate-token
 * Proxy para o webhook n8n de validação de token.
 * O n8n consulta o Supabase e retorna { valid, used, plan, image_limit }.
 * Nenhuma chave do Supabase fica exposta no servidor Nuxt.
 */

const N8N_WEBHOOK = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/validate-token'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { token } = body ?? {}

  if (!token || typeof token !== 'string' || token.length < 32) {
    return { valid: false }
  }

  const res = await fetch(N8N_WEBHOOK, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({ token }),
  })

  if (!res.ok) {
    return { valid: false }
  }

  return res.json()
})
