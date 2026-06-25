<script setup lang="ts">
useHead({ title: 'ScanCrush — Análise da conversa' })

// ════════════════════════════════════════════════════
// PLAN LIMITS
// currentPlan is set here for frontend UX only.
// ⚠️ BACKEND REQUIRED: validate plan + usage server-side
// ════════════════════════════════════════════════════
const PLAN_LIMITS: Record<string, number> = { free: 1, revealed: 4, raiox: 10 }

const CHECKOUT_URLS = {
  basico:   'https://go.perfectpay.com.br/PPU38CQDB0D',
  revealed: 'https://go.perfectpay.com.br/PPU38CQC51R',
  raiox:    'https://go.perfectpay.com.br/PPU38CQC51K',
}

function goToCheckout(plan: 'basico' | 'revealed' | 'raiox') {
  if (import.meta.client) window.location.href = CHECKOUT_URLS[plan]
}

// LAUNCH_MODE: true = análise gratuita e sem restrições
// Altere para FALSE para ativar paywall e limites reais
const LAUNCH_MODE = false

const currentPlan = ref<string>('free')

function getImageLimit(): number {
  return PLAN_LIMITS[currentPlan.value] || 1   // || captura também 0 inválido vindo do token
}

// ── Screen control ──
const currentScreen = ref<number>(1)

function goTo(n: number) {
  currentScreen.value = n
  if (import.meta.client) window.scrollTo({ top: 0, behavior: 'smooth' })
  if (n === 2) checkAnalysisDone()
}

// ── Upload state ──
const uploadedFiles = ref<File[]>([])
const filePreviews = ref<{ src: string; idx: number; name: string }[]>([])
const showUploadMeta = ref(false)
const uploadCounterText = ref('0 / 1 imagem')
const uploadCounterClass = ref('')
const uploadBarWidth = ref('0%')
const uploadBarClass = ref('')
const showLimitAlert = ref(false)
const limitAlertText = ref('⚠️ Você atingiu o limite de imagens do seu plano.')
const btnContinueDisabled = ref(true)
const dropAreaStyle = ref({ pointerEvents: 'auto' as any, opacity: '1' })

// ── Drop area drag state ──
const isDragOver = ref(false)

function onDragOver(e: DragEvent) {
  e.preventDefault()
  isDragOver.value = true
}
function onDragLeave() {
  isDragOver.value = false
}
function onDrop(e: DragEvent) {
  e.preventDefault()
  isDragOver.value = false
  if (e.dataTransfer?.files) handleFiles(e.dataTransfer.files)
}
function onFileChange(e: Event) {
  const input = e.target as HTMLInputElement
  if (input.files) handleFiles(input.files)
}

// ── Limites por imagem (anti-arquivo pesado / anti-montagem) ──
const MAX_IMG_BYTES = 2 * 1024 * 1024   // 2 MB por imagem
const MAX_IMG_ASPECT = 5                 // lado maior até 5× o menor (print normal ~2,2:1; montagem de 3+ telas reprova)

// Carrega a imagem só para medir a proporção (largura × altura)
function getImageAspect(file: File): Promise<number> {
  return new Promise((resolve) => {
    const url = URL.createObjectURL(file)
    const img = new Image()
    img.onload = () => {
      URL.revokeObjectURL(url)
      const w = img.naturalWidth, h = img.naturalHeight
      resolve(w && h ? Math.max(w, h) / Math.min(w, h) : 1)
    }
    img.onerror = () => { URL.revokeObjectURL(url); resolve(1) }
    img.src = url
  })
}

async function handleFiles(newFiles: FileList | File[]) {
  const limit = getImageLimit()
  const imgs = Array.from(newFiles).filter(f => f.type.startsWith('image/'))
  if (!imgs.length) return
  // iOS returns files in reverse selection order when selecting multiple at once; restore intended order
  if (imgs.length > 1) imgs.reverse()

  const slots = limit - uploadedFiles.value.length
  if (slots <= 0) { updateUploadUI(); return }
  const candidates = imgs.slice(0, slots)

  // Valida tamanho + proporção de cada arquivo
  const accepted: File[] = []
  let rejectTitle = '', rejectMsg = ''
  for (const f of candidates) {
    if (f.size > MAX_IMG_BYTES) {
      rejectTitle = 'Essa imagem ficou pesada demais'
      rejectMsg = 'Para a leitura sair certinha, cada print precisa ter até 2MB. Envie a imagem direto da galeria, sem editar — o print original da conversa já é tudo que a gente precisa. 💜'
      continue
    }
    const aspect = await getImageAspect(f)
    if (aspect > MAX_IMG_ASPECT) {
      rejectTitle = 'Isso parece uma montagem'
      rejectMsg = 'A leitura fica mais precisa com o print original da conversa, do jeitinho que ele aparece no seu celular — sem várias telas coladas numa imagem só. 💜'
      continue
    }
    accepted.push(f)
  }

  if (accepted.length) {
    uploadedFiles.value = [...uploadedFiles.value, ...accepted]
    renderPreviews()
    btnContinueDisabled.value = false
  }
  updateUploadUI()
  // imagem rejeitada (tamanho/proporção) → popup de aviso, mais visível que o alerta inline
  if (rejectMsg) {
    invalidContentTitle.value = rejectTitle
    invalidContentMsg.value = rejectMsg
    showInvalidContent.value = true
    if (import.meta.client) document.body.style.overflow = 'hidden'
  }
}

function updateUploadUI() {
  const limit = getImageLimit()
  const count = uploadedFiles.value.length
  const pct = Math.min((count / limit) * 100, 100)
  const unit = limit === 1 ? 'imagem' : 'imagens'

  if (count > 0) showUploadMeta.value = true

  uploadCounterText.value = `${count} / ${limit} ${unit}`
  uploadCounterClass.value = pct >= 100 ? 'full' : pct >= 70 ? 'warn' : ''

  uploadBarWidth.value = pct + '%'
  uploadBarClass.value = pct >= 100 ? 'full' : pct >= 70 ? 'warn' : ''

  if (count >= limit && !LAUNCH_MODE) {
    dropAreaStyle.value = { pointerEvents: 'none', opacity: '0.45' }
    showLimitAlert.value = true
    if (currentPlan.value === 'free') {
      limitAlertText.value = '⚠️ Este plano analisa somente 1 print por análise. '
    } else {
      limitAlertText.value = `⚠️ Você atingiu o limite de ${limit} ${unit} do seu plano. Faça upgrade para enviar mais.`
    }
  } else if (count < limit || LAUNCH_MODE) {
    dropAreaStyle.value = { pointerEvents: 'auto', opacity: '1' }
    showLimitAlert.value = false
  }
}

function renderPreviews() {
  // Revoke old URLs
  filePreviews.value.forEach(p => URL.revokeObjectURL(p.src))
  if (uploadedFiles.value.length === 0) {
    filePreviews.value = []
    return
  }
  filePreviews.value = uploadedFiles.value.map((file, idx) => ({
    src:  URL.createObjectURL(file),
    idx,
    name: file.name,
  }))
}

function removeFile(idx: number) {
  uploadedFiles.value = uploadedFiles.value.filter((_, i) => i !== idx)
  renderPreviews()
  updateUploadUI()
  if (uploadedFiles.value.length === 0) {
    btnContinueDisabled.value = true
    showUploadMeta.value = false
  }
}

function removeAllFiles() {
  uploadedFiles.value = []
  renderPreviews()
  showUploadMeta.value = false
  showLimitAlert.value = false
  dropAreaStyle.value = { pointerEvents: 'auto', opacity: '1' }
  btnContinueDisabled.value = true
}

// ── Paid flow detection ──
const accessToken = ref('')
const customerId = ref('')

// ── Screen 2: Observations ──
const userName  = ref('')
const userEmail = ref('')
const bDay = ref('')
const bMonth = ref('')
const bYear = ref('')
const observations = ref('')
const selectedTags = ref<string[]>([])
const userAgeRange  = ref('')
const crushName     = ref('')
const crushAgeRange = ref('')
const termsAccepted = ref(false)
const showValidationMsg = ref(false)
const validationMsgHtml = ref('')
const showInvalidContent = ref(false)
const invalidContentMsg = ref('')
const invalidContentTitle = ref('Esse print não parece uma conversa')
function closeInvalidContent() {
  showInvalidContent.value = false
  if (import.meta.client) document.body.style.overflow = ''
}
const showAnalysisBlockedMsg = ref(false)
const showBtnGenerate = ref(true)

const TAGS = [
  'animado(a)', 'feliz', 'confuso(a)', 'ansioso(a)',
  'carente', 'curioso(a)', 'magoado(a)', 'inseguro(a)',
  'frustrado(a)', 'empolgado(a)', 'confiante',
  'esperançoso(a)', 'gostando dele(a)',
  'com medo de perder', 'me sentindo ignorado(a)',
  'parecendo que só eu me esforço',
]

function toggleTag(tag: string) {
  const idx = selectedTags.value.indexOf(tag)
  if (idx === -1) selectedTags.value.push(tag)
  else selectedTags.value.splice(idx, 1)
}

// Days options: 1–31
const dayOptions = Array.from({ length: 31 }, (_, i) => {
  const d = String(i + 1).padStart(2, '0')
  return { value: d, label: d }
})

// Year options: current -10 down to 1930
const currentYear = new Date().getFullYear()
const yearOptions = Array.from(
  { length: currentYear - 10 - 1930 + 1 },
  (_, i) => ({ value: String(currentYear - 10 - i), label: String(currentYear - 10 - i) })
)

function checkAnalysisDone() {
  // Sem limite de quantidade no cliente: cada token = 1 análise (uso único garantido no servidor).
  showBtnGenerate.value = true
  showAnalysisBlockedMsg.value = false
}

function validateS2(): boolean {
  const missing: string[] = []
  if (!userAgeRange.value) missing.push('sua <strong>faixa etária</strong>')
  if (selectedTags.value.length === 0) missing.push('pelo menos um <strong>sentimento</strong>')

  let msg = ''
  if (missing.length === 1) {
    msg = `Preencha ${missing[0]}`
  } else if (missing.length > 1) {
    const last = missing[missing.length - 1]
    const rest = missing.slice(0, -1)
    msg = `Preencha ${rest.join(', ')} e ${last}`
  }
  if (!termsAccepted.value) {
    const terms = 'confirme que é <strong>maior de 18 anos</strong> e aceite os <strong>Termos</strong>'
    msg = msg ? `${msg}, e ${terms}` : `Por favor, ${terms}`
  }

  if (msg) {
    validationMsgHtml.value = `⚠️ ${msg} para continuar.`
    showValidationMsg.value = true
    return false
  }
  showValidationMsg.value = false
  return true
}

// ── Screen 3: Loading ──
const loadingMessages = [
  ['Lendo os prints...', 'identificando quem é quem na conversa'],
  ['Mapeando padrões...', 'quem inicia, quem some, quem responde com pressa'],
  ['Analisando consistência...', 'o que ele(a) diz vs. o que ele(a) faz'],
  ['Identificando sinais...', 'positivos, negativos e os que passam despercebidos'],
  ['Calculando o score...', 'baseado em comportamento, não em intenção'],
  ['Gerando o relatório...', 'quase pronto — vale cada segundo'],
]
const loadingText = ref('')
const loadingSub = ref('')
const loadingProgress = ref(0)
let msgIdx = 0
let msgInterval: ReturnType<typeof setInterval> | null = null
let progressInterval: ReturnType<typeof setInterval> | null = null

function updateLoadingMsg() {
  loadingText.value = loadingMessages[0][0]
  loadingSub.value  = loadingMessages[0][1]
  loadingProgress.value = 0

  // Avança texto a cada 18s (6 msgs × 18s = ~108s antes de loop)
  msgInterval = setInterval(() => {
    msgIdx = (msgIdx + 1) % loadingMessages.length
    loadingText.value = ''
    setTimeout(() => {
      loadingText.value = loadingMessages[msgIdx][0]
      loadingSub.value  = loadingMessages[msgIdx][1]
    }, 300)
  }, 18000)

  // Progresso fake: avança até 92% em ~7min, para de crescer após isso
  progressInterval = setInterval(() => {
    if (loadingProgress.value < 92) {
      // acelera no começo, desacelera no final
      const step = loadingProgress.value < 30 ? 1.2 : loadingProgress.value < 60 ? 0.7 : 0.25
      loadingProgress.value = Math.min(92, loadingProgress.value + step)
    }
  }, 1000)
}

// ── Image count warning (sent fewer than plan allows) ──
const showImageCountWarning = ref(false)

function tryProceed() {
  if (uploadedFiles.value.length === 0) return
  const limit = getImageLimit()
  if (limit > 1 && uploadedFiles.value.length < limit) {
    showImageCountWarning.value = true
    if (import.meta.client) document.body.style.overflow = 'hidden'
  } else {
    openConfirmDialog()
  }
}

function closeImageCountWarning() {
  showImageCountWarning.value = false
  if (import.meta.client) document.body.style.overflow = ''
}

function proceedFromWarning() {
  closeImageCountWarning()
  openConfirmDialog()
}

// ── Confirm dialog (pre-send) ──
const showConfirmDialog = ref(false)

// Scroll state for the confirm previews carousel
const confirmPreviewsEl   = ref<HTMLElement | null>(null)
const confirmScrollLeft   = ref(0)
const confirmCanScrollRight = ref(false)

function onConfirmScroll() {
  const el = confirmPreviewsEl.value
  if (!el) return
  confirmScrollLeft.value     = el.scrollLeft
  confirmCanScrollRight.value = el.scrollLeft + el.clientWidth < el.scrollWidth - 2
}

function scrollConfirm(dir: 1 | -1) {
  confirmPreviewsEl.value?.scrollBy({ left: dir * 200, behavior: 'smooth' })
}

function updateConfirmScroll() {
  nextTick(() => {
    const el = confirmPreviewsEl.value
    if (!el) return
    confirmScrollLeft.value     = 0
    confirmCanScrollRight.value = el.scrollWidth > el.clientWidth + 2
  })
}

function openConfirmDialog() {
  if (uploadedFiles.value.length === 0) return
  showConfirmDialog.value = true
  if (import.meta.client) document.body.style.overflow = 'hidden'
  updateConfirmScroll()
}

function closeConfirmDialog() {
  showConfirmDialog.value = false
  if (import.meta.client) document.body.style.overflow = ''
}

// ── Lightbox (expand image preview) ──
const lightboxSrc = ref<string | null>(null)
function openLightbox(src: string) { lightboxSrc.value = src }
function closeLightbox() { lightboxSrc.value = null }

// ── Drag to reorder previews ──
const dragPreviewIdx = ref<number | null>(null)
const dragOverIdx    = ref<number | null>(null)

function onPreviewDragStart(visualIdx: number) {
  dragPreviewIdx.value = visualIdx
}

function onPreviewDrop(targetIdx: number) {
  const src = dragPreviewIdx.value
  dragPreviewIdx.value = null
  dragOverIdx.value    = null
  if (src === null || src === targetIdx) return
  const files = [...uploadedFiles.value]
  const [moved] = files.splice(src, 1)
  files.splice(targetIdx, 0, moved)
  uploadedFiles.value = files
  renderPreviews()
}

// ── Screen 4: Result ──
const scoreBarWidth = ref('0%')
// Cover width = inverted scoreBarWidth (dark cover from right that shrinks as score grows)
const scoreBarCoverWidth = computed(() => {
  const pct = parseFloat(scoreBarWidth.value) || 0
  return `${100 - pct}%`
})
const btnNewAnalysisText = ref('Nova análise')
const btnNewAnalysisStyle = ref({})

// Dados do resultado vindos do webhook
const resultPlan     = ref('')
const resultData     = ref<any>(null)
const resultCta      = ref<any>(null)
const resultRelDyn   = ref<any>(null)
const resultUserName  = ref<string>('')   // nome da usuária para normalização de texto
const resultUserEmail = ref<string>('')   // e-mail do comprador — atribuição no PDF (anti-compartilhamento)
const resultProtocol  = ref<string>('')   // ID/protocolo da análise (legitimidade no PDF)
const resultPrintCount = ref<number | null>(null)  // nº de prints analisados (capa)
const resultAnalysisDate = ref<string>('')          // data REAL da análise (gerado_at)
const resultFeelingsRaw = ref<string>('')           // sentimentos relatados no form — eco no "Para você"
const resultFeelings = computed<string[]>(() => {
  const fromData = resultFeelingsRaw.value
    ? resultFeelingsRaw.value.split(',').map(s => s.trim()).filter(Boolean)
    : []
  return fromData.length ? fromData : selectedTags.value
})


/** Extrai texto de um item que pode ser string ou objeto {label, text, description, situation} */
function txt(item: any): string {
  if (!item) return ''
  if (typeof item === 'string') return item
  return item.label || item.title || item.text || item.description || item.situation || ''
}

/** Extrai subtexto complementar de um item (ex: contradiction de inconsistencies) */
function txtSub(item: any): string {
  if (!item || typeof item === 'string') return ''
  return item.contradiction || item.explanation || item.subtitle || ''
}

/** Normaliza texto da IA: CRUSH → Crush, nome da usuária → você (sem forçar maiúscula no meio da frase) */
function norm(text: string): string {
  if (!text) return text
  let t = text.replace(/\bCRUSH\b/g, 'Crush')
  if (resultUserName.value) {
    const firstName = resultUserName.value.split(' ')[0]
    if (firstName && firstName.toLowerCase() !== 'você') {
      try {
        const escaped = firstName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
        // substitui o nome por "você" minúsculo — sem capitalizar no meio da frase
        t = t.replace(new RegExp(`\\b${escaped}\\b`, 'g'), 'você')
      } catch { /* segurança: não quebra se regex falhar */ }
    }
  }
  // "Você" com maiúscula APENAS no início do texto (começo de frase)
  t = t.replace(/^(\s*)você\b/, '$1Você')
  return t
}

/** Primeira letra maiúscula (valores curtos: engajamento, postura, consistência) */
function capFirst(text: string): string {
  if (!text) return text
  return text.charAt(0).toUpperCase() + text.slice(1)
}

/** Mapeia user_posture.level → nomenclatura neutra */
const postureLevelMap: Record<string, string> = {
  'carente':    'Alta busca por conexão',
  'emocionado': 'Investimento emocional elevado',
  'emocionada': 'Investimento emocional elevado',
  'ansioso':    'Alta ansiedade emocional',
  'ansiosa':    'Alta ansiedade emocional',
  'inseguro':   'Busca por validação',
  'insegura':   'Busca por validação',
  'investido':  'Alto investimento afetivo',
  'investida':  'Alto investimento afetivo',
}
function postureLabel(level: string): string {
  return postureLevelMap[level?.toLowerCase()] ?? level
}

/** key_patterns achatados para Resumo Executivo */
const allKeyPatterns = computed(() => {
  const res: { text: string; kind: 'pos' | 'neg' }[] = []
  for (const item of resultData.value?.key_patterns?.positive ?? []) {
    res.push({ text: txt(item), kind: 'pos' })
  }
  for (const item of resultData.value?.key_patterns?.negative ?? []) {
    res.push({ text: txt(item), kind: 'neg' })
  }
  return res.slice(0, 5)
})

/** Há pelo menos 1 sinal? (evita renderizar "Sinais na conversa" vazio) */
const hasSignals = computed(() => {
  const s = resultData.value?.signals
  if (!s) return false
  return ((s.positive?.length ?? 0) + (s.negative?.length ?? 0) + (s.neutral?.length ?? 0)) > 0
})

/** deep_analysis normalizado: aceita strings (legado) e objetos {tone,title,text} */
const deepAnalysisItems = computed(() => {
  const arr = resultData.value?.deep_analysis ?? []
  const toneMap: Record<string, string> = {
    positivo: 'positivo', negativo: 'negativo',
    atencao: 'atencao', 'atenção': 'atencao', neutro: 'atencao',
  }
  return arr.map((item: any) => {
    if (typeof item === 'string') return { tone: '', title: '', text: item }
    return {
      tone:  toneMap[(item.tone || '').toLowerCase()] ?? '',
      title: item.title || '',
      text:  item.text || txt(item),
    }
  })
})

/** Mapeia situation_label.level → texto do pill */
function verdictText(level: string | null): string {
  const map: Record<string, string> = {
    cilada:    '🚨 Atenção: sinais preocupantes',
    'atenção': '⚠️ Prossiga com cautela',
    atencao:   '⚠️ Prossiga com cautela',
    'dúvida':  '🤔 Situação ambígua',
    duvida:    '🤔 Situação ambígua',
    seguro:    '✅ Sinais positivos',
  }
  return map[level ?? ''] ?? '— Resultado gerado'
}

function downloadPdf() {
  if (import.meta.client) window.print()
}

// ── PDF premium: data formatada + geometria do medidor de score ──
const analysisDateFormatted = computed(() => {
  try {
    // Usa a data REAL da análise (gerado_at do n8n); cai para "agora" só se ausente.
    const d = resultAnalysisDate.value ? new Date(resultAnalysisDate.value) : new Date()
    const valid = !isNaN(d.getTime()) ? d : new Date()
    return valid.toLocaleDateString('pt-BR', { day: '2-digit', month: 'long', year: 'numeric' })
  } catch { return '' }
})
/** score limitado a 0–100 para o medidor */
const scoreValue = computed(() => {
  const s = Number(resultData.value?.interest_score)
  return Number.isFinite(s) ? Math.max(0, Math.min(100, s)) : 0
})
/** posição X do marcador no SVG do score (viewBox 0 0 500 –, trilho 30→470) */
const scoreMarkerX = computed(() => 30 + (scoreValue.value / 100) * 440)

