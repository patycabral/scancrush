<script setup lang="ts">
useHead({ title: 'ScanCrush — Analisar conversa' })

// ════════════════════════════════════════════════════
// PLAN LIMITS
// currentPlan is set here for frontend UX only.
// ⚠️ BACKEND REQUIRED: validate plan + usage server-side
// ════════════════════════════════════════════════════
const PLAN_LIMITS: Record<string, number> = { free: 1, basic: 5, revealed: 10, xray: 20 }

const KIWIFY_URLS = {
  basic:    'https://pay.kiwify.com.br/lksicGT',
  revealed: 'https://pay.kiwify.com.br/9er8Nn9',
  raiox:    'https://pay.kiwify.com.br/ZYqerZF',
  upsell:   'https://pay.kiwify.com.br/4PEh4AL',
}

function goToCheckout(plan: 'basic' | 'revealed' | 'raiox') {
  if (import.meta.client) window.location.href = KIWIFY_URLS[plan]
}

// LAUNCH_MODE: true = análise gratuita e sem restrições
// Altere para FALSE para ativar paywall e limites reais
const LAUNCH_MODE = true

const currentPlan = ref<string>('free')

function getImageLimit(): number {
  return PLAN_LIMITS[currentPlan.value] ?? 1
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
const filePreviews = ref<{ src: string; idx: number }[]>([])
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

function handleFiles(newFiles: FileList | File[]) {
  const limit = getImageLimit()
  const imgs = Array.from(newFiles).filter(f => f.type.startsWith('image/'))
  if (!imgs.length) return

  const slots = limit - uploadedFiles.value.length
  if (slots <= 0) { updateUploadUI(); return }
  const accepted = imgs.slice(0, slots)

  uploadedFiles.value = [...uploadedFiles.value, ...accepted]
  renderPreviews()
  updateUploadUI()
  btnContinueDisabled.value = false
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
      limitAlertText.value = '⚠️ Você já usou sua análise gratuita. Faça upgrade para enviar mais imagens e obter uma análise completa.'
      btnContinueDisabled.value = true
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
    src: URL.createObjectURL(file),
    idx
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
const userName = ref('')
const bDay = ref('')
const bMonth = ref('')
const bYear = ref('')
const observations = ref('')
const selectedTags = ref<string[]>([])
const crushName = ref('')
const crushAgeRange = ref('')
const showValidationMsg = ref(false)
const validationMsgHtml = ref('')
const showAnalysisBlockedMsg = ref(false)
const showBtnGenerate = ref(true)

const TAGS = [
  'confusa', 'ansiosa', 'insegura', 'com medo de perder ele',
  'carente', 'cansada', 'frustrada', 'magoada', 'esperançosa',
  'apegada', 'me sentindo ignorada', 'parecendo que só eu me esforço',
  'gostando dele'
]

// Shuffle tags (Fisher-Yates)
const shuffledTags = ref<string[]>([])
function shuffleTags() {
  const arr = [...TAGS]
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[arr[i], arr[j]] = [arr[j], arr[i]]
  }
  shuffledTags.value = arr
}

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
  if (LAUNCH_MODE) return
  const done = import.meta.client ? sessionStorage.getItem('sc_analysis_done') : null
  if (done) {
    showBtnGenerate.value = false
    showAnalysisBlockedMsg.value = true
  } else {
    showBtnGenerate.value = true
    showAnalysisBlockedMsg.value = false
  }
}

