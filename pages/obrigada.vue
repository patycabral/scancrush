<script setup lang="ts">
useHead({ title: 'ScanCrush — Pagamento aprovado' })

// Perfect Pay pode enviar ?status=processing para pagamentos pendentes (Pix/boleto)
const status = ref<'approved' | 'processing'>('approved')

onMounted(() => {
  const params = new URLSearchParams(window.location.search)
  const s = params.get('status')
  if (s === 'processing') status.value = 'processing'
})
</script>

<template>
  <div class="ty-page">

    <!-- ── Header minimalista ── -->
    <header class="ty-header">
      <NuxtLink to="/" class="logo" aria-label="ScanCrush">
        <svg width="22" height="22" viewBox="0 0 28 28" fill="none">
          <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
          <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
        </svg>
        <span class="logo-word">Scan<span>Crush</span></span>
      </NuxtLink>
    </header>

    <!-- ── Conteúdo principal ── -->
    <main class="ty-main">
      <div class="ty-card">

        <!-- Estado: APROVADO -->
        <template v-if="status === 'approved'">

          <div class="ty-icon-wrap">
            <div class="ty-icon-ring"></div>
            <svg class="ty-check" width="28" height="28" viewBox="0 0 28 28" fill="none">
              <path d="M6 14.5L11.5 20L22 9" stroke="#FF2D6B" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>

          <h1 class="ty-title">Pagamento aprovado.</h1>

          <p class="ty-sub">
            Agora falta só o próximo passo: enviar os prints<br class="br-desktop"> para receber sua análise.
          </p>

          <div class="ty-email-notice">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <rect x="2" y="4" width="20" height="16" rx="2"/><path d="M2 7l10 7 10-7"/>
            </svg>
            <p>
              Em alguns minutos, você vai receber um e-mail com o link de acesso para enviar suas conversas.
              <span class="ty-spam-hint">Confira também a caixa de spam, promoções ou lixo eletrônico.</span>
            </p>
          </div>

          <div class="ty-divider"></div>

          <div class="ty-steps">
            <p class="ty-steps-label">O que acontece agora</p>
            <ol class="ty-steps-list">
              <li>
                <span class="ty-step-num">1</span>
                <span>Você recebe o link de acesso no e-mail usado na compra.</span>
              </li>
              <li>
                <span class="ty-step-num">2</span>
                <span>Envia os prints da conversa.</span>
              </li>
              <li>
                <span class="ty-step-num">3</span>
                <span>A análise é gerada com base nas mensagens enviadas.</span>
              </li>
              <li>
                <span class="ty-step-num">4</span>
                <span>O resultado fica disponível logo após o envio.</span>
              </li>
            </ol>
          </div>

          <p class="ty-disclaimer">
            O acesso é individual e pode expirar após o uso ou após o prazo definido para a sessão.
          </p>

        </template>

        <!-- Estado: EM PROCESSAMENTO (Pix / boleto) -->
        <!-- Para ativar: adicionar ?status=processing na URL -->
        <template v-else>

          <div class="ty-icon-wrap processing">
            <div class="ty-icon-ring"></div>
            <svg class="ty-clock" width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#FFB800" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 3"/>
            </svg>
          </div>

          <h1 class="ty-title">Pagamento em processamento.</h1>

          <p class="ty-sub">
            Estamos aguardando a confirmação do pagamento.
          </p>

          <div class="ty-email-notice">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <rect x="2" y="4" width="20" height="16" rx="2"/><path d="M2 7l10 7 10-7"/>
            </svg>
            <p>
              Assim que o pagamento for aprovado, você receberá por e-mail o link para enviar os prints e acessar sua análise.
              <span class="ty-spam-hint">Pagamentos por Pix e cartão costumam ser confirmados mais rapidamente.</span>
            </p>
          </div>

          <p class="ty-disclaimer">
            O acesso é individual e pode expirar após o uso ou após o prazo definido para a sessão.
          </p>

        </template>

        <!-- CTA comum -->
        <NuxtLink to="/" class="ty-back-link">← Voltar para o início</NuxtLink>

      </div>
    </main>

  </div>