/** cobertura (da direita) da barra de reciprocidade — encolhe conforme o score */
const recipScore = computed(() => {
  const s = Number(resultData.value?.reciprocity?.score)
  return Number.isFinite(s) ? Math.max(0, Math.min(100, s)) : 0
})
/** Métricas de reciprocidade com proporção Você×Crush calculada (placar) */
const recipMetrics = computed(() => {
  return (resultData.value?.reciprocity?.metrics ?? []).map((m: any) => {
    const pu = parseFloat(String(m?.user ?? '').replace(/[^\d.]/g, ''))
    const pc = parseFloat(String(m?.crush ?? '').replace(/[^\d.]/g, ''))
    const hasU = Number.isFinite(pu), hasC = Number.isFinite(pc)
    // 0/0 (ou sem número) → NÃO OBSERVADO: barra vazia, sem predominância, fora do score
    const noData = (!hasU && !hasC) || (hasU && hasC && pu === 0 && pc === 0)
    let u: number | null = null, c: number | null = null
    if (!noData) {
      if (hasU && hasC && pu + pc > 0) { const t = pu + pc; u = Math.round((pu / t) * 100); c = 100 - u }
      else if (hasU) { u = Math.round(Math.max(0, Math.min(100, pu))); c = 100 - u }
      else if (hasC) { c = Math.round(Math.max(0, Math.min(100, pc))); u = 100 - c }
    }
    let dominance = ''
    if (!noData && u != null && c != null) {
      dominance = u >= 60 ? 'Você' : c >= 60 ? 'Crush' : 'Equilibrada'
    }
    return { label: m?.label ?? '', user: m?.user ?? '', crush: m?.crush ?? '', u, c, dominance, noData }
  })
})

/** NOVO modelo: critérios pontuados (score/max_score por critério) */
const recipCriteria = computed(() => {
  const arr = resultData.value?.reciprocity?.criteria ?? []
  return arr.map((c: any) => {
    const score = Number(c?.score) || 0
    const max   = Number(c?.max_score) || 0
    const pct   = max > 0 ? Math.min(Math.round((score / max) * 100), 100) : 0
    let status  = String(c?.status ?? '').toLowerCase().trim()
    if (!['forte', 'parcial', 'fraco', 'ausente'].includes(status)) {
      status = max === 0 ? 'ausente' : pct >= 75 ? 'forte' : pct >= 35 ? 'parcial' : 'fraco'
    }
    return { label: c?.label ?? '', explanation: c?.explanation ?? '', score, max, pct, status, noData: status === 'ausente' }
  })
})

/** Veredito do score — faixas determinísticas (0-24 baixa · 25-49 parcial · 50-74 moderada · 75-100 alta) */
const recipLabel = computed(() => {
  const s = recipScore.value
  if (s <= 24) return { title: 'Reciprocidade baixa',    sub: 'Investimento unilateral' }
  if (s <= 49) return { title: 'Reciprocidade parcial',  sub: 'Equilíbrio desigual' }
  if (s <= 74) return { title: 'Reciprocidade moderada', sub: 'Equilíbrio parcial' }
  return              { title: 'Reciprocidade alta',     sub: 'Bem distribuída' }
})

function updateNewAnalysisBtn() {
  if (currentPlan.value === 'free') {
    btnNewAnalysisText.value = 'Fazer upgrade'
    btnNewAnalysisStyle.value = { color: 'var(--pink)' }
  }
}

async function startAnalysis() {
  if (!validateS2()) return

  goTo(3)
  msgIdx = 0
  updateLoadingMsg()

  msgInterval = setInterval(() => {
    msgIdx = (msgIdx + 1) % loadingMessages.length
    loadingText.value = ''
    setTimeout(() => {
      loadingText.value = loadingMessages[msgIdx][0]
      loadingSub.value = loadingMessages[msgIdx][1]
    }, 300)
  }, 1800)

  // ── Build FormData ──
  const form = new FormData()

  // Sempre envia todos os campos do formulário, mesmo os vazios (null/empty string).
  // O n8n recebe o payload completo e decide o que salvar no banco.
  form.append('token',          accessToken.value)
  form.append('plan',           currentPlan.value)
  form.append('image_count',    String(uploadedFiles.value.length))
  form.append('user_age_range', userAgeRange.value || 'não informado')
  // '' = não selecionado, 'null' = "Não sei" selecionado — ambos enviam 'null' ao webhook
  form.append('crush_age_range', (crushAgeRange.value && crushAgeRange.value !== 'null') ? crushAgeRange.value : 'null')
  form.append('observations',   observations.value.trim())
  form.append('feelings',       selectedTags.value.join(', '))
  // Free não tem token/sessão no Supabase: envia nome/e-mail/crush pelo form.
  // No pago esses campos vêm do token (DB) — aqui vão vazios e o n8n os ignora.
  form.append('user_name',      userName.value.trim())
  form.append('user_email',     userEmail.value.trim())
  form.append('crush_name',     crushName.value.trim())

  uploadedFiles.value.forEach(file => form.append('images', file))

  try {
    // ── Todos os planos (free e pago): análise completa via n8n ───
    // O "Separa os Planos" no n8n roteia pelo campo `plan` do form.
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 8 * 60 * 1000)

    const res = await fetch('https://scancrush-n8n.xpsbu9.easypanel.host/webhook/analyze', {
      method: 'POST',
      body: form,
      signal: controller.signal,
    })
    clearTimeout(timeoutId)

    if (!res.ok) throw new Error(`HTTP ${res.status}`)

    const data = await res.json()

    // ── Tratamento de erros do webhook ──────────────────────────
    if (!data?.success) {
      if (msgInterval) clearInterval(msgInterval)
      if (progressInterval) clearInterval(progressInterval)
      if (import.meta.client) sessionStorage.removeItem('sc_analysis_done')

      if (data?.status === 'limit_reached') {
        goTo(5)   // tela de limite 24h
      } else if (data?.error === 'invalid_session') {
        goTo(6)   // tela de sessão inválida/expirada
      } else if (data?.error === 'invalid_content' || data?.error === 'AI_ERROR') {
        // Guardrails/IA: não é conversa ou conteúdo bloqueado → popup amigável + volta ao upload (screen 1)
        goTo(1)
        invalidContentTitle.value = 'Esse print não parece uma conversa'
        invalidContentMsg.value = data?.message ?? 'Uma ou mais imagens enviadas não parecem prints de uma conversa. Volte e confira as imagens antes de enviar novamente.'
        showInvalidContent.value = true
        if (import.meta.client) document.body.style.overflow = 'hidden'
      } else {
        goTo(2)
        validationMsgHtml.value = `⚠️ ${data?.message ?? 'Erro ao processar análise. Tente novamente.'}`
        showValidationMsg.value = true
      }
      return
    }

    // ── Sucesso: popular dados do resultado ─────────────────────
    const plan = data.plan ?? currentPlan.value
    resultPlan.value  = plan
    currentPlan.value = plan   // atualiza isFree para desbloquear conteúdo pago

    resultUserName.value  = data.user_name ?? ''
    resultUserEmail.value = data.user_email ?? ''
    resultProtocol.value  = data.protocol ?? ''
    resultPrintCount.value = data.print_count ?? (uploadedFiles.value.length || null)
    resultAnalysisDate.value = data.generated_at ?? ''
    resultFeelingsRaw.value = data.feelings ?? ''

    // data pode chegar como string JSON ou array do n8n — parsear/desempacotar
    const rawData = typeof data.data === 'string' ? JSON.parse(data.data) : (data.data ?? data.analysis ?? {})
    resultData.value  = Array.isArray(rawData) ? (rawData[0] ?? {}) : rawData
    // cta é sempre string de texto — nunca JSON.parse
    resultCta.value   = data.cta ?? null

    // relationship_dynamics: pode vir na raiz (legado) ou normalizado no webhook_response
    const relDyn = data.relationship_dynamics ?? data.analysis?.executive_summary?.relationship_dynamics ?? null
    resultRelDyn.value = relDyn ? {
      'Análise do Usuário (você)': relDyn.user   ?? relDyn['Análise do Usuário (você)'] ?? null,
      'Análise do(a) Crush':       relDyn.crush  ?? relDyn['Análise do(a) Crush']       ?? null,
      'Conclusão':                 relDyn.conclusion ?? data.analysis?.executive_summary?.conclusion ?? null,
    } : null

    if (msgInterval) clearInterval(msgInterval)
    if (progressInterval) clearInterval(progressInterval)
    loadingProgress.value = 100
    await new Promise(r => setTimeout(r, 400)) // breve flash nos 100% antes de trocar tela
    goTo(4)
    updateNewAnalysisBtn()

    // Animar barra do score após render
    const score = resultData.value?.interest_score ?? 0
    setTimeout(() => { scoreBarWidth.value = `${Math.min(score, 100)}%` }, 100)

  } catch {
    if (msgInterval) clearInterval(msgInterval)
    if (progressInterval) clearInterval(progressInterval)
    if (import.meta.client) sessionStorage.removeItem('sc_analysis_done')
    goTo(2)
    validationMsgHtml.value = '⚠️ Erro ao processar sua análise. Verifique sua conexão e tente novamente.'
    showValidationMsg.value = true
  }
}

// ── Modal ──
const isModalOpen = ref(false)

function openModal() {
  isModalOpen.value = true
  if (import.meta.client) document.body.style.overflow = 'hidden'
}
function closeModal() {
  isModalOpen.value = false
  if (import.meta.client) document.body.style.overflow = ''
}
function handleOverlayClick(e: MouseEvent) {
  if ((e.target as HTMLElement).classList.contains('modal-overlay')) closeModal()
}

// ── Handle "Fazer nova análise" — sempre abre modal de planos ──
function handleNewAnalysis() {
  openModal()
}

function resetAll() {
  uploadedFiles.value = []
  renderPreviews()
  btnContinueDisabled.value = true
  userName.value  = ''
  userEmail.value = ''
  userAgeRange.value  = ''
  observations.value  = ''
  selectedTags.value  = []
  crushName.value     = ''
  crushAgeRange.value = ''
  termsAccepted.value = false
  scoreBarWidth.value = '0%'
  showUploadMeta.value = false
  uploadCounterText.value = ''
  uploadBarWidth.value = '0%'
  uploadBarClass.value = ''
  uploadCounterClass.value = ''
  showLimitAlert.value = false
  dropAreaStyle.value = { pointerEvents: 'auto', opacity: '1' }
  btnNewAnalysisText.value = 'Nova análise'
  btnNewAnalysisStyle.value = {}
  accessToken.value = ''
  customerId.value = ''
  if (import.meta.client) {
    sessionStorage.removeItem('sc_analysis_done')
    localStorage.removeItem('sc_token')
    localStorage.removeItem('sc_plan')
    localStorage.removeItem('sc_plan_name')
    localStorage.removeItem('sc_max_images')
    localStorage.removeItem('sc_expires_at')
  }
  goTo(1)
}

// ── Keyboard esc to close modal / lightbox / upsell ──
function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    if (lightboxSrc.value) { closeLightbox(); return }
    if (showInvalidContent.value) { closeInvalidContent(); return }
    if (showImageCountWarning.value) { closeImageCountWarning(); return }
    if (showConfirmDialog.value) { closeConfirmDialog(); return }
    closeModal()
  }
}

// Plan names for display
const PLAN_NAMES: Record<string, string> = {
  free:     'Primeiras Impressões',
  revealed: 'Sinais Revelados',
  raiox:    'Raio-X do Crush',
}
const planDisplayName = computed(() => PLAN_NAMES[currentPlan.value] ?? 'Primeiras Impressões')
const planImageLimit  = computed(() => PLAN_LIMITS[currentPlan.value] || 1)
const isFree          = computed(() => currentPlan.value === 'free')

// Copy condicional por plano
const uploadTitle    = computed(() => isFree.value ? 'Talvez os sinais já estejam aí' : 'Envie os prints da conversa')
const uploadSubtitle = computed(() => isFree.value
  ? 'Envie 1 print da conversa para gerar sua leitura inicial.'
  : 'A análise identifica padrões, sinais e intenções com base nas mensagens enviadas.')
const dropMainText   = computed(() => isFree.value ? 'Envie 1 print da conversa' : 'Arraste os prints aqui')
const obsQuestion    = computed(() => isFree.value
  ? 'O que te deixou em dúvida nessa conversa?'
  : 'O que mais está te incomodando nessa conversa?')
const obsPlaceholder = computed(() => isFree.value
  ? 'Ex: "às vezes demonstra interesse e depois some" · "não sei se estou exagerando" · "parece diferente comigo"'
  : 'Ex: \'ele responde diferente às vezes\' · \'parece distante\' · \'não sei se estou exagerando\' · \'às vezes demonstra interesse e depois some\'')

// ── Token validation state ──
const route           = useRoute()
// Inicializa como true se já há token na URL — evita flash de conteúdo antes do overlay aparecer
const tokenValidating = ref(!!route.query.token || !!route.query.r)
const accessError     = ref('')

const VALIDATE_URL = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/validate-access-token'
const PRINT_RESULT_URL = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/print-result'

// Modo visualização (link do e-mail): reabre o resultado já gerado, somente leitura.
// Valida token + protocolo + e-mail no n8n antes de devolver o result_json salvo.
async function loadSharedResult(token: string, protocol: string, email: string) {
  tokenValidating.value = true
  accessError.value = ''
  try {
    const res = await fetch(PRINT_RESULT_URL, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      // n8n lê body.protocolo (Set "Recebe Vars do webhook")
      body:    JSON.stringify({ token, protocolo: protocol, email }),
    })
    const data = await res.json()

    if (!data?.success) {
      accessError.value = data?.error?.message ?? 'Não foi possível abrir este relatório. O link pode estar incorreto.'
      return
    }

    // Resolve a chave do plano (aceita chave OU nome). Default 'free' = nunca mostra
    // mais do que o plano pago (evita vazar conteúdo completo num plano básico).
    const VALID_KEYS = new Set(['free', 'revealed', 'raiox'])
    const rawPlan = data.plan ?? data.plan_name ?? ''
    const plan = VALID_KEYS.has(rawPlan) ? rawPlan : (PLAN_NAME_TO_KEY[rawPlan] ?? 'free')
    resultPlan.value      = plan
    currentPlan.value     = plan
    resultUserName.value  = data.user_name ?? ''
    resultUserEmail.value = data.user_email ?? ''
    resultProtocol.value  = data.protocol ?? protocol ?? ''
    resultPrintCount.value = data.print_count ?? (uploadedFiles.value.length || null)
    resultAnalysisDate.value = data.generated_at ?? ''
    resultFeelingsRaw.value = data.feelings ?? ''

    const rawData = typeof data.data === 'string' ? JSON.parse(data.data) : (data.data ?? data.analysis ?? {})
    resultData.value = Array.isArray(rawData) ? (rawData[0] ?? {}) : rawData
    resultCta.value  = data.cta ?? null

    const relDyn = resultData.value?.executive_summary?.relationship_dynamics ?? null
    resultRelDyn.value = relDyn ? {
      'Análise do Usuário (você)': relDyn.user ?? null,
      'Análise do(a) Crush':       relDyn.crush ?? null,
      'Conclusão':                 relDyn.conclusion ?? resultData.value?.executive_summary?.conclusion ?? null,
    } : null

    goTo(4)
    const score = resultData.value?.interest_score ?? 0
    setTimeout(() => { scoreBarWidth.value = `${Math.min(score, 100)}%` }, 100)

    // Veio do botão "Baixar PDF" do e-mail (?dl=1) → abre a janela de impressão
    if (import.meta.client && route.query.dl) {
      setTimeout(() => downloadPdf(), 1200)
    }
  } catch {
    accessError.value = 'Não foi possível abrir este relatório. Verifique sua conexão e tente novamente.'
  } finally {
    tokenValidating.value = false
  }
}

// Mapeia o nome do plano vindo do webhook para a chave interna
const PLAN_NAME_TO_KEY: Record<string, string> = {
  'Primeiras Impressões': 'free',
  'Sinais Revelados':     'revealed',
  'Raio-X do Crush':      'raiox',
}

const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000

async function validateToken(token: string, email?: string) {
  tokenValidating.value = true
  accessError.value     = ''

  try {
    // Sempre envia token + email (o e-mail pode vir vazio; o backend resolve/retorna o do comprador)
    const payload: Record<string, string> = { token, email: email ?? '' }

    const res  = await fetch(VALIDATE_URL, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(payload),
    })
    const data = await res.json()

    if (data.success) {
      const { access } = data

      // Suporta plan como chave interna ("revealed"/"raiox") OU nome completo ("Sinais Revelados")
      const VALID_KEYS = new Set(['free', 'revealed', 'raiox'])
      const planKey  = VALID_KEYS.has(access.plan) ? access.plan : (PLAN_NAME_TO_KEY[access.plan] ?? 'free')
      const planName = access.plan_name ?? PLAN_NAMES[planKey] ?? planKey


      accessToken.value        = access.token
      currentPlan.value        = planKey
      // E-mail verificado do comprador: prioriza o retorno do webhook, cai no e-mail do link.
      userEmail.value          = access.email ?? data.user_email ?? email ?? ''
      if (Number(access.max_prints) > 0) PLAN_LIMITS[planKey] = Number(access.max_prints)

      const expiresAt = access.expires_at
        ? new Date(access.expires_at).getTime()
        : Date.now() + THIRTY_DAYS_MS

      localStorage.setItem('sc_token',      access.token)
      localStorage.setItem('sc_plan',       planKey)
      localStorage.setItem('sc_plan_name',  planName)
      localStorage.setItem('sc_max_images', String(access.max_prints))
      localStorage.setItem('sc_expires_at', String(expiresAt))
      if (access.access_id) localStorage.setItem('sc_access_id', access.access_id)

      // Remove token e e-mail da URL sem recarregar
      const url = new URL(window.location.href)
      url.searchParams.delete('token')
      url.searchParams.delete('e')
      url.searchParams.delete('email')
      window.history.replaceState({}, '', url.toString())

    } else {
      accessError.value = data.error?.message ?? 'Seu link de acesso não é válido ou expirou.'
    }
  } catch (err) {
    console.error('[ScanCrush] validateToken → erro técnico:', err)
    accessError.value = 'Não foi possível validar seu acesso. Verifique sua conexão e tente novamente.'
  } finally {
    tokenValidating.value = false
  }
}

function clearStoredSession() {
  if (!import.meta.client) return
  for (const k of ['sc_token','sc_plan','sc_plan_name','sc_max_images','sc_expires_at','sc_access_id']) {
    localStorage.removeItem(k)
  }
  accessToken.value = ''
  currentPlan.value = 'free'
}


onMounted(async () => {
  const urlToken = route.query.token as string | undefined
  const urlEmail = (route.query.e as string) || (route.query.email as string) || undefined

  const reportToken = route.query.r as string | undefined

  if (reportToken) {
    // Link do e-mail: abre o relatório já gerado em modo visualização
    await loadSharedResult(reportToken, (route.query.p as string) ?? '', (route.query.e as string) ?? '')
  } else if (urlToken) {
    // Token na URL: sempre valida no webhook, nunca cai em free por falha
    await validateToken(urlToken, urlEmail)
  } else {
    // Não há mais plano gratuito: o acesso é SEMPRE via link com ?token= (pós-compra)
    // ou ?r= (reabrir relatório). Acesso direto sem token → manda escolher um plano.
    clearStoredSession()
    if (import.meta.client) { window.location.href = '/#b-pricing'; return }
  }


  checkAnalysisDone()
  updateUploadUI()
  window.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  if (msgInterval) clearInterval(msgInterval)
  if (progressInterval) clearInterval(progressInterval)
  window.removeEventListener('keydown', onKeydown)
  filePreviews.value.forEach(p => URL.revokeObjectURL(p.src))
})
</script>

<template>
<!-- ══════════════════════════════════════════════════ -->
<!-- TOKEN VALIDATION OVERLAY -->
<!-- ══════════════════════════════════════════════════ -->
<div v-if="tokenValidating || accessError" class="token-overlay">
  <div class="token-card">

    <!-- Loading -->
    <template v-if="tokenValidating">
      <div class="token-spinner"></div>
      <p class="token-msg">Validando seu acesso…</p>
    </template>

    <!-- Erro -->
    <template v-else>
      <div class="token-icon-err">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
          stroke="#FF2D6B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="9"/>
          <path d="M12 8v4m0 4h.01"/>
        </svg>
      </div>
      <p class="token-err-title">Acesso não autorizado</p>
      <p class="token-err-msg">{{ accessError }}</p>
      <p class="token-support">Precisa de ajuda? <a href="mailto:suporte@scancrush.com">suporte@scancrush.com</a></p>
      <NuxtLink to="/" class="token-back">← Voltar para o início</NuxtLink>
    </template>

  </div>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- SCREEN 1: Upload -->
