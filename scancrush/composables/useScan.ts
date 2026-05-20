/**
 * useScan — Estado e lógica do fluxo de análise
 *
 * Responsável por:
 * - Upload e gerenciamento de imagens
 * - Validação dos dados do perfil
 * - Chamada às APIs de preview e análise completa
 * - Controle de tela (1: upload → 2: perfil → 3: resultado)
 */

import type { PlanKey } from './usePlans'

export type Screen = 1 | 2 | 3

export interface ScanPayload {
  name: string
  birthdate: string | null
  age: number | null
  observations: string
  emotionalTags: string[]
  plan: PlanKey
}

export interface ScanResult {
  score: number
  positivos: string[]
  negativos: string[]
  conclusao: string
  perfil?: string
  padroes?: string[]
}

export function useScan() {
  const { getLimit, isLimitReached, currentPlan, LAUNCH_MODE } = usePlans()
  const { sessionToken, markAnalysisDone } = useSession()

  // ── Estado ──────────────────────────────────────────────────
  const currentScreen  = useState<Screen>('currentScreen', () => 1)
  const uploadedFiles  = useState<File[]>('uploadedFiles', () => [])
  const isLoading      = useState<boolean>('scanLoading', () => false)
  const error          = useState<string | null>('scanError', () => null)
  const result         = useState<ScanResult | null>('scanResult', () => null)

  // ── Upload ───────────────────────────────────────────────────
  function handleFiles(newFiles: FileList | File[]) {
    const limit     = getLimit()
    const current   = uploadedFiles.value.length
    const remaining = limit === Infinity ? Infinity : limit - current

    if (remaining <= 0) return

    const toAdd = remaining === Infinity
      ? Array.from(newFiles)
      : Array.from(newFiles).slice(0, remaining)

    uploadedFiles.value = [...uploadedFiles.value, ...toAdd]
  }

  function removeFile(index: number) {
    uploadedFiles.value = uploadedFiles.value.filter((_, i) => i !== index)
  }

  function removeAllFiles() {
    uploadedFiles.value = []
  }

  // ── Datas e Payload ──────────────────────────────────────────
  function calcAge(dateStr: string): number {
    const birth = new Date(dateStr)
    const today = new Date()
    let age = today.getFullYear() - birth.getFullYear()
    const m = today.getMonth() - birth.getMonth()
    if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) age--
    return age
  }

  function buildBirthdate(day: string, month: string, year: string): string | null {
    if (!day || !month || !year) return null
    return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`
  }

  function buildPayload(
    name: string,
    birthdate: string | null,
    observations: string,
    emotionalTags: string[],
  ): ScanPayload {
    return {
      name,
      birthdate,
      age: birthdate ? calcAge(birthdate) : null,
      observations,
      emotionalTags,
      plan: currentPlan.value,
    }
  }

  // ── API Calls ────────────────────────────────────────────────

  /** Análise de preview — gratuita, resultado parcial */
  async function runPreview(payload: ScanPayload) {
    isLoading.value = true
    error.value = null
    try {
      const data = await $fetch<{ preview: string }>('/api/preview', {
        method: 'POST',
        body: payload,
      })
      result.value = {
        score: 0,
        positivos: [],
        negativos: [],
        conclusao: data.preview,
      }
      currentScreen.value = 3
    } catch (e: any) {
      error.value = e?.data?.message ?? 'Erro ao processar preview.'
    } finally {
      isLoading.value = false
    }
  }

  /** Análise completa — requer token de pagamento */
  async function runAnalysis(payload: ScanPayload) {
    isLoading.value = true
    error.value = null
    try {
      // TODO: enviar imagens como FormData quando integrar IA real
      const data = await $fetch<ScanResult>('/api/analyze', {
        method: 'POST',
        body: {
          ...payload,
          token: sessionToken.value,
        },
      })
      result.value = data
      markAnalysisDone()
      currentScreen.value = 3
    } catch (e: any) {
      error.value = e?.data?.message ?? 'Erro ao processar análise.'
    } finally {
      isLoading.value = false
    }
  }

  // ── Navegação ────────────────────────────────────────────────
  function goToScreen(screen: Screen) {
    currentScreen.value = screen
  }

  function reset() {
    uploadedFiles.value  = []
    result.value         = null
    error.value          = null
    currentScreen.value  = 1
  }

  // ── Computed helpers ─────────────────────────────────────────
  const uploadCount = computed(() => uploadedFiles.value.length)
  const uploadLimit = computed(() => getLimit())
  const limitReached = computed(() => isLimitReached(uploadedFiles.value.length))

  return {
    // Estado (readonly para componentes)
    currentScreen: readonly(currentScreen),
    uploadedFiles: readonly(uploadedFiles),
    isLoading:     readonly(isLoading),
    error:         readonly(error),
    result:        readonly(result),

    // Computed
    uploadCount,
    uploadLimit,
    limitReached,

    // Ações
    handleFiles,
    removeFile,
    removeAllFiles,
    buildBirthdate,
    buildPayload,
    runPreview,
    runAnalysis,
    goToScreen,
    reset,
  }
}
