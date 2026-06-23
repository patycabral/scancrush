<script setup lang="ts">
const plansModal = ref()

const navScrolled = ref(false)
function onScroll() { navScrolled.value = window.scrollY > 30 }

const mobileMenuOpen = ref(false)
function toggleMobileMenu() { mobileMenuOpen.value = !mobileMenuOpen.value }
function closeMobileMenu() { mobileMenuOpen.value = false }
onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
})
onUnmounted(() => window.removeEventListener('scroll', onScroll))
</script>

<template>
<nav class="nav" :class="{ scrolled: navScrolled }">
  <div class="container">
    <div class="nav-inner">
      <NuxtLink to="/" class="logo">
        <svg width="26" height="26" viewBox="0 0 28 28" fill="none">
          <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
          <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
          <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
          <line x1="14" y1="2" x2="14" y2="5.5" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="14" y1="22.5" x2="14" y2="26" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="2" y1="14" x2="5.5" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
          <line x1="22.5" y1="14" x2="26" y2="14" stroke="#FF2D6B" stroke-width="1.5" stroke-linecap="round"/>
        </svg>
        <span class="logo-word">Scan<span>Crush</span></span>
      </NuxtLink>

      <ul class="nav-links">
        <li><a href="/#b-how">Como funciona</a></li>
        <li><a href="/#b-report">O relatório</a></li>
        <li><a href="/#b-patty">A Patty</a></li>
        <li><a href="/#b-pricing">Planos</a></li>
        <li><NuxtLink to="/blog">Blog</NuxtLink></li>
      </ul>

      <div class="nav-right">
        <button class="btn-nav" @click="plansModal?.open()">Analisar conversa</button>
      </div>

      <button class="nav-mobile-btn" :class="{ active: mobileMenuOpen }" @click="toggleMobileMenu()" aria-label="Menu">
        <span></span><span></span><span></span>
      </button>
    </div>

    <!-- Menu mobile (dropdown do hamburguer) -->
    <div class="nav-mobile-menu" :class="{ open: mobileMenuOpen }">
      <a href="/#b-how" @click="closeMobileMenu()">Como funciona</a>
      <a href="/#b-report" @click="closeMobileMenu()">O relatório</a>
      <a href="/#b-patty" @click="closeMobileMenu()">A Patty</a>
      <a href="/#b-pricing" @click="closeMobileMenu()">Planos</a>
      <NuxtLink to="/blog" @click="closeMobileMenu()">Blog</NuxtLink>
      <button class="btn-nav" @click="plansModal?.open(); closeMobileMenu()">Analisar conversa</button>
    </div>
  </div>
</nav>

<!-- PLANS MODAL (componente compartilhado, padrão print 9) -->
<PlansModal ref="plansModal" />
</template>

<style scoped>
.grad { background: linear-gradient(135deg,#FF2D6B,#9B5DE5); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
</style>
