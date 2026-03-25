/**
 * usePlans — Controle de planos, limites e modal de upgrade
 *
 * LAUNCH_MODE = true → análise gratuita e sem restrições (fase de lançamento)
 * LAUNCH_MODE = false → paywall ativo com limites reais por plano
 */

// ════ Altere para FALSE para ativar o paywall ════
export const LAUNCH_MODE = true

export const PLAN_LIMITS = {
  free:     1,
  basic:    5,
  revealed: 10,
  xray:     20,
} as const

export type PlanKey = keyof typeof PLAN_LIMITS

export function usePlans() {
  const currentPlan = useState<PlanKey>('currentPlan', () => 'free')
  const isModalOpen = useState<boolean>('plansModalOpen', () => false)

  function openModal() {
    isModalOpen.value = true
  }

  function closeModal() {
    isModalOpen.value = false
  }

  /** Retorna o limite de imagens do plano atual (Infinity em LAUNCH_MODE) */
  function getLimit(): number {
    if (LAUNCH_MODE) return Infinity
    return PLAN_LIMITS[currentPlan.value]
  }

  /** Verifica se o usuário atingiu o limite de uploads */
  function isLimitReached(count: number): boolean {
    if (LAUNCH_MODE) return false
    return count >= PLAN_LIMITS[currentPlan.value]
  }

  /** Eleva o plano após pagamento confirmado */
  function setPlan(plan: PlanKey) {
    currentPlan.value = plan
  }

  return {
    LAUNCH_MODE,
    currentPlan: readonly(currentPlan),
    isModalOpen: readonly(isModalOpen),
    openModal,
    closeModal,
    getLimit,
    isLimitReached,
    setPlan,
  }
}
