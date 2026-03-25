<script setup lang="ts">
import type { Lang } from '~/composables/useAppI18n'

const { t, lang, setLang } = useAppI18n()

const langs: { value: Lang; label: string }[] = [
  { value: 'pt', label: 'PT' },
  { value: 'en', label: 'EN' },
  { value: 'es', label: 'ES' },
]
</script>

<template>
  <nav class="sticky top-0 z-50 flex items-center justify-between px-6 py-5 border-b border-white/[0.06] bg-bg/80 backdrop-blur-xl">
    <!-- Logo -->
    <NuxtLink to="/" class="flex items-center gap-2 text-lg font-extrabold tracking-tight no-underline text-brand-text">
      <svg width="20" height="20" viewBox="0 0 28 28" fill="none" class="drop-shadow-[0_0_6px_#FF2D6B]">
        <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
        <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
        <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
      </svg>
      Scan<span class="text-pink">Crush</span>
    </NuxtLink>

    <!-- Links + CTA -->
    <div class="hidden md:flex items-center gap-8">
      <a href="/#how" class="text-sm font-medium text-brand-text-2 hover:text-brand-text transition-colors">
        {{ t.nav.how }}
      </a>
      <a href="/#report" class="text-sm font-medium text-brand-text-2 hover:text-brand-text transition-colors">
        {{ t.nav.report }}
      </a>
      <a href="/#pricing" class="text-sm font-medium text-brand-text-2 hover:text-brand-text transition-colors">
        {{ t.nav.pricing }}
      </a>

      <!-- Seletor de idioma -->
      <div class="flex items-center gap-1">
        <button
          v-for="l in langs"
          :key="l.value"
          @click="setLang(l.value)"
          class="text-xs px-2 py-1 rounded font-mono transition-colors"
          :class="lang === l.value
            ? 'text-pink font-semibold'
            : 'text-brand-text-3 hover:text-brand-text-2'"
        >
          {{ l.label }}
        </button>
      </div>

      <NuxtLink to="/scan" class="btn-primary text-sm">
        {{ t.nav.cta }}
      </NuxtLink>
    </div>

    <!-- Mobile: apenas CTA -->
    <NuxtLink to="/scan" class="md:hidden btn-primary text-sm">
      {{ t.nav.cta }}
    </NuxtLink>
  </nav>
</template>
