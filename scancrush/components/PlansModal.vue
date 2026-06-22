<script setup lang="ts">
// Modal de planos compartilhado (padrão "print 9" — o mesmo do /scan).
// Uso: <PlansModal ref="plansModal" /> e abrir com plansModal.value?.open()
const CHECKOUT_URLS = {
  basico:   'https://go.perfectpay.com.br/PPU38CQDB0D',
  revealed: 'https://go.perfectpay.com.br/PPU38CQC51R',
  raiox:    'https://go.perfectpay.com.br/PPU38CQC51K',
}

const isOpen = ref(false)

function open() {
  isOpen.value = true
  if (import.meta.client) document.body.style.overflow = 'hidden'
}
function close() {
  isOpen.value = false
  if (import.meta.client) document.body.style.overflow = ''
}
function goToCheckout(plan: 'basico' | 'revealed' | 'raiox') {
  if (import.meta.client) window.location.href = CHECKOUT_URLS[plan]
}
function handleOverlayClick(e: MouseEvent) {
  if ((e.target as HTMLElement).classList.contains('modal-overlay')) close()
}
function onKeydown(e: KeyboardEvent) { if (e.key === 'Escape') close() }

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => {
  window.removeEventListener('keydown', onKeydown)
  if (import.meta.client) document.body.style.overflow = ''
})

defineExpose({ open, close })
</script>

<template>
<div class="modal-overlay" :class="{ open: isOpen }" @click="handleOverlayClick($event)">
  <div class="modal-card">

    <button class="modal-close" @click="close()" aria-label="Fechar">×</button>

    <p class="modal-eyebrow">// Acesse a análise</p>
    <h2 class="modal-title">Escolha o quanto <span>você quer enxergar.</span></h2>

    <div class="modal-plans">

      <!-- Plan: Primeiras Impressões -->
      <div class="plan-card">
        <div class="plan-name">Primeiras Impressões</div>
        <div class="plan-price">
          <span class="curr">R$</span>6<span class="cents">,90</span>
        </div>
        <p class="plan-period">pagamento único</p>
        <p class="plan-desc">A primeira leitura da conversa, por menos que um café.</p>
        <ul class="plan-items">
          <li class="plan-item">1 print analisado</li>
          <li class="plan-item">Score de Interesse</li>
          <li class="plan-item">Visão geral da conversa</li>
          <li class="plan-item">1 sinal positivo + 1 de atenção</li>
          <li class="plan-item">Conclusão inicial</li>
        </ul>
        <button class="btn-plan" @click="goToCheckout('basico')">Analisar agora</button>
      </div>

      <!-- Plan: Sinais Revelados (FEATURED) -->
      <div class="plan-card featured">
        <div class="plan-badge">Mais escolhido</div>
        <div class="plan-name">Sinais Revelados</div>
        <div class="plan-price">
          <span class="curr">R$</span>19<span class="cents">,90</span>
        </div>
        <p class="plan-period">pagamento único</p>
        <p class="plan-desc">Descubra o que realmente está escondido nas mensagens.</p>
        <ul class="plan-items">
          <li class="plan-item">Até 4 prints analisados</li>
          <li class="plan-item">Score de Interesse</li>
          <li class="plan-item">Análise completa da conversa</li>
          <li class="plan-item">Sinais positivos e negativos</li>
          <li class="plan-item">Trechos importantes destacados</li>
          <li class="plan-item">Interpretação da intenção da conversa</li>
          <li class="plan-item">Conclusão aprofundada</li>
        </ul>
        <button class="btn-plan primary" @click="goToCheckout('revealed')">Desbloquear análise completa</button>
      </div>

      <!-- Plan: Raio-X do Crush -->
      <div class="plan-card">
        <div class="plan-name">Raio-X do Crush</div>
        <div class="plan-price">
          <span class="curr">R$</span>44<span class="cents">,90</span>
        </div>
        <p class="plan-period">pagamento único</p>
        <p class="plan-desc">Para conversas mais longas e sinais mais difíceis de entender.</p>
        <ul class="plan-items">
          <li class="plan-item plan-item-includes">✓ Tudo do plano Sinais Revelados</li>
          <li class="plan-item">Até 10 prints analisados</li>
          <li class="plan-item">Identificação de padrões repetitivos</li>
          <li class="plan-item">Contradições emocionais</li>
          <li class="plan-item">Análise do nível de reciprocidade</li>
          <li class="plan-item">Perfil comportamental da conversa</li>
          <li class="plan-item">Conclusão mais detalhada</li>
        </ul>
        <button class="btn-plan" @click="goToCheckout('raiox')">Fazer análise avançada</button>
      </div>

    </div>

    <div class="modal-divider"></div>
    <p class="modal-guarantee">Pagamento seguro · acesso imediato · uso único</p>

  </div>
</div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(7,7,13,0.88);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.25s ease;
}
.modal-overlay.open {
  opacity: 1;
  pointer-events: all;
}
.modal-card {
  background: linear-gradient(160deg, #0F0F1E, #0A0A14);
  border: 1px solid rgba(255,45,107,0.22);
  border-radius: 24px;
  padding: 36px 28px 32px;
  width: 100%;
  max-width: clamp(520px, 92vw, 1040px);
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  box-shadow:
    0 0 80px rgba(255,45,107,0.1),
    0 40px 80px rgba(0,0,0,0.6);
  transform: scale(0.92) translateY(12px);
  transition: transform 0.32s cubic-bezier(0.22, 1, 0.36, 1);
}
.modal-card::-webkit-scrollbar { width: 4px; }
.modal-card::-webkit-scrollbar-track { background: transparent; }
.modal-card::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.08); border-radius: 4px; }
.modal-overlay.open .modal-card {
  transform: scale(1) translateY(0);
}

