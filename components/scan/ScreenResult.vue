<script setup lang="ts">
const { result, reset } = useScan()
const { currentPlan, openModal, LAUNCH_MODE } = usePlans()

const isPaid = computed(() => currentPlan.value !== 'free' || LAUNCH_MODE)

const scoreColor = computed(() => {
  const s = result.value?.score ?? 0
  if (s >= 70) return '#00D68F'
  if (s >= 40) return '#FFB800'
  return '#FF4D4D'
})

const verdict = computed(() => {
  const s = result.value?.score ?? 0
  if (s >= 70) return { label: 'SINAL VERDE', color: '#00D68F' }
  if (s >= 40) return { label: 'ATENÇÃO', color: '#FFB800' }
  return { label: 'SINAL VERMELHO', color: '#FF4D4D' }
})

function handleNewAnalysis() {
  if (currentPlan.value === 'free') {
    openModal()
  } else {
    reset()
  }
}
</script>

<template>
  <div class="flex flex-col items-center gap-6 w-full max-w-[600px] mx-auto py-10 px-6">
    <div v-if="result">
      <!-- Score -->
      <div class="w-full rounded-2xl p-6 text-center mb-2" style="background: linear-gradient(160deg, rgba(22,12,38,0.97), rgba(14,8,28,0.97)); border: 1px solid var(--pink-border);">
        <p class="section-tag">Score de interesse</p>
        <div class="text-7xl font-extrabold tracking-tight mb-2" :style="{ color: scoreColor }">
          {{ result.score }}
        </div>
        <div class="inline-block px-4 py-1 rounded-full text-xs font-mono font-semibold tracking-widest" :style="{ color: verdict.color, background: `${verdict.color}18`, border: `1px solid ${verdict.color}40` }">
          {{ verdict.label }}
        </div>
      </div>

      <!-- Aviso de acesso único -->
      <div class="w-full rounded-xl p-4 text-xs text-center mb-4" style="background: rgba(255,184,0,0.05); border: 1px solid rgba(255,184,0,0.14); color: rgba(255,184,0,0.82);">
        ⚠️ Esta é uma análise de acesso único. Salve o que precisar antes de sair.
      </div>

      <!-- Sinais positivos -->
      <div class="w-full rounded-2xl p-6 mb-3" style="background: rgba(0,214,143,0.05); border: 1px solid rgba(0,214,143,0.15);">
        <p class="text-xs font-mono uppercase tracking-widest mb-3" style="color: #00D68F;">✦ Sinais positivos</p>
        <ul class="flex flex-col gap-2">
          <li v-for="item in result.positivos" :key="item" class="flex items-start gap-2 text-sm text-brand-text-2">
            <span style="color: #00D68F;" class="flex-shrink-0 mt-0.5">+</span>
            {{ item }}
          </li>
        </ul>
      </div>

      <!-- Sinais negativos -->
      <div class="w-full rounded-2xl p-6 mb-3" style="background: rgba(255,77,77,0.05); border: 1px solid rgba(255,77,77,0.15);">
        <p class="text-xs font-mono uppercase tracking-widest mb-3" style="color: #FF4D4D;">✦ Pontos de atenção</p>
        <ul class="flex flex-col gap-2">
          <li v-for="item in result.negativos" :key="item" class="flex items-start gap-2 text-sm text-brand-text-2">
            <span style="color: #FF4D4D;" class="flex-shrink-0 mt-0.5">−</span>
            {{ item }}
          </li>
        </ul>
      </div>

      <!-- Conclusão (desbloqueada) -->
      <div v-if="isPaid" class="w-full rounded-2xl p-6 mb-3" style="background: var(--card); border: 1px solid var(--border);">
        <p class="section-tag">Conclusão</p>
        <p class="text-sm text-brand-text-2 leading-relaxed">{{ result.conclusao }}</p>
      </div>

      <!-- Perfil emocional (desbloqueado) -->
      <div v-if="isPaid && result.perfil" class="w-full rounded-2xl p-6 mb-3" style="background: var(--card); border: 1px solid var(--border);">
        <p class="section-tag">Perfil emocional</p>
        <p class="text-sm text-brand-text-2 leading-relaxed">{{ result.perfil }}</p>
      </div>

      <!-- Padrões (desbloqueados) -->
      <div v-if="isPaid && result.padroes?.length" class="w-full rounded-2xl p-6 mb-4" style="background: var(--card); border: 1px solid var(--border);">
        <p class="section-tag">Padrões identificados</p>
        <ul class="flex flex-col gap-2">
          <li v-for="p in result.padroes" :key="p" class="flex items-start gap-2 text-sm text-brand-text-2">
            <span class="text-pink flex-shrink-0 mt-0.5">✦</span>
            {{ p }}
          </li>
        </ul>
      </div>

      <!-- Bloqueado (free sem LAUNCH_MODE) -->
      <div v-if="!isPaid" class="w-full rounded-2xl p-6 mb-4 text-center" style="background: rgba(155,93,229,0.06); border: 1px solid rgba(155,93,229,0.2);">
        <p class="text-sm font-semibold mb-2">🔒 Relatório completo bloqueado</p>
        <p class="text-xs text-brand-text-2 mb-4">Desbloqueie a conclusão, perfil emocional e padrões de comportamento.</p>
        <button @click="openModal" class="btn-primary">
          Desbloquear análise completa
        </button>
      </div>

      <!-- Nova análise -->
      <button @click="handleNewAnalysis" class="w-full btn-outline">
        {{ currentPlan === 'free' ? 'Fazer upgrade' : 'Nova análise' }}
      </button>
    </div>

    <!-- Estado vazio (não deveria acontecer em fluxo normal) -->
    <div v-else class="text-center text-brand-text-2 py-20">
      <p>Nenhum resultado disponível.</p>
      <button @click="reset" class="btn-outline mt-4">Voltar ao início</button>
    </div>
  </div>
</template>