<!-- ══════════════════════════════════════════════════ -->
<div class="screen" :class="{ active: currentScreen === 1 }">
  <header class="screen-header">
    <NuxtLink to="/" class="logo">
      <svg width="22" height="22" viewBox="0 0 28 28" fill="none">
        <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
        <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
        <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
        <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
      </svg>
      <span class="logo-word">Scan<span>Crush</span></span>
    </NuxtLink>
    <div></div>
  </header>

  <div class="screen-body">
    <div class="step-dots">
      <div class="step-dot active"></div>
      <div class="step-dot"></div>
    </div>

    <!-- Plan badge -->
    <div class="plan-info-badge">
      <span class="plan-info-name">{{ planDisplayName }}</span>
      <span class="plan-info-sep">·</span>
      <span class="plan-info-limit">até {{ planImageLimit }} {{ planImageLimit === 1 ? 'imagem' : 'imagens' }}</span>
    </div>

    <!-- Free plan limit notice -->
    <p v-if="currentPlan === 'free'" class="free-limit-notice">
      ⏳ análise única
    </p>

    <h1 class="screen-title">{{ uploadTitle }}</h1>
    <p class="screen-subtitle">{{ uploadSubtitle }}</p>

    <div
      class="file-drop-area"
      :class="{ 'drag-over': isDragOver }"
      :style="dropAreaStyle"
      @dragover="onDragOver"
      @dragleave="onDragLeave"
      @drop="onDrop"
    >
      <input type="file" accept="image/jpeg,image/png" :multiple="!isFree" title="" @change="onFileChange" />
      <span class="drop-icon">📱</span>
      <p class="drop-text">{{ dropMainText }}<br>ou <strong>clique para selecionar</strong></p>
      <span class="drop-hint">PNG · JPG · JPEG</span>
    </div>

    <div class="file-previews" v-show="filePreviews.length > 0">
      <div
        v-for="(preview, visualIdx) in filePreviews"
        :key="preview.idx"
        class="preview-item"
        :class="{ 'is-drag-target': dragOverIdx === visualIdx }"
        :data-name="preview.name"
        draggable="true"
        @dragstart="onPreviewDragStart(visualIdx)"
        @dragover.prevent="dragOverIdx = visualIdx"
        @dragleave="dragOverIdx = null"
        @drop.prevent="onPreviewDrop(visualIdx)"
        @dragend="dragOverIdx = null"
      >
        <img class="preview-thumb" :src="preview.src" alt="Print" @click="openLightbox(preview.src)" />
        <span class="preview-order">{{ visualIdx + 1 }}</span>
        <button class="preview-remove" @click.stop="removeFile(preview.idx)" title="Remover imagem">×</button>
      </div>
    </div>
    <p class="previews-hint" v-show="filePreviews.length > 0">Toque para ampliar · arraste para reordenar</p>

    <!-- Upload counter + progress bar + clear all -->
    <div class="upload-meta" v-show="showUploadMeta">
      <span class="upload-counter" :class="uploadCounterClass">{{ uploadCounterText }}</span>
      <div class="upload-bar-track">
        <div class="upload-bar-fill" :class="uploadBarClass" :style="{ width: uploadBarWidth }"></div>
      </div>
      <button class="preview-clear-all" @click="removeAllFiles()">Remover todas</button>
    </div>

    <!-- Limit reached alert -->
    <div class="limit-alert" :class="{ visible: showLimitAlert }">
      <p class="limit-alert-text">{{ limitAlertText }}</p>
    </div>

    <button class="btn-main" :disabled="btnContinueDisabled" @click="tryProceed()">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><polyline points="9 18 15 12 9 6"/></svg>
      Continuar
    </button>
  </div>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- SCREEN 2: Observations -->
<!-- ══════════════════════════════════════════════════ -->
<div class="screen" :class="{ active: currentScreen === 2 }">
  <header class="screen-header">
    <button class="back-btn" @click="goTo(1)">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
      Voltar
    </button>
    <NuxtLink to="/" class="logo">
      <svg width="22" height="22" viewBox="0 0 28 28" fill="none">
        <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
        <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
        <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
        <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
      </svg>
      <span class="logo-word">Scan<span>Crush</span></span>
    </NuxtLink>
    <div></div>
  </header>

  <div class="screen-body">
    <div class="step-dots">
      <div class="step-dot done"></div>
      <div class="step-dot active"></div>
    </div>

    <h1 class="screen-title">Conte um pouco mais</h1>
    <p class="screen-subtitle">Vamos personalizar a análise para o seu perfil</p>

    <!-- Faixas etárias lado a lado -->
    <div class="person-fields">
      <div class="field-group">
        <label class="field-label" for="userAgeRange">Sua faixa etária</label>
        <select class="date-select" id="userAgeRange" :class="{ empty: !userAgeRange }" v-model="userAgeRange" style="flex:1;min-width:0">
          <option value="" disabled>Selecionar</option>
          <option value="18-20">18 – 20 anos</option>
          <option value="21-25">21 – 25 anos</option>
          <option value="26-30">26 – 30 anos</option>
          <option value="31-35">31 – 35 anos</option>
          <option value="36-40">36 – 40 anos</option>
          <option value="41-50">41 – 50 anos</option>
          <option value="50+">Acima de 50</option>
        </select>
      </div>
      <div class="field-group">
        <label class="field-label" for="crushAgeRange">Faixa etária dele(a) <span class="field-optional">(opcional)</span></label>
        <select class="date-select" id="crushAgeRange" :class="{ empty: !crushAgeRange }" v-model="crushAgeRange" style="flex:1;min-width:0">
          <option value="" disabled>Selecionar</option>
          <option value="18-20">18 – 20 anos</option>
          <option value="21-25">21 – 25 anos</option>
          <option value="26-30">26 – 30 anos</option>
          <option value="31-35">31 – 35 anos</option>
          <option value="36-40">36 – 40 anos</option>
          <option value="41-50">41 – 50 anos</option>
          <option value="50+">Acima de 50</option>
          <option value="null">Não sei / prefiro não informar</option>
        </select>
      </div>
    </div>

    <div class="person-divider"></div>

    <label class="field-label" style="margin-bottom:12px;display:block">{{ obsQuestion }} <span class="field-optional">(opcional)</span></label>

    <textarea
      class="obs-textarea"
      v-model="observations"
      :placeholder="obsPlaceholder"
      rows="5"
    ></textarea>

    <span class="tag-label">Como você tem se sentido nessa situação?</span>
    <div class="tag-group">
      <div
        v-for="tag in TAGS"
        :key="tag"
        class="obs-tag"
        :class="{ selected: selectedTags.includes(tag) }"
        @click="toggleTag(tag)"
      >{{ tag }}</div>
    </div>

    <!-- Disclaimer — plano gratuito -->
    <template v-if="isFree">
      <div class="free-disclaimer-card">
        <p>🧠 A IA lê os padrões, sinais e contradições da conversa.</p>
        <p class="free-disclaimer-sub">Não adivinha sentimentos — mostra o que costuma passar despercebido na hora.</p>
      </div>
    </template>

    <!-- Disclaimer — plano pago -->
    <div v-else class="once-warning">
      A análise será feita exclusivamente com base no conteúdo enviado.<br>
      <strong>Quanto mais contexto você enviar, mais precisa a análise fica.</strong>
    </div>

    <!-- Aceite obrigatório (TODOS os planos): 18+ + termos + privacidade -->
    <div class="paid-terms-wrap">
      <label class="paid-terms-label">
        <input type="checkbox" v-model="termsAccepted" class="paid-terms-check" />
        <span>Declaro ser maior de 18 anos e concordar com os <a href="/terms.html" target="_blank" rel="noopener">Termos de Uso</a> e a <a href="/privacy.html" target="_blank" rel="noopener">Política de Privacidade</a></span>
      </label>
    </div>

    <!-- Validation errors -->
    <div class="validation-msg" :class="{ visible: showValidationMsg }" v-html="validationMsgHtml"></div>

    <!-- Shown if analysis already done this session -->
    <div class="analysis-blocked-msg" :class="{ visible: showAnalysisBlockedMsg }">
      ⚠️ Esta análise é única e não pode ser refeita.<br>
      <span style="font-size:12px;opacity:0.7;display:block;margin-top:6px">Faça upgrade para gerar uma nova análise.</span>
    </div>

    <button class="btn-main" v-show="showBtnGenerate" @click="startAnalysis()">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      Ver os sinais da conversa
    </button>
    <p v-if="isFree" class="leitura-inicial-hint">✨ Essa é uma leitura inicial baseada no print enviado.</p>
  </div>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- IMAGE COUNT WARNING -->
<!-- ══════════════════════════════════════════════════ -->
<div class="confirm-overlay" :class="{ open: showImageCountWarning }" @click.self="closeImageCountWarning()">
  <div class="confirm-card icw-card">
    <button class="confirm-close" @click="closeImageCountWarning()" aria-label="Fechar">×</button>
    <h2 class="confirm-title">Você enviou {{ uploadedFiles.length }} {{ uploadedFiles.length === 1 ? 'imagem' : 'imagens' }}</h2>
    <p class="confirm-sub">
      Seu plano permite até <strong>{{ planImageLimit }} imagens</strong> para uma análise mais completa.<br><br>
      Após gerar a análise, esta sessão será encerrada e as imagens restantes não poderão ser adicionadas depois.<br><br>
      Deseja continuar com <strong>{{ uploadedFiles.length }} {{ uploadedFiles.length === 1 ? 'imagem' : 'imagens' }}</strong> ou aproveitar o restante do seu limite antes de gerar a análise?
    </p>
    <div class="confirm-actions">
      <button class="confirm-btn-cancel" @click="closeImageCountWarning()">Adicionar mais imagens</button>
      <button class="confirm-btn-ok" @click="proceedFromWarning()">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
        Gerar análise com {{ uploadedFiles.length }} {{ uploadedFiles.length === 1 ? 'imagem' : 'imagens' }}
      </button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- POPUP: conteúdo inválido (não é conversa / bloqueado) -->
<!-- ══════════════════════════════════════════════════ -->
<div class="confirm-overlay" :class="{ open: showInvalidContent }">
  <div class="confirm-card icw-card">
    <button class="confirm-close" @click="closeInvalidContent()" aria-label="Fechar">×</button>
    <div class="invalid-pop-icon">
      <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#FF2D6B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
    </div>
    <h2 class="confirm-title">{{ invalidContentTitle }}</h2>
    <p class="confirm-sub">{{ invalidContentMsg }}</p>
    <div class="confirm-actions">
      <button class="confirm-btn-ok" @click="closeInvalidContent()">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
        Enviar outro print
      </button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- CONFIRM DIALOG: verificar imagens antes de enviar -->
<!-- ══════════════════════════════════════════════════ -->
<div class="confirm-overlay" :class="{ open: showConfirmDialog }" @click.self="closeConfirmDialog()">
  <div class="confirm-card">
    <button class="confirm-close" @click="closeConfirmDialog()" aria-label="Fechar">×</button>

    <p class="confirm-eyebrow">// revisar antes de continuar</p>
    <h2 class="confirm-title">Tudo certo com os prints?</h2>
    <p class="confirm-sub">Confira se os prints estão <strong>na ordem certa</strong> e se nenhuma imagem importante ficou de fora.</p>
    <p class="confirm-sub-hint">Toque na imagem para ampliar.</p>

    <div class="confirm-previews-wrap">
      <div class="confirm-fade-left"  v-if="confirmScrollLeft > 0"></div>
      <button class="confirm-nav-btn confirm-nav-left"  v-if="confirmScrollLeft > 0"  @click="scrollConfirm(-1)" aria-label="Anterior">‹</button>
      <div class="confirm-previews" ref="confirmPreviewsEl" @scroll="onConfirmScroll">
        <div v-for="(preview, ci) in filePreviews" :key="preview.idx" class="confirm-thumb-wrap" @click="openLightbox(preview.src)">
          <img class="confirm-thumb" :src="preview.src" alt="Print" />
          <span class="confirm-thumb-order">{{ ci + 1 }}</span>
          <div class="confirm-thumb-zoom">🔍</div>
        </div>
      </div>
      <button class="confirm-nav-btn confirm-nav-right" v-if="confirmCanScrollRight" @click="scrollConfirm(1)"  aria-label="Próximo">›</button>
      <div class="confirm-fade-right" v-if="confirmCanScrollRight"></div>
    </div>

    <div class="confirm-actions">
      <button class="confirm-btn-cancel" @click="closeConfirmDialog()">Revisar prints</button>
      <button class="confirm-btn-ok" @click="closeConfirmDialog(); goTo(2)">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
        Sim, continuar
      </button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- LIGHTBOX: expand image -->
<!-- ══════════════════════════════════════════════════ -->
<div class="lightbox-overlay" :class="{ open: lightboxSrc }" @click="closeLightbox()">
  <button class="lightbox-close" @click="closeLightbox()" aria-label="Fechar">×</button>
  <img v-if="lightboxSrc" class="lightbox-img" :src="lightboxSrc" alt="Print ampliado" @click.stop />
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- SCREEN 3: Loading -->
<!-- ══════════════════════════════════════════════════ -->
<div class="screen" :class="{ active: currentScreen === 3 }">
  <div class="loading-wrap">
    <div class="scan-ring">
      <div class="scan-inner">🔍</div>
    </div>
    <div class="loading-content">
      <p class="loading-text">{{ loadingText }}</p>
      <p class="loading-sub">{{ loadingSub }}</p>
    </div>
    <div class="loading-bar-wrap">
      <div class="loading-bar-track">
        <div class="loading-bar-fill" :style="{ width: loadingProgress + '%' }"></div>
      </div>
      <span class="loading-bar-pct">{{ Math.round(loadingProgress) }}%</span>
    </div>
    <p class="loading-notice">A análise é feita em tempo real — pode levar alguns minutos.<br>Não feche esta tela.</p>
  </div>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- SCREEN 4: Result                               -->
<!-- ══════════════════════════════════════════════════ -->
<div class="screen" :class="{ active: currentScreen === 4 }">
  <header class="screen-header">
    <NuxtLink to="/" class="logo">
      <svg width="22" height="22" viewBox="0 0 28 28" fill="none">
        <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
        <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
      </svg>
      <span class="logo-word">Scan<span>Crush</span></span>
    </NuxtLink>
    <button class="header-action" @click="handleNewAnalysis()">Fazer nova análise</button>
  </header>

  <!-- ── Banner (todos os planos) ── -->
  <div class="result-notice-wrap">
    <div class="result-notice-card result-notice-ok">
      <div class="notice-body">
        <strong><span class="notice-check">✓</span> Seu resultado foi gerado com sucesso.</strong>
        Uma cópia da sua análise foi enviada para o e-mail usado na compra. Você também pode baixar o PDF ao final desta página.
        <span class="notice-sub">Evite fechar esta aba antes de concluir sua leitura.</span>
      </div>
    </div>
  </div>

  <div class="result-body">

    <!-- ① FREE: label de contexto ── -->
    <div v-if="isFree" class="free-result-intro">
      <div class="free-result-label">Leitura inicial da conversa</div>
    </div>

    <!-- ② Score + Veredicto — FREE e pago ── -->
    <div class="score-card">
      <div class="score-label">Score de Engajamento Observado</div>
      <div class="score-row">
        <div class="score-num">{{ resultData?.interest_score ?? '—' }}<sup>/100</sup></div>
        <div style="flex:1">
          <div class="score-bar-track">
            <div class="score-bar-cover" :style="{ width: scoreBarCoverWidth }"></div>
          </div>
          <div class="score-bar-labels">
            <span>Baixo</span><span>Médio</span><span>Alto</span>
          </div>
        </div>
      </div>
      <div class="verdict-pill">{{ verdictText(resultData?.situation_label?.level) }}</div>
    </div>

    <!-- ③ O que este resultado significa (summary) — FREE e pago ── -->
    <div v-if="resultData?.summary" class="res-card">
      <div class="res-label">O que este resultado significa</div>
      <p class="res-body">{{ norm(resultData.summary) }}</p>
    </div>

    <!-- ③b FREE: Resumo Executivo (insights do score, chips) ── -->
    <div v-if="isFree && allKeyPatterns.length" class="res-card">
      <div class="res-label">Visão Geral da Conversa</div>
      <div class="exec-chips">
        <span v-for="(kp, i) in allKeyPatterns" :key="'fkp'+i" :class="['exec-chip', kp.kind]">
          {{ norm(kp.text) }}
        </span>
      </div>
    </div>

    <!-- ④ FREE: sinais limitados + gate de upgrade ── -->
    <template v-if="isFree">
      <div v-if="hasSignals" class="res-card">
        <div class="res-label">Sinais na conversa</div>
        <div v-if="resultData.signals.positive?.[0]" class="signal-item">
          <span class="sig-dot g"></span>{{ norm(txt(resultData.signals.positive[0])) }}
        </div>
        <div v-if="resultData.signals.negative?.[0]" class="signal-item">
          <span class="sig-dot r"></span>{{ norm(txt(resultData.signals.negative[0])) }}
        </div>
      </div>
      <div class="free-insight-card">
        <div v-if="resultFeelings.length" class="for-you-feelings">
          <span class="ff-intro">Você relatou se sentir</span>
          <span v-for="(f, i) in resultFeelings" :key="'fff'+i" class="ff-chip">{{ capFirst(f) }}</span>
        </div>
        <p class="free-insight-text">{{ norm(resultData?.final_message ?? '') }}</p>
        <div class="result-signature">
          <img src="/brand/patty-avatar.webp" alt="" class="result-sig-avatar" width="28" height="28" loading="lazy" />
          <span>— Patty, do ScanCrush</span>
        </div>
      </div>
      <!-- Download PDF da leitura inicial (free também baixa) -->
      <div class="pdf-download-card">
        <div class="pdf-download-title">Guarde sua leitura inicial</div>
        <p class="pdf-download-desc">Baixe esta primeira leitura em PDF para consultar quando quiser.</p>
        <button class="btn-pdf-primary" @click="downloadPdf()">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
          Baixar leitura em PDF
        </button>
        <p class="pdf-hint">Na janela de impressão, escolha "Salvar como PDF" como destino.</p>
      </div>

      <p class="free-upgrade-hint">✨ A versão completa revela padrões que não aparecem em uma leitura inicial.</p>
      <div class="free-upgrade-card">
        <p class="free-upgrade-title">Quer ver a leitura completa?</p>
        <p class="free-upgrade-desc">Desbloqueie padrões emocionais, inconsistências, reciprocidade e interpretação contextual da conversa.</p>
        <button class="btn-unlock" @click="openModal()">Desbloquear análise completa</button>
      </div>
    </template>

    <!-- ── CONTEÚDO PAGO ──────────────────────────── -->
    <template v-if="!isFree">

      <!-- ⑤ Resumo Executivo (key_patterns como chips) ── -->
      <div v-if="allKeyPatterns.length" class="res-card">
        <div class="res-label">Visão Geral da Conversa</div>
        <div class="exec-chips">
          <span v-for="(kp, i) in allKeyPatterns" :key="'kp'+i"
                :class="['exec-chip', kp.kind]">
            {{ norm(kp.text) }}
          </span>
        </div>
      </div>

      <!-- ⑥ Sinais na Conversa ── -->
      <div v-if="hasSignals" class="res-card">
        <div class="res-label">Sinais na Conversa</div>
        <div v-for="(item, i) in resultData.signals.positive ?? []" :key="'sp'+i" class="signal-item">
          <span class="sig-dot g"></span>{{ norm(txt(item)) }}
        </div>
        <div v-for="(item, i) in resultData.signals.negative ?? []" :key="'sn'+i" class="signal-item">
          <span class="sig-dot r"></span>{{ norm(txt(item)) }}
        </div>
        <div v-for="(item, i) in resultData.signals.neutral ?? []" :key="'snu'+i" class="signal-item">
          <span class="sig-dot y"></span>{{ norm(txt(item)) }}
        </div>
      </div>

      <!-- ⑦ Trechos Mais Reveladores (highlights) ── -->
      <div v-if="resultData?.highlights?.length" class="res-card">
        <div class="res-label">Trechos Mais Reveladores</div>
        <div v-for="(item, i) in resultData.highlights" :key="'hl'+i" class="highlight-card">
          <div class="highlight-quote">"{{ norm(txt(item)) }}"</div>
          <div v-if="txtSub(item)" class="highlight-exp">{{ norm(txtSub(item)) }}</div>
        </div>
      </div>

      <!-- ⑧ Contradições Identificadas (inconsistencies) ── -->
      <div v-if="resultData?.inconsistencies?.length" class="res-card contradiction-card">
        <div class="res-label">Contradições Identificadas</div>
        <div v-for="(item, i) in resultData.inconsistencies" :key="'ic'+i" class="contradiction-item">
          <div class="contradiction-title">{{ norm(txt(item)) }}</div>
          <div v-if="txtSub(item)" class="contradiction-sub">{{ norm(txtSub(item)) }}</div>
        </div>
      </div>

      <!-- ⑨ Comportamento do Crush ── -->
      <div v-if="resultData?.behavior" class="res-card">
        <div class="res-label">Comportamento do Crush</div>
        <div v-if="resultData.behavior.engagement_level" class="behavior-row">
          <span class="behavior-label">Engajamento</span>
          <span class="behavior-val">{{ capFirst(norm(resultData.behavior.engagement_level)) }}</span>
        </div>
        <div v-if="resultData.behavior.consistency" class="behavior-row">
          <span class="behavior-label">Consistência</span>
          <span class="behavior-val">{{ capFirst(norm(resultData.behavior.consistency)) }}</span>
        </div>
        <div v-if="resultData.behavior.response_pattern" class="behavior-row res-behavior-pattern">
          <span class="behavior-label">Padrão</span>
          <span class="behavior-val">{{ capFirst(norm(resultData.behavior.response_pattern)) }}</span>
        </div>
      </div>

      <!-- ⑩ Seu Comportamento (user_posture + emotional_profile) ── -->
      <div v-if="resultData?.user_posture || resultData?.emotional_profile" class="res-card">
        <div class="res-label">Seu Comportamento</div>
        <template v-if="resultData?.user_posture">
          <div class="behavior-row" style="align-items:flex-start">
            <span class="behavior-label">Sua postura</span>
            <span class="behavior-val" style="flex:1">
              <span class="posture-badge">{{ capFirst(postureLabel(resultData.user_posture.level)) }}</span>
              <span v-if="resultData.user_posture.explanation" class="posture-exp">{{ norm(resultData.user_posture.explanation) }}</span>
            </span>
          </div>
        </template>
        <template v-if="resultData?.emotional_profile">
          <div class="behavior-row" style="align-items:flex-start; margin-top:12px">
            <span class="behavior-label">Perfil</span>
            <span class="behavior-val" style="flex:1">
              <span class="emotional-type">{{ capFirst(norm(resultData.emotional_profile.type)) }}</span>
              <span v-if="resultData.emotional_profile.description" class="emotional-desc">{{ norm(resultData.emotional_profile.description) }}</span>
            </span>
          </div>
        </template>
      </div>

      <!-- ⑩b Nível de Reciprocidade — painel premium ── -->
      <div v-if="resultData?.reciprocity" class="res-card recip-panel">
        <div class="res-label">Nível de Reciprocidade</div>

        <!-- HERO: score protagonista + veredito + gauge -->
        <div v-if="resultData.reciprocity.score != null" class="recip-hero">
          <div class="recip-hero-score">
            <span class="recip-hero-num">{{ resultData.reciprocity.score }}</span>
            <span class="recip-hero-max">/100</span>
          </div>
          <div class="recip-hero-meta">
            <div class="recip-hero-verdict">{{ recipLabel.title }}</div>
            <div class="recip-hero-sub">{{ recipLabel.sub }}</div>
            <div class="recip-gauge">
              <div class="recip-gauge-track">
                <div class="recip-gauge-fill" :style="{ width: recipScore + '%' }"></div>
                <div class="recip-gauge-marker" :style="{ left: recipScore + '%' }"></div>
              </div>
              <div class="recip-gauge-scale"><span>Unilateral</span><span>Equilibrado</span></div>
            </div>
          </div>
        </div>

        <!-- CRITÉRIOS pontuados (novo modelo quantitativo) -->
        <div v-if="recipCriteria.length" class="recip-crit-list">
          <div class="recip-crit-head"><span>Critério</span><span>Pontos</span></div>
          <div v-for="(c, i) in recipCriteria" :key="'rc'+i" class="recip-crit" :class="c.status">
            <div class="recip-crit-top">
              <span class="recip-crit-label">{{ norm(c.label) }}</span>
              <span class="recip-crit-points">
                {{ c.score }}<span class="recip-crit-max">/{{ c.max }}</span>
              </span>
            </div>
            <p class="recip-crit-exp">{{ c.noData ? 'Não observado no recorte.' : norm(c.explanation) }}</p>
            <div class="recip-crit-bar"><div class="recip-crit-bar-fill" :style="{ width: (c.noData ? 0 : c.pct) + '%' }"></div></div>
          </div>
        </div>

        <!-- LEGADO: métricas Você×Crush (análises antigas, sem `criteria`) -->
        <div v-else-if="recipMetrics.length" class="recip-metrics">
          <div v-for="(m, i) in recipMetrics" :key="'rm'+i" class="recip-metric">
            <div class="recip-metric-top">
              <span class="recip-metric-label">{{ norm(m.label) }}</span>
              <span class="recip-metric-val">
                <template v-if="m.noData"><span class="lbl">Não observado no recorte</span></template>
                <template v-else>
                  <span class="lbl">Você</span> <b class="u">{{ m.user }}</b>
                  <span class="sep">·</span>
                  <b class="c">{{ m.crush }}</b> <span class="lbl">Crush</span>
                </template>
              </span>
            </div>
            <div class="recip-bar2">
              <template v-if="m.u != null">
                <div class="recip-bar2-user" :style="{ width: m.u + '%' }"></div>
                <div class="recip-bar2-crush" :style="{ width: m.c + '%' }"></div>
              </template>
              <div v-else class="recip-bar2-empty"></div>
            </div>
            <div v-if="m.dominance" class="recip-dominance">Predominância: <span>{{ m.dominance }}</span></div>
          </div>
        </div>

        <!-- CONCLUSÃO EXECUTIVA -->
        <div v-if="resultData.reciprocity.summary" class="recip-conclusion">
          <span class="recip-conclusion-tag">Leitura</span>
          <p>{{ norm(resultData.reciprocity.summary) }}</p>
        </div>
      </div>

      <!-- ⑪ Dinâmica da Relação ── -->
      <div v-if="resultRelDyn" class="res-card">
        <div class="res-label">Dinâmica da Relação</div>
        <div v-if="resultRelDyn['Análise do Usuário (você)']" class="behavior-row" style="align-items:flex-start">
          <span class="behavior-label">Você</span>
          <span class="behavior-val">{{ norm(resultRelDyn['Análise do Usuário (você)']) }}</span>
        </div>
        <div v-if="resultRelDyn['Análise do(a) Crush']" class="behavior-row" style="align-items:flex-start; margin-top:10px">
          <span class="behavior-label">Crush</span>
          <span class="behavior-val">{{ norm(resultRelDyn['Análise do(a) Crush']) }}</span>
        </div>
        <div v-if="resultRelDyn['Conclusão']" class="dynamics-conclusion">
          {{ norm(resultRelDyn['Conclusão']) }}
        </div>
      </div>

      <!-- ⑫ Análise Aprofundada (raiox only) ── -->
      <div v-if="deepAnalysisItems.length" class="res-card">
        <div class="res-label">Análise Aprofundada</div>
        <div v-for="(item, i) in deepAnalysisItems" :key="'da'+i" class="deep-paragraph">
          <div v-if="item.title" class="deep-title" :class="item.tone">{{ item.title }}</div>
          <p class="deep-text">{{ norm(item.text) }}</p>
        </div>
      </div>

      <!-- ⑬ Conclusão da Análise ── -->
      <div v-if="resultData?.final_verdict" class="res-card conclusion-card">
        <div class="res-label">Conclusão da Análise</div>
        <p class="conclusion-text">{{ norm(resultData.final_verdict) }}</p>
      </div>

      <!-- ⑭ Para Você (mensagem final) ── -->
      <div v-if="resultData?.final_message" class="for-you-card">
        <div class="for-you-label">Para Você</div>
        <div v-if="resultFeelings.length" class="for-you-feelings">
          <span class="ff-intro">Você relatou se sentir</span>
          <span v-for="(f, i) in resultFeelings" :key="'ff'+i" class="ff-chip">{{ capFirst(f) }}</span>
        </div>
        <p class="for-you-text">{{ norm(resultData.final_message) }}</p>
        <div class="result-signature">
          <img src="/brand/patty-avatar.webp" alt="" class="result-sig-avatar" width="28" height="28" loading="lazy" />
          <span>— Patty, do ScanCrush</span>
        </div>
      </div>

      <!-- ⑭b Limites da leitura ── -->
      <div v-if="resultData?.limits" class="res-card limits-card">
        <div class="res-label">Limites da leitura</div>
        <p class="limits-text">{{ norm(resultData.limits) }}</p>
      </div>

      <!-- ⑮ Sobre esta análise (encerramento em dois níveis) ── -->
      <div class="about-analysis-card">
        <div class="about-label">Sobre esta análise</div>
        <p class="about-emotional">Agora você tem uma leitura mais clara do que apareceu neste recorte.</p>
        <p class="about-text">Esta leitura foi gerada exclusivamente a partir do recorte enviado. O resultado não representa uma verdade absoluta sobre sentimentos, intenções ou personalidade. Trata-se de uma interpretação contextual baseada nos padrões observados nas mensagens analisadas.</p>
        <div class="about-sign">
          <span class="about-sign-brand">
            <svg width="18" height="18" viewBox="0 0 28 28" fill="none">
              <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
              <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
              <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
              <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
              <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
              <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
              <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
            </svg>
            <span class="about-sign-word">Scan<span>Crush</span></span>
          </span>
          <span class="about-sign-slogan">Nem sempre os sinais são óbvios.</span>
        </div>
      </div>

      <!-- ⑯ Download PDF (card de valor) ── -->
      <div class="pdf-download-card">
        <div class="pdf-download-title">Seu relatório completo, para guardar</div>
        <p class="pdf-download-desc">Baixe sua análise em PDF — formatada para leitura, envio e consulta quando quiser.</p>
        <button class="btn-pdf-primary" @click="downloadPdf()">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
          Baixar relatório em PDF
        </button>
        <p class="pdf-hint">Na janela de impressão, escolha "Salvar como PDF" como destino.</p>
      </div>

    </template>
    <!-- ── fim conteúdo pago ── -->

  </div>

  <!-- ⑯ Footer ── -->
  <footer class="result-footer">
    <div class="footer-inner">
      <div class="footer-brand">
        <svg width="18" height="18" viewBox="0 0 28 28" fill="none">
          <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
          <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
          <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
          <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        </svg>
        <span class="footer-brand-word">Scan<span>Crush</span></span>
      </div>
      <nav class="footer-links">
        <a href="/terms.html" target="_blank">Termos de Uso</a>
        <a href="/privacy.html" target="_blank">Privacidade</a>
        <a href="mailto:contato@scancrush.com">Contato</a>
      </nav>
      <p class="footer-copy">© 2026 ScanCrush · Este relatório é gerado por IA e representa observações sobre padrões comportamentais. Não constitui diagnóstico psicológico.</p>
    </div>
  </footer>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- PDF DOCUMENT (print-only, identidade própria light) -->
