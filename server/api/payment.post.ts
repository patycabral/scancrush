/**
 * POST /api/payment
 * Confirmação de pagamento e geração do token de acesso
 *
 * Em produção: este endpoint será chamado pelo webhook do Kiwify/Stripe
 * Por enquanto: mock que aprova qualquer requisição (para testes)
 *
 * TODO: validar assinatura do webhook antes de gerar token
 */

import { createAnalysisToken } from './analyze.post'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { plan = 'basic' } = body

  // TODO: validar webhook real
  // const signature = getHeader(event, 'x-kiwify-signature')
  // if (!isValidSignature(signature, body)) throw createError({ statusCode: 401 })

  // Gera token de acesso único com validade de 15 minutos
  const token = createAnalysisToken(plan)

  // Monta URL de redirecionamento com o token
  const origin = getRequestURL(event).origin
  const redirectUrl = `${origin}/scan?token=${token}`

  return {
    success: true,
    token,
    redirectUrl,
    // O usuário será redirecionado para esta URL após o pagamento
  }
})