</template>

<style scoped>
/* ── BASE ── */
.ty-page {
  min-height: 100vh;
  background: var(--bg);
  display: flex;
  flex-direction: column;
  font-family: var(--font);
  -webkit-font-smoothing: antialiased;
}

/* ── HEADER ── */
.ty-header {
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

/* ── MAIN ── */
.ty-main {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 48px 20px 64px;
}

/* ── CARD ── */
.ty-card {
  background: var(--surface);
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 20px;
  padding: 52px 44px;
  max-width: 520px;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  position: relative;
}

.ty-card::before {
  content: '';
  position: absolute;
  top: -1px; left: 20%; right: 20%;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--pink), transparent);
  opacity: 0.6;
}

/* ── ICON ── */
.ty-icon-wrap {
  position: relative;
  width: 64px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 28px;
}

.ty-icon-ring {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  background: rgba(255,45,107,0.08);
  border: 1px solid rgba(255,45,107,0.25);
  box-shadow: 0 0 28px rgba(255,45,107,0.15);
}

.ty-icon-wrap.processing .ty-icon-ring {
  background: rgba(255,184,0,0.08);
  border-color: rgba(255,184,0,0.25);
  box-shadow: 0 0 28px rgba(255,184,0,0.12);
}

/* ── TITLE ── */
.ty-title {
  font-size: clamp(22px, 4vw, 28px);
  font-weight: 800;
  color: var(--text);
  letter-spacing: -0.6px;
  line-height: 1.2;
  margin-bottom: 12px;
}

.ty-sub {
  font-size: 15px;
  color: var(--text-2);
  line-height: 1.65;
  margin-bottom: 28px;
  max-width: 380px;
}

/* ── EMAIL NOTICE ── */
.ty-email-notice {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  background: rgba(255,255,255,0.03);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 12px;
  padding: 16px 18px;
  text-align: left;
  margin-bottom: 28px;
  width: 100%;
}

.ty-email-notice svg {
  color: var(--text-3);
  flex-shrink: 0;
  margin-top: 2px;
}

.ty-email-notice p {
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.6;
  margin: 0;
}

.ty-spam-hint {
  display: block;
  margin-top: 6px;
  font-size: 12px;
  color: var(--text-3);
}

/* ── DIVIDER ── */
.ty-divider {
  width: 100%;
  height: 1px;
  background: var(--border);
  margin-bottom: 28px;
}

/* ── STEPS ── */
.ty-steps {
  width: 100%;
  text-align: left;
  margin-bottom: 24px;
}

.ty-steps-label {
  font-size: 10px;
  font-family: var(--mono, monospace);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--text-3);
  margin-bottom: 16px;
}

.ty-steps-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.ty-steps-list li {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  font-size: 13px;
  color: var(--text-2);
  line-height: 1.55;
}

.ty-step-num {
  flex-shrink: 0;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: rgba(255,45,107,0.1);
  border: 1px solid rgba(255,45,107,0.2);
  color: var(--pink);
  font-size: 11px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 1px;
}

/* ── DISCLAIMER ── */
.ty-disclaimer {
  font-size: 11px;
  color: var(--text-3);
  line-height: 1.6;
  margin-bottom: 28px;
  font-family: var(--mono, monospace);
  max-width: 340px;
}

/* ── BACK LINK ── */
.ty-back-link {
  font-size: 13px;
  color: var(--text-3);
  text-decoration: none;
  transition: color 0.2s;
}
.ty-back-link:hover { color: var(--text-2); }

/* ── HELPERS ── */
.br-desktop { display: none; }
@media (min-width: 560px) { .br-desktop { display: inline; } }

/* ── MOBILE ── */
@media (max-width: 560px) {
  .ty-card {
    padding: 36px 24px;
    border-radius: 16px;
  }
  .ty-main {
    align-items: flex-start;
    padding-top: 32px;
  }
}
</style>
