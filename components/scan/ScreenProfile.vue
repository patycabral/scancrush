<script setup lang="ts">
const { buildBirthdate, buildPayload, runPreview, runAnalysis } = useScan()
const { LAUNCH_MODE } = usePlans()
const { sessionToken } = useSession()

const emit = defineEmits<{ back: [] }>()

// Campos do formulário
const name       = ref('')
const bDay       = ref('')
const bMonth     = ref('')
const bYear      = ref('')
const observations = ref('')
const selectedTags = ref<string[]>([])
const validationMsg = ref('')

// Tags emocionais — embaralhadas no mount
const TAGS = [
  'confusa', 'ansiosa', 'insegura', 'com medo de perder ele',
  'carente', 'cansada', 'frustrada', 'magoada', 'esperançosa',
  'apegada', 'me sentindo ignorada', 'parecendo que só eu me esforço',
  'gostando dele',
]
const shuffledTags = ref<string[]>([])
onMounted(() => {
  shuffledTags.value = [...TAGS].sort(() => Math.random() - 0.5)
})

// Meses
const months = [
  { value: '01', label: 'Janeiro' }, { value: '02', label: 'Fevereiro' },
  { value: '03', label: 'Março' },   { value: '04', label: 'Abril' },
  { value: '05', label: 'Maio' },    { value: '06', label: 'Junho' },
  { value: '07', label: 'Julho' },   { value: '08', label: 'Agosto' },
  { value: '09', label: 'Setembro' },{ value: '10', label: 'Outubro' },
  { value: '11', label: 'Novembro' },{ value: '12', label: 'Dezembro' },
]

// Dias e anos
const days  = Array.from({ length: 31 }, (_, i) => String(i + 1).padStart(2, '0'))
const maxYear = new Date().getFullYear() - 10
const years = Array.from({ length: maxYear - 1930 + 1 }, (_, i) => String(maxYear - i))

// Erros por campo
const errors = reactive({ name: false, date: false, tags: false })

function toggleTag(tag: string) {
  const idx = selectedTags.value.indexOf(tag)
  if (idx === -1) selectedTags.value.push(tag)
  else selectedTags.value.splice(idx, 1)
  errors.tags = false
  validationMsg.value = ''
}

function validate(): boolean {
  const missing: string[] = []
  errors.name = !name.value.trim()
  errors.date = !bDay.value || !bMonth.value || !bYear.value
  errors.tags = selectedTags.value.length === 0

  if (errors.name)  missing.push('seu <strong>nome</strong>')
  if (errors.date)  missing.push('sua <strong>data de nascimento</strong> completa')
  if (errors.tags)  missing.push('pelo menos um <strong>sentimento</strong>')

  if (missing.length === 0) return true

  const last = missing.pop()!
  validationMsg.value = missing.length > 0
    ? `⚠️ Preencha ${missing.join(', ')} e ${last} para continuar.`
    : `⚠️ Preencha ${last} para continuar.`
  return false
}

async function submit() {
  if (!validate()) return

  const birthdate = buildBirthdate(bDay.value, bMonth.value, bYear.value)
  const payload   = buildPayload(name.value.trim(), birthdate, observations.value.trim(), selectedTags.value)

  // Com paywall ativo e token presente → análise completa; senão → preview
  if (!LAUNCH_MODE && sessionToken.value) {
    await runAnalysis(payload)
  } else {
    await runPreview(payload)
  }
}
</script>

<template>
  <div class="flex flex-col items-center gap-6 w-full max-w-[600px] mx-auto py-10 px-6">
    <!-- Título -->
    <div class="text-center">
      <h1 class="text-2xl font-extrabold tracking-tight mb-2">Conte um pouco mais</h1>
      <p class="text-sm text-brand-text-2">Vamos personalizar a análise para o seu perfil</p>
    </div>

    <div class="w-full h-px bg-white/[0.06]" />

    <!-- Nome + Data -->
    <div class="w-full grid grid-cols-1 md:grid-cols-2 gap-4">
      <!-- Nome -->
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-mono uppercase tracking-widest text-brand-text-3">Seu nome</label>
        <input
          v-model="name"
          type="text"
          placeholder="Como você se chama?"
          class="input"
          :class="{ 'input-error': errors.name }"
          autocomplete="given-name"
          @input="errors.name = false; validationMsg = ''"
        />
      </div>

      <!-- Data de nascimento -->
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-mono uppercase tracking-widest text-brand-text-3">Sua data de nascimento</label>
        <div class="grid gap-1.5" style="grid-template-columns: 1fr 1.1fr 1.5fr;">
          <select
            v-model="bDay"
            class="input text-sm"
            :class="{ 'input-error': errors.date && !bDay }"
            @change="errors.date = false; validationMsg = ''"
          >
            <option value="">Dia</option>
            <option v-for="d in days" :key="d" :value="d">{{ d }}</option>
          </select>
          <select
            v-model="bMonth"
            class="input text-sm"
            :class="{ 'input-error': errors.date && !bMonth }"
            @change="errors.date = false; validationMsg = ''"
          >
            <option value="">Mês</option>
            <option v-for="m in months" :key="m.value" :value="m.value">{{ m.label }}</option>
          </select>
          <select
            v-model="bYear"
            class="input text-sm"
            :class="{ 'input-error': errors.date && !bYear }"
            @change="errors.date = false; validationMsg = ''"
          >
            <option value="">Ano</option>
            <option v-for="y in years" :key="y" :value="y">{{ y }}</option>
          </select>
        </div>
      </div>
    </div>

    <div class="w-full h-px bg-white/[0.06]" />

    <!-- Observações -->
    <div class="w-full flex flex-col gap-2">
      <label class="text-sm font-medium text-brand-text-2">O que você percebeu no comportamento dele?</label>
      <textarea
        v-model="observations"
        rows="4"
        placeholder="Ex: ele demora pra responder, parece distante, some às vezes..."
        class="input resize-none"
      />
    </div>

    <!-- Tags emocionais -->
    <div class="w-full flex flex-col gap-3">
      <label class="text-xs font-mono uppercase tracking-widest text-brand-text-3">
        Como você tem se sentido nessa situação?
      </label>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="tag in shuffledTags"
          :key="tag"
          @click="toggleTag(tag)"
          class="px-4 py-2 rounded-full text-sm border transition-all duration-150 cursor-pointer select-none"
          :class="selectedTags.includes(tag)
            ? 'border-purple/50 text-brand-text'
            : 'border-white/10 text-brand-text-2 hover:border-purple/30 hover:text-brand-text'"
          :style="selectedTags.includes(tag) ? 'background: var(--purple-dim);' : ''"
        >
          {{ tag }}
        </button>
      </div>
    </div>

    <!-- Mensagem de validação -->
    <div
      v-if="validationMsg"
      class="w-full rounded-xl p-4 text-sm"
      style="background: rgba(255,77,77,0.06); border: 1px solid rgba(255,77,77,0.2); color: #ff9090;"
      v-html="validationMsg"
    />

    <!-- Ações -->
    <div class="w-full flex gap-3">
      <button
        @click="emit('back')"
        class="btn-outline flex-shrink-0"
      >
        ← Voltar
      </button>
      <button @click="submit" class="btn-primary flex-1">
        Gerar análise →
      </button>
    </div>
  </div>
</template>