function validateS2(): boolean {
  const missing: string[] = []
  const name = userName.value.trim()
  if (!name) missing.push('seu <strong>nome</strong>')
  if (!bDay.value || !bMonth.value || !bYear.value) missing.push('sua <strong>data de nascimento</strong> completa')
  if (selectedTags.value.length === 0) missing.push('pelo menos um <strong>sentimento</strong>')

  if (missing.length) {
    if (missing.length === 1) {
      validationMsgHtml.value = `⚠️ Preencha ${missing[0]} para continuar.`
    } else {
      const last = missing[missing.length - 1]
      const rest = missing.slice(0, -1)
      validationMsgHtml.value = `⚠️ Preencha ${rest.join(', ')} e ${last} para continuar.`
    }
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
  ['Analisando consistência...', 'o que ele diz vs. o que ele faz'],
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

// ── Confirm dialog (pre-send) ──
const showConfirmDialog = ref(false)

function openConfirmDialog() {
  if (uploadedFiles.value.length === 0) return
  showConfirmDialog.value = true
  if (import.meta.client) document.body.style.overflow = 'hidden'
}

function closeConfirmDialog() {
  showConfirmDialog.value = false
  if (import.meta.client) document.body.style.overflow = ''
}

// ── Lightbox (expand image preview) ──
const lightboxSrc = ref<string | null>(null)
function openLightbox(src: string) { lightboxSrc.value = src }
function closeLightbox() { lightboxSrc.value = null }

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
const resultPlan = ref('')
const resultData = ref<any>(null)
const resultCta  = ref<any>(null)
const resultRelDyn = ref<any>(null)      // raiox only: relationship_dynamics
const resultUpsellOffer = ref<any>(null) // upsell dinâmico por situation_label

// ── Result timer (urgency) ──
const resultTimerSeconds = ref(15 * 60) // 15 minutos
const resultTimerDisplay = computed(() => {
  const m = Math.floor(resultTimerSeconds.value / 60)
  const s = resultTimerSeconds.value % 60
  return `${m}:${String(s).padStart(2, '0')}`
})
const resultTimerUrgent = computed(() => resultTimerSeconds.value < 3 * 60)
let resultTimerInterval: ReturnType<typeof setInterval> | null = null

function startResultTimer() {
  resultTimerSeconds.value = 15 * 60
  if (resultTimerInterval) clearInterval(resultTimerInterval)
  resultTimerInterval = setInterval(() => {
    if (resultTimerSeconds.value > 0) {
      resultTimerSeconds.value--
    } else {
      clearInterval(resultTimerInterval!)
    }
  }, 1000)
}

// ── Upsell Modal ──
const showUpsellModal = ref(false)
function openUpsellModal() {
  showUpsellModal.value = true
  if (import.meta.client) document.body.style.overflow = 'hidden'
}
function closeUpsellModal() {
  showUpsellModal.value = false
  if (import.meta.client) document.body.style.overflow = ''
}
function goToCheckoutUpsell() {
  if (import.meta.client) window.location.href = KIWIFY_URLS.upsell
}

/** Extrai texto de um item que pode ser string ou objeto {label, text, description} */
function txt(item: any): string {
  if (!item) return ''
  if (typeof item === 'string') return item
  return item.label || item.title || item.text || item.description || ''
}

/** Mapeia situation_label.level → texto do pill */
function verdictText(level: string | null): string {
  const map: Record<string, string> = {
    cilada:  '🚨 Atenção: sinais preocupantes',
    atencao: '⚠️ Prossiga com cautela',
    duvida:  '🤔 Situação ambígua',
    seguro:  '✅ Sinais positivos',
  }
  return map[level ?? ''] ?? '— Resultado gerado'
}

function updateNewAnalysisBtn() {
  if (currentPlan.value === 'free') {
    btnNewAnalysisText.value = 'Fazer upgrade'
    btnNewAnalysisStyle.value = { color: 'var(--pink)' }
  }
}

async function startAnalysis() {
  if (!validateS2()) return

  if (!LAUNCH_MODE && import.meta.client && sessionStorage.getItem('sc_analysis_done')) {
    checkAnalysisDone()
    return
  }

  if (import.meta.client) sessionStorage.setItem('sc_analysis_done', '1')

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
  form.append('plan',            currentPlan.value)
  form.append('access_token',    accessToken.value)
  form.append('customer_id',     customerId.value)
  form.append('user_name',       userName.value.trim())

  const birthDate = (bYear.value && bMonth.value && bDay.value)
    ? `${bYear.value}-${String(bMonth.value).padStart(2, '0')}-${String(bDay.value).padStart(2, '0')}`
    : ''
  form.append('birth_date',      birthDate)

  form.append('crush_name',      crushName.value.trim())
  form.append('crush_age_range', crushAgeRange.value || 'não informado')
  form.append('observations',    observations.value.trim())
  form.append('feelings',        selectedTags.value.join(', '))

  uploadedFiles.value.forEach(file => form.append('images', file))

  try {
    // Timeout de 8 minutos — n8n pode demorar com imagens pesadas
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

    // data pode chegar como string JSON ou array do n8n — parsear/desempacotar
    const rawData = typeof data.data === 'string' ? JSON.parse(data.data) : (data.data ?? {})
    resultData.value  = Array.isArray(rawData) ? (rawData[0] ?? {}) : rawData
    // cta é sempre string de texto — nunca JSON.parse
    resultCta.value   = data.cta ?? null
    resultRelDyn.value = data.relationship_dynamics ?? null
    // upsell_offer só é setado se show_upsell !== false (quem comprou order bump não recebe)
    const showUpsell = data.show_upsell !== false
    resultUpsellOffer.value = showUpsell
      ? (typeof data.upsell_offer === 'string' ? JSON.parse(data.upsell_offer) : (data.upsell_offer ?? null))
      : null

    if (msgInterval) clearInterval(msgInterval)
    if (progressInterval) clearInterval(progressInterval)
    loadingProgress.value = 100
    await new Promise(r => setTimeout(r, 400)) // breve flash nos 100% antes de trocar tela
    goTo(4)
    updateNewAnalysisBtn()
    startResultTimer()

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

// ── Handle "Nova análise" / "Fazer upgrade" ──
function handleNewAnalysis() {
  if (currentPlan.value === 'free') {
    // Se tem dados de upsell dinâmico, abre o upsell modal
    if (resultUpsellOffer.value) openUpsellModal()
    else openModal()
  } else {
    resetAll()
  }
}

function resetAll() {
  uploadedFiles.value = []
  renderPreviews()
  btnContinueDisabled.value = true
  userName.value = ''
  bDay.value = ''
  bMonth.value = ''
  bYear.value = ''
  observations.value = ''
  selectedTags.value = []
  crushName.value = ''
  crushAgeRange.value = ''
  scoreBarWidth.value = '0%'
  resultUpsellOffer.value = null
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
    sessionStorage.removeItem('sc_access_token')
    sessionStorage.removeItem('sc_customer_id')
  }
  goTo(1)
}

// ── Keyboard esc to close modal / lightbox / upsell ──
function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    if (lightboxSrc.value) { closeLightbox(); return }
    if (showConfirmDialog.value) { closeConfirmDialog(); return }
    if (showUpsellModal.value) { closeUpsellModal(); return }
    closeModal()
  }
}

// Plan names for display
const PLAN_NAMES: Record<string, string> = {
  free: 'Gratuito',
  basic: 'Sinais Básicos',
  revealed: 'Sinais Revelados',
  raiox: 'Raio-X do Crush',
}
const planDisplayName = computed(() => PLAN_NAMES[currentPlan.value] ?? 'Gratuito')
const planImageLimit = computed(() => PLAN_LIMITS[currentPlan.value] ?? 1)

onMounted(() => {
  if (import.meta.client) {
    // 1. Check URL param first (coming from Kiwify redirect)
    const urlParams = new URLSearchParams(window.location.search)
    const planParam       = urlParams.get('plan')
    const tokenParam      = urlParams.get('access_token')
    const customerIdParam = urlParams.get('customer_id')
    const validPlans = Object.keys(PLAN_LIMITS)

    if (planParam && validPlans.includes(planParam)) {
      currentPlan.value = planParam
      sessionStorage.setItem('sc_plan', planParam)
    } else {
      // 2. Fallback to saved session plan
      const saved = sessionStorage.getItem('sc_plan')
      if (saved && validPlans.includes(saved)) currentPlan.value = saved
    }

    // 3. Read access_token (paid flow)
    if (tokenParam) {
      accessToken.value = tokenParam
      sessionStorage.setItem('sc_access_token', tokenParam)
    } else {
      const savedToken = sessionStorage.getItem('sc_access_token')
      if (savedToken) accessToken.value = savedToken
    }

    // 4. Read customer_id
    if (customerIdParam) {
      customerId.value = customerIdParam
      sessionStorage.setItem('sc_customer_id', customerIdParam)
    } else {
      const savedCid = sessionStorage.getItem('sc_customer_id')
      if (savedCid) customerId.value = savedCid
    }
  }
  shuffleTags()
  checkAnalysisDone()
  updateUploadUI()
  window.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  if (msgInterval) clearInterval(msgInterval)
  if (progressInterval) clearInterval(progressInterval)
  if (resultTimerInterval) clearInterval(resultTimerInterval)
  window.removeEventListener('keydown', onKeydown)
  filePreviews.value.forEach(p => URL.revokeObjectURL(p.src))
})
</script>

<template>
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
      ⏳ Plano gratuito · 1 análise a cada 48h
    </p>

    <h1 class="screen-title">Cole a conversa</h1>
    <p class="screen-subtitle">Envie os prints da conversa para análise</p>

    <div
      class="file-drop-area"
      :class="{ 'drag-over': isDragOver }"
      :style="dropAreaStyle"
      @dragover="onDragOver"
      @dragleave="onDragLeave"
      @drop="onDrop"
    >
      <input type="file" accept="image/*" multiple @change="onFileChange" />
      <span class="drop-icon">📱</span>
      <p class="drop-text">Arraste os prints aqui<br>ou <strong>clique para selecionar</strong></p>
      <span class="drop-hint">JPG · PNG · WEBP · apenas imagens</span>
    </div>

    <div class="file-previews" v-show="filePreviews.length > 0">
      <div v-for="preview in filePreviews" :key="preview.idx" class="preview-item">
        <img class="preview-thumb" :src="preview.src" alt="Preview" />
        <button class="preview-remove" @click.stop="removeFile(preview.idx)" title="Remover imagem">×</button>
      </div>
    </div>

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
      <button class="btn-upgrade-inline" @click="openModal()">🔓 Desbloquear análise completa</button>
    </div>

    <button class="btn-main" :disabled="btnContinueDisabled" @click="openConfirmDialog()">
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

    <!-- Dados pessoais para personalização da IA -->
    <div class="person-fields">
      <div class="field-group">
        <label class="field-label" for="userName">Seu nome</label>
        <input
          class="obs-input"
          type="text"
          id="userName"
          v-model="userName"
          placeholder="Como você se chama?"
          autocomplete="given-name"
        />
      </div>
      <div class="field-group">
        <label class="field-label">Sua data de nascimento</label>
        <div class="date-picker">
          <select class="date-select" :class="{ empty: !bDay }" v-model="bDay" aria-label="Dia">
            <option value="">Dia</option>
            <option v-for="opt in dayOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
          </select>
          <select class="date-select" :class="{ empty: !bMonth }" v-model="bMonth" aria-label="Mês">
            <option value="">Mês</option>
            <option value="01">Jan</option>
            <option value="02">Fev</option>
            <option value="03">Mar</option>
            <option value="04">Abr</option>
            <option value="05">Mai</option>
            <option value="06">Jun</option>
            <option value="07">Jul</option>
            <option value="08">Ago</option>
            <option value="09">Set</option>
            <option value="10">Out</option>
            <option value="11">Nov</option>
            <option value="12">Dez</option>
          </select>
          <select class="date-select" :class="{ empty: !bYear }" v-model="bYear" aria-label="Ano">
            <option value="">Ano</option>
            <option v-for="opt in yearOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
          </select>
        </div>
      </div>
    </div>

    <div class="person-divider"></div>

    <!-- Dados do crush -->
    <div class="person-fields">
      <div class="field-group">
        <label class="field-label" for="crushName">Nome do crush <span class="field-optional">(opcional)</span></label>
        <input
          class="obs-input"
          type="text"
          id="crushName"
          v-model="crushName"
          placeholder="Ex: João, o boy do trampo..."
          autocomplete="off"
        />
      </div>
      <div class="field-group">
        <label class="field-label" for="crushAgeRange">Faixa etária dele <span class="field-optional">(opcional)</span></label>
        <select class="date-select" id="crushAgeRange" v-model="crushAgeRange" style="flex:1;min-width:0">
          <option value="">Não sei / prefiro não dizer</option>
          <option value="menor-18">Menos de 18 anos</option>
          <option value="18-24">18 – 24 anos</option>
          <option value="25-30">25 – 30 anos</option>
          <option value="31-35">31 – 35 anos</option>
          <option value="36-40">36 – 40 anos</option>
          <option value="41-50">41 – 50 anos</option>
          <option value="50+">Acima de 50</option>
        </select>
      </div>
    </div>

    <div class="person-divider"></div>

    <label class="field-label" style="margin-bottom:12px;display:block">O que você percebeu no comportamento dele(a)?</label>

    <textarea
      class="obs-textarea"
      v-model="observations"
      placeholder="Ex: ele demora pra responder, parece distante, some às vezes..."
      rows="5"
    ></textarea>

    <span class="tag-label">Como você tem se sentido nessa situação?</span>
    <div class="tag-group">
      <div
        v-for="tag in shuffledTags"
        :key="tag"
        class="obs-tag"
        :class="{ selected: selectedTags.includes(tag) }"
        @click="toggleTag(tag)"
      >{{ tag }}</div>
    </div>

    <!-- One-time warning -->
    <div class="once-warning">
      ⚠️ Esta análise será gerada uma única vez. Revise tudo antes de continuar.
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
      Gerar análise
    </button>
  </div>
</div>

<!-- ══════════════════════════════════════════════════ -->
<!-- CONFIRM DIALOG: verificar imagens antes de enviar -->
<!-- ══════════════════════════════════════════════════ -->
<div class="confirm-overlay" :class="{ open: showConfirmDialog }" @click.self="closeConfirmDialog()">
  <div class="confirm-card">
    <button class="confirm-close" @click="closeConfirmDialog()" aria-label="Fechar">×</button>

    <p class="confirm-eyebrow">// verificar antes de continuar</p>
    <h2 class="confirm-title">Os prints estão certos?</h2>
    <p class="confirm-sub">Confirme que <strong>todos são da mesma conversa</strong> e que nenhuma imagem errada entrou. <span class="confirm-sub-hint">Toque na imagem para ampliar.</span></p>

    <div class="confirm-previews">
      <div v-for="preview in filePreviews" :key="preview.idx" class="confirm-thumb-wrap" @click="openLightbox(preview.src)">
        <img class="confirm-thumb" :src="preview.src" alt="Print" />
        <div class="confirm-thumb-zoom">🔍</div>
      </div>
    </div>

    <div class="confirm-actions">
      <button class="confirm-btn-cancel" @click="closeConfirmDialog()">Corrigir imagens</button>
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
<!-- SCREEN 4: Result -->
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
    <button class="header-action" :style="btnNewAnalysisStyle" @click="handleNewAnalysis()">{{ btnNewAnalysisText }}</button>
  </header>

  <div class="result-notice-wrap">
    <div class="result-notice-card">
      ⚠️ Não atualize nem feche esta página — o resultado não fica salvo e não poderá ser recuperado.
    </div>
  </div>

  <div class="result-body">

    <!-- ── Score ── -->
    <div class="score-card">
      <div class="score-label">Score de interesse</div>
      <div class="score-row">
        <div class="score-num">{{ resultData?.interest_score ?? '—' }}<sup>/100</sup></div>
        <div style="flex:1">
          <div class="score-bar-track">
            <!-- dark cover shrinks from right as score increases -->
            <div class="score-bar-cover" :style="{ width: scoreBarCoverWidth }"></div>
          </div>
          <div class="score-bar-labels">
            <span>Distante</span>
            <span>Ambíguo</span>
            <span>Interesse</span>
          </div>
        </div>
      </div>
      <div class="verdict-pill">{{ verdictText(resultData?.situation_label?.level) }}</div>
    </div>

    <!-- ── Resumo ── -->
    <div v-if="resultData?.summary" class="result-summary-card">
      <p class="result-summary-text">{{ resultData.summary }}</p>
    </div>

    <!-- ── Padrões principais (todos os planos) ── -->
    <div v-if="resultData?.key_patterns" class="signals-card">
      <div class="signals-title">Padrões identificados</div>

      <template v-if="resultData.key_patterns.positive?.length">
        <div class="signal-section-label">Positivos</div>
        <div v-for="(item, i) in resultData.key_patterns.positive" :key="'kp+'+i" class="signal-item">
          <span class="sig-dot g"></span>{{ txt(item) }}
        </div>
      </template>

      <template v-if="resultData.key_patterns.negative?.length">
        <div class="signal-section-label" style="margin-top:10px">Negativos</div>
        <div v-for="(item, i) in resultData.key_patterns.negative" :key="'kp-'+i" class="signal-item">
          <span class="sig-dot r"></span>{{ txt(item) }}
        </div>
      </template>
    </div>

    <!-- ── Sinais (basic+) ── -->
    <div v-if="resultData?.signals" class="signals-card">
      <div class="signals-title">Sinais na conversa</div>
      <div v-for="(item, i) in resultData.signals.positive ?? []" :key="'sp'+i" class="signal-item">
        <span class="sig-dot g"></span>{{ txt(item) }}
      </div>
      <div v-for="(item, i) in resultData.signals.negative ?? []" :key="'sn'+i" class="signal-item">
        <span class="sig-dot r"></span>{{ txt(item) }}
      </div>
      <div v-for="(item, i) in resultData.signals.neutral ?? []" :key="'snu'+i" class="signal-item">
        <span class="sig-dot y"></span>{{ txt(item) }}
      </div>
    </div>

    <!-- ── Comportamento (basic+) ── -->
    <div v-if="resultData?.behavior" class="signals-card">
      <div class="signals-title">Comportamento</div>
      <div v-if="resultData.behavior.engagement_level" class="behavior-row">
        <span class="behavior-label">Engajamento</span>
        <span class="behavior-val">{{ resultData.behavior.engagement_level }}</span>
      </div>
      <div v-if="resultData.behavior.consistency" class="behavior-row">
        <span class="behavior-label">Consistência</span>
        <span class="behavior-val">{{ resultData.behavior.consistency }}</span>
      </div>
      <div v-if="resultData.behavior.response_pattern" class="behavior-row">
        <span class="behavior-label">Padrão de resposta</span>
        <span class="behavior-val">{{ resultData.behavior.response_pattern }}</span>
      </div>
    </div>

    <!-- ── Highlights / Padrões ocultos / Inconsistências (revealed+) ── -->
    <template v-if="resultData?.highlights?.length || resultData?.hidden_patterns?.length || resultData?.inconsistencies?.length">
      <div class="signals-card">
        <div class="signals-title">Leitura mais profunda</div>

        <template v-if="resultData?.highlights?.length">
          <div class="signal-section-label">Destaques</div>
          <div v-for="(item, i) in resultData.highlights" :key="'hl'+i" class="signal-item">
            <span class="sig-dot y"></span>{{ txt(item) }}
          </div>
        </template>

        <template v-if="resultData?.hidden_patterns?.length">
          <div class="signal-section-label" style="margin-top:10px">Padrões ocultos</div>
          <div v-for="(item, i) in resultData.hidden_patterns" :key="'hp'+i" class="signal-item">
            <span class="sig-dot r"></span>{{ txt(item) }}
          </div>
        </template>

        <template v-if="resultData?.inconsistencies?.length">
          <div class="signal-section-label" style="margin-top:10px">Inconsistências</div>
          <div v-for="(item, i) in resultData.inconsistencies" :key="'ic'+i" class="signal-item">
            <span class="sig-dot r"></span>{{ txt(item) }}
          </div>
        </template>
      </div>
    </template>

    <!-- ── Dinâmica do relacionamento (raiox only) ── -->
    <div v-if="resultRelDyn" class="signals-card">
      <div class="signals-title">Dinâmica do relacionamento</div>
      <div v-if="resultRelDyn['Análise do Usuário (você)']" class="behavior-row">
        <span class="behavior-label">Você</span>
        <span class="behavior-val">{{ resultRelDyn['Análise do Usuário (você)'] }}</span>
      </div>
      <div v-if="resultRelDyn['Análise do(a) Crush']" class="behavior-row">
        <span class="behavior-label">Crush</span>
        <span class="behavior-val">{{ resultRelDyn['Análise do(a) Crush'] }}</span>
      </div>
      <div v-if="resultRelDyn['Conclusão']" class="result-conclusion">
        {{ resultRelDyn['Conclusão'] }}
      </div>
    </div>

    <!-- ── Score explanation (revealed+) ── -->
    <div v-if="resultData?.score_explanation?.reason" class="result-summary-card">
      <p class="result-summary-text" style="font-size:13px;opacity:0.8">
        {{ resultData.score_explanation.reason }}
      </p>
    </div>

    <!-- ── Mensagem final ── -->
    <p v-if="resultData?.final_message" class="result-final-msg">
      {{ resultData.final_message }}
    </p>

    <!-- ── Seção bloqueada (free / basic / revealed) ── -->
    <div v-if="resultCta" class="locked-card">
      <div class="locked-blur">
        Perfil emocional completo, padrões de comportamento profundo, e a conclusão final sobre o que essa pessoa realmente demonstra — o que ela sente versus o que ela faz. A análise completa revela o que está por trás do padrão identificado...
      </div>
      <div class="locked-overlay">
        <p class="locked-label">🔒 Análise completa bloqueada</p>
        <button class="locked-sub-btn" @click="resultUpsellOffer ? openUpsellModal() : openModal()">Ver análise completa →</button>
      </div>
    </div>

    <!-- ── CTA de upgrade (free / basic / revealed) ── -->
    <template v-if="resultCta">
      <div class="cta-result-card">
        <p class="cta-result-sub">{{ typeof resultCta === 'string' ? resultCta : (resultCta.subtitle ?? '') }}</p>
      </div>
      <button class="btn-unlock" @click="resultUpsellOffer ? openUpsellModal() : openModal()">
        🔓 {{ typeof resultCta === 'string' ? 'Desbloquear análise completa' : (resultCta.button_label ?? 'Desbloquear análise completa') }}
      </button>
    </template>

    <div class="result-timer" :class="{ urgent: resultTimerUrgent }">
      <span class="result-timer-icon">⏳</span>
      <span>Este relatório some em <strong>{{ resultTimerDisplay }}</strong></span>
    </div>

  </div>
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
    <h1 class="limit-title">Você já fez sua análise gratuita hoje</h1>
    <p class="limit-desc">
      O plano gratuito permite <strong>1 análise a cada 48h</strong>.<br>
      Sua próxima análise gratuita estará disponível amanhã.
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
<!-- UPSELL MODAL: emotional, personalized            -->
<!-- ══════════════════════════════════════════════════ -->
<div class="upsell-overlay" :class="{ open: showUpsellModal }" @click.self="closeUpsellModal()">
  <div class="upsell-card">
    <button class="upsell-close" @click="closeUpsellModal()" aria-label="Fechar">×</button>

    <!-- Resultado em contexto -->
    <div class="upsell-verdict-mini">{{ verdictText(resultData?.situation_label?.level) }}</div>

    <h2 class="upsell-title">{{ resultUpsellOffer?.title ?? 'Tem algo aqui que você ainda não viu' }}</h2>
    <p class="upsell-sub">{{ resultUpsellOffer?.subtitle ?? 'Alguns padrões só aparecem quando a leitura vai mais fundo.' }}</p>

    <!-- O que está bloqueado -->
    <div class="upsell-locked-preview">
      <p class="upsell-locked-label">// ainda bloqueado para você</p>
      <ul class="upsell-locked-list">
        <li v-if="(resultData?.counts?.negative_locked ?? 0) > 0">
          {{ resultData.counts.negative_locked }} sinal(is) negativo(s) oculto(s)
        </li>
        <li v-if="(resultData?.counts?.positive_locked ?? 0) > 0">
          {{ resultData.counts.positive_locked }} sinal(is) positivo(s) oculto(s)
        </li>
        <li>Perfil emocional completo</li>
        <li>Padrões ocultos de comportamento</li>
        <li>Conclusão direta sem rodeios</li>
      </ul>
    </div>

    <div class="upsell-price-row">
      <span class="upsell-price">R$<strong>{{ resultUpsellOffer?.price ?? '7,40' }}</strong></span>
      <span class="upsell-price-label">acesso único · agora</span>
    </div>

    <button class="upsell-btn" @click="goToCheckoutUpsell()">
      🔓 {{ resultUpsellOffer?.button_label ?? 'Desbloquear análise completa' }}
    </button>

    <p class="upsell-guarantee">Pagamento seguro · acesso imediato · sem assinatura</p>

    <button class="upsell-see-plans" @click="closeUpsellModal(); openModal()">Ver todos os planos →</button>
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

      <!-- Plan: Sinais Básicos -->
      <div class="plan-card">
        <div class="plan-name">Sinais Básicos</div>
        <div class="plan-price">
          <span class="curr">R$</span>14<span class="cents">,90</span>
        </div>
        <p class="plan-period">pagamento único</p>
        <p class="plan-desc">Veja se existe interesse… ou só educação.</p>
        <ul class="plan-items">
          <li class="plan-item">Descubra o nível real de interesse</li>
          <li class="plan-item">Entenda os sinais principais da conversa</li>
          <li class="plan-item">Receba uma conclusão direta</li>
          <li class="plan-item">Até 5 prints</li>
        </ul>
        <button class="btn-plan" @click="goToCheckout('basic')">Ver análise básica</button>
      </div>

      <!-- Plan: Sinais Revelados (FEATURED) -->
      <div class="plan-card featured">
        <div class="plan-badge">Mais escolhido</div>
        <div class="plan-name">Sinais Revelados</div>
        <p class="plan-hook">🔥 O mais escolhido por quem quer parar de duvidar</p>
        <div class="plan-price">
          <span class="curr">R$</span>27<span class="cents">,90</span>
        </div>
        <p class="plan-period">pagamento único</p>
        <p class="plan-desc">Aqui você começa a enxergar o que realmente está acontecendo.</p>
        <ul class="plan-items">
          <li class="plan-item plan-item-includes">+ Tudo de Sinais Básicos</li>
          <li class="plan-item">Descubra padrões escondidos na conversa</li>
          <li class="plan-item">Entenda por que a pessoa age de forma confusa</li>
          <li class="plan-item">Veja trechos que revelam intenção</li>
          <li class="plan-item">Interpretação mais profunda</li>
          <li class="plan-item">Até 10 prints</li>
        </ul>
        <button class="btn-plan primary" @click="goToCheckout('revealed')">Quero entender tudo</button>
      </div>

      <!-- Plan: Raio-X do Crush -->
      <div class="plan-card">
        <div class="plan-name">Raio-X do Crush</div>
        <div class="plan-price">
          <span class="curr">R$</span>39<span class="cents">,90</span>
        </div>
        <p class="plan-period">pagamento único</p>
        <p class="plan-desc">Para quem quer parar de duvidar… e finalmente entender tudo.</p>
        <ul class="plan-items">
          <li class="plan-item plan-item-includes">+ Tudo de Sinais Revelados</li>
          <li class="plan-item">Diagnóstico completo do comportamento</li>
          <li class="plan-item">Padrões emocionais e inconsistências</li>
          <li class="plan-item">O que a pessoa realmente demonstra (não o que diz)</li>
          <li class="plan-item">Conclusão clara + direcionamento</li>
          <li class="plan-item">Até 20 prints</li>
        </ul>
        <button class="btn-plan" @click="goToCheckout('raiox')">Ver análise completa</button>
      </div>

    </div>

    <div class="modal-divider"></div>
    <p class="modal-guarantee">🔒 Pagamento seguro · acesso imediato · uso único</p>

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
  font-weight: 500;
  color: var(--text-2);
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 8px;
  transition: color 0.2s;
  font-family: var(--font);
}
.header-action:hover { color: var(--text); }

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
  border-radius: 12px;
  padding: 14px 20px;
  font-size: 13px;
  font-weight: 300;
  line-height: 1.6;
  text-align: center;
  background: rgba(255, 184, 0, 0.05);
  border: 1px solid rgba(255, 184, 0, 0.2);
  color: #FFB800;
  max-width: 560px;
  width: 100%;
}

