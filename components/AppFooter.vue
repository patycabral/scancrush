<script setup lang="ts">
const { t } = useAppI18n()
</script>

<template>
  <footer class="border-t border-white/[0.06] py-10 px-6">
    <div class="max-w-5xl mx-auto">
      <!-- Logo + tagline -->
      <div class="flex flex-col md:flex-row items-center justify-between gap-6 mb-8">
        <NuxtLink to="/" class="flex items-center gap-2 text-base font-extrabold tracking-tight no-underline text-brand-text">
          <svg width="18" height="18" viewBox="0 0 28 28" fill="none" class="drop-shadow-[0_0_6px_#FF2D6B]">
            <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
            <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
            <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
          </svg>
          Scan<span class="text-pink">Crush</span>
        </NuxtLink>
        <p class="text-xs text-brand-text-3">{{ t.footer.tagline }}</p>
      </div>

      <!-- Links -->
      <div class="flex flex-wrap justify-center gap-x-8 gap-y-2 mb-8">
        <a href="/#how" class="text-xs text-brand-text-2 hover:text-brand-text transition-colors">{{ t.footer.how }}</a>
        <a href="/#pricing" class="text-xs text-brand-text-2 hover:text-brand-text transition-colors">{{ t.footer.pricing }}</a>
        <a href="/#faq" class="text-xs text-brand-text-2 hover:text-brand-text transition-colors">{{ t.footer.faq }}</a>
        <NuxtLink to="/privacy" class="text-xs text-brand-text-2 hover:text-brand-text transition-colors">{{ t.footer.privacy }}</NuxtLink>
        <NuxtLink to="/terms" class="text-xs text-brand-text-2 hover:text-brand-text transition-colors">{{ t.footer.terms }}</NuxtLink>
      </div>

      <!-- Copyright -->
      <p class="text-center text-xs text-brand-text-3">{{ t.footer.copy }}</p>
    </div>
  </footer>
</template>