<!-- ══════════════════════════════════════════════════ -->
<div class="pdf-doc" v-if="resultData">

  <!-- ── PÁGINA 1: CAPA ── -->
  <section class="pdf-cover">
    <div class="pdf-cover-strip"></div>

    <!-- Marca d'água sutil de identidade -->
    <svg class="pdf-cover-watermark" viewBox="0 0 28 28" fill="none" aria-hidden="true">
      <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="0.8" stroke-dasharray="4 2.5"/>
      <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="0.9"/>
      <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
    </svg>

    <div class="pdf-cover-top">
      <div class="pdf-logo">
        <svg width="34" height="34" viewBox="0 0 28 28" fill="none">
          <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.4"/>
          <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
          <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
          <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        </svg>
        <span class="pdf-logo-word">Scan<span>Crush</span></span>
      </div>
      <p class="pdf-cover-slogan">Nem sempre os sinais são óbvios.</p>
    </div>

    <div class="pdf-cover-center">
      <p class="pdf-cover-eyebrow">Relatório de análise comportamental</p>
      <h1 class="pdf-cover-title">{{ planDisplayName.toUpperCase() }}</h1>
      <p class="pdf-cover-subtitle">Análise comportamental baseada exclusivamente no recorte enviado.</p>

      <!-- Score teaser (compacto): número + classificação -->
      <div class="pdf-cover-score">
        <div class="pdf-cover-score-num">{{ resultData?.interest_score ?? '—' }}<span>/100</span></div>
        <div class="pdf-verdict-pill">{{ verdictText(resultData?.situation_label?.level) }}</div>
      </div>
    </div>

    <div class="pdf-cover-foot">
      <p v-if="resultPrintCount" class="pdf-cover-prints">Análise baseada em <strong>{{ resultPrintCount }} {{ resultPrintCount === 1 ? 'print' : 'prints' }}</strong></p>
      <p class="pdf-cover-protocol" v-if="resultProtocol">Protocolo: <strong>{{ resultProtocol }}</strong></p>
      <p v-if="resultUserEmail" class="pdf-cover-owner">Gerado para: <strong>{{ resultUserEmail }}</strong></p>
      <p class="pdf-cover-meta">{{ analysisDateFormatted }} · scancrush.com</p>
    </div>
  </section>

  <!-- Rodapé fixo: repete em todas as páginas na impressão (atribuição/anti-compartilhamento) -->
  <div class="pdf-running-foot">
    <template v-if="resultUserEmail">Gerado para: {{ resultUserEmail }} · scancrush.com</template>
    <template v-else>scancrush.com</template>
  </div>

  <!-- ── PÁGINA 2+: RELATÓRIO ── -->
  <section class="pdf-report">

    <!-- Medidor completo do score (movido da capa) -->
    <div class="pdf-block pdf-block--score">
      <div class="pdf-block-label">Score de Engajamento Observado</div>
      <div class="pdf-score-block">
        <div class="pdf-score-num">{{ resultData?.interest_score ?? '—' }}<span>/100</span></div>
        <svg class="pdf-score-svg" viewBox="0 0 500 56" preserveAspectRatio="xMidYMid meet">
          <defs>
            <linearGradient id="pdfScoreGrad" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%"  stop-color="#FF2D6B"/>
              <stop offset="25%" stop-color="#FF4D4D"/>
              <stop offset="50%" stop-color="#FF8C00"/>
              <stop offset="75%" stop-color="#FFB800"/>
              <stop offset="100%" stop-color="#00D68F"/>
            </linearGradient>
          </defs>
          <rect x="30" y="28" width="440" height="14" rx="7" fill="url(#pdfScoreGrad)"/>
          <g :transform="`translate(${scoreMarkerX}, 0)`">
            <polygon points="0,20 -7,8 7,8" fill="#1a1a2e"/>
            <circle cx="0" cy="35" r="6" fill="#fff" stroke="#1a1a2e" stroke-width="2.5"/>
          </g>
        </svg>
        <div class="pdf-score-scale"><span>Baixo</span><span>Médio</span><span>Alto</span></div>
        <div class="pdf-verdict-pill">{{ verdictText(resultData?.situation_label?.level) }}</div>
      </div>
    </div>

    <div v-if="resultData?.summary" class="pdf-block">
      <div class="pdf-block-label">O que este resultado significa</div>
      <p class="pdf-p">{{ norm(resultData.summary) }}</p>
    </div>

    <div v-if="allKeyPatterns.length" class="pdf-block">
      <div class="pdf-block-label">Visão Geral da Conversa</div>
      <div class="pdf-chips">
        <span v-for="(kp, i) in allKeyPatterns" :key="'pkp'+i" :class="['pdf-chip', kp.kind]">{{ norm(kp.text) }}</span>
      </div>
    </div>

    <div v-if="hasSignals" class="pdf-block">
      <div class="pdf-block-label">Sinais na Conversa</div>
      <div v-for="(item, i) in resultData.signals.positive ?? []" :key="'psp'+i" class="pdf-signal">
        <span class="pdf-dot g"></span>{{ norm(txt(item)) }}
      </div>
      <div v-for="(item, i) in resultData.signals.negative ?? []" :key="'psn'+i" class="pdf-signal">
        <span class="pdf-dot r"></span>{{ norm(txt(item)) }}
      </div>
      <div v-for="(item, i) in resultData.signals.neutral ?? []" :key="'psnu'+i" class="pdf-signal">
        <span class="pdf-dot y"></span>{{ norm(txt(item)) }}
      </div>
    </div>

    <div v-if="resultData?.highlights?.length" class="pdf-block">
      <div class="pdf-block-label">Trechos Mais Reveladores</div>
      <div v-for="(item, i) in resultData.highlights" :key="'phl'+i" class="pdf-highlight">
        <div class="pdf-quote">"{{ norm(txt(item)) }}"</div>
        <div v-if="txtSub(item)" class="pdf-quote-exp">{{ norm(txtSub(item)) }}</div>
      </div>
    </div>

    <div v-if="resultData?.inconsistencies?.length" class="pdf-block">
      <div class="pdf-block-label">Contradições Identificadas</div>
      <div v-for="(item, i) in resultData.inconsistencies" :key="'pic'+i" class="pdf-contradiction">
        <div class="pdf-contradiction-title">{{ norm(txt(item)) }}</div>
        <div v-if="txtSub(item)" class="pdf-contradiction-sub">{{ norm(txtSub(item)) }}</div>
      </div>
    </div>

    <div v-if="resultData?.behavior" class="pdf-block">
      <div class="pdf-block-label">Comportamento do Crush</div>
      <div v-if="resultData.behavior.engagement_level" class="pdf-row">
        <span class="pdf-row-label">Engajamento</span><span class="pdf-row-val">{{ norm(resultData.behavior.engagement_level) }}</span>
      </div>
      <div v-if="resultData.behavior.consistency" class="pdf-row">
        <span class="pdf-row-label">Consistência</span><span class="pdf-row-val">{{ norm(resultData.behavior.consistency) }}</span>
      </div>
      <div v-if="resultData.behavior.response_pattern" class="pdf-row">
        <span class="pdf-row-label">Padrão</span><span class="pdf-row-val">{{ norm(resultData.behavior.response_pattern) }}</span>
      </div>
    </div>

    <div v-if="resultData?.user_posture || resultData?.emotional_profile" class="pdf-block">
      <div class="pdf-block-label">Seu Comportamento</div>
      <div v-if="resultData?.user_posture" class="pdf-row">
        <span class="pdf-row-label">Sua postura</span>
        <span class="pdf-row-val"><strong class="pdf-accent-pink">{{ postureLabel(resultData.user_posture.level) }}</strong><span v-if="resultData.user_posture.explanation" class="pdf-row-sub">{{ norm(resultData.user_posture.explanation) }}</span></span>
      </div>
      <div v-if="resultData?.emotional_profile" class="pdf-row">
        <span class="pdf-row-label">Perfil</span>
        <span class="pdf-row-val"><strong class="pdf-accent-purple">{{ norm(resultData.emotional_profile.type) }}</strong><span v-if="resultData.emotional_profile.description" class="pdf-row-sub">{{ norm(resultData.emotional_profile.description) }}</span></span>
      </div>
    </div>

    <div v-if="resultData?.reciprocity" class="pdf-block">
      <div class="pdf-block-label">Nível de Reciprocidade</div>
      <div v-if="resultData.reciprocity.score != null" class="pdf-recip-hero">
        <div class="pdf-recip-score">
          <span class="pdf-recip-num">{{ resultData.reciprocity.score }}</span>
          <span class="pdf-recip-max">/100</span>
        </div>
        <div class="pdf-recip-meta">
          <div class="pdf-recip-verdict">{{ recipLabel.title }}</div>
          <div class="pdf-recip-sub">{{ recipLabel.sub }}</div>
          <div class="pdf-recip-gauge">
            <div class="pdf-recip-gauge-track">
              <div class="pdf-recip-gauge-fill" :style="{ width: recipScore + '%' }"></div>
              <div class="pdf-recip-gauge-marker" :style="{ left: recipScore + '%' }"></div>
            </div>
            <div class="pdf-recip-scale"><span>Unilateral</span><span>Equilibrado</span></div>
          </div>
        </div>
      </div>
      <!-- CRITÉRIOS pontuados (novo modelo) -->
      <div v-if="recipCriteria.length" class="pdf-recip-crit-list">
        <div v-for="(c, i) in recipCriteria" :key="'prc'+i" class="pdf-recip-crit" :class="c.status">
          <div class="pdf-recip-crit-top">
            <span class="pdf-recip-crit-label">{{ norm(c.label) }}</span>
            <span class="pdf-recip-crit-points">{{ c.score }}/{{ c.max }}</span>
          </div>
          <p class="pdf-recip-crit-exp">{{ c.noData ? 'Não observado no recorte.' : norm(c.explanation) }}</p>
          <div class="pdf-recip-crit-bar"><div class="pdf-recip-crit-bar-fill" :style="{ width: (c.noData ? 0 : c.pct) + '%' }"></div></div>
        </div>
      </div>

      <!-- LEGADO: métricas Você×Crush (análises antigas) -->
      <template v-else>
        <div v-for="(m, i) in recipMetrics" :key="'prm'+i" class="pdf-recip-metric">
          <div class="pdf-recip-mtop">
            <span class="pdf-recip-mlabel">{{ norm(m.label) }}</span>
            <span class="pdf-recip-mval">
              <template v-if="m.noData"><span class="lbl">Não observado no recorte</span></template>
              <template v-else>
                <span class="lbl">Você</span> <b class="u">{{ m.user }}</b>
                <span class="sep">·</span>
                <b class="c">{{ m.crush }}</b> <span class="lbl">Crush</span>
              </template>
            </span>
          </div>
          <div class="pdf-recip-bar2">
            <template v-if="m.u != null">
              <div class="pdf-recip-bar2-u" :style="{ width: m.u + '%' }"></div>
              <div class="pdf-recip-bar2-c" :style="{ width: m.c + '%' }"></div>
            </template>
            <div v-else class="pdf-recip-bar2-empty"></div>
          </div>
          <div v-if="m.dominance" class="pdf-recip-dominance">Predominância: <span>{{ m.dominance }}</span></div>
        </div>
      </template>
      <div v-if="resultData.reciprocity.summary" class="pdf-recip-conclusion">
        <span class="pdf-recip-conclusion-tag">Leitura</span>
        <p>{{ norm(resultData.reciprocity.summary) }}</p>
      </div>
    </div>

    <div v-if="resultRelDyn" class="pdf-block">
      <div class="pdf-block-label">Dinâmica da Relação</div>
      <div v-if="resultRelDyn['Análise do Usuário (você)']" class="pdf-row">
        <span class="pdf-row-label">Você</span><span class="pdf-row-val">{{ norm(resultRelDyn['Análise do Usuário (você)']) }}</span>
      </div>
      <div v-if="resultRelDyn['Análise do(a) Crush']" class="pdf-row">
        <span class="pdf-row-label">Crush</span><span class="pdf-row-val">{{ norm(resultRelDyn['Análise do(a) Crush']) }}</span>
      </div>
      <p v-if="resultRelDyn['Conclusão']" class="pdf-conclusion">{{ norm(resultRelDyn['Conclusão']) }}</p>
    </div>

    <div v-if="deepAnalysisItems.length" class="pdf-block">
      <div class="pdf-block-label">Análise Aprofundada</div>
      <div v-for="(item, i) in deepAnalysisItems" :key="'pda'+i" class="pdf-deep-item">
        <div v-if="item.title" class="pdf-deep-title" :class="item.tone">{{ item.title }}</div>
        <p class="pdf-p">{{ norm(item.text) }}</p>
      </div>
    </div>

    <div v-if="resultData?.final_verdict" class="pdf-block pdf-block--verdict">
      <div class="pdf-block-label">Conclusão da Análise</div>
      <p class="pdf-p">{{ norm(resultData.final_verdict) }}</p>
    </div>

    <div v-if="resultData?.final_message" class="pdf-block pdf-block--foryou">
      <div class="pdf-block-label">Para Você</div>
      <div v-if="resultFeelings.length" class="pdf-foryou-feelings">
        <span class="pdf-ff-intro">Você relatou se sentir</span>
        <span v-for="(f, i) in resultFeelings" :key="'pff'+i" class="pdf-ff-chip">{{ capFirst(f) }}</span>
      </div>
      <p class="pdf-p">{{ norm(resultData.final_message) }}</p>
      <p class="pdf-signature">— Patty, do ScanCrush</p>
    </div>

    <div v-if="resultData?.limits" class="pdf-block pdf-block--limits">
      <div class="pdf-block-label">Limites da leitura</div>
      <p class="pdf-p">{{ norm(resultData.limits) }}</p>
    </div>

    <!-- Encerramento (dois níveis: emocional + institucional) -->
    <div class="pdf-about">
      <div class="pdf-block-label">Sobre esta análise</div>
      <p class="pdf-about-emotional">Agora você tem uma leitura mais clara do que apareceu neste recorte.</p>
      <p class="pdf-about-legal">Esta leitura foi gerada exclusivamente a partir do recorte enviado. O resultado não representa uma verdade absoluta sobre sentimentos, intenções ou personalidade. Trata-se de uma interpretação contextual baseada nos padrões observados nas mensagens analisadas.</p>
      <div class="pdf-about-sign">
        <span class="pdf-about-brand">
          <svg width="16" height="16" viewBox="0 0 28 28" fill="none">
            <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.4"/>
            <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
            <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
            <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
            <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
            <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
            <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
          <span class="pdf-about-word">Scan<span>Crush</span></span>
        </span>
        <span class="pdf-about-slogan">Nem sempre os sinais são óbvios.</span>
      </div>
    </div>

    <!-- CTA: nova análise → planos da landing -->
    <div class="pdf-cta">
      <p class="pdf-cta-text">Quer ir mais fundo nessa conversa?</p>
      <a class="pdf-cta-btn" href="https://scancrush.com/#b-pricing">Fazer uma nova análise</a>
    </div>

    <footer class="pdf-footer">
      <p>© 2026 ScanCrush. Todos os direitos reservados.</p>
      <p class="pdf-footer-site">scancrush.com</p>
    </footer>
  </section>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- SCREEN 5: Limit Reached (free plan 24h block) -->
