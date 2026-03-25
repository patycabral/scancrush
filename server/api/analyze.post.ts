/**
 * POST /api/analyze
 * Proxy para o webhook n8n.
 * Resolve CORS em desenvolvimento (browser → localhost → n8n).
 * Em produção também funciona (servidor → n8n, sem CORS).
 */

const N8N_WEBHOOK = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/analyze'

export default defineEventHandler(async (event) => {
  // Lê multipart (imagens + campos de texto)
  const parts = await readMultipartFormData(event)

  if (!parts || parts.length === 0) {
    throw createError({ statusCode: 400, message: 'Nenhum dado recebido.' })
  }

  // Reconstrói o FormData para repassar ao n8n
  const form = new FormData()

  for (const part of parts) {
    const name = part.name ?? 'field'

    if (part.filename) {
      // Arquivo (imagem)
      const blob = new Blob([part.data], { type: part.type ?? 'application/octet-stream' })
      form.append(name, blob, part.filename)
    } else {
      // Campo de texto
      form.append(name, part.data.toString())
    }
  }

  // Encaminha para o n8n
  const res = await fetch(N8N_WEBHOOK, { method: 'POST', body: form })

  if (!res.ok) {
    throw createError({ statusCode: res.status, message: `n8n retornou ${res.status}` })
  }

  return res.json()
})
