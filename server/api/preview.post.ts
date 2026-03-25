/**
 * POST /api/preview
 * Análise gratuita e limitada — sem token necessário
 *
 * TODO: integrar Claude API para gerar preview real
 * Retorna apenas uma frase de teaser para motivar o upgrade
 */

export default defineEventHandler(async (event) => {
  const body = await readBody(event)

  // TODO: passar body (observations, emotionalTags) para o prompt da IA
  // const { observations, emotionalTags, name } = body

  // Mock MVP — substituir por chamada real à Claude API
  return {
    preview: 'Existe interesse… mas os padrões revelam algo que você precisa ver com mais calma.',
  }
})