<!-- ══════════════════════════════════════════════════ -->
<div class="screen" :class="{ active: currentScreen === 5 }">
  <header class="screen-header">
    <NuxtLink to="/" class="logo">
      <svg width="22" height="22" viewBox="0 0 28 28" fill="none">
        <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
        <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
        <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
        <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
      </svg>
      <span class="logo-word">Scan<span>Crush</span></span>
    </NuxtLink>
    <div></div>
  </header>

  <div class="screen-body limit-body">
    <div class="limit-icon">⏳</div>
    <h1 class="limit-title">Esta análise já foi utilizada</h1>
    <p class="limit-desc">
      Cada acesso é de <strong>uso único</strong>.<br>
      Para uma nova leitura, faça uma nova análise.
    </p>

    <div class="limit-divider"></div>

    <p class="limit-upgrade-label">Quer analisar mais conversas agora?</p>
    <p class="limit-upgrade-sub">Escolha um plano e tenha acesso imediato — sem precisar esperar.</p>

    <button class="btn-main" @click="openModal()">
      Ver planos
    </button>

    <NuxtLink to="/" class="limit-back-link">Voltar para o início</NuxtLink>
  </div>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- SCREEN 6: Sessão inválida / expirada / já usada  -->
<!-- ══════════════════════════════════════════════════ -->
<div class="screen" :class="{ active: currentScreen === 6 }">
  <header class="screen-header">
    <NuxtLink to="/" class="logo">
      <svg width="22" height="22" viewBox="0 0 28 28" fill="none">
        <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
        <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
        <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
        <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
      </svg>
      <span class="logo-word">Scan<span>Crush</span></span>
    </NuxtLink>
    <div></div>
  </header>

  <div class="screen-body limit-body">
    <div class="limit-icon">🔒</div>
    <h1 class="limit-title">Acesso inválido ou expirado</h1>
    <p class="limit-desc">
      Este link de análise já foi utilizado, expirou ou não é válido.<br>
      Cada compra gera um acesso único.
    </p>

    <div class="limit-divider"></div>

    <p class="limit-upgrade-label">Quer fazer uma nova análise?</p>
    <p class="limit-upgrade-sub">Escolha um plano e receba um novo link de acesso imediatamente.</p>

    <button class="btn-main" @click="openModal()">
      Ver planos
    </button>

    <NuxtLink to="/" class="limit-back-link">Voltar para o início</NuxtLink>
  </div>
</div>


<!-- ══════════════════════════════════════════════════ -->
<!-- MODAL: Plans -->
<!-- ══════════════════════════════════════════════════ -->
<div class="modal-overlay" :class="{ open: isModalOpen }" @click="handleOverlayClick($event)">
  <div class="modal-card">

    <button class="modal-close" @click="closeModal()" aria-label="Fechar">×</button>

    <p class="modal-eyebrow">// Acesse a análise</p>
    <h2 class="modal-title">Escolha o quanto <span>você quer enxergar.</span></h2>

    <div class="modal-plans">

      <!-- Plan: Primeiras Impressões -->
      <div class="plan-card">
        <div class="plan-name">Primeiras Impressões</div>
        <div class="plan-price">
          <span class="curr">R$</span>6<span class="cents">,90</span>
        </div>
        <p class="plan-period">pagamento único</p>
        <p class="plan-desc">A primeira leitura da conversa, por menos que um café.</p>
        <ul class="plan-items">
          <li class="plan-item">1 print analisado</li>
          <li class="plan-item">Score de Engajamento</li>
          <li class="plan-item">Visão geral da conversa</li>
          <li class="plan-item">1 sinal positivo + 1 de atenção</li>
          <li class="plan-item">Conclusão inicial</li>
        </ul>
        <button class="btn-plan" @click="goToCheckout('basico')">Analisar agora</button>
      </div>

      <!-- Plan: Sinais Revelados (FEATURED) -->
      <div class="plan-card featured">
        <div class="plan-badge">Mais escolhido</div>
        <div class="plan-name">Sinais Revelados</div>
        <div class="plan-price">
          <span class="curr">R$</span>19<span class="cents">,90</span>
        </div>
        <p class="plan-period">pagamento único</p>
        <p class="plan-desc">Descubra o que realmente está escondido nas mensagens.</p>
        <ul class="plan-items">
          <li class="plan-item">Até 4 prints analisados</li>
          <li class="plan-item">Score de Engajamento</li>
          <li class="plan-item">Análise completa da conversa</li>
          <li class="plan-item">Sinais positivos e negativos</li>
          <li class="plan-item">Trechos importantes destacados</li>
          <li class="plan-item">Interpretação da intenção da conversa</li>
          <li class="plan-item">Conclusão aprofundada</li>
        </ul>
        <button class="btn-plan primary" @click="goToCheckout('revealed')">Desbloquear análise completa</button>
      </div>

      <!-- Plan: Raio-X do Crush -->
      <div class="plan-card">
        <div class="plan-name">Raio-X do Crush</div>
        <div class="plan-price">
          <span class="curr">R$</span>44<span class="cents">,90</span>
        </div>
        <p class="plan-period">pagamento único</p>
        <p class="plan-desc">Para conversas mais longas e sinais mais difíceis de entender.</p>
        <ul class="plan-items">
          <li class="plan-item plan-item-includes">✓ Tudo do plano Sinais Revelados</li>
          <li class="plan-item">Até 10 prints analisados</li>
          <li class="plan-item">Identificação de padrões repetitivos</li>
          <li class="plan-item">Contradições emocionais</li>
          <li class="plan-item">Análise do nível de reciprocidade</li>
          <li class="plan-item">Perfil comportamental da conversa</li>
          <li class="plan-item">Conclusão mais detalhada</li>
        </ul>
        <button class="btn-plan" @click="goToCheckout('raiox')">Fazer análise avançada</button>
      </div>

    </div>

    <div class="modal-divider"></div>
    <p class="modal-guarantee">Pagamento seguro · acesso imediato · uso único</p>

  </div>
</div>
</template>

<style>
:root {
  --bg:          #07070D;
  --surface:     #0D0D1A;
  --card:        #111120;
  --border:      rgba(255,255,255,0.06);
  --pink:        #FF2D6B;
  --pink-glow:   rgba(255,45,107,0.18);
  --pink-border: rgba(255,45,107,0.28);
  --purple:      #9B5DE5;
  --purple-dim:  rgba(155,93,229,0.12);
  --teal:        #00F5D4;
  --amber:       #FFB800;
  --danger:      #FF4D4D;
  --safe:        #00D68F;
  --text:        #EEEEF8;
  --text-2:      #9090B8;
  --text-3:      #4A4A6A;
  --font:        'Sora', sans-serif;
  --mono:        'JetBrains Mono', monospace;
  --glow-pink:   0 0 48px rgba(255,45,107,0.35), 0 0 100px rgba(255,45,107,0.1);
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body {
  background: var(--bg);
  color: var(--text);
  font-family: var(--font);
  min-height: 100vh;
  -webkit-font-smoothing: antialiased;
  overflow-x: hidden;
}

/* Background */
body::before {
  content: '';
  position: fixed;
  inset: 0;
  background:
    radial-gradient(ellipse 80% 60% at 50% -10%, rgba(155,93,229,0.07) 0%, transparent 70%),
    radial-gradient(ellipse 60% 40% at 80% 80%, rgba(255,45,107,0.04) 0%, transparent 60%);
  pointer-events: none;
  z-index: 0;
}
body::after {
  content: '';
  position: fixed;
  inset: 0;
  background-image:
    linear-gradient(rgba(255,255,255,0.01) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.01) 1px, transparent 1px);
  background-size: 64px 64px;
  pointer-events: none;
  z-index: 0;
}

/* ── SCREENS ── */
.screen {
  display: none;
  min-height: 100vh;
  flex-direction: column;
  position: relative;
  z-index: 1;
}
.screen.active { display: flex; }

/* ── PLAN BADGE ── */
.plan-info-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(255,255,255,0.04);
  border: 1px solid var(--border);
  border-radius: 100px;
  padding: 5px 14px;
  font-size: 12px;
  margin-bottom: 16px;
  font-family: var(--mono);
}
.plan-info-name {
  color: var(--pink);
  font-weight: 600;
}
.plan-info-sep {
  color: var(--text-3);
}
.plan-info-limit {
  color: var(--text-2);
}
.leitura-inicial-hint {
  margin: 12px 0 0;
  text-align: center;
  font-size: 13px;
  color: #FFB800;
}
.free-limit-notice {
  font-size: 11px;
  color: var(--text-3);
  font-family: var(--mono);
  margin-top: -8px;
  margin-bottom: 20px;
  letter-spacing: 0.01em;
}

/* ── HEADER ── */
.screen-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid var(--border);
  background: rgba(7,7,13,0.7);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  position: sticky;
  top: 0;
  z-index: 10;
}
.logo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 800;
  letter-spacing: -0.5px;
  text-decoration: none;
  color: var(--text);
}
.logo svg { filter: drop-shadow(0 0 6px var(--pink)); }
.logo-word { color: var(--text); }
.logo-word span { color: var(--pink); }

.back-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 500;
  color: var(--text-2);
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 8px;
  transition: color 0.2s, background 0.2s;
  font-family: var(--font);
}
.back-btn:hover { color: var(--text); background: rgba(255,255,255,0.04); }

.header-action {
  font-size: 13px;
  font-weight: 700;
  color: var(--pink);
  background: rgba(255,45,107,0.08);
  border: 1px solid var(--pink-border);
  cursor: pointer;
  padding: 9px 16px;
  border-radius: 100px;
  transition: all 0.2s;
  font-family: var(--font);
  white-space: nowrap;
}
.header-action:hover { background: rgba(255,45,107,0.16); color: var(--text); }

/* ── BODY ── */
.screen-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40px 24px 48px;
  max-width: 600px;
  width: 100%;
  margin: 0 auto;
}

/* ── STEP INDICATOR ── */
.step-dots {
  display: flex;
  gap: 6px;
  margin-bottom: 36px;
}
.step-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: var(--text-3);
  transition: all 0.3s;
}
.step-dot.active {
  width: 20px;
  border-radius: 3px;
  background: var(--pink);
  box-shadow: 0 0 8px rgba(255,45,107,0.5);
}
.step-dot.done { background: var(--safe); }

/* ── TITLES ── */
.screen-title {
  font-size: clamp(26px, 6vw, 34px);
  font-weight: 800;
  letter-spacing: -1px;
  text-align: center;
  margin-bottom: 10px;
  line-height: 1.15;
}
.screen-subtitle {
  font-size: 15px;
  color: var(--text-2);
  font-weight: 300;
  text-align: center;
  margin-bottom: 36px;
  line-height: 1.65;
}

/* ── FILE DROP ── */
.file-drop-area {
  width: 100%;
  border: 1.5px dashed rgba(155,93,229,0.3);
  border-radius: 18px;
  padding: 40px 24px;
  text-align: center;
  cursor: pointer;
  transition: all 0.25s;
  background: rgba(155,93,229,0.03);
  position: relative;
  margin-bottom: 24px;
}
.file-drop-area:hover, .file-drop-area.drag-over {
  border-color: var(--purple);
  background: var(--purple-dim);
}
.file-drop-area input[type="file"] {
  position: absolute;
  inset: 0;
  opacity: 0;
  cursor: pointer;
}
.drop-icon {
  font-size: 36px;
  margin-bottom: 14px;
  display: block;
}
.drop-text {
  font-size: 15px;
  font-weight: 500;
  color: var(--text);
  margin-bottom: 6px;
}
.drop-text strong { color: var(--purple); }
.drop-hint {
  font-size: 12px;
  font-family: var(--mono);
  color: var(--text-3);
}

/* File previews */
.file-previews {
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 12px;
}
.preview-item {
  position: relative;
  animation: fadeIn 0.3s ease;
  flex-shrink: 0;
}
.preview-thumb {
  width: 72px; height: 72px;
  border-radius: 10px;
  object-fit: cover;
  border: 1px solid var(--border);
  display: block;
  cursor: pointer;
  transition: opacity 0.15s;
}
.preview-thumb:hover { opacity: 0.85; }
.preview-item {
  cursor: grab;
  position: relative;
}
.preview-item:active { cursor: grabbing; }

/* Tooltip com nome do arquivo */
.preview-item[data-name]::after {
  content: attr(data-name);
  position: absolute;
  bottom: calc(100% + 7px);
  left: 50%;
  transform: translateX(-50%);
  background: rgba(10,10,20,0.92);
  border: 1px solid rgba(255,255,255,0.1);
  color: var(--text-2);
  font-size: 10px;
  font-family: var(--mono);
  line-height: 1.4;
  padding: 5px 9px;
  border-radius: 7px;
  white-space: nowrap;
  max-width: 140px;
  overflow: hidden;
  text-overflow: ellipsis;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.15s ease;
  z-index: 10;
  backdrop-filter: blur(8px);
}
.preview-item[data-name]:hover::after {
  opacity: 1;
}
.preview-item.is-drag-target .preview-thumb {
  opacity: 0.4;
  outline: 2px solid var(--purple);
  outline-offset: 2px;
}
.previews-hint {
  width: 100%;
  text-align: center;
  font-size: 11px;
  font-family: var(--mono);
  color: var(--text-3);
  margin-bottom: 4px;
}
.preview-order {
  position: absolute;
  bottom: 5px;
  left: 5px;
  min-width: 18px;
  height: 18px;
  padding: 0 4px;
  background: rgba(10,10,20,0.82);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 5px;
  font-size: 10px;
  font-weight: 600;
  font-family: var(--mono);
  color: rgba(255,255,255,0.75);
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
  backdrop-filter: blur(4px);
  z-index: 2;
}

.preview-remove {
  position: absolute;
  top: -7px; right: -7px;
  width: 22px; height: 22px;
  border-radius: 50%;
  background: rgba(10,10,20,0.96);
  border: 1px solid rgba(255,255,255,0.18);
  color: var(--text-2);
  font-size: 13px;
  line-height: 1;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: all 0.15s;
  z-index: 2;
}
.preview-remove:hover { background: var(--danger); border-color: var(--danger); color: white; }
.preview-clear-all {
  font-size: 11px;
  color: var(--text-3);
  background: none;
  border: none;
  cursor: pointer;
  font-family: var(--mono);
  padding: 4px 0;
  transition: color 0.2s;
  text-decoration: underline;
  text-underline-offset: 3px;
}
.preview-clear-all:hover { color: var(--danger); }
@keyframes fadeIn { from{opacity:0;transform:scale(0.8)} to{opacity:1;transform:scale(1)} }

/* Validation message (Screen 2) */
.validation-msg {
  width: 100%;
  background: rgba(255,77,77,0.06);
  border: 1px solid rgba(255,77,77,0.2);
  border-radius: 12px;
  padding: 13px 16px;
  font-size: 13px;
  color: #FF7070;
  font-weight: 400;
  line-height: 1.65;
  margin-bottom: 12px;
  display: none;
  animation: fadeIn 0.25s ease;
}
.validation-msg.visible { display: block; }

/* ── PERSON FIELDS ── */
.person-fields {
  width: 100%;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 20px;
}
@media (max-width: 400px) {
  .person-fields { grid-template-columns: 1fr; }
}
.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.field-label {
  font-size: 10px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: var(--text-3);
}
.field-optional {
  font-size: 9px;
  opacity: 0.5;
  text-transform: none;
  letter-spacing: 0;
  font-family: var(--sans);
}
.obs-input {
  width: 100%;
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 12px 14px;
  font-size: 14px;
  font-family: var(--font);
  color: var(--text);
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  font-weight: 400;
}
.obs-input:focus {
  border-color: rgba(155,93,229,0.45);
  box-shadow: 0 0 0 3px rgba(155,93,229,0.07);
}
.obs-input::placeholder { color: var(--text-3); }
.obs-input.input-error { border-color: rgba(255,77,77,0.5); box-shadow: 0 0 0 3px rgba(255,77,77,0.07); }
.obs-input.input-error:focus { border-color: rgba(255,77,77,0.6); }
/* Custom date picker */
.date-picker {
  display: grid;
  grid-template-columns: 1fr 1.1fr 1.5fr;
  gap: 6px;
}
.date-select {
  width: 100%;
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 12px 10px;
  font-size: 14px;
  font-family: var(--font);
  color: var(--text);
  outline: none;
  cursor: pointer;
  appearance: none;
  -webkit-appearance: none;
  transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6' viewBox='0 0 10 6'%3E%3Cpath d='M1 1l4 4 4-4' stroke='%234A4A6A' stroke-width='1.5' fill='none' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 10px center;
  padding-right: 28px;
}
.date-select:focus {
  border-color: rgba(155,93,229,0.45);
  box-shadow: 0 0 0 3px rgba(155,93,229,0.07);
  background-color: rgba(155,93,229,0.04);
}
.date-select option {
  background: #0D0D1A;
  color: var(--text);
}
/* Placeholder state (first option selected) */
.date-select.empty { color: var(--text-3); }
.date-select.input-error { border-color: rgba(255,77,77,0.5); box-shadow: 0 0 0 3px rgba(255,77,77,0.07); }
.person-divider {
  width: 100%;
  height: 1px;
  background: var(--border);
  margin-bottom: 20px;
}

/* ── TEXTAREA ── */
.obs-textarea {
  width: 100%;
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 16px;
  font-size: 15px;
  font-family: var(--font);
  color: var(--text);
  outline: none;
  resize: none;
  min-height: 130px;
  line-height: 1.65;
  font-weight: 300;
  transition: border-color 0.2s, box-shadow 0.2s;
  margin-bottom: 20px;
}
.obs-textarea:focus {
  border-color: rgba(155,93,229,0.45);
  box-shadow: 0 0 0 3px rgba(155,93,229,0.07);
}
.obs-textarea::placeholder { color: var(--text-3); }

/* ── TAGS ── */
.tag-label {
  font-size: 11px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: var(--text-3);
  margin-bottom: 12px;
  align-self: flex-start;
}
.tag-group {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  width: 100%;
  margin-bottom: 36px;
}
.obs-tag {
  padding: 8px 16px;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 500;
  border: 1px solid var(--border);
  color: var(--text-2);
  cursor: pointer;
  transition: all 0.2s;
  user-select: none;
}
.obs-tag:hover { border-color: var(--purple); color: var(--text); }
.obs-tag.selected {
  background: var(--purple-dim);
  border-color: rgba(155,93,229,0.45);
  color: var(--purple);
}

