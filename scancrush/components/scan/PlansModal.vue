<script setup lang="ts">
const { isModalOpen, closeModal } = usePlans()
const { t } = useAppI18n()

// Fechar ao pressionar ESC
onMounted(() => {
  const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') closeModal() }
  window.addEventListener('keydown', handler)
  onUnmounted(() => window.removeEventListener('keydown', handler))
})

const plans = computed(() => [
  {
    key: 'basic',
    name: t.value.pricing.plan1_name,
    price: t.value.pricing.plan1_price,
    desc: t.value.pricing.plan1_desc,
    items: [
      t.value.pricing.plan1_item1,
      t.value.pricing.plan1_item2,
      t.value.pricing.plan1_item3,
      t.value.pricing.plan1_item4,
    ],
    cta: t.value.pricing.plan1_cta,
    featured: false,
  },
  {
    key: 'revealed',
    name: t.value.pricing.plan2_name,
    price: t.value.pricing.plan2_price,
    hook: t.value.pricing.plan2_hook,
    desc: t.value.pricing.plan2_desc,
    items: [
      t.value.pricing.plan2_item1,
      t.value.pricing.plan2_item2,
      t.value.pricing.plan2_item3,
      t.value.pricing.plan2_item4,
    ],
    cta: t.value.pricing.plan2_cta,
    featured: true,
  },
  {
    key: 'xray',
    name: t.value.pricing.plan3_name,
    price: t.value.pricing.plan3_price,
    desc: t.value.pricing.plan3_desc,
    items: [
      t.value.pricing.plan3_item1,
      t.value.pricing.plan3_item2,
      t.value.pricing.plan3_item3,
      t.value.pricing.plan3_item4,
    ],
    cta: t.value.pricing.plan3_cta,
    featured: false,
  },
])

function selectPlan(planKey: string) {
  // TODO: redirecionar para checkout externo (Kiwify/Stripe)
  // window.location.href = `https://pay.kiwify.com.br/xxx?plan=${planKey}`
  console.log('Plano selecionado:', planKey)
  closeModal()
}
</script>

<template>
  <Teleport to="body">
    <Transition name="modal">
      <div
        v-if="isModalOpen"
        class="fixed inset-0 z-[1000] flex items-center justify-center p-4"
        style="background: rgba(7,7,13,0.88); backdrop-filter: blur(14px);"
        @click.self="closeModal"
      >
        <div class="w-full rounded-2xl p-8 relative" style="max-width: clamp(520px, 68vw, 960px); background: #0D0D1A; border: 1px solid rgba(255,255,255,0.08);">
          <!-- Fechar -->
          <button
            @click="closeModal"
            class="absolute top-4 right-4 w-8 h-8 flex items-center justify-center rounded-full text-brand-text-3 hover:text-brand-text hover:bg-white/5 transition-all text-lg"
          >
            ✕
          </button>

          <!-- Header -->
          <div class="text-center mb-8">
            <span class="section-tag">{{ t.pricing.tag }}</span>
            <h2 class="text-2xl font-extrabold tracking-tight mb-1">
              {{ t.pricing.title }}
              <span class="text-pink">{{ t.pricing.title_accent }}</span>
            </h2>
            <p class="text-sm text-brand-text-2">Acesso imediato após o pagamento. Uso único.</p>
          </div>

          <!-- Planos -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div
              v-for="plan in plans"
              :key="plan.key"
              class="relative rounded-2xl p-6 flex flex-col gap-4 transition-all duration-200 hover:-translate-y-0.5"
              :class="plan.featured
                ? 'border-2'
                : 'border'"
              :style="plan.featured
                ? 'background: rgba(155,93,229,0.08); border-color: rgba(155,93,229,0.4);'
                : 'background: rgba(255,255,255,0.03); border-color: rgba(255,255,255,0.08);'"
            >
              <!-- Gradiente topo no plano featured -->
              <div
                v-if="plan.featured"
                class="absolute top-0 left-0 right-0 h-0.5 rounded-t-2xl"
                style="background: linear-gradient(90deg, transparent, #FF2D6B, #9B5DE5, transparent);"
              />

              <!-- Badge popular -->
              <div v-if="plan.featured" class="flex justify-center">
                <span class="text-xs font-mono uppercase tracking-widest px-3 py-1 rounded-full" style="background: rgba(155,93,229,0.15); color: #9B5DE5;">
                  {{ t.pricing.popular }}
                </span>
              </div>

              <!-- Hook (só no featured) -->
              <p v-if="plan.featured && 'hook' in plan" class="text-xs text-center" style="color: rgba(255,184,0,0.8);">
                {{ (plan as any).hook }}
              </p>

              <!-- Nome + Preço -->
              <div>
                <p class="text-xs font-mono uppercase tracking-widest text-brand-text-3 mb-1">{{ plan.name }}</p>
                <p class="text-3xl font-extrabold tracking-tight">
                  {{ plan.price }}
                </p>
                <p class="text-xs text-brand-text-2 mt-1">{{ plan.desc }}</p>
              </div>

              <!-- Itens -->
              <ul class="flex flex-col gap-2 flex-1">
                <li v-for="item in plan.items" :key="item" class="flex items-start gap-2 text-sm text-brand-text-2">
                  <span class="text-pink text-xs mt-0.5 flex-shrink-0">✦</span>
                  {{ item }}
                </li>
              </ul>

              <!-- CTA -->
              <button
                @click="selectPlan(plan.key)"
                class="w-full py-3 rounded-xl text-sm font-semibold transition-all duration-200"
                :class="plan.featured ? 'btn-primary' : 'btn-outline'"
              >
                {{ plan.cta }}
              </button>
            </div>
          </div>

          <!-- Aviso de segurança -->
          <p class="text-center text-xs text-brand-text-3 mt-6">
            🔒 Pagamento seguro · Acesso imediato · Análise de uso único
          </p>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.25s ease;
}
.modal-enter-active .relative,
.modal-leave-active .relative {
  transition: transform 0.32s cubic-bezier(0.22, 1, 0.36, 1);
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
.modal-enter-from .relative {
  transform: scale(0.92) translateY(12px);
}
</style>
