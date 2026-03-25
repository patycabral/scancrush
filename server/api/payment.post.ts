/**
 * POST /api/payment
 * Endpoint legado — pagamento e geração de token agora são processados
 * pelo workflow n8n (Kiwify webhook → Supabase → redirect /tack).
 * Este arquivo existe apenas para evitar erros de build.
 */

export default defineEventHandler(async () => {
  throw createError({
    statusCode: 410,
    message: 'Este endpoint não está mais em uso. O pagamento é processado via Kiwify + n8n.',
  })
})