/* Close button */
.modal-close {
  position: absolute;
  top: 16px; right: 16px;
  width: 34px; height: 34px;
  border-radius: 50%;
  background: rgba(255,255,255,0.05);
  border: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: var(--text-2);
  font-size: 20px;
  line-height: 1;
  transition: all 0.2s;
  font-family: var(--font);
}
.modal-close:hover { background: rgba(255,255,255,0.1); color: var(--text); }

/* Modal header */
.modal-eyebrow {
  font-size: 10px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: var(--pink);
  margin-bottom: 12px;
}
.modal-title span { color: var(--pink); }
.modal-title {
  font-size: clamp(18px, 4vw, 22px);
  font-weight: 800;
  letter-spacing: -0.6px;
  line-height: 1.2;
  margin-bottom: 8px;
  padding-right: 36px;
}

/* Plans grid */
.modal-plans {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14px;
  max-width: 1000px;
  margin: 26px auto 0;
}
@media (max-width: 860px) {
  .modal-plans { grid-template-columns: 1fr; }
  .modal-card { padding: 28px 20px 24px; }
}

/* Plan card */
.plan-card {
  background: rgba(255,255,255,0.02);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 20px 16px;
  display: flex;
  flex-direction: column;
  gap: 0;
  position: relative;
  transition: border-color 0.2s;
}
.plan-card.featured {
  border-color: rgba(255,45,107,0.38);
  background: linear-gradient(160deg, rgba(255,45,107,0.08), rgba(17,17,32,0.98));
  box-shadow: 0 0 40px rgba(255,45,107,0.14), inset 0 1px 0 rgba(255,45,107,0.2);
  padding: 26px 18px;
}
.plan-card.featured::before {
  content: '';
  position: absolute;
  top: -1px; left: -1px; right: -1px;
  height: 2px;
  border-radius: 16px 16px 0 0;
  background: linear-gradient(90deg, transparent, var(--pink), var(--purple), transparent);
}

.plan-badge {
  position: absolute;
  top: -11px;
  left: 50%;
  transform: translateX(-50%);
  background: linear-gradient(90deg, var(--pink), #C0004D);
  color: white;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 0.06em;
  padding: 4px 14px;
  border-radius: 100px;
  white-space: nowrap;
  box-shadow: 0 0 16px rgba(255,45,107,0.4);
}

.plan-name {
  font-size: 13px;
  font-weight: 700;
  color: var(--text);
  letter-spacing: -0.2px;
  margin-bottom: 10px;
}
.plan-price {
  font-size: 28px;
  font-weight: 800;
  color: var(--text);
  letter-spacing: -1px;
  line-height: 1;
  margin-bottom: 4px;
  display: flex;
  align-items: flex-start;
  gap: 2px;
}
.plan-price .curr {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-2);
  margin-top: 5px;
}
.plan-price .cents {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-2);
  align-self: flex-end;
  margin-bottom: 2px;
}
.plan-period {
  font-size: 11px;
  color: var(--text-3);
  font-family: var(--mono);
  margin-bottom: 16px;
}

.plan-items {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 7px;
  margin-bottom: 18px;
}
.plan-item {
  font-size: 12px;
  color: var(--text-2);
  font-weight: 300;
  display: flex;
  align-items: flex-start;
  gap: 7px;
  line-height: 1.45;
}
.plan-item::before {
  content: '✦';
  color: var(--pink);
  font-size: 8px;
  margin-top: 2px;
  flex-shrink: 0;
  opacity: 0.7;
}
.plan-card.featured .plan-item { color: var(--text); }
.plan-item-includes {
  color: var(--pink) !important;
  font-size: 11px;
  opacity: 0.8;
  padding-bottom: 4px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  margin-bottom: 2px;
}
.plan-item-includes::before { display: none; }
.plan-desc {
  font-size: 12px;
  color: var(--text-2);
  font-weight: 300;
  font-style: italic;
  line-height: 1.6;
  margin-bottom: 14px;
}

.btn-plan {
  width: 100%;
  padding: 12px;
  border-radius: 100px;
  font-size: 13px;
  font-weight: 700;
  font-family: var(--font);
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(255,255,255,0.05);
  color: var(--text-2);
  cursor: pointer;
  transition: all 0.2s;
  margin-top: auto;
}
.btn-plan:hover { background: rgba(255,255,255,0.1); color: var(--text); }
.btn-plan.primary {
  background: linear-gradient(135deg, var(--pink), #C0004D);
  border: none;
  color: white;
  box-shadow: 0 0 24px rgba(255,45,107,0.4);
}
.btn-plan.primary:hover { transform: translateY(-1px); box-shadow: 0 0 40px rgba(255,45,107,0.6); }

/* Modal divider */
.modal-divider {
  height: 1px;
  background: var(--border);
  margin: 24px 0 16px;
}
.modal-guarantee {
  text-align: center;
  font-size: 12px;
  color: var(--text-3);
  font-family: var(--mono);
}
</style>
