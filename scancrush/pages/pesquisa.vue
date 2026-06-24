<script setup lang="ts">
useHead({
  title: 'Pesquisa rápida — ScanCrush',
  meta: [{ name: 'robots', content: 'noindex, nofollow' }],
})

const route = useRoute()
const token     = (route.query.token as string) || (route.query.r as string) || ''
const protocolo = (route.query.p as string) || ''
const email     = (route.query.e as string) || ''
const source    = (route.query.source as string) || 'email'

const VALIDATE_URL = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/valida-pesquisa' // valida token / validade / já respondida
const RESEARCH_URL = 'https://scancrush-n8n.xpsbu9.easypanel.host/webhook/research'        // salva as respostas

// estados: loading | form | done | already | expired | invalid | error
const state         = ref<'loading' | 'form' | 'done' | 'already' | 'expired' | 'invalid' | 'error'>('loading')
const sending       = ref(false)
const errorMsg      = ref('')
const validationMsg = ref('')   // mensagem vinda do webhook (sobrepõe o texto padrão do card)

// ── Respostas ──
const nps             = ref<number | null>(null)
const npsReason       = ref('')
const npsReasonOther  = ref('')
const csat            = reactive({ clarity: 0, helpfulness: 0, depth: 0, value: 0, quali: 0 })
const csatHover       = reactive({ clarity: 0, helpfulness: 0, depth: 0, value: 0, quali: 0 })
const helped          = ref('')
const mostUseful      = ref('')
const mostUsefulOther = ref('')
const wouldUse        = ref('')
const feedback        = ref('')
const contactConsent  = ref('')

const npsScale = [0,1,2,3,4,5,6,7,8,9,10]

const reasonOpts = [
  { v:'clareza',        l:'Clareza da análise' },
  { v:'qualidade',      l:'Qualidade da análise' },
  { v:'profundidade',   l:'Profundidade da análise' },
  { v:'utilidade',      l:'Utilidade da análise' },
  { v:'custo_beneficio',l:'Custo-benefício' },
  { v:'preco',          l:'Preço' },
  { v:'coerencia',      l:'Coerência com a conversa' },
  { v:'facilidade',     l:'Facilidade de entendimento' },
  { v:'confianca',      l:'Confiança no resultado' },
  { v:'outro',          l:'Outro' },
]
const csatAttrs = [
  { k:'clarity'    as const, l:'Clareza da análise' },
  { k:'helpfulness'as const, l:'Ajuda para enxergar a situação' },
  { k:'depth'      as const, l:'Profundidade da leitura' },
  { k:'value'      as const, l:'Custo-benefício' },
  { k:'quali'      as const, l:'Qualidade da análise' },
]
const helpedOpts   = [{ v:'sim', l:'Sim' }, { v:'parcialmente', l:'Parcialmente' }, { v:'nao', l:'Não' }]
const usefulOpts = [
  { v:'score',            l:'Score de Engajamento Observado' },
  { v:'sinais_positivos', l:'Sinais positivos' },
  { v:'pontos_atencao',   l:'Pontos de atenção' },
  { v:'trechos',          l:'Trechos destacados' },
  { v:'conclusao',        l:'Conclusão final' },
  { v:'clareza',          l:'Clareza da explicação' },
  { v:'outro',            l:'Outro' },
]
const wouldUseOpts = [{ v:'sim', l:'Sim' }, { v:'talvez', l:'Talvez' }, { v:'nao', l:'Não' }]
const contactOpts  = [{ v:'sim', l:'Sim, autorizo o contato' }, { v:'nao', l:'Não, prefiro não ser contatada' }]

// ── Navegação do quiz ──
const step  = ref(1)
const total = 8
const progressPct = computed(() => `${Math.round((step.value / total) * 100)}%`)

// Cada passo libera "Continuar" quando respondido (CSAT e aberta são opcionais).
const canNext = computed(() => {
  switch (step.value) {
    case 1: return nps.value !== null
    case 2: return npsReason.value !== ''
    case 3: return true
    case 4: return helped.value !== ''
    case 5: return mostUseful.value !== ''
    case 6: return wouldUse.value !== ''
    case 7: return true
    case 8: return contactConsent.value !== ''
    default: return false
  }
})

function back() { if (step.value > 1) step.value -= 1 }
function next() {
  if (!canNext.value || sending.value) return
  if (step.value < total) step.value += 1
  else submit()
}

