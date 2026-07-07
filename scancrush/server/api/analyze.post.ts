/**
 * POST /api/analyze
 * Proxy para o webhook n8n.
 * Resolve CORS em desenvolvimento (browser → localhost → n8n).
 * Em produção também funciona (servidor → n8n, sem CORS).
 */

export default defineEventHandler(async (event) => {
  const N8N_WEBHOOK = `${useRuntimeConfig(event).n8nBase}/webhook/analyze`
  // Lê multipart (imagens + campos de texto)
  const parts = await readMultipartFormData(event)

  if (!parts || parts.length === 0) {
    throw createError({ statusCode: 400, message: 'Nenhum dado recebido.' })
  }

  // ── Validação server-side de upload (M/5.4) ────────────────────────────────
  // O front já valida tipo/tamanho/qtd, mas alguém pode chamar /api/analyze
  // direto. Aqui barramos lixo/abuso ANTES de gastar n8n + IA. O limite real
  // por plano continua sendo validado no n8n pela sessão (C2) — este é o teto
  // absoluto de sanidade.
  const MAX_IMAGE_BYTES = 15 * 1024 * 1024  // 15MB por imagem (o front comprime bem abaixo)
  const MAX_IMAGES      = 12                // teto absoluto (limite por plano é do n8n)
  const MAX_TOTAL_BYTES = 40 * 1024 * 1024  // teto total da requisição

  let imageCount = 0
  let totalBytes = 0
  for (const part of parts) {
    totalBytes += part.data?.length ?? 0
    if (!part.filename) continue // campo de texto (token, plan, etc.)
    imageCount++
    const type = (part.type ?? '').toLowerCase()
    if (!type.startsWith('image/')) {
      return { success: false, error: 'invalid_upload', message: 'Envie apenas imagens (prints da conversa).' }
    }
    if ((part.data?.length ?? 0) > MAX_IMAGE_BYTES) {
      return { success: false, error: 'invalid_upload', message: 'Uma das imagens é grande demais. Tente novamente.' }
    }
  }
  if (imageCount === 0) {
    return { success: false, error: 'invalid_upload', message: 'Nenhuma imagem foi enviada.' }
  }
  if (imageCount > MAX_IMAGES) {
    return { success: false, error: 'invalid_upload', message: 'Foram enviadas imagens demais.' }
  }
  if (totalBytes > MAX_TOTAL_BYTES) {
    return { success: false, error: 'invalid_upload', message: 'O envio total ficou grande demais. Reduza a quantidade de prints.' }
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