/* ── MAIN BUTTON ── */
.btn-main {
  width: 100%;
  padding: 17px;
  background: linear-gradient(135deg, var(--pink), #C0004D);
  color: white;
  border-radius: 100px;
  font-size: 16px;
  font-weight: 700;
  font-family: var(--font);
  border: none;
  cursor: pointer;
  transition: all 0.25s;
  box-shadow: var(--glow-pink);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-top: auto;
}
.btn-main:hover { transform: translateY(-2px); box-shadow: 0 0 70px rgba(255,45,107,0.55); }
.btn-main:disabled {
  opacity: 0.35;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

/* ── LOADING SCREEN ── */
.loading-wrap {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 32px;
  padding: 40px 24px;
}
.scan-ring {
  width: 100px; height: 100px;
  border-radius: 50%;
  border: 2px solid rgba(255,45,107,0.15);
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}
.scan-ring::before {
  content: '';
  position: absolute;
  inset: -2px;
  border-radius: 50%;
  border: 2px solid transparent;
  border-top-color: var(--pink);
  animation: spin 1.1s linear infinite;
}
.scan-ring::after {
  content: '';
  position: absolute;
  inset: 10px;
  border-radius: 50%;
  border: 1px solid transparent;
  border-top-color: var(--purple);
  animation: spin 1.8s linear infinite reverse;
}
.scan-inner {
  width: 38px; height: 38px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(255,45,107,0.25), rgba(155,93,229,0.08));
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
}
@keyframes spin { to { transform: rotate(360deg); } }

.loading-text {
  font-size: 17px;
  font-weight: 600;
  color: var(--text);
  text-align: center;
  letter-spacing: -0.3px;
  transition: opacity 0.4s;
}
.loading-sub {
  font-size: 13px;
  color: var(--text-3);
  font-family: var(--mono);
  text-align: center;
  letter-spacing: 0.05em;
}
.loading-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: center;
}
.loading-bar-wrap {
  width: 100%;
  max-width: 280px;
  display: flex;
  align-items: center;
  gap: 10px;
}
.loading-bar-track {
  flex: 1;
  height: 4px;
  background: rgba(255,255,255,0.06);
  border-radius: 100px;
  overflow: hidden;
}
.loading-bar-fill {
  height: 100%;
  border-radius: 100px;
  background: linear-gradient(90deg, var(--purple), var(--pink));
  transition: width 1s ease;
}
.loading-bar-pct {
  font-size: 11px;
  font-family: var(--mono);
  color: var(--text-3);
  min-width: 32px;
  text-align: right;
}
.loading-notice {
  font-size: 11px;
  color: var(--text-3);
  font-family: var(--mono);
  text-align: center;
  line-height: 1.7;
  max-width: 280px;
}

/* ── RESULT NOTICE CARD ── */
.result-notice-wrap {
  padding: 16px 20px 0;
  display: flex;
  justify-content: center;
}
.result-notice-card {
  border-radius: 14px;
  padding: 14px 18px;
  font-size: 13px;
  font-weight: 300;
  line-height: 1.6;
  max-width: 560px;
  width: 100%;
}
.result-notice-ok {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  background: rgba(0,214,143,0.05);
  border: 1px solid rgba(0,214,143,0.2);
  color: var(--text-2);
  text-align: center;
}
.notice-check {
  color: var(--safe);
  margin-right: 6px;
}
.notice-body {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.notice-body strong {
  color: var(--text);
  font-weight: 600;
  display: block;
  margin-bottom: 2px;
}
.notice-sub {
  display: block;
  font-size: 11px;
  color: var(--text-3);
  margin-top: 4px;
}


/* ── RESULT SCREEN ── */
.result-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 32px 24px 48px;
  max-width: 600px;
  width: 100%;
  margin: 0 auto;
  gap: 16px;
}

/* ── Pesquisa pós-análise (CTA discreto) ── */
.survey-cta {
  width: 100%;
  text-align: center;
  border-top: 1px solid var(--border);
  margin-top: 8px;
  padding-top: 26px;
}
.survey-cta-text { font-size: 14px; color: var(--text-2); margin-bottom: 12px; }
.survey-cta-text strong { color: var(--text); }
.survey-cta-btn {
  display: inline-block;
  padding: 11px 24px;
  border-radius: 100px;
  border: 1px solid rgba(155,93,229,0.4);
  background: rgba(155,93,229,0.10);
  color: var(--text);
  font-size: 13.5px;
  font-weight: 600;
  text-decoration: none;
  transition: background 0.2s, border-color 0.2s;
}
.survey-cta-btn:hover { background: rgba(155,93,229,0.18); border-color: var(--purple); }

.score-card {
  width: 100%;
  background: linear-gradient(160deg, rgba(22,12,38,0.97), rgba(14,8,28,0.97));
  border: 1px solid var(--pink-border);
  border-radius: 20px;
  padding: 28px;
  position: relative;
  overflow: hidden;
}
.score-card::before {
  content: '';
  position: absolute;
  top: -1px; left: -1px; right: -1px;
  height: 2px;
  background: linear-gradient(90deg, transparent, var(--pink), var(--purple), transparent);
}
.score-label {
  font-size: 10px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: var(--text-2);
  margin-bottom: 10px;
}
.score-row {
  display: flex;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 16px;
}
.score-num {
  font-size: 64px;
  font-weight: 800;
  line-height: 1;
  color: var(--pink);
  text-shadow: 0 0 50px rgba(255,45,107,0.45);
  letter-spacing: -2px;
}
.score-num sup { font-size: 22px; letter-spacing: 0; color: var(--text-2); }
.score-bar-track {
  flex: 1;
  height: 8px;
  /* Full gradient always visible — cover masks unscored portion */
  background: linear-gradient(90deg, #FF4D4D 0%, #FF8800 18%, #FFB800 45%, #a8dd63 72%, #00D68F 100%);
  border-radius: 100px;
  overflow: hidden;
  margin-bottom: 6px;
  position: relative;
}
/* Dark cover from right — shrinks as score grows */
.score-bar-cover {
  position: absolute;
  top: 0; right: 0; bottom: 0;
  background: var(--bg);
  border-radius: 0 100px 100px 0;
  transition: width 1.2s cubic-bezier(0.22, 1, 0.36, 1);
}
.score-bar-labels {
  display: flex;
  justify-content: space-between;
  font-size: 9px;
  font-family: var(--mono);
  color: var(--text-3);
}
.verdict-pill {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 18px;
  border-radius: 100px;
  background: rgba(255,184,0,0.08);
  border: 1px solid rgba(255,184,0,0.22);
  font-size: 13px;
  font-weight: 700;
  color: var(--amber);
  margin-top: 4px;
  letter-spacing: 0.02em;
}

/* ── RES-CARD: card base universal para result ── */
.res-card {
  width: 100%;
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: 18px;
  padding: 22px;
}
.res-label {
  font-size: 11px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--text-2);
  font-weight: 500;
  margin-bottom: 14px;
}
.res-body {
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.7;
  margin: 0;
}

/* ── EXEC CHIPS (Resumo Executivo) ── */
.exec-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.exec-chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 400;
  line-height: 1.3;
}
.exec-chip.pos {
  background: rgba(0,214,143,0.07);
  border: 1px solid rgba(0,214,143,0.2);
  color: var(--safe);
}
.exec-chip.neg {
  background: rgba(255,45,107,0.06);
  border: 1px solid rgba(255,45,107,0.18);
  color: #ff6b8e;
}