/* ── RESULT TIMER ── */
.result-timer {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 13px;
  color: var(--text-3);
  font-family: var(--mono);
  padding: 12px;
  border-radius: 12px;
  border: 1px solid var(--border);
  background: rgba(255,255,255,0.02);
  margin-top: 8px;
  transition: all 0.4s;
}
.result-timer strong { color: var(--text-2); }
.result-timer.urgent {
  border-color: rgba(255,77,77,0.3);
  background: rgba(255,77,77,0.06);
  color: var(--danger);
}
.result-timer.urgent strong { color: var(--danger); }

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

.signals-card {
  width: 100%;
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: 18px;
  padding: 22px;
}
.signals-title {
  font-size: 10px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: var(--text-3);
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
  margin-top: 8px;
}
.btn-unlock:hover { transform: translateY(-2px); box-shadow: 0 0 70px rgba(255,45,107,0.55); }

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
  max-width: clamp(520px, 68vw, 960px);
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
  gap: 12px;
}
@media (max-width: 520px) {
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
  color: rgba(255,184,0,0.82);
  font-weight: 400;
  line-height: 1.65;
  margin-bottom: 14px;
  text-align: center;
}

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
  line-height: 1.5;
}
.result-conclusion {
  margin-top: 14px;
  padding-top: 14px;
  border-top: 1px solid var(--border);
  font-size: 14px;
  color: var(--text);
  line-height: 1.7;
  font-style: italic;
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

/* ── CONFIRM DIALOG ── */
.confirm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(7,7,13,0.82);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  z-index: 200;
  display: flex;
  align-items: flex-end;
  justify-content: center;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.25s;
}
.confirm-overlay.open {
  opacity: 1;
  pointer-events: auto;
}
.confirm-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-bottom: none;
  border-radius: 20px 20px 0 0;
  padding: 28px 24px 32px;
  width: 100%;
  max-width: 540px;
  position: relative;
  transform: translateY(20px);
  transition: transform 0.3s cubic-bezier(0.22,1,0.36,1);
}
.confirm-overlay.open .confirm-card { transform: translateY(0); }
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
  font-size: 20px;
  font-weight: 800;
  margin-bottom: 10px;
  letter-spacing: -0.3px;
}
.confirm-sub {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.6;
  margin-bottom: 20px;
}
.confirm-sub strong { color: var(--text); }
.confirm-previews {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  padding-bottom: 4px;
  margin-bottom: 24px;
  scrollbar-width: none;
}
.confirm-previews::-webkit-scrollbar { display: none; }
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

