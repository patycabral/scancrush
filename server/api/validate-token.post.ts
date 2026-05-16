/**
 * POST /api/validate-token
 * Proxy para o webhook n8n de validação de token.
 * Nenhuma chave do Supabase fica exposta no servidor Nuxt.
 *
 * Resposta esperada do n8n:
 *   válido:   { valid: true,  plan: "basic"|"plus"|"full", max_images: 5, used: false }
 *   inválido: { valid: false, error: "TOKEN_INVALID"|"TOKEN_EXPIRED"|"TOKEN_ALREADY_USED" }
 */

const N8N_WEBHOOK = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/validate-token'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { token } = body ?? {}

  if (!token || typeof token !== 'string' || token.length < 32) {
    return { valid: false, error: 'TOKEN_INVALID' }
  }

  try {
    const res = await fetch(N8N_WEBHOOK, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ token }),
    })

    if (!res.ok) return { valid: false, error: 'TOKEN_INVALID' }

    return res.json()
  } catch {
    return { valid: false, error: 'TOKEN_INVALID' }
  }
})
