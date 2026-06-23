<script setup lang="ts">
useHead({
  title: 'Pesquisa rápida — ScanCrush',
  meta: [{ name: 'robots', content: 'noindex, nofollow' }],
})

const route = useRoute()
const token  = (route.query.token as string) || (route.query.r as string) || ''
const source = (route.query.source as string) || 'result_page'

const RESEARCH_URL = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/research'

// ── Respostas ──
const nps        = ref<number | null>(null)
const helped     = ref('')   // sim | parcialmente | nao
const mostUseful = ref('')
const wouldUse   = ref('')   // sim | talvez | nao
const feedback   = ref('')

const state    = ref<'form' | 'sending' | 'done' | 'error'>('form')
const errorMsg = ref('')

const npsScale = [0,1,2,3,4,5,6,7,8,9,10]
const helpedOpts   = [{ v:'sim', l:'Sim' }, { v:'parcialmente', l:'Parcialmente' }, { v:'nao', l:'Não' }]
const wouldUseOpts = [{ v:'sim', l:'Sim' }, { v:'talvez', l:'Talvez' }, { v:'nao', l:'Não' }]
const usefulOpts = [
  { v:'score',            l:'Score de Engajamento Observado' },
  { v:'sinais_positivos', l:'Sinais positivos' },
  { v:'pontos_atencao',   l:'Pontos de atenção' },
  { v:'trechos',          l:'Trechos destacados' },
  { v:'conclusao',        l:'Conclusão final' },
  { v:'clareza',          l:'Clareza da explicação' },
  { v:'outro',            l:'Outro' },
]

const canSubmit = computed(() => nps.value !== null)

async function submit() {
  if (!canSubmit.value || state.value === 'sending') return
  state.value = 'sending'
  try {
    await $fetch(RESEARCH_URL, {
      method: 'POST',
      body: {
        token,
        source,
        nps_score:            nps.value,
        helped_see_something: helped.value || null,
        most_useful_part:     mostUseful.value || null,
        would_use_again:      wouldUse.value || null,
        open_feedback:        feedback.value.trim() || null,
      },
    })
    state.value = 'done'
    if (import.meta.client) window.scrollTo({ top: 0, behavior: 'smooth' })
  } catch (e) {
    state.value = 'error'
    errorMsg.value = 'Não foi possível enviar agora. Tente novamente em instantes.'
  }
}
</script>

<template>
<div class="ps-page">
  <header class="ps-header">
    <NuxtLink to="/" class="ps-logo">
      <svg width="24" height="24" viewBox="0 0 28 28" fill="none">
        <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
        <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
        <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
      </svg>
      <span>Scan<span class="ps-pink">Crush</span></span>
    </NuxtLink>
  </header>

  <main class="ps-main">
    <!-- ── FORM ── -->
    <div v-if="state !== 'done'" class="ps-card">
      <p class="ps-eyebrow">// A Patty quer saber</p>
      <h1 class="ps-title">Antes de ir, conta pra Patty: <span class="grad">essa análise te ajudou?</span></h1>
      <p class="ps-sub">5 perguntas rápidas (menos de 1 minuto). Seu feedback ajuda a melhorar as próximas leituras.</p>

      <!-- Q1 NPS -->
      <div class="ps-q">
        <p class="ps-q-label">1. De 0 a 10, o quanto essa análise foi útil para você?</p>
        <div class="ps-nps">
          <button v-for="n in npsScale" :key="n" type="button"
            class="ps-nps-btn" :class="{ active: nps === n }" @click="nps = n">{{ n }}</button>
        </div>
        <div class="ps-nps-scale"><span>Nada útil</span><span>Muito útil</span></div>
      </div>

      <!-- Q2 helped -->
      <div class="ps-q">
        <p class="ps-q-label">2. A análise ajudou a enxergar algo que você ainda não tinha percebido?</p>
        <div class="ps-pills">
          <button v-for="o in helpedOpts" :key="o.v" type="button"
            class="ps-pill" :class="{ active: helped === o.v }" @click="helped = o.v">{{ o.l }}</button>
        </div>
      </div>

      <!-- Q3 most useful -->
      <div class="ps-q">
        <p class="ps-q-label">3. O que mais chamou sua atenção no resultado?</p>
        <div class="ps-pills">
          <button v-for="o in usefulOpts" :key="o.v" type="button"
            class="ps-pill" :class="{ active: mostUseful === o.v }" @click="mostUseful = o.v">{{ o.l }}</button>
        </div>
      </div>

      <!-- Q4 would use again -->
      <div class="ps-q">
        <p class="ps-q-label">4. Você usaria o ScanCrush novamente?</p>
        <div class="ps-pills">
          <button v-for="o in wouldUseOpts" :key="o.v" type="button"
            class="ps-pill" :class="{ active: wouldUse === o.v }" @click="wouldUse = o.v">{{ o.l }}</button>
        </div>
      </div>

      <!-- Q5 open -->
      <div class="ps-q">
        <p class="ps-q-label">5. Alguma sugestão, crítica ou comentário? <span class="ps-opt">(opcional)</span></p>
        <textarea v-model="feedback" class="ps-textarea" rows="4" placeholder="Escreve aqui pra Patty…"></textarea>
      </div>

      <p v-if="state === 'error'" class="ps-error">{{ errorMsg }}</p>

      <button class="ps-submit" :disabled="!canSubmit || state === 'sending'" @click="submit()">
        {{ state === 'sending' ? 'Enviando…' : 'Enviar respostas' }}
      </button>
      <p class="ps-hint">Responda apenas se quiser — leva menos de 1 minuto.</p>
    </div>

    <!-- ── THANK YOU ── -->
    <div v-else class="ps-card ps-thanks">
      <div class="ps-thanks-icon">💜</div>
      <h1 class="ps-title">Obrigada por ajudar a melhorar o ScanCrush!</h1>
      <p class="ps-sub">Seu feedback nos ajuda a melhorar as próximas análises e a sua experiência.</p>
      <p class="ps-sign">— Patty, sua observadora no ScanCrush</p>
      <NuxtLink to="/" class="ps-submit ps-back">Voltar ao ScanCrush</NuxtLink>
    </div>
  </main>