/* ── UPSELL MODAL ── */
.upsell-overlay {
  position: fixed;
  inset: 0;
  z-index: 900;
  background: rgba(0,0,0,0.75);
  display: flex;
  align-items: flex-end;
  justify-content: center;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.25s;
}
.upsell-overlay.open { opacity: 1; pointer-events: auto; }
.upsell-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 24px 24px 0 0;
  padding: 32px 24px 36px;
  width: 100%;
  max-width: 520px;
  position: relative;
  transform: translateY(100%);
  transition: transform 0.3s cubic-bezier(0.22, 1, 0.36, 1);
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 14px;
}
.upsell-overlay.open .upsell-card { transform: translateY(0); }
.upsell-close {
  position: absolute;
  top: 16px; right: 18px;
  background: rgba(255,255,255,0.06);
  border: none;
  color: var(--text-2);
  font-size: 22px;
  width: 36px; height: 36px;
  border-radius: 50%;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
}
.upsell-verdict-mini {
  font-size: 11px;
  font-family: var(--mono);
  color: var(--amber);
  background: rgba(255,184,0,0.1);
  border: 1px solid rgba(255,184,0,0.2);
  border-radius: 100px;
  padding: 4px 14px;
  letter-spacing: 0.05em;
}
.upsell-title {
  font-size: clamp(18px, 4vw, 22px);
  font-weight: 800;
  line-height: 1.25;
  letter-spacing: -0.3px;
  color: var(--text);
  margin: 0;
}
.upsell-sub {
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.65;
  max-width: 340px;
}
.upsell-locked-preview {
  width: 100%;
  background: rgba(255,45,107,0.04);
  border: 1px solid rgba(255,45,107,0.12);
  border-radius: 14px;
  padding: 16px 20px;
  text-align: left;
}
.upsell-locked-label {
  font-size: 10px;
  font-family: var(--mono);
  color: var(--text-3);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-bottom: 10px;
}
.upsell-locked-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.upsell-locked-list li {
  font-size: 13px;
  color: var(--text-2);
  display: flex;
  align-items: center;
  gap: 8px;
}
.upsell-locked-list li::before {
  content: '🔒';
  font-size: 11px;
  flex-shrink: 0;
}
.upsell-price-row {
  display: flex;
  align-items: baseline;
  gap: 10px;
  margin-top: 4px;
}
.upsell-price {
  font-size: 32px;
  font-weight: 800;
  color: var(--text);
  letter-spacing: -1px;
}
.upsell-price strong { font-size: inherit; }
.upsell-price-label {
  font-size: 12px;
  color: var(--text-3);
  font-family: var(--mono);
}
.upsell-btn {
  width: 100%;
  padding: 16px;
  border-radius: 100px;
  border: none;
  background: linear-gradient(135deg, var(--pink), #C0004D);
  color: #fff;
  font-size: 16px;
  font-weight: 700;
  font-family: var(--font);
  cursor: pointer;
  box-shadow: var(--glow-pink);
  letter-spacing: 0.01em;
}
.upsell-guarantee {
  font-size: 11px;
  color: var(--text-3);
  font-family: var(--mono);
}
.upsell-see-plans {
  background: none;
  border: none;
  color: var(--text-3);
  font-size: 12px;
  cursor: pointer;
  font-family: var(--font);
  text-decoration: underline;
  text-underline-offset: 3px;
  margin-top: -4px;
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
</style>
