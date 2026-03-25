<script setup lang="ts">
useHead({ title: 'ScanCrush — Preparando seu acesso...' })

const token = ref('')
const plan  = ref('')
const seconds = ref(5)
const progress = ref(0)

let interval: ReturnType<typeof setInterval> | null = null

onMounted(() => {
  const params = new URLSearchParams(window.location.search)
  token.value = params.get('token') ?? ''
  plan.value  = params.get('plan')  ?? ''

  if (!token.value) return

  const total = seconds.value * 1000
  const step  = 50 // ms
  let elapsed = 0

  interval = setInterval(() => {
    elapsed += step
    progress.value = Math.min((elapsed / total) * 100, 100)

    const remaining = Math.ceil((total - elapsed) / 1000)
    seconds.value = remaining > 0 ? remaining : 0

    if (elapsed >= total) {
      clearInterval(interval!)
      redirect()
    }
  }, step)
})

onUnmounted(() => {
  if (interval) clearInterval(interval)
})

function redirect() {
  if (token.value) {
    window.location.href = `/scan?access_token=${token.value}`
  }
}
</script>

<template>
  <div class="tack-page">
    <div class="tack-card">

      <div class="tack-icon">✓</div>

      <h1 class="tack-title">Pagamento confirmado.</h1>
      <p class="tack-sub">Estamos preparando seu acesso…</p>

      <div class="tack-progress-wrap">
        <div class="tack-progress-bar" :style="{ width: progress + '%' }"></div>
      </div>

      <p class="tack-countdown">
        Redirecionando em <span>{{ seconds }}</span> segundo{{ seconds !== 1 ? 's' : '' }}…
      </p>

      <button v-if="token" class="tack-btn" @click="redirect()">
        Se não redirecionar, clique aqui
      </button>

      <div v-if="!token" class="tack-error-box">
        <p class="tack-error">Houve um erro ao processar seu acesso.</p>
        <p class="tack-error-hint">Entre em contato com o nosso suporte (contato@scancrush.com) para que possamos resolver.</p>
      </div>

    </div>
  </div>
</template>

<style scoped>
.tack-page {
  min-height: 100vh;
  background: var(--bg);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.tack-card {
  background: var(--surface);
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 20px;
  padding: 48px 40px;
  max-width: 440px;
  width: 100%;
  text-align: center;
}

.tack-icon {
  width: 56px;
  height: 56px;
  background: rgba(255,45,107,0.12);
  border: 1px solid var(--pink-border);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  color: var(--pink);
  margin: 0 auto 24px;
}

.tack-title {
  font-size: 22px;
  font-weight: 700;
  color: var(--text);
  margin-bottom: 8px;
}

.tack-sub {
  font-size: 14px;
  color: var(--text-2);
  margin-bottom: 32px;
}

.tack-progress-wrap {
  height: 4px;
  background: rgba(255,255,255,0.06);
  border-radius: 100px;
  overflow: hidden;
  margin-bottom: 16px;
}

.tack-progress-bar {
  height: 100%;
  background: var(--pink);
  border-radius: 100px;
  transition: width 50ms linear;
}

.tack-countdown {
  font-size: 13px;
  color: var(--text-2);
  margin-bottom: 28px;
}

.tack-countdown span {
  color: var(--text);
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}

.tack-btn {
  font-size: 13px;
  color: var(--text-2);
  background: none;
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 100px;
  padding: 10px 20px;
  cursor: pointer;
  transition: color 0.2s, border-color 0.2s;
}

.tack-btn:hover {
  color: var(--text);
  border-color: rgba(255,255,255,0.2);
}

.tack-error-box {
  margin-top: 8px;
  padding: 16px;
  background: rgba(255,45,107,0.06);
  border: 1px solid var(--pink-border);
  border-radius: 10px;
}
.tack-error {
  font-size: 13px;
  color: var(--pink);
  margin-bottom: 4px;
}
.tack-error-hint {
  font-size: 12px;
  color: var(--text-2);
}
</style>