</div>
</template>

<style scoped>
.ps-page { min-height: 100vh; background: var(--bg); color: var(--text); font-family: var(--font); }
.ps-header { padding: 20px 24px; border-bottom: 1px solid var(--border); }
.ps-logo { display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text); font-weight: 800; font-size: 18px; }
.ps-pink { color: var(--pink); }
.ps-main { max-width: 640px; margin: 0 auto; padding: 40px 22px 80px; }
.ps-card { background: var(--card); border: 1px solid var(--border); border-radius: 20px; padding: 32px 28px; }
.ps-eyebrow { font-size: 11px; font-family: var(--mono); text-transform: uppercase; letter-spacing: 0.12em; color: var(--pink); margin-bottom: 12px; }
.ps-title { font-size: clamp(22px, 4.5vw, 30px); font-weight: 800; letter-spacing: -0.8px; line-height: 1.18; margin-bottom: 12px; }
.ps-sub { font-size: 15px; color: var(--text-2); font-weight: 300; line-height: 1.6; margin-bottom: 28px; }
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }

.ps-q { margin-bottom: 26px; }
.ps-q-label { font-size: 14.5px; font-weight: 600; color: var(--text); margin-bottom: 12px; line-height: 1.5; }
.ps-opt { font-weight: 400; color: var(--text-3); font-size: 13px; }

.ps-nps { display: flex; flex-wrap: wrap; gap: 6px; }
.ps-nps-btn { flex: 1; min-width: 36px; padding: 10px 0; border-radius: 10px; border: 1px solid var(--border); background: rgba(255,255,255,0.02); color: var(--text-2); font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.15s; font-family: var(--font); }
.ps-nps-btn:hover { border-color: rgba(255,45,107,0.4); }
.ps-nps-btn.active { background: linear-gradient(135deg, var(--pink), #C0004D); color: #fff; border-color: transparent; }
.ps-nps-scale { display: flex; justify-content: space-between; margin-top: 7px; font-size: 11px; font-family: var(--mono); color: var(--text-3); }

.ps-pills { display: flex; flex-wrap: wrap; gap: 8px; }
.ps-pill { padding: 9px 16px; border-radius: 100px; border: 1px solid var(--border); background: rgba(255,255,255,0.02); color: var(--text-2); font-size: 13.5px; cursor: pointer; transition: all 0.15s; font-family: var(--font); }
.ps-pill:hover { border-color: rgba(155,93,229,0.45); }
.ps-pill.active { background: rgba(155,93,229,0.16); border-color: var(--purple); color: var(--text); }

.ps-textarea { width: 100%; background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 12px; padding: 14px; color: var(--text); font-family: var(--font); font-size: 14px; line-height: 1.6; resize: vertical; }
.ps-textarea:focus { outline: none; border-color: rgba(155,93,229,0.5); }

.ps-error { color: #FF6B8E; font-size: 13px; margin-bottom: 12px; }
.ps-submit { display: block; width: 100%; text-align: center; padding: 16px; border: none; border-radius: 100px; background: linear-gradient(135deg, var(--pink), #C0004D); color: #fff; font-size: 16px; font-weight: 700; font-family: var(--font); cursor: pointer; box-shadow: var(--glow-pink); transition: opacity 0.2s, transform 0.2s; text-decoration: none; }
.ps-submit:disabled { opacity: 0.45; cursor: not-allowed; box-shadow: none; }
.ps-submit:not(:disabled):hover { transform: translateY(-1px); }
.ps-hint { text-align: center; font-size: 11.5px; color: var(--text-3); margin-top: 12px; }

.ps-thanks { text-align: center; }
.ps-thanks-icon { font-size: 44px; margin-bottom: 14px; }
.ps-sign { font-family: var(--mono); font-size: 13px; font-style: italic; color: var(--purple); margin: 18px 0 26px; }
.ps-back { max-width: 280px; margin: 0 auto; }
</style>
