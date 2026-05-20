/**
 * POST /api/mark-upsell-intent
 * Marca upsell_intent=true na sessão quando o usuário clica no botão
 * de upsell. O WF01 usa esse flag para encontrar a sessão correta
 * quando o pagamento do upsell é confirmado pela Kiwify.
 *
 * Body: { token: string }
 * Response: { ok: true } | { ok: false }
 */

const N8N_WEBHOOK = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/mark-upsell-intent'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { token } = body ?? {}

  if (!token || typeof token !== 'string' || token.length < 32) {
    return { ok: false }
  }

  try {
    const res = await fetch(N8N_WEBHOOK, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ token }),
    })
    return res.ok ? { ok: true } : { ok: false }
  } catch {
    return { ok: false }
  }
})