// ── Valida o link ao abrir (token + validade + status) ──
// Contrato esperado do /webhook/valida-pesquisa:
//   { status: 'pendente'   }                 → pode responder (mostra o quiz)
//   { status: 'respondida', message?: '...' } → já respondeu
//   { status: 'expirada',   message?: '...' } → fora da validade
//   { status: 'invalida',   message?: '...' } → token inexistente/errado
onMounted(async () => {
  if (!token) { state.value = 'invalid'; return }
  try {
    const res: any = await $fetch(VALIDATE_URL, {
      method: 'POST',
      body: { token, protocolo, email },
    })
    const st = String(res?.status ?? '').toLowerCase()
    validationMsg.value = res?.message || ''
    if (st === 'respondida' || st === 'concluido') state.value = 'already'
    else if (st === 'expirada')                    state.value = 'expired'
    else if (st === 'invalida')                    state.value = 'invalid'
    else                                            state.value = 'form'   // pendente / desconhecido
  } catch (e) {
    state.value = 'form'   // fail-open: se o webhook cair, deixa responder
  }
})

async function submit() {
  if (sending.value) return
  sending.value = true
  errorMsg.value = ''
  try {
    const res: any = await $fetch(RESEARCH_URL, {
      method: 'POST',
      body: {
        token, protocolo, email, source,
        nps_score:            nps.value,
        nps_reason:           npsReason.value || null,
        nps_reason_other:     npsReason.value === 'outro' ? (npsReasonOther.value.trim() || null) : null,
        csat_clarity:         csat.clarity || null,
        csat_helpfulness:     csat.helpfulness || null,
        csat_depth:           csat.depth || null,
        csat_value_for_money: csat.value || null,
        csat_quali:           csat.quali || null,
        helped_see_something: helped.value || null,
        most_useful_part:     mostUseful.value || null,
        most_useful_part_other: mostUseful.value === 'outro' ? (mostUsefulOther.value.trim() || null) : null,
        would_use_again:      wouldUse.value || null,
        open_feedback:        feedback.value.trim() || null,
        contact_permission:    contactConsent.value === 'sim',
        contact_permission_at: contactConsent.value === 'sim' ? new Date().toISOString() : null,
        contact_channels:      contactConsent.value === 'sim' ? 'email_whatsapp' : null,
        contact_purpose:       contactConsent.value === 'sim' ? 'pesquisa_experiencia' : null,
      },
    })
    const st = String(res?.status ?? 'ok').toLowerCase()
    validationMsg.value = res?.message || ''
    if (st === 'respondida' || st === 'concluido') state.value = 'already'
    else if (st === 'expirada') state.value = 'expired'
    else state.value = 'done'
    if (import.meta.client) window.scrollTo({ top: 0, behavior: 'smooth' })
  } catch (e) {
    errorMsg.value = 'Não foi possível enviar agora. Tente novamente em instantes.'
  } finally {
    sending.value = false
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
    <!-- LOADING -->
    <div v-if="state === 'loading'" class="ps-card ps-msg">
      <div class="ps-spinner"></div>
      <p class="ps-sub" style="margin:0">Validando seu link…</p>
    </div>

    <!-- FORM (mini quiz, 1 pergunta por tela) -->
    <div v-else-if="state === 'form'" class="ps-card">
      <p class="ps-eyebrow">// A Patty quer saber</p>

      <div class="ps-progress"><div class="ps-progress-bar" :style="{ width: progressPct }"></div></div>
      <p class="ps-step-count">{{ step }} de {{ total }}</p>

      <Transition name="ps-slide" mode="out-in">
        <div :key="step" class="ps-step">

          <!-- 1 · NPS -->
          <template v-if="step === 1">
            <p class="ps-q-label">De 0 a 10, o quanto você recomendaria o ScanCrush para um amigo(a) ou familiar?</p>
            <div class="ps-nps">
              <button v-for="n in npsScale" :key="n" type="button" class="ps-nps-btn" :class="{ active: nps === n }" @click="nps = n">{{ n }}</button>
            </div>
          </template>

          <!-- 2 · Motivo da nota (puxa a nota) -->
          <template v-else-if="step === 2">
            <p class="ps-q-label">Qual o principal motivo de você dar nota {{ nps }} para o ScanCrush?</p>
            <div class="ps-pills">
              <button v-for="o in reasonOpts" :key="o.v" type="button" class="ps-pill" :class="{ active: npsReason === o.v }" @click="npsReason = o.v">{{ o.l }}</button>
            </div>
            <input v-if="npsReason === 'outro'" v-model="npsReasonOther" class="ps-input" type="text" maxlength="160" placeholder="Me conta o principal motivo da sua nota." />
          </template>

          <!-- 3 · CSAT por atributos (estrelas) -->
          <template v-else-if="step === 3">
            <p class="ps-q-label">Como foi sua experiência?</p>
            <p class="ps-q-help">De acordo com o seu resultado, como você avalia:</p>
            <div class="ps-csat">
              <div v-for="a in csatAttrs" :key="a.k" class="ps-csat-row" @mouseleave="csatHover[a.k] = 0">
                <span class="ps-csat-label">{{ a.l }}</span>
                <div class="ps-stars">
                  <button
                    v-for="s in 5" :key="s" type="button" class="ps-star"
                    :class="{ on: (csatHover[a.k] || csat[a.k]) >= s }"
                    @mouseenter="csatHover[a.k] = s" @click="csat[a.k] = s"
                    :aria-label="`${a.l}: ${s} de 5`"
                  >★</button>
                </div>
              </div>
            </div>
          </template>

          <!-- 4 · Enxergou algo novo -->
          <template v-else-if="step === 4">
            <p class="ps-q-label">Essa análise ajudou você a enxergar algo que ainda não tinha percebido?</p>
            <div class="ps-pills">
              <button v-for="o in helpedOpts" :key="o.v" type="button" class="ps-pill" :class="{ active: helped === o.v }" @click="helped = o.v">{{ o.l }}</button>
            </div>
          </template>

          <!-- 5 · O que mais chamou atenção -->
          <template v-else-if="step === 5">
            <p class="ps-q-label">O que mais chamou sua atenção no resultado?</p>
            <div class="ps-pills">
              <button v-for="o in usefulOpts" :key="o.v" type="button" class="ps-pill" :class="{ active: mostUseful === o.v }" @click="mostUseful = o.v">{{ o.l }}</button>
            </div>
            <input v-if="mostUseful === 'outro'" v-model="mostUsefulOther" class="ps-input" type="text" maxlength="160" placeholder="Qual parte chamou mais sua atenção?" />
          </template>

          <!-- 6 · Recompra -->
          <template v-else-if="step === 6">
            <p class="ps-q-label">Você usaria o ScanCrush novamente?</p>
            <div class="ps-pills">
              <button v-for="o in wouldUseOpts" :key="o.v" type="button" class="ps-pill" :class="{ active: wouldUse === o.v }" @click="wouldUse = o.v">{{ o.l }}</button>
            </div>
          </template>

          <!-- 7 · Pergunta aberta (opcional) -->
          <template v-else-if="step === 7">
            <p class="ps-q-label">Poderia nos contar um pouco mais sobre a sua experiência? <span class="ps-opt">(opcional)</span></p>
            <textarea v-model="feedback" class="ps-textarea" rows="4" maxlength="600" placeholder="Compartilhe aqui o que gostou, o que faltou, ideias de melhoria…"></textarea>
          </template>

          <!-- 8 · Consentimento de contato -->
          <template v-else>
            <p class="ps-q-label">Podemos falar com você depois?</p>
            <p class="ps-q-text">Às vezes, nossa equipe conversa com alguns clientes para entender melhor a experiência no ScanCrush.</p>
            <p class="ps-q-help">Só entraremos em contato se você permitir. O contato pode acontecer pelo e-mail ou WhatsApp informado na compra, apenas para pesquisa e melhoria da plataforma.</p>
            <div class="ps-pills">
              <button v-for="o in contactOpts" :key="o.v" type="button" class="ps-pill" :class="{ active: contactConsent === o.v }" @click="contactConsent = o.v">{{ o.l }}</button>
            </div>
            <p class="ps-consent-note">Você pode pedir para retirar essa autorização a qualquer momento.</p>
          </template>

        </div>
      </Transition>

      <p v-if="errorMsg" class="ps-error">{{ errorMsg }}</p>

      <div class="ps-nav">
        <button v-if="step > 1" type="button" class="ps-nav-back" @click="back()">← Voltar</button>
        <button type="button" class="ps-nav-next" :disabled="!canNext || sending" @click="next()">
          {{ step === total ? (sending ? 'Enviando…' : 'Enviar respostas') : 'Continuar' }}
        </button>
      </div>
    </div>

    <!-- DONE -->
    <div v-else-if="state === 'done'" class="ps-card ps-msg">
      <img src="/brand/patty-avatar.webp" alt="Patty" class="ps-done-avatar" width="76" height="76" />
      <h1 class="ps-title">Obrigada por responder 💗</h1>
      <p class="ps-sub">Sua resposta ajuda a Patty a melhorar as próximas análises e a experiência do ScanCrush.</p>
      <p class="ps-sign">— Patty, do ScanCrush</p>
      <NuxtLink to="/" class="ps-submit ps-back">← Voltar ao ScanCrush</NuxtLink>
    </div>

    <!-- ALREADY ANSWERED -->
    <div v-else-if="state === 'already'" class="ps-card ps-msg">
      <div class="ps-icon">✓</div>
      <h1 class="ps-title">Você já respondeu 💜</h1>
      <p class="ps-sub">{{ validationMsg || 'Obrigada! Essa pesquisa só pode ser respondida uma vez por análise.' }}</p>
      <NuxtLink to="/" class="ps-submit ps-back">Voltar ao ScanCrush</NuxtLink>
    </div>

    <!-- EXPIRED -->
    <div v-else-if="state === 'expired'" class="ps-card ps-msg">
      <div class="ps-icon">⏳</div>
      <h1 class="ps-title">Essa pesquisa expirou</h1>
      <p class="ps-sub">{{ validationMsg || 'O prazo para responder esta pesquisa já passou. Obrigada pelo interesse!' }}</p>
      <NuxtLink to="/" class="ps-submit ps-back">Voltar ao ScanCrush</NuxtLink>
    </div>

    <!-- INVALID -->
    <div v-else class="ps-card ps-msg">
      <div class="ps-icon">⚠️</div>
      <h1 class="ps-title">Link inválido</h1>
      <p class="ps-sub">{{ validationMsg || 'Esse link de pesquisa não é válido. Use o link enviado no seu e-mail.' }}</p>
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
.ps-main { max-width: 600px; margin: 0 auto; padding: 40px 22px 80px; }
.ps-card { background: var(--card); border: 1px solid var(--border); border-radius: 20px; padding: 30px 28px; }
.ps-eyebrow { font-size: 11px; font-family: var(--mono); text-transform: uppercase; letter-spacing: 0.12em; color: var(--pink); margin-bottom: 16px; }
.ps-title { font-size: clamp(22px, 4.5vw, 30px); font-weight: 800; letter-spacing: -0.8px; line-height: 1.18; margin-bottom: 12px; }
.ps-sub { font-size: 15px; color: var(--text-2); font-weight: 300; line-height: 1.6; margin-bottom: 28px; }
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }

/* progresso */
.ps-progress { height: 5px; border-radius: 100px; background: rgba(255,255,255,0.06); overflow: hidden; }
.ps-progress-bar { height: 100%; border-radius: 100px; background: linear-gradient(135deg, var(--pink), #9B5DE5); transition: width 0.35s ease; }
.ps-step-count { font-size: 11px; font-family: var(--mono); color: var(--text-3); margin: 8px 0 22px; letter-spacing: 0.05em; }

/* passo */
.ps-step { min-height: 190px; }
.ps-q-label { font-size: 17px; font-weight: 700; color: var(--text); margin-bottom: 16px; line-height: 1.4; letter-spacing: -0.3px; }
.ps-q-text { font-size: 14.5px; color: var(--text-2); font-weight: 300; line-height: 1.6; margin: -8px 0 12px; }
.ps-q-help { font-size: 13.5px; color: var(--text-3); margin: -4px 0 18px; line-height: 1.55; }
.ps-q-text + .ps-q-help { margin-top: 0; }
.ps-opt { font-weight: 400; color: var(--text-3); font-size: 13px; }
.ps-consent-note { font-size: 12px; color: var(--text-3); font-style: italic; margin: 16px 0 0; }

.ps-nps { display: flex; flex-wrap: wrap; gap: 6px; }
.ps-nps-btn { flex: 1; min-width: 38px; padding: 12px 0; border-radius: 10px; border: 1px solid var(--border); background: rgba(255,255,255,0.02); color: var(--text-2); font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.15s; font-family: var(--font); }
.ps-nps-btn:hover { border-color: rgba(255,45,107,0.4); }
.ps-nps-btn.active { background: linear-gradient(135deg, var(--pink), #C0004D); color: #fff; border-color: transparent; }

.ps-pills { display: flex; flex-wrap: wrap; gap: 8px; }
.ps-pill { padding: 10px 16px; border-radius: 100px; border: 1px solid var(--border); background: rgba(255,255,255,0.02); color: var(--text-2); font-size: 13.5px; cursor: pointer; transition: all 0.15s; font-family: var(--font); }
.ps-pill:hover { border-color: rgba(155,93,229,0.45); }
.ps-pill.active { background: rgba(155,93,229,0.16); border-color: var(--purple); color: var(--text); }

/* CSAT estrelas */
.ps-csat { display: flex; flex-direction: column; gap: 2px; }
.ps-csat-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; padding: 12px 0; border-bottom: 1px solid var(--border); }
.ps-csat-row:last-child { border-bottom: none; }
.ps-csat-label { font-size: 14px; color: var(--text-2); }
.ps-stars { display: flex; gap: 3px; flex-shrink: 0; }
.ps-star { font-size: 26px; line-height: 1; background: none; border: none; cursor: pointer; color: rgba(255,255,255,0.16); transition: color 0.12s, transform 0.12s; padding: 0 1px; }
.ps-star:hover { transform: scale(1.18); }
.ps-star.on { color: #FFB800; }

.ps-input { width: 100%; margin-top: 12px; background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 12px; padding: 13px 14px; color: var(--text); font-family: var(--font); font-size: 14px; }
.ps-input:focus { outline: none; border-color: rgba(155,93,229,0.5); }
.ps-textarea { width: 100%; background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: 12px; padding: 14px; color: var(--text); font-family: var(--font); font-size: 14px; line-height: 1.6; resize: vertical; }
.ps-textarea:focus { outline: none; border-color: rgba(155,93,229,0.5); }

/* navegação */
.ps-error { color: #FF6B8E; font-size: 13px; margin: 18px 0 0; }
.ps-nav { display: flex; align-items: center; gap: 12px; margin-top: 28px; }
.ps-nav-back { flex-shrink: 0; padding: 14px 20px; border-radius: 100px; border: 1px solid var(--border); background: transparent; color: var(--text-2); font-size: 14px; font-weight: 600; font-family: var(--font); cursor: pointer; transition: all 0.15s; }
.ps-nav-back:hover { border-color: var(--text-3); color: var(--text); }
.ps-nav-next { flex: 1; padding: 15px; border: none; border-radius: 100px; background: linear-gradient(135deg, var(--pink), #C0004D); color: #fff; font-size: 15px; font-weight: 700; font-family: var(--font); cursor: pointer; box-shadow: var(--glow-pink); transition: opacity 0.2s, transform 0.2s; }
.ps-nav-next:disabled { opacity: 0.4; cursor: not-allowed; box-shadow: none; }
.ps-nav-next:not(:disabled):hover { transform: translateY(-1px); }

/* transição entre telas */
.ps-slide-enter-active, .ps-slide-leave-active { transition: opacity 0.22s ease, transform 0.22s ease; }
.ps-slide-enter-from { opacity: 0; transform: translateX(14px); }
.ps-slide-leave-to { opacity: 0; transform: translateX(-14px); }

/* telas de mensagem */
.ps-submit { display: block; width: 100%; text-align: center; padding: 16px; border: none; border-radius: 100px; background: linear-gradient(135deg, var(--pink), #C0004D); color: #fff; font-size: 16px; font-weight: 700; font-family: var(--font); cursor: pointer; box-shadow: var(--glow-pink); transition: transform 0.2s; text-decoration: none; }
.ps-submit:hover { transform: translateY(-1px); }
.ps-msg { text-align: center; }
.ps-icon { font-size: 42px; margin-bottom: 14px; }
.ps-done-avatar { width: 76px; height: 76px; border-radius: 50%; border: 2px solid rgba(155,93,229,0.45); margin: 0 auto 18px; display: block; object-fit: cover; }
.ps-sign { font-family: var(--mono); font-size: 13px; font-style: italic; color: var(--purple); margin: 18px 0 26px; }
.ps-back { max-width: 280px; margin: 18px auto 0; }
.ps-spinner { width: 34px; height: 34px; border: 3px solid var(--border); border-top-color: var(--pink); border-radius: 50%; margin: 0 auto 16px; animation: ps-spin 0.8s linear infinite; }
@keyframes ps-spin { to { transform: rotate(360deg); } }

@media (max-width: 480px) {
  .ps-card { padding: 26px 20px; }
  .ps-csat-label { font-size: 13px; }
  .ps-star { font-size: 24px; }
}
</style>
