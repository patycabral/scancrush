<script setup lang="ts">
const { uploadedFiles, uploadCount, uploadLimit, limitReached, handleFiles, removeFile, removeAllFiles } = useScan()
const { openModal, LAUNCH_MODE } = usePlans()

const emit = defineEmits<{ next: [] }>()

const fileInputRef = ref<HTMLInputElement>()
const isDragging = ref(false)

const canContinue = computed(() => uploadedFiles.value.length > 0)

const uploadPercent = computed(() => {
  if (uploadLimit.value === Infinity) return (uploadCount.value / 5) * 100
  return (uploadCount.value / uploadLimit.value) * 100
})

const counterLabel = computed(() => {
  const limit = uploadLimit.value === Infinity ? '∞' : uploadLimit.value
  const unit = uploadCount.value === 1 ? 'imagem' : 'imagens'
  return `${uploadCount.value} / ${limit} ${unit}`
})

function onDrop(e: DragEvent) {
  isDragging.value = false
  if (e.dataTransfer?.files) handleFiles(e.dataTransfer.files)
}

function onFileInput(e: Event) {
  const input = e.target as HTMLInputElement
  if (input.files) handleFiles(input.files)
  input.value = ''
}

function triggerInput() {
  if (limitReached.value && !LAUNCH_MODE) return
  fileInputRef.value?.click()
}

function getObjectUrl(file: File) {
  return URL.createObjectURL(file)
}
</script>

<template>
  <div class="flex flex-col items-center gap-6 w-full max-w-[600px] mx-auto py-10 px-6">
    <!-- Título -->
    <div class="text-center">
      <h1 class="text-2xl font-extrabold tracking-tight mb-2">Mostre o que aconteceu</h1>
      <p class="text-sm text-brand-text-2">Envie prints da conversa que você quer entender</p>
    </div>

    <!-- Drop Area -->
    <div
      @click="triggerInput"
      @dragover.prevent="isDragging = true"
      @dragleave="isDragging = false"
      @drop.prevent="onDrop"
      class="w-full rounded-2xl border-2 border-dashed p-10 flex flex-col items-center gap-3 cursor-pointer transition-all duration-200"
      :class="isDragging
        ? 'border-pink bg-pink/5'
        : 'border-white/10 hover:border-white/20 hover:bg-white/[0.02]'"
    >
      <div class="w-12 h-12 rounded-full flex items-center justify-center" style="background: rgba(255,45,107,0.1);">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
          <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M17 8l-5-5-5 5M12 3v12" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
      </div>
      <p class="text-sm font-medium text-brand-text-2">
        {{ isDragging ? 'Solte aqui…' : 'Arraste ou clique para enviar' }}
      </p>
      <p class="text-xs text-brand-text-3">PNG, JPG, WEBP · Até {{ uploadLimit === Infinity ? 20 : uploadLimit }} imagens</p>
    </div>

    <input
      ref="fileInputRef"
      type="file"
      accept="image/*"
      multiple
      class="hidden"
      @change="onFileInput"
    />

    <!-- Counter + Previews -->
    <div v-if="uploadCount > 0" class="w-full flex flex-col gap-3">
      <!-- Meta: contador + barra + limpar tudo -->
      <div class="flex items-center gap-3">
        <span class="text-xs font-mono text-brand-text-3">{{ counterLabel }}</span>
        <div class="flex-1 h-1 rounded-full bg-white/5">
          <div
            class="h-1 rounded-full transition-all duration-300"
            :style="{ width: `${Math.min(uploadPercent, 100)}%`, background: 'var(--pink)' }"
          />
        </div>
        <button @click="removeAllFiles" class="text-xs font-mono text-brand-text-3 hover:text-danger transition-colors">
          Remover todas
        </button>
      </div>

      <!-- Thumbnails -->
      <div class="flex flex-wrap gap-2">
        <div
          v-for="(file, idx) in uploadedFiles"
          :key="idx"
          class="relative group"
        >
          <img
            :src="getObjectUrl(file)"
            class="w-16 h-16 object-cover rounded-xl border border-white/10"
            :alt="`Preview ${idx + 1}`"
          />
          <button
            @click="removeFile(idx)"
            class="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full flex items-center justify-center text-xs transition-all opacity-0 group-hover:opacity-100"
            style="background: rgba(10,10,20,0.96); border: 1px solid rgba(255,255,255,0.1);"
            :class="{ 'hover:bg-danger hover:text-white hover:border-danger': true }"
          >
            ×
          </button>
        </div>
      </div>
    </div>

    <!-- Alerta de limite (só com paywall ativo) -->
    <div
      v-if="limitReached && !LAUNCH_MODE"
      class="w-full rounded-xl p-4 text-xs flex flex-col gap-2"
      style="background: rgba(255,184,0,0.05); border: 1px solid rgba(255,184,0,0.15); color: rgba(255,184,0,0.85);"
    >
      <p>⚠️ Você atingiu o limite do seu plano atual.</p>
      <button @click="openModal" class="btn-primary text-xs self-start">
        🔓 Desbloquear análise completa
      </button>
    </div>

    <!-- CTA Continuar -->
    <button
      :disabled="!canContinue"
      @click="emit('next')"
      class="w-full py-4 rounded-xl font-semibold text-sm transition-all duration-200"
      :class="canContinue
        ? 'btn-primary'
        : 'opacity-30 cursor-not-allowed bg-white/5 text-brand-text-3'"
    >
      Continuar →
    </button>
  </div>
</template>
