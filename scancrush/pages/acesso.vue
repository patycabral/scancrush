<script setup lang="ts">
useHead({ title: 'ScanCrush — Validando acesso...' })

const VALIDATE_URL = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/validate-access-token'

type PageState = 'loading' | 'no-token' | 'error'

const state        = ref<PageState>('loading')
const errorMessage = ref('')

onMounted(async () => {
  const params = new URLSearchParams(window.location.search)
  const token  = params.get('token')


  if (!token) {
    state.value = 'no-token'
    return
  }

  const payload: Record<string, string> = { token }
  const emailParam = params.get('email')
  if (emailParam) payload.email = emailParam


  try {
    const res  = await fetch(VALIDATE_URL, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(payload),
    })

    const data = await res.json()

    if (data.success) {
      const { access } = data
      sessionStorage.setItem('sc_token',      access.token)
      sessionStorage.setItem('sc_plan',       access.plan)
      sessionStorage.setItem('sc_max_images', String(access.max_prints))
      sessionStorage.setItem('sc_plan_name',  access.plan_name)
      sessionStorage.setItem('sc_access_id',  access.access_id)

      window.location.href = '/scan'
    } else {
      errorMessage.value = data.error?.message ?? 'Seu link de acesso não é válido ou expirou.'
      state.value = 'error'
    }
  } catch (err) {
    console.error('[acesso] erro na chamada do webhook:', err)
    errorMessage.value = 'Não foi possível validar seu acesso. Tente novamente ou entre em contato com o suporte.'
    state.value = 'error'
  }
})
</script>

<template>
  <div class="ac-page">

    <header class="ac-header">
      <NuxtLink to="/" class="logo" aria-label="ScanCrush">
        <svg width="22" height="22" viewBox="0 0 28 28" fill="none">
          <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
          <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
        </svg>
        <span class="logo-word">Scan<span>Crush</span></span>
      </NuxtLink>
    </header>

    <main class="ac-main">
      <div class="ac-card">

        <!-- ── Loading ── -->
        <template v-if="state === 'loading'">
          <div class="ac-spinner-wrap">
            <div class="ac-spinner"></div>
          </div>
          <h1 class="ac-title">Validando seu acesso…</h1>
          <p class="ac-sub">Aguarde um momento.</p>
        </template>

        <!-- ── Sem token ── -->
        <template v-else-if="state === 'no-token'">
          <div class="ac-icon-wrap">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
              stroke="#FF2D6B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="9"/>
              <path d="M12 8v4m0 4h.01"/>
            </svg>
          </div>
          <h1 class="ac-title">Link inválido</h1>
          <p class="ac-error-msg">Link de acesso inválido. Verifique se você abriu o link correto enviado por e-mail.</p>
          <p class="ac-support-hint">
            Em caso de dúvidas, entre em contato:
            <a href="mailto:suporte@scancrush.com">suporte@scancrush.com</a>
          </p>
          <NuxtLink to="/" class="ac-back">← Voltar para o início</NuxtLink>
        </template>

        <!-- ── Erro de validação ── -->
        <template v-else>
          <div class="ac-icon-wrap">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
              stroke="#FF2D6B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="9"/>
              <path d="M12 8v4m0 4h.01"/>
            </svg>
          </div>
          <h1 class="ac-title">Acesso não autorizado</h1>
          <p class="ac-error-msg">{{ errorMessage }}</p>
          <p class="ac-support-hint">
            Se você acabou de realizar a compra e está com dificuldades, entre em contato:
            <a href="mailto:suporte@scancrush.com">suporte@scancrush.com</a>
          </p>
          <NuxtLink to="/" class="ac-back">← Voltar para o início</NuxtLink>
        </template>

      </div>
    </main>

  </div>
</template>

<style scoped>
.ac-page {
  min-height: 100vh;
  background: var(--bg);
  display: flex;
  flex-direction: column;
  font-family: var(--font);
  -webkit-font-smoothing: antialiased;
}

.ac-header {
  padding: 20px 28px;
  border-bottom: 1px solid var(--border);
  background: rgba(7,7,13,0.7);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
}

.logo {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 800;
  letter-spacing: -0.5px;
  text-decoration: none;
  color: var(--text);
}
.logo svg { filter: drop-shadow(0 0 6px rgba(255,45,107,0.5)); }
.logo-word { color: var(--text); }
.logo-word span { color: var(--pink); }

.ac-main {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 48px 20px 64px;
}

.ac-card {
  background: var(--surface);
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 20px;
  padding: 52px 44px;
  max-width: 480px;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  position: relative;
}

.ac-card::before {
  content: '';
  position: absolute;
  top: -1px; left: 20%; right: 20%;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--pink), transparent);
  opacity: 0.5;
}

/* Spinner */
.ac-spinner-wrap {
  width: 56px;
  height: 56px;
  margin-bottom: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.ac-spinner {
  width: 36px;
  height: 36px;
  border: 2.5px solid rgba(255,45,107,0.15);
  border-top-color: var(--pink);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* Icon (error states) */
.ac-icon-wrap {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: rgba(255,45,107,0.08);
  border: 1px solid rgba(255,45,107,0.25);
  box-shadow: 0 0 24px rgba(255,45,107,0.12);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 28px;
}

.ac-title {
  font-size: clamp(20px, 4vw, 26px);
  font-weight: 800;
  color: var(--text);
  letter-spacing: -0.5px;
  margin-bottom: 10px;
}

.ac-sub {
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.6;
}

.ac-error-msg {
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.65;
  margin-bottom: 20px;
  max-width: 360px;
}

.ac-support-hint {
  font-size: 12px;
  color: var(--text-3);
  line-height: 1.6;
  margin-bottom: 28px;
}
.ac-support-hint a {
  color: var(--text-2);
  text-decoration: underline;
  text-underline-offset: 3px;
}

.ac-back {
  font-size: 13px;
  color: var(--text-3);
  text-decoration: none;
  transition: color 0.2s;
}
.ac-back:hover { color: var(--text-2); }

@media (max-width: 560px) {
  .ac-card { padding: 36px 24px; border-radius: 16px; }
  .ac-main { align-items: flex-start; padding-top: 32px; }
}
</style>