/* ── NÍVEL DE RECIPROCIDADE — painel premium (Variante C: Executivo) ── */
.recip-hero {
  display: flex; align-items: center; gap: 22px;
  padding-bottom: 22px; margin-bottom: 20px;
  border-bottom: 1px solid var(--border);
}
.recip-hero-score { display: flex; align-items: baseline; flex-shrink: 0; }
.recip-hero-num {
  font-size: 58px; font-weight: 800; line-height: 0.85; letter-spacing: -2.5px;
  background: linear-gradient(135deg, #ffffff 0%, #b9b9da 100%);
  -webkit-background-clip: text; background-clip: text;
  -webkit-text-fill-color: transparent;
}
.recip-hero-max { font-size: 15px; font-weight: 700; color: var(--text-3); margin-left: 4px; }
.recip-hero-meta { flex: 1; min-width: 0; }
.recip-hero-verdict { font-size: 15px; font-weight: 700; color: var(--text); letter-spacing: -0.2px; }
.recip-hero-sub {
  font-size: 10.5px; font-family: var(--mono); text-transform: uppercase;
  letter-spacing: 0.1em; color: var(--pink); margin-top: 4px;
}
.recip-gauge { margin-top: 14px; }
.recip-gauge-track {
  position: relative; height: 6px; border-radius: 100px;
  background: rgba(255,255,255,0.07);
}
.recip-gauge-fill {
  position: absolute; left: 0; top: 0; bottom: 0; border-radius: 100px;
  background: linear-gradient(90deg, var(--pink), var(--purple));
}
.recip-gauge-marker {
  position: absolute; top: 50%; width: 12px; height: 12px; border-radius: 50%;
  background: #fff; transform: translate(-50%, -50%);
  box-shadow: 0 0 0 3px var(--bg), 0 0 10px var(--pink-glow);
}
.recip-gauge-scale {
  display: flex; justify-content: space-between; margin-top: 8px;
  font-size: 9px; font-family: var(--mono); text-transform: uppercase;
  letter-spacing: 0.06em; color: var(--text-3);
}

.recip-metrics { display: flex; flex-direction: column; gap: 15px; }
.recip-metric-top {
  display: flex; align-items: baseline; justify-content: space-between;
  gap: 12px; margin-bottom: 8px;
}
.recip-metric-label {
  font-family: var(--mono); font-size: 10px; text-transform: uppercase;
  letter-spacing: 0.08em; color: var(--text-2);
}
.recip-metric-val { font-size: 11px; font-family: var(--mono); white-space: nowrap; flex-shrink: 0; }
.recip-metric-val .lbl { color: var(--text-3); }
.recip-metric-val .sep { color: var(--text-3); margin: 0 5px; }
.recip-metric-val b { font-weight: 700; }
.recip-metric-val b.u { color: var(--pink); }
.recip-metric-val b.c { color: var(--purple); }
.recip-bar2 {
  height: 6px; border-radius: 100px; overflow: hidden;
  display: flex; background: rgba(255,255,255,0.05);
}
.recip-bar2-user { background: linear-gradient(90deg, var(--pink), #ff6b8e); height: 100%; }
.recip-bar2-crush { background: var(--purple); height: 100%; }
.recip-bar2-empty { width: 100%; background: rgba(255,255,255,0.05); height: 100%; }
.recip-dominance { margin-top: 6px; font-family: var(--mono); font-size: 9px; text-transform: uppercase; letter-spacing: 0.06em; color: var(--text-3); }
.recip-dominance span { color: var(--text-2); font-weight: 700; }

/* ── Critérios pontuados (novo modelo quantitativo) ── */
.recip-crit-head {
  display: flex; justify-content: space-between;
  font-family: var(--mono); font-size: 9px; text-transform: uppercase;
  letter-spacing: 0.1em; color: var(--text-3);
  padding-bottom: 9px; border-bottom: 1px solid var(--border);
}
.recip-crit { padding: 13px 0; border-bottom: 1px solid rgba(255,255,255,0.05); }
.recip-crit:last-child { border-bottom: none; }
.recip-crit-top { display: flex; align-items: baseline; justify-content: space-between; gap: 12px; }
.recip-crit-label { font-size: 13.5px; font-weight: 600; color: var(--text); }
.recip-crit-points { font-family: var(--mono); font-size: 14px; font-weight: 700; white-space: nowrap; flex-shrink: 0; }
.recip-crit-max { color: var(--text-3); font-weight: 400; font-size: 11px; }
.recip-crit-exp { margin: 4px 0 9px; font-size: 12.5px; color: var(--text-2); font-weight: 300; line-height: 1.55; }
.recip-crit-bar { height: 4px; border-radius: 100px; overflow: hidden; background: rgba(255,255,255,0.06); }
.recip-crit-bar-fill { height: 100%; border-radius: 100px; transition: width 0.5s ease; }
.recip-crit.forte   .recip-crit-points { color: #00D68F; }
.recip-crit.forte   .recip-crit-bar-fill { background: linear-gradient(90deg, #00D68F, #34D399); }
.recip-crit.parcial .recip-crit-points { color: #b98cff; }
.recip-crit.parcial .recip-crit-bar-fill { background: linear-gradient(90deg, var(--purple), #b98cff); }
.recip-crit.fraco   .recip-crit-points { color: #FF8C00; }
.recip-crit.fraco   .recip-crit-bar-fill { background: linear-gradient(90deg, #FF8C00, #ffb347); }
.recip-crit.ausente .recip-crit-points { color: var(--text-3); }
.recip-crit.ausente .recip-crit-exp { font-style: italic; color: var(--text-3); }
.recip-crit.ausente .recip-crit-bar { background: repeating-linear-gradient(90deg, rgba(255,255,255,0.07) 0 5px, transparent 5px 10px); }

.recip-conclusion {
  margin-top: 22px; padding: 15px 17px; border-radius: 12px;
  background: rgba(255,255,255,0.02);
  border: 1px solid var(--border); border-left: 2px solid var(--pink);
}
.recip-conclusion-tag {
  display: block; font-family: var(--mono); font-size: 9px;
  text-transform: uppercase; letter-spacing: 0.14em; color: var(--pink); margin-bottom: 7px;
}
.recip-conclusion p { margin: 0; font-size: 13px; color: var(--text); line-height: 1.65; }

/* ── CONTRADICTIONS CARD ── */
.contradiction-card {
  background: rgba(155,93,229,0.04);
  border-color: rgba(155,93,229,0.2);
}
.contradiction-item {
  padding: 12px 0;
  border-bottom: 1px solid var(--border);
}
.contradiction-item:last-child { border-bottom: none; padding-bottom: 0; }
.contradiction-item:first-child { padding-top: 0; }
.contradiction-title {
  font-size: 14px;
  font-weight: 500;
  color: var(--text);
  line-height: 1.5;
  margin-bottom: 6px;
}
.contradiction-sub {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.65;
}

/* ── POSTURE ── */
.posture-badge {
  display: inline-block;
  font-size: 13px;
  font-weight: 600;
  color: var(--pink);
  margin-bottom: 4px;
}
.posture-exp {
  display: block;
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.6;
  margin-top: 4px;
}
.emotional-type {
  display: block;
  font-size: 13px;
  font-weight: 500;
  color: var(--purple);
  margin-bottom: 4px;
}
.emotional-desc {
  display: block;
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.65;
}

/* ── DYNAMICS CONCLUSION ── */
.dynamics-conclusion {
  margin-top: 14px;
  padding-top: 14px;
  border-top: 1px solid var(--border);
  font-size: 14px;
  color: var(--text);
  line-height: 1.75;
}

/* ── CONCLUSÃO DA ANÁLISE ── */
.conclusion-card {
  background: rgba(255,45,107,0.04);
  border-color: rgba(255,45,107,0.18);
}
.conclusion-text {
  font-size: 14px;
  color: var(--text);
  line-height: 1.7;
  margin: 0;
  font-weight: 400;
}

/* ── PARA VOCÊ ── */
.for-you-card {
  width: 100%;
  background: linear-gradient(135deg, rgba(155,93,229,0.08), rgba(255,45,107,0.05));
  border: 1px solid rgba(155,93,229,0.22);
  border-radius: 18px;
  padding: 28px 24px;
  position: relative;
  overflow: hidden;
}
.for-you-card::before {
  content: '';
  position: absolute;
  top: -1px; left: 15%; right: 15%;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(155,93,229,0.5), transparent);
}
.for-you-label {
  font-size: 11px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--purple);
  font-weight: 500;
  margin-bottom: 14px;
}
.for-you-feelings { margin: 0 0 14px; }
.for-you-feelings .ff-intro {
  font-family: var(--mono); font-size: 10px; text-transform: uppercase;
  letter-spacing: 0.08em; color: var(--text-3); display: block; margin-bottom: 7px;
}
.ff-chip {
  display: inline-block; margin: 0 6px 6px 0; padding: 4px 12px; border-radius: 100px;
  background: rgba(155,93,229,0.12); border: 1px solid rgba(155,93,229,0.32);
  color: #c9a5f0; font-size: 12px; font-weight: 600;
}
.for-you-text {
  font-size: 15px;
  color: var(--text);
  line-height: 1.8;
  margin: 0;
  font-weight: 400;
}
.result-signature {
  margin: 14px 0 0;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 9px;
  font-family: var(--mono);
  font-size: 12px;
  font-style: italic;
  color: var(--purple);
  text-align: right;
}
.result-sig-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  flex-shrink: 0;
  border: 1.5px solid rgba(155,93,229,0.45);
}

/* ── SIGNALS CARD (mantido para compatibilidade) ── */
.signals-card {
  width: 100%;
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: 18px;
  padding: 22px;
}
.signals-title {
  font-size: 11px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--text-2);
  font-weight: 500;
  margin-bottom: 14px;
}
.signal-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  font-size: 13px;
  color: var(--text-2);
  font-weight: 300;
  line-height: 1.5;
  padding: 8px 0;
  border-bottom: 1px solid var(--border);
}
.signal-item:last-child { border-bottom: none; }
.sig-dot {
  width: 7px; height: 7px;
  border-radius: 50%;
  flex-shrink: 0;
  margin-top: 4px;
}
.sig-dot.r { background: var(--danger); box-shadow: 0 0 6px var(--danger); }
.sig-dot.g { background: var(--safe); box-shadow: 0 0 6px var(--safe); }

/* ── Free plan result ── */
.free-result-intro {
  width: 100%;
  margin-bottom: 4px;
}
.free-result-label {
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 0.12em;
  color: var(--pink);
  text-transform: uppercase;
  opacity: 0.8;
}
.free-insight-card {
  width: 100%;
  background: linear-gradient(135deg, rgba(155,93,229,0.08), rgba(255,45,107,0.06));
  border: 1px solid rgba(155,93,229,0.2);
  border-radius: 18px;
  padding: 24px 22px;
  position: relative;
}
.free-insight-card::before {
  content: '';
  position: absolute;
  top: -1px; left: 15%; right: 15%;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(155,93,229,0.5), transparent);
}
.free-insight-text {
  font-size: 15px;
  color: var(--text);
  line-height: 1.75;
  margin: 0;
  font-weight: 400;
}
.free-upgrade-hint {
  font-size: 13px;
  color: var(--text-3);
  text-align: center;
  margin: 6px 0 2px;
  line-height: 1.5;
}
.free-upgrade-card {
  width: 100%;
  background: var(--surface);
  border: 1px solid rgba(155,93,229,0.22);
  border-radius: 18px;
  padding: 24px 22px;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 8px;
  margin-bottom: 4px;
}
.free-upgrade-title {
  font-size: 17px;
  font-weight: 700;
  color: var(--text);
  margin: 0;
  letter-spacing: -0.3px;
}
.free-upgrade-desc {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.6;
  margin: 0 0 6px;
}

/* Locked section */
.locked-card {
  width: 100%;
  background: var(--card);
  border: 1px dashed rgba(255,45,107,0.2);
  border-radius: 18px;
  overflow: hidden;
  position: relative;
}
.locked-blur {
  padding: 22px;
  filter: blur(6px);
  opacity: 0.3;
  user-select: none;
  pointer-events: none;
  font-size: 13px;
  color: var(--text-2);
  font-weight: 300;
  line-height: 1.8;
}
.locked-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to bottom, transparent 0%, rgba(17,17,32,0.92) 40%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  padding: 20px;
  gap: 8px;
}
.locked-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--text);
  text-align: center;
}
.locked-sub-btn {
  font-size: 12px;
  font-weight: 600;
  color: var(--pink);
  background: rgba(255,45,107,0.1);
  border: 1px solid rgba(255,45,107,0.3);
  border-radius: 100px;
  padding: 7px 18px;
  cursor: pointer;
  font-family: var(--font);
  transition: background 0.2s, border-color 0.2s;
  margin-bottom: 4px;
}
.locked-sub-btn:hover {
  background: rgba(255,45,107,0.18);
  border-color: rgba(255,45,107,0.5);
}

.btn-unlock {
  width: 100%;
  padding: 17px;
  background: linear-gradient(135deg, var(--purple), #6D34A8);
  color: white;
  border-radius: 100px;
  font-size: 16px;
  font-weight: 700;
  font-family: var(--font);
  border: none;
  cursor: pointer;
  transition: all 0.25s;
  box-shadow: 0 0 50px rgba(155,93,229,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-top: 8px;
}
.btn-unlock:hover { transform: translateY(-2px); box-shadow: 0 0 70px rgba(155,93,229,0.55); }

.result-hint {
  font-size: 11px;
  color: var(--text-3);
  text-align: center;
  padding-bottom: 8px;
}

/* ── RESPONSIVE ── */
@media (min-width: 600px) {
  .screen-body, .result-body {
    padding: 56px 32px 64px;
  }
  .screen-header { padding: 22px 32px; }
}

/* ── MODAL OVERLAY ── */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(7,7,13,0.88);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.25s ease;
}
.modal-overlay.open {
  opacity: 1;
  pointer-events: all;
}
.modal-card {
  background: linear-gradient(160deg, #0F0F1E, #0A0A14);
  border: 1px solid rgba(255,45,107,0.22);
  border-radius: 24px;
  padding: 36px 28px 32px;
  width: 100%;
  max-width: clamp(520px, 92vw, 1040px);
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  box-shadow:
    0 0 80px rgba(255,45,107,0.1),
    0 40px 80px rgba(0,0,0,0.6);
  transform: scale(0.92) translateY(12px);
  transition: transform 0.32s cubic-bezier(0.22, 1, 0.36, 1);
}
.modal-card::-webkit-scrollbar { width: 4px; }
.modal-card::-webkit-scrollbar-track { background: transparent; }
.modal-card::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.08); border-radius: 4px; }
.modal-overlay.open .modal-card {
  transform: scale(1) translateY(0);
}

/* Close button */
.modal-close {
  position: absolute;
  top: 16px; right: 16px;
  width: 34px; height: 34px;
  border-radius: 50%;
  background: rgba(255,255,255,0.05);
  border: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: var(--text-2);
  font-size: 20px;
  line-height: 1;
  transition: all 0.2s;
  font-family: var(--font);
}
.modal-close:hover { background: rgba(255,255,255,0.1); color: var(--text); }

/* Modal header */
.modal-eyebrow {
  font-size: 10px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: var(--pink);
  margin-bottom: 12px;
}
.modal-title span { color: var(--pink); }
.modal-title {
  font-size: clamp(18px, 4vw, 22px);
  font-weight: 800;
  letter-spacing: -0.6px;
  line-height: 1.2;
  margin-bottom: 8px;
  padding-right: 36px;
}
.modal-sub {
  font-size: 14px;
  color: var(--text-2);
  font-weight: 300;
  line-height: 1.65;
  margin-bottom: 28px;
}
.modal-hook-sub {
  font-size: 13px;
  color: var(--text-2);
  margin-bottom: 24px;
}

/* Plans grid */
.modal-plans {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14px;
  max-width: 1000px;
  margin: 26px auto 0;   /* centraliza os 3 cards + espaço p/ o badge não colar no título */
}
@media (max-width: 860px) {
  .modal-plans { grid-template-columns: 1fr; }
  .modal-card { padding: 28px 20px 24px; }
}

/* Plan card */
.plan-card {
  background: rgba(255,255,255,0.02);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 20px 16px;
  display: flex;
  flex-direction: column;
  gap: 0;
  position: relative;
  transition: border-color 0.2s;
}
.plan-card.featured {
  border-color: rgba(255,45,107,0.38);
  background: linear-gradient(160deg, rgba(255,45,107,0.08), rgba(17,17,32,0.98));
  box-shadow: 0 0 40px rgba(255,45,107,0.14), inset 0 1px 0 rgba(255,45,107,0.2);
  padding: 26px 18px;
}
.plan-card.featured::before {
  content: '';
  position: absolute;
  top: -1px; left: -1px; right: -1px;
  height: 2px;
  border-radius: 16px 16px 0 0;
  background: linear-gradient(90deg, transparent, var(--pink), var(--purple), transparent);
}

.plan-badge {
  position: absolute;
  top: -11px;
  left: 50%;
  transform: translateX(-50%);
  background: linear-gradient(90deg, var(--pink), #C0004D);
  color: white;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 0.06em;
  padding: 4px 14px;
  border-radius: 100px;
  white-space: nowrap;
  box-shadow: 0 0 16px rgba(255,45,107,0.4);
}

.plan-name {
  font-size: 13px;
  font-weight: 700;
  color: var(--text);
  letter-spacing: -0.2px;
  margin-bottom: 10px;
}
.plan-price {
  font-size: 28px;
  font-weight: 800;
  color: var(--text);
  letter-spacing: -1px;
  line-height: 1;
  margin-bottom: 4px;
  display: flex;
  align-items: flex-start;
  gap: 2px;
}
.plan-price .curr {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-2);
  margin-top: 5px;
}
.plan-price .cents {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-2);
  align-self: flex-end;
  margin-bottom: 2px;
}
.plan-period {
  font-size: 11px;
  color: var(--text-3);
  font-family: var(--mono);
  margin-bottom: 16px;
}

.plan-items {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 7px;
  margin-bottom: 18px;
}
.plan-item {
  font-size: 12px;
  color: var(--text-2);
  font-weight: 300;
  display: flex;
  align-items: flex-start;
  gap: 7px;
  line-height: 1.45;
}
.plan-item::before {
  content: '✦';
  color: var(--pink);
  font-size: 8px;
  margin-top: 2px;
  flex-shrink: 0;
  opacity: 0.7;
}
.plan-card.featured .plan-item { color: var(--text); }
.plan-item-includes {
  color: var(--pink) !important;
  font-size: 11px;
  opacity: 0.8;
  padding-bottom: 4px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  margin-bottom: 2px;
}
.plan-item-includes::before { display: none; }
.plan-desc {
  font-size: 12px;
  color: var(--text-2);
  font-weight: 300;
  font-style: italic;
  line-height: 1.6;
  margin-bottom: 14px;
}
.plan-hook {
  font-size: 11px;
  font-weight: 600;
  color: var(--pink);
  line-height: 1.45;
  margin-bottom: 12px;
  letter-spacing: -0.1px;
}
.plan-access {
  font-size: 11px;
  color: var(--text-3);
  text-align: center;
  margin-top: 8px;
  font-family: var(--mono);
}

.btn-plan {
  width: 100%;
  padding: 12px;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 700;
  font-family: var(--font);
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(255,255,255,0.05);
  color: var(--text-2);
  cursor: pointer;
  transition: all 0.2s;
  margin-top: auto;
}
.btn-plan:hover { background: rgba(255,255,255,0.1); color: var(--text); }
.btn-plan.primary {
  background: linear-gradient(135deg, var(--pink), #C0004D);
  border: none;
  color: white;
  box-shadow: 0 0 24px rgba(255,45,107,0.4);
}
.btn-plan.primary:hover { transform: translateY(-1px); box-shadow: 0 0 40px rgba(255,45,107,0.6); }

/* Modal divider */
.modal-divider {
  height: 1px;
  background: var(--border);
  margin: 24px 0 16px;
}
.modal-guarantee {
  text-align: center;
  font-size: 12px;
  color: var(--text-3);
  font-family: var(--mono);
}

/* ── UPLOAD LIMIT UX ── */
.upload-meta {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 10px;
}
.upload-counter {
  font-size: 12px;
  font-family: var(--mono);
  color: var(--text-3);
  white-space: nowrap;
  transition: color 0.3s;
  flex-shrink: 0;
}
.upload-counter.warn { color: var(--amber); }
.upload-counter.full { color: var(--danger); }
.upload-bar-track {
  flex: 1;
  height: 3px;
  background: rgba(255,255,255,0.06);
  border-radius: 100px;
  overflow: hidden;
}
.upload-bar-fill {
  height: 100%;
  border-radius: 100px;
  background: var(--purple);
  width: 0%;
  transition: width 0.4s cubic-bezier(0.22,1,0.36,1), background 0.3s;
}
.upload-bar-fill.warn { background: var(--amber); }
.upload-bar-fill.full { background: var(--danger); }

/* Limit alert */
.limit-alert {
  width: 100%;
  background: rgba(255,184,0,0.06);
  border: 1px solid rgba(255,184,0,0.2);
  border-radius: 14px;
  padding: 16px 18px;
  display: none;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 12px;
  margin-bottom: 16px;
  animation: fadeIn 0.3s ease;
}
.limit-alert.visible { display: flex; }
.limit-alert-icon { font-size: 20px; }
.limit-alert-text {
  font-size: 13px;
  color: var(--amber);
  font-weight: 400;
  line-height: 1.65;
}
.btn-upgrade-inline {
  width: 100%;
  padding: 13px;
  background: linear-gradient(135deg, var(--pink), #C0004D);
  color: white;
  border-radius: 100px;
  font-size: 14px;
  font-weight: 700;
  font-family: var(--font);
  border: none;
  cursor: pointer;
  box-shadow: 0 0 24px rgba(255,45,107,0.3);
  transition: all 0.25s;
}
.btn-upgrade-inline:hover { transform: translateY(-1px); box-shadow: 0 0 40px rgba(255,45,107,0.55); }

/* Warning before generate */
.once-warning {
  width: 100%;
  background: rgba(255,184,0,0.05);
  border: 1px solid rgba(255,184,0,0.14);
  border-radius: 12px;
  padding: 13px 16px;
  font-size: 12px;
  color: rgba(255,184,0,0.65);
  font-weight: 400;
  line-height: 1.7;
  margin-bottom: 14px;
  text-align: center;
}
.once-warning strong {
  color: rgba(255,184,0,0.92);
  font-weight: 600;
}

/* Disclaimer cards — plano gratuito */
.free-disclaimer-card {
  width: 100%;
  background: rgba(155,93,229,0.06);
  border: 1px solid rgba(155,93,229,0.18);
  border-radius: 12px;
  padding: 14px 16px;
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.65;
  margin-bottom: 10px;
  text-align: center;
}
.free-disclaimer-card p { margin: 0 0 4px; }
.free-disclaimer-card p:last-child { margin: 0; }
.free-disclaimer-sub {
  font-size: 12px;
  color: var(--text-3);
  margin-top: 6px !important;
}
.free-disclaimer-card--soft {
  background: rgba(255,255,255,0.03);
  border-color: rgba(255,255,255,0.07);
  font-size: 12px;
  color: var(--text-3);
  text-align: center;
}

/* Terms — paid flow */
.paid-terms-wrap {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 14px;
}
.paid-terms-notice {
  font-size: 12px;
  color: var(--text-3);
  text-align: center;
  line-height: 1.5;
}
.paid-terms-label {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  cursor: pointer;
  font-size: 12px;
  color: var(--text-3);
  line-height: 1.55;
  padding: 12px 14px;
  background: rgba(255,255,255,0.03);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 10px;
  transition: border-color 0.2s;
}
.paid-terms-label:hover { border-color: rgba(255,255,255,0.12); }
.paid-terms-check {
  flex-shrink: 0;
  margin-top: 1px;
  accent-color: var(--pink);
  width: 14px;
  height: 14px;
  cursor: pointer;
}
.paid-terms-label a {
  color: var(--text-2);
  text-decoration: underline;
  text-underline-offset: 3px;
}
.paid-terms-label a:hover { color: var(--text); }

/* Blocked state after analysis */
.analysis-blocked-msg {
  width: 100%;
  background: rgba(255,184,0,0.05);
  border: 1px solid rgba(255,184,0,0.14);
  border-radius: 14px;
  padding: 18px;
  font-size: 13px;
  color: var(--amber);
  line-height: 1.65;
  text-align: center;
  display: none;
  animation: fadeIn 0.3s ease;
}
.analysis-blocked-msg.visible { display: block; }

/* Updated result hint */
.result-urgent {
  font-size: 12px;
  color: var(--amber);
  text-align: center;
  margin-top: 12px;
  padding-bottom: 8px;
  line-height: 1.5;
  opacity: 0.9;
}

/* ── RESULT: novos elementos dinâmicos ── */
.result-summary-card {
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 16px 18px;
  margin-bottom: 16px;
}
.result-summary-text {
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.7;
}
.signal-section-label {
  font-size: 10px;
  font-family: var(--mono);
  letter-spacing: 0.08em;
  color: var(--text-3);
  text-transform: uppercase;
  margin-bottom: 6px;
  margin-top: 2px;
}
.sig-dot.y {
  background: var(--amber);
  box-shadow: 0 0 6px rgba(255,184,0,0.5);
}
.behavior-row {
  display: flex;
  gap: 12px;
  margin-bottom: 8px;
  align-items: flex-start;
}
.behavior-label {
  font-size: 11px;
  font-family: var(--mono);
  color: var(--text-3);
  min-width: 100px;
  flex-shrink: 0;
  padding-top: 1px;
}
.behavior-val {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.6;
}
.res-behavior-pattern .behavior-val {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.65;
}
.result-conclusion {
  margin-top: 14px;
  padding-top: 14px;
  border-top: 1px solid var(--border);
  font-size: 14px;
  color: var(--text);
  line-height: 1.75;
}
.cta-result-card {
  background: linear-gradient(135deg, rgba(255,45,107,0.08), rgba(155,93,229,0.06));
  border: 1px solid var(--pink-border);
  border-radius: 14px;
  padding: 18px;
  margin-bottom: 14px;
  text-align: center;
}
.cta-result-title {
  font-size: 16px;
  font-weight: 700;
  margin-bottom: 6px;
  line-height: 1.4;
}
.cta-result-sub {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.6;
}
.cta-price-note {
  text-align: center;
  font-size: 12px;
  color: var(--text-3);
  margin-top: 10px;
  margin-bottom: 6px;
}
.result-final-msg {
  text-align: center;
  font-size: 14px;
  font-style: italic;
  color: var(--text-2);
  margin: 16px 0 8px;
  line-height: 1.6;
}

/* ── HIGHLIGHT CARDS ── */
.highlight-card {
  background: rgba(255,184,0,0.04);
  border: 1px solid rgba(255,184,0,0.15);
  border-radius: 12px;
  padding: 14px 16px;
  margin-bottom: 10px;
}
.highlight-card:last-child { margin-bottom: 0; }
.highlight-quote {
  font-size: 14px;
  font-style: italic;
  color: #FFB800;
  line-height: 1.55;
  margin-bottom: 8px;
  font-weight: 400;
}
.highlight-exp {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.65;
}

/* ── DEEP ANALYSIS PARAGRAPHS ── */
.deep-paragraph {
  padding: 14px 0;
  border-bottom: 1px solid var(--border);
}
.deep-paragraph:last-child { border-bottom: none; padding-bottom: 0; }
.deep-paragraph:first-child { padding-top: 0; }
.deep-title {
  font-family: var(--mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-weight: 700;
  margin-bottom: 7px;
}
.deep-title.positivo { color: var(--safe); }
.deep-title.negativo { color: #ff6b8e; }
.deep-title.atencao  { color: var(--amber); }
.deep-text {
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.75;
  margin: 0;
}

/* ── FINAL VERDICT CARD ── */
.final-verdict-card {
  width: 100%;
  background: rgba(255,45,107,0.05);
  border: 1px solid rgba(255,45,107,0.2);
  border-radius: 14px;
  padding: 18px 20px;
}
.final-verdict-text {
  font-size: 14px;
  color: var(--text-1);
  line-height: 1.6;
  margin: 0;
  font-weight: 400;
}

/* ── LIMITES DA LEITURA ── */
.limits-card { background: transparent; border-color: var(--border); }
.limits-text { font-size: 13px; color: var(--text-2); line-height: 1.75; margin: 0; }

/* ── SOBRE ESTA ANÁLISE (encerramento web) ── */
.about-analysis-card {
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 22px 22px 20px;
  background: linear-gradient(160deg, rgba(255,45,107,0.04), rgba(155,93,229,0.03));
}
.about-label {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  color: var(--text-3);
  margin-bottom: 12px;
}
.about-emotional {
  font-size: 15px;
  color: var(--text);
  line-height: 1.7;
  font-weight: 600;
  margin: 0 0 14px;
  letter-spacing: -0.1px;
}
.about-text {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.75;
  margin: 0 0 18px;
}
.about-sign {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 4px;
  padding-top: 16px;
  border-top: 1px solid var(--border);
}
.about-sign-brand {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  font-size: 15px;
  font-weight: 800;
  letter-spacing: -0.3px;
  color: var(--text);
}
.about-sign-brand svg { filter: drop-shadow(0 0 6px var(--pink)); }
.about-sign-word span { color: var(--pink); }
.about-sign-slogan {
  font-size: 12px;
  color: var(--text-3);
  font-style: italic;
}

/* ── PDF DOWNLOAD — CARD DE VALOR ── */
.pdf-download-card {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 8px;
  padding: 26px 22px 22px;
  margin-top: 8px;
  border: 1px solid var(--pink-border);
  border-radius: 18px;
  background:
    radial-gradient(ellipse 80% 120% at 50% 0%, rgba(255,45,107,0.08), transparent 70%),
    var(--card);
}
.pdf-download-title {
  font-size: 17px;
  font-weight: 800;
  letter-spacing: -0.3px;
  color: var(--text);
}
.pdf-download-desc {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.6;
  max-width: 360px;
  margin: 0 0 8px;
}
.btn-pdf-primary {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 18px;
  background: linear-gradient(135deg, var(--pink), #C0004D);
  color: white;
  border-radius: 100px;
  font-size: 16px;
  font-weight: 700;
  font-family: var(--font);
  border: none;
  cursor: pointer;
  transition: all 0.25s;
  box-shadow: var(--glow-pink);
  letter-spacing: 0.01em;
}
.btn-pdf-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 0 60px rgba(255,45,107,0.5), 0 0 110px rgba(255,45,107,0.15);
}
.pdf-hint {
  font-size: 12px;
  color: var(--text-3);
  text-align: center;
  margin: 0;
}

/* ── FOOTER ── */
.result-footer {
  border-top: 1px solid var(--border);
  padding: 28px 24px;
  margin-top: 16px;
}
.footer-inner {
  max-width: 600px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  text-align: center;
}
.footer-brand {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  font-size: 15px;
  font-weight: 800;
  letter-spacing: -0.3px;
  color: var(--text-2);
}
.footer-brand svg { filter: drop-shadow(0 0 6px var(--pink)); }
.footer-brand-word span { color: var(--pink); }
.footer-links {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  justify-content: center;
}
.footer-links a {
  font-size: 12px;
  color: var(--text-3);
  text-decoration: none;
  transition: color 0.2s;
}
.footer-links a:hover { color: var(--text-2); }
.footer-copy {
  font-size: 11px;
  color: var(--text-3);
  line-height: 1.6;
  max-width: 440px;
  margin: 0;
  opacity: 0.7;
}

/* ════════════════════════════════════════════════════ */
/* PDF DOCUMENT — identidade própria, light premium       */
/* Oculto na tela; renderizado apenas na impressão.       */
/* ════════════════════════════════════════════════════ */
.pdf-doc {
  display: none;
  --pdf-ink:    #1a1a2e;
  --pdf-body:   #3a3a52;
  --pdf-muted:  #6a6a82;
  --pdf-faint:  #9a9ab0;
  --pdf-line:   #eaeaf1;
  --pdf-card:   #ffffff;
  --pdf-soft:   #f7f7fb;
  --pdf-pink:   #FF2D6B;
  --pdf-purple: #9B5DE5;
  --pdf-green:  #00A36C;
  --pdf-amber:  #E08A00;
  font-family: var(--font);
  color: var(--pdf-body);
}

/* ---- CAPA ---- */
.pdf-cover {
  position: relative;
  display: flex;
  flex-direction: column;
  min-height: 100%;
  padding: 6mm 2mm 4mm;
  text-align: center;
  overflow: hidden;
}
/* Faixa superior com gradiente de marca */
.pdf-cover-strip {
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 5px;
  background: linear-gradient(90deg, #FF2D6B, #9B5DE5);
}
/* Marca d'água do símbolo — discreta */
.pdf-cover-watermark {
  position: absolute;
  width: 150mm;
  height: 150mm;
  right: -45mm;
  bottom: -40mm;
  opacity: 0.04;
  pointer-events: none;
}
.pdf-cover-top { padding-top: 8mm; position: relative; }
.pdf-logo {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 9px;
}
.pdf-logo-word {
  font-size: 24px;
  font-weight: 800;
  letter-spacing: -0.5px;
  color: var(--pdf-ink);
}
.pdf-logo-word span { color: var(--pdf-pink); }
.pdf-cover-slogan {
  margin: 12px 0 0;
  font-size: 13px;
  font-style: italic;
  color: var(--pdf-muted);
  letter-spacing: 0.01em;
}
.pdf-cover-center {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 14mm 0;
  position: relative;
}
.pdf-cover-eyebrow {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--pdf-faint);
  margin: 0 0 14px;
}
.pdf-cover-title {
  font-size: 44px;
  font-weight: 800;
  letter-spacing: 2.5px;
  color: var(--pdf-ink);
  margin: 0;
  line-height: 1.05;
}
.pdf-cover-subtitle {
  font-size: 14px;
  color: var(--pdf-muted);
  max-width: 360px;
  line-height: 1.6;
  margin: 16px auto 0;
}
/* Score teaser compacto na capa */
.pdf-cover-score {
  margin-top: 14mm;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}
.pdf-cover-score-num {
  font-size: 46px;
  font-weight: 800;
  color: var(--pdf-ink);
  line-height: 1;
  letter-spacing: -2px;
}
.pdf-cover-score-num span { font-size: 16px; color: var(--pdf-faint); font-weight: 700; }
.pdf-cover-protocol {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--pdf-muted);
  margin: 0 0 6px;
}
.pdf-cover-protocol strong { color: var(--pdf-ink); }
.pdf-cover-prints {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--pdf-muted);
  margin: 0 0 6px;
}
.pdf-cover-prints strong { color: var(--pdf-pink); }
.pdf-score-block {
  width: 100%;
  max-width: 440px;
  margin: 0 auto;
  text-align: center;
}
.pdf-block--score { text-align: center; }
.pdf-score-num {
  font-size: 60px;
  font-weight: 800;
  color: var(--pdf-ink);
  line-height: 1;
  letter-spacing: -2px;
}
.pdf-score-num span { font-size: 20px; color: var(--pdf-faint); font-weight: 700; }
.pdf-score-caption {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--pdf-faint);
  margin: 8px 0 14px;
}
.pdf-score-svg { width: 100%; height: auto; display: block; }
.pdf-score-scale {
  display: flex;
  justify-content: space-between;
  padding: 0 24px;
  margin-top: 2px;
  font-size: 10px;
  color: var(--pdf-faint);
}
.pdf-verdict-pill {
  display: inline-block;
  margin-top: 16px;
  padding: 9px 22px;
  border-radius: 100px;
  background: rgba(255,45,107,0.08);
  border: 1px solid rgba(255,45,107,0.28);
  font-size: 14px;
  font-weight: 700;
  color: var(--pdf-ink);
}
.pdf-cover-foot {
  padding-top: 6mm;
}
.pdf-cover-owner {
  font-size: 11px;
  color: var(--pdf-muted);
  margin: 0 0 4px;
}
.pdf-cover-owner strong { color: var(--pdf-pink); }
.pdf-cover-meta {
  font-size: 10px;
  color: var(--pdf-faint);
  margin: 0;
}
/* Rodapé fixo — repete em cada página impressa */
.pdf-running-foot {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  text-align: center;
  font-family: var(--mono);
  font-size: 8.5px;
  letter-spacing: 0.04em;
  color: var(--pdf-faint);
}

/* ---- RELATÓRIO ---- */
.pdf-report { padding: 2mm; }
.pdf-block {
  border: 1px solid var(--pdf-line);
  border-radius: 14px;
  padding: 18px 20px;
  margin-bottom: 12px;
  background: var(--pdf-card);
}
.pdf-block--verdict { border-left: 3px solid var(--pdf-pink); }
.pdf-block--foryou  { border-left: 3px solid var(--pdf-purple); background: var(--pdf-soft); }
.pdf-foryou-feelings { margin: 0 0 9px; }
.pdf-signature { margin: 8px 0 0; font-family: var(--mono); font-size: 10.5px; font-style: italic; color: var(--pdf-purple); text-align: right; }
.pdf-ff-intro { font-family: var(--mono); font-size: 9px; text-transform: uppercase; letter-spacing: 0.06em; color: var(--pdf-faint); display: block; margin-bottom: 5px; }
.pdf-ff-chip { display: inline-block; margin: 0 5px 5px 0; padding: 3px 10px; border-radius: 100px; background: rgba(155,93,229,0.10); border: 1px solid rgba(155,93,229,0.32); color: var(--pdf-purple); font-size: 11px; font-weight: 700; }
.pdf-block--limits  { background: var(--pdf-soft); }
.pdf-block--limits .pdf-p { color: var(--pdf-faint); font-size: 12px; }
.pdf-block-label {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--pdf-faint);
  margin-bottom: 12px;
}
.pdf-p {
  font-size: 13px;
  color: var(--pdf-body);
  line-height: 1.75;
  margin: 0 0 10px;
}
.pdf-p:last-child { margin-bottom: 0; }
.pdf-deep-item + .pdf-deep-item { margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--pdf-line); }
.pdf-deep-title {
  font-family: var(--mono);
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  font-weight: 700;
  margin-bottom: 5px;
}
.pdf-deep-title.positivo { color: var(--pdf-green); }
.pdf-deep-title.negativo { color: var(--pdf-pink); }
.pdf-deep-title.atencao  { color: var(--pdf-amber); }

/* ── PDF: Nível de Reciprocidade — painel premium (Variante C) ── */
.pdf-recip-hero { display: flex; align-items: center; gap: 18px; padding-bottom: 16px; margin-bottom: 16px; border-bottom: 1px solid var(--pdf-line); }
.pdf-recip-score { display: flex; align-items: baseline; flex-shrink: 0; }
.pdf-recip-num { font-size: 44px; font-weight: 800; color: var(--pdf-ink); letter-spacing: -2px; line-height: 0.85; }
.pdf-recip-max { font-size: 13px; font-weight: 700; color: var(--pdf-faint); margin-left: 3px; }
.pdf-recip-meta { flex: 1; min-width: 0; }
.pdf-recip-verdict { font-size: 13px; font-weight: 700; color: var(--pdf-ink); }
.pdf-recip-sub { font-family: var(--mono); font-size: 9.5px; text-transform: uppercase; letter-spacing: 0.1em; color: var(--pdf-pink); margin-top: 3px; }
.pdf-recip-gauge { margin-top: 11px; }
.pdf-recip-gauge-track { position: relative; height: 6px; border-radius: 100px; background: #eaeaf1; }
.pdf-recip-gauge-fill { position: absolute; left: 0; top: 0; bottom: 0; border-radius: 100px; background: linear-gradient(90deg, var(--pdf-pink), var(--pdf-purple)); }
.pdf-recip-gauge-marker { position: absolute; top: 50%; width: 11px; height: 11px; border-radius: 50%; background: #fff; transform: translate(-50%, -50%); box-shadow: 0 0 0 2px #fff, 0 0 0 3px var(--pdf-pink); }
.pdf-recip-scale { display: flex; justify-content: space-between; margin-top: 7px; font-family: var(--mono); font-size: 8.5px; text-transform: uppercase; letter-spacing: 0.06em; color: var(--pdf-faint); }
.pdf-recip-metric { padding: 0 0 12px; }
.pdf-recip-metric:last-of-type { padding-bottom: 0; }
.pdf-recip-mtop { display: flex; align-items: baseline; justify-content: space-between; gap: 12px; margin-bottom: 6px; }
.pdf-recip-mlabel { font-family: var(--mono); font-size: 9.5px; text-transform: uppercase; letter-spacing: 0.06em; color: var(--pdf-muted); }
.pdf-recip-mval { font-family: var(--mono); font-size: 10px; white-space: nowrap; flex-shrink: 0; }
.pdf-recip-mval .lbl { color: var(--pdf-faint); }
.pdf-recip-mval .sep { color: var(--pdf-faint); margin: 0 5px; }
.pdf-recip-mval b { font-weight: 800; }
.pdf-recip-mval b.u { color: var(--pdf-pink); }
.pdf-recip-mval b.c { color: var(--pdf-purple); }
.pdf-recip-bar2 { height: 6px; border-radius: 100px; overflow: hidden; display: flex; background: #eef0f4; }
.pdf-recip-bar2-u { background: var(--pdf-pink); height: 100%; }
.pdf-recip-bar2-c { background: var(--pdf-purple); height: 100%; }
.pdf-recip-dominance { margin-top: 5px; font-family: var(--mono); font-size: 8.5px; text-transform: uppercase; letter-spacing: 0.05em; color: var(--pdf-faint); }
.pdf-recip-dominance span { color: var(--pdf-muted); font-weight: 700; }

/* ── Critérios pontuados no PDF (novo modelo) ── */
.pdf-recip-crit { padding: 9px 0; border-bottom: 1px solid var(--pdf-line); }
.pdf-recip-crit:last-of-type { border-bottom: none; }
.pdf-recip-crit-top { display: flex; align-items: baseline; justify-content: space-between; gap: 10px; }
.pdf-recip-crit-label { font-size: 12.5px; font-weight: 700; color: var(--pdf-body); }
.pdf-recip-crit-points { font-family: var(--mono); font-size: 12.5px; font-weight: 700; white-space: nowrap; }
.pdf-recip-crit-exp { margin: 3px 0 7px; font-size: 11.5px; color: var(--pdf-muted); line-height: 1.5; }
.pdf-recip-crit-bar { height: 4px; border-radius: 100px; overflow: hidden; background: #eef0f4; }
.pdf-recip-crit-bar-fill { height: 100%; border-radius: 100px; }
.pdf-recip-crit.forte   .pdf-recip-crit-points { color: #0a9d6e; }
.pdf-recip-crit.forte   .pdf-recip-crit-bar-fill { background: #00C281; }
.pdf-recip-crit.parcial .pdf-recip-crit-points { color: #7a3fd0; }
.pdf-recip-crit.parcial .pdf-recip-crit-bar-fill { background: #9B5DE5; }
.pdf-recip-crit.fraco   .pdf-recip-crit-points { color: #d97400; }
.pdf-recip-crit.fraco   .pdf-recip-crit-bar-fill { background: #FF8C00; }
.pdf-recip-crit.ausente .pdf-recip-crit-points { color: var(--pdf-faint); }
.pdf-recip-crit.ausente .pdf-recip-crit-exp { font-style: italic; color: var(--pdf-faint); }
.pdf-recip-crit.ausente .pdf-recip-crit-bar { background: repeating-linear-gradient(90deg, #e2e5ea 0 5px, transparent 5px 10px); }
.pdf-recip-bar2-empty { width: 100%; background: #eef0f4; height: 100%; }
.pdf-recip-conclusion { margin-top: 16px; padding: 12px 14px; border-radius: 9px; background: #faf7fb; border: 1px solid var(--pdf-line); border-left: 2px solid var(--pdf-pink); }
.pdf-recip-conclusion-tag { display: block; font-family: var(--mono); font-size: 8.5px; text-transform: uppercase; letter-spacing: 0.14em; color: var(--pdf-pink); margin-bottom: 6px; }
.pdf-recip-conclusion p { margin: 0; font-size: 12.5px; color: var(--pdf-ink); line-height: 1.6; }
.pdf-chips { display: flex; flex-wrap: wrap; gap: 7px; }
.pdf-chip {
  font-size: 12px;
  padding: 5px 13px;
  border-radius: 100px;
  border: 1px solid;
}
.pdf-chip.pos { color: var(--pdf-green); border-color: rgba(0,163,108,0.4); background: rgba(0,163,108,0.07); }
.pdf-chip.neg { color: var(--pdf-pink);  border-color: rgba(255,45,107,0.4); background: rgba(255,45,107,0.06); }
.pdf-signal {
  position: relative;
  padding-left: 18px;
  font-size: 13px;
  color: var(--pdf-body);
  line-height: 1.65;
  margin-bottom: 7px;
}
.pdf-dot {
  position: absolute;
  left: 0; top: 7px;
  width: 7px; height: 7px;
  border-radius: 50%;
}
.pdf-dot.g { background: var(--pdf-green); }
.pdf-dot.r { background: var(--pdf-pink); }
.pdf-dot.y { background: var(--pdf-amber); }
.pdf-highlight {
  padding: 13px 15px;
  background: var(--pdf-soft);
  border-left: 2px solid var(--pdf-purple);
  border-radius: 8px;
  margin-bottom: 10px;
}
.pdf-quote {
  font-size: 13px;
  font-style: italic;
  color: var(--pdf-ink);
  line-height: 1.55;
  margin-bottom: 6px;
}
.pdf-quote-exp { font-size: 12.5px; color: var(--pdf-muted); line-height: 1.6; }
.pdf-contradiction {
  padding-bottom: 10px;
  margin-bottom: 10px;
  border-bottom: 1px solid var(--pdf-line);
}
.pdf-contradiction:last-child { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }
.pdf-contradiction-title { font-size: 13.5px; font-weight: 600; color: var(--pdf-ink); line-height: 1.5; }
.pdf-contradiction-sub { font-size: 12.5px; color: var(--pdf-muted); line-height: 1.6; margin-top: 4px; }
.pdf-row {
  display: flex;
  gap: 14px;
  margin-bottom: 10px;
}
.pdf-row:last-child { margin-bottom: 0; }
.pdf-row-label {
  flex: 0 0 92px;
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--pdf-faint);
  padding-top: 2px;
}
.pdf-row-val { flex: 1; font-size: 13px; color: var(--pdf-body); line-height: 1.6; }
.pdf-row-sub { display: block; font-size: 12px; color: var(--pdf-muted); margin-top: 3px; }
.pdf-accent-pink { color: var(--pdf-pink); }
.pdf-accent-purple { color: var(--pdf-purple); }
.pdf-conclusion {
  margin: 12px 0 0;
  padding-top: 12px;
  border-top: 1px solid var(--pdf-line);
  font-size: 13.5px;
  color: var(--pdf-ink);
  line-height: 1.7;
}

/* ---- Encerramento + footer ---- */
.pdf-about {
  margin-top: 4px;
  padding: 22px;
  border-radius: 14px;
  background: var(--pdf-soft);
  border: 1px solid var(--pdf-line);
}
.pdf-about-emotional {
  font-size: 15px;
  font-weight: 600;
  color: var(--pdf-ink);
  line-height: 1.7;
  margin: 0 0 14px;
}
.pdf-about-legal {
  font-size: 11.5px;
  color: var(--pdf-faint);
  line-height: 1.7;
  margin: 0;
}
.pdf-about-sign {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 4px;
  margin-top: 16px;
  padding-top: 14px;
  border-top: 1px solid var(--pdf-line);
}
.pdf-about-brand { display: inline-flex; align-items: center; gap: 6px; font-size: 15px; font-weight: 800; color: var(--pdf-ink); }
.pdf-about-word span { color: var(--pdf-pink); }
.pdf-about-slogan { font-size: 12px; font-style: italic; color: var(--pdf-muted); }
.pdf-cta { text-align: center; margin: 0; padding: 18px 0 6px; }
.pdf-cta-text { font-size: 13px; color: var(--pdf-body); margin: 0 0 10px; }
.pdf-cta-btn {
  display: inline-block; padding: 11px 26px; border-radius: 100px;
  background: linear-gradient(135deg, var(--pdf-pink), var(--pdf-purple));
  color: #fff; font-size: 13px; font-weight: 700; text-decoration: none;
}
.pdf-footer {
  text-align: center;
  margin-top: 14px;
  padding-top: 14px;
  border-top: 1px solid var(--pdf-line);
}
.pdf-footer p { margin: 0; font-size: 11px; color: var(--pdf-faint); }
.pdf-footer-site { margin-top: 4px !important; color: var(--pdf-pink) !important; font-weight: 600; }

/* ════════════════════════════════════════════════════ */
/* PRINT — exibe somente o documento PDF                  */
/* ════════════════════════════════════════════════════ */
@media print {
  @page { size: A4; margin: 12mm; }
  html, body {
    background: #fff !important;
    width: auto !important;
    margin: 0 !important;
    padding: 0 !important;
  }
  body::before, body::after { display: none !important; }
  .screen,
  .token-overlay,
  .modal-overlay,
  .confirm-overlay,
  .lightbox-overlay { display: none !important; }

  .pdf-doc {
    display: block !important;
    /* largura fixa = área útil do A4 (210mm − 2×12mm). Sem isto, o mobile
       calcula o layout na largura da tela (~390px) e escala → quebra tudo. */
    width: 186mm !important;
    margin: 0 auto !important;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }
  /* garante cores/gradientes/barras em navegadores mobile (não herdam sempre) */
  .pdf-doc * {
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }
  .pdf-cover { min-height: 240mm; page-break-after: always; }
  .pdf-report { padding-bottom: 10mm; }
  .pdf-block, .pdf-highlight, .pdf-about, .pdf-score-block { page-break-inside: avoid; }
  .pdf-running-foot { display: block !important; }
}

/* ── CONFIRM DIALOG ── */
.confirm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(4,4,10,0.72);
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  z-index: 200;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s ease;
}
.confirm-overlay.open {
  opacity: 1;
  pointer-events: auto;
}
.confirm-card {
  background: linear-gradient(160deg, #111120, #0c0c19);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 20px;
  padding: 32px 28px 28px;
  width: 100%;
  max-width: 420px;
  position: relative;
  box-shadow:
    0 0 0 1px rgba(255,255,255,0.04) inset,
    0 24px 60px rgba(0,0,0,0.55),
    0 4px 20px rgba(0,0,0,0.3);
  transform: scale(0.96) translateY(8px);
  transition: transform 0.28s cubic-bezier(0.22,1,0.36,1);
}
.confirm-overlay.open .confirm-card {
  transform: scale(1) translateY(0);
}
.invalid-pop-icon {
  width: 52px; height: 52px; border-radius: 50%;
  background: rgba(255,45,107,0.12); border: 1px solid var(--pink-border);
  display: flex; align-items: center; justify-content: center;
  margin: 4px auto 14px;
}
.icw-card .confirm-title,
.icw-card .confirm-sub { text-align: center; }
.icw-card .confirm-actions { flex-direction: column; gap: 10px; }
.icw-card .confirm-btn-cancel,
.icw-card .confirm-btn-ok { width: 100%; justify-content: center; }

@media (max-width: 480px) {
  .confirm-card { padding: 28px 20px 24px; border-radius: 16px; }
  .confirm-actions { flex-direction: column; gap: 8px; }
  .confirm-btn-cancel, .confirm-btn-ok { width: 100%; justify-content: center; flex: unset; }
}
.confirm-close {
  position: absolute;
  top: 16px;
  right: 18px;
  background: none;
  border: none;
  color: var(--text-3);
  font-size: 22px;
  cursor: pointer;
  line-height: 1;
}
.confirm-eyebrow {
  font-family: var(--mono);
  font-size: 11px;
  color: var(--pink);
  letter-spacing: 0.05em;
  margin-bottom: 8px;
}
.confirm-title {
  font-size: 19px;
  font-weight: 800;
  margin-bottom: 12px;
  letter-spacing: -0.3px;
  color: var(--text);
}
.confirm-sub {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.7;
  margin-bottom: 6px;
}
.confirm-sub strong { color: var(--text); }
.confirm-sub-hint {
  display: block;
  font-size: 11px;
  color: var(--text-3);
  margin-bottom: 20px;
}
.confirm-previews-wrap {
  position: relative;
  margin-bottom: 24px;
}
.confirm-previews {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  padding-bottom: 4px;
  scrollbar-width: none;
}
.confirm-previews::-webkit-scrollbar { display: none; }
.confirm-fade-left,
.confirm-fade-right {
  position: absolute;
  top: 0;
  bottom: 4px;
  width: 48px;
  pointer-events: none;
  z-index: 1;
}
.confirm-fade-left  { left: 0;  background: linear-gradient(to right, var(--surface), transparent); }
.confirm-fade-right { right: 0; background: linear-gradient(to left,  var(--surface), transparent); }
.confirm-nav-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  z-index: 2;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: 1px solid rgba(255,255,255,0.12);
  background: rgba(20,20,30,0.85);
  backdrop-filter: blur(6px);
  color: var(--text);
  font-size: 18px;
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  padding: 0;
  transition: background 0.15s, border-color 0.15s;
}
.confirm-nav-btn:hover { background: rgba(255,45,107,0.15); border-color: var(--pink-border); }
.confirm-nav-left  { left: 4px; }
.confirm-nav-right { right: 4px; }
.confirm-thumb-wrap {
  flex-shrink: 0;
  width: 80px;
  height: 130px;
  border-radius: 10px;
  overflow: hidden;
  border: 1px solid var(--border);
}
.confirm-thumb {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.confirm-actions {
  display: flex;
  gap: 10px;
}
.confirm-btn-cancel {
  flex: 1;
  padding: 13px;
  border-radius: 100px;
  border: 1px solid var(--border);
  background: transparent;
  color: var(--text-2);
  font-size: 13px;
  font-weight: 600;
  font-family: var(--font);
  cursor: pointer;
}
.confirm-btn-ok {
  flex: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  padding: 13px;
  border-radius: 100px;
  border: none;
  background: linear-gradient(135deg, var(--pink), #C0004D);
  color: #fff;
  font-size: 13px;
  font-weight: 700;
  font-family: var(--font);
  cursor: pointer;
  box-shadow: 0 0 20px rgba(255,45,107,0.35);
}


/* ── CONFIRM: extra styles ── */
.confirm-sub-hint {
  color: var(--text-3);
  font-style: italic;
}
.confirm-thumb-wrap {
  cursor: zoom-in;
  position: relative;
}
.confirm-thumb-zoom {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  background: rgba(0,0,0,0.45);
  border-radius: 10px;
  opacity: 0;
  transition: opacity 0.18s;
}
.confirm-thumb-wrap:hover .confirm-thumb-zoom { opacity: 1; }
.confirm-thumb-order {
  position: absolute;
  bottom: 6px;
  left: 6px;
  min-width: 20px;
  height: 20px;
  padding: 0 5px;
  background: rgba(10,10,20,0.82);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 5px;
  font-size: 11px;
  font-weight: 600;
  font-family: var(--mono);
  color: rgba(255,255,255,0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
  backdrop-filter: blur(4px);
  z-index: 2;
}

/* ── LIGHTBOX ── */
.lightbox-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(0,0,0,0.92);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s;
}
.lightbox-overlay.open {
  opacity: 1;
  pointer-events: auto;
}
.lightbox-img {
  max-width: 92vw;
  max-height: 88vh;
  border-radius: 12px;
  object-fit: contain;
  box-shadow: 0 0 60px rgba(0,0,0,0.8);
}
.lightbox-close {
  position: absolute;
  top: 18px;
  right: 22px;
  background: rgba(255,255,255,0.1);
  border: none;
  color: #fff;
  font-size: 28px;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

/* ── PLAN HOOK inside featured card ── */
.plan-hook {
  font-size: 11px;
  color: var(--amber);
  font-weight: 600;
  font-family: var(--mono);
  letter-spacing: 0.01em;
  margin-top: -4px;
  margin-bottom: 4px;
}

/* ── SCREEN 5: Limit Reached ── */
.limit-body {
  align-items: center;
  text-align: center;
  justify-content: center;
  padding-top: 48px;
}
.limit-icon {
  font-size: 52px;
  margin-bottom: 24px;
  line-height: 1;
}
.limit-title {
  font-size: clamp(22px, 5vw, 30px);
  font-weight: 800;
  letter-spacing: -0.5px;
  margin-bottom: 14px;
  line-height: 1.2;
}
.limit-desc {
  font-size: 15px;
  color: var(--text-2);
  line-height: 1.7;
  max-width: 340px;
  margin-bottom: 32px;
}
.limit-desc strong { color: var(--text); }
.limit-divider {
  width: 40px;
  height: 1px;
  background: var(--border);
  margin-bottom: 28px;
}
.limit-upgrade-label {
  font-size: 16px;
  font-weight: 700;
  margin-bottom: 8px;
}
.limit-upgrade-sub {
  font-size: 13px;
  color: var(--text-2);
  max-width: 300px;
  line-height: 1.6;
  margin-bottom: 28px;
}
.limit-back-link {
  display: block;
  margin-top: 20px;
  font-size: 13px;
  color: var(--text-3);
  text-decoration: none;
}
.limit-back-link:hover { color: var(--text-2); }

/* ── Token validation overlay ── */
.token-overlay {
  position: fixed;
  inset: 0;
  background: var(--bg);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 24px;
}
.token-card {
  background: var(--surface);
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 20px;
  padding: 48px 40px;
  max-width: 420px;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}
.token-spinner {
  width: 36px;
  height: 36px;
  border: 2.5px solid rgba(255,45,107,0.15);
  border-top-color: var(--pink);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-bottom: 20px;
}
@keyframes spin { to { transform: rotate(360deg); } }
.token-msg {
  font-size: 15px;
  color: var(--text-2);
}
.token-icon-err {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  background: rgba(255,45,107,0.08);
  border: 1px solid rgba(255,45,107,0.25);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
}
.token-err-title {
  font-size: 18px;
  font-weight: 700;
  color: var(--text);
  margin-bottom: 10px;
}
.token-err-msg {
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.6;
  margin-bottom: 16px;
  max-width: 320px;
}
.token-support {
  font-size: 12px;
  color: var(--text-3);
  margin-bottom: 24px;
}
.token-support a {
  color: var(--text-2);
  text-decoration: underline;
  text-underline-offset: 3px;
}
.token-back {
  font-size: 13px;
  color: var(--text-3);
  text-decoration: none;
  transition: color 0.2s;
}
.token-back:hover { color: var(--text-2); }
</style>
