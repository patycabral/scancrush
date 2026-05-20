/**
 * useSession — Controle de sessão temporária pós-pagamento
 *
 * Token de uso único gerado pelo server após confirmação de pagamento.
 * Armazenado em sessionStorage (expira ao fechar o navegador).
 * Sem banco de dados — MVP com controle server-side em memória.
 */

export function useSession() {
  const sessionToken = useState<string | null>('sessionToken', () => {
    if (import.meta.client) {
      return sessionStorage.getItem('sc_token')
    }
    return null
  })

  const analysisDone = useState<boolean>('analysisDone', () => {
    if (import.meta.client) {
      return !!sessionStorage.getItem('sc_analysis_done')
    }
    return false
  })

  /** Salva o token de acesso após pagamento */
  function setToken(token: string) {
    sessionToken.value = token
    if (import.meta.client) {
      sessionStorage.setItem('sc_token', token)
    }
  }

  /** Marca que a análise foi gerada (acesso único) */
  function markAnalysisDone() {
    analysisDone.value = true
    if (import.meta.client) {
      sessionStorage.setItem('sc_analysis_done', '1')
    }
  }

  /** Limpa sessão completamente (ex: nova análise paga) */
  function clearSession() {
    sessionToken.value = null
    analysisDone.value = false
    if (import.meta.client) {
      sessionStorage.removeItem('sc_token')
      sessionStorage.removeItem('sc_analysis_done')
    }
  }

  /** Verifica se o token está presente (não valida expiração — isso é feito no server) */
  function hasToken(): boolean {
    return !!sessionToken.value
  }

  return {
    sessionToken: readonly(sessionToken),
    analysisDone: readonly(analysisDone),
    setToken,
    markAnalysisDone,
    clearSession,
    hasToken,
  }
}
