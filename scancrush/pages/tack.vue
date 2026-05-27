<script setup lang="ts">
useHead({ title: 'ScanCrush — Pagamento confirmado' })
</script>

<template>
  <div class="tack-page">
    <div class="tack-card">

      <div class="tack-icon">✓</div>

      <h1 class="tack-title">Pagamento confirmado.</h1>
      <p class="tack-sub">
        Enviamos o link de acesso ao ScanCrush para o e-mail cadastrado na compra.
      </p>
      <p class="tack-hint">
        Verifique sua caixa de entrada — e também a pasta de spam, caso não encontre.
      </p>

      <div class="tack-divider"></div>

      <p class="tack-support">
        Algum problema? Fale com a gente:<br/>
        <a href="mailto:suporte@scancrush.com">suporte@scancrush.com</a>
      </p>

    </div>
  </div>
</template>

<style scoped>
.tack-page {
  min-height: 100vh;
  background: var(--bg);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.tack-card {
  background: var(--surface);
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 20px;
  padding: 48px 40px;
  max-width: 440px;
  width: 100%;
  text-align: center;
}

.tack-icon {
  width: 56px;
  height: 56px;
  background: rgba(255,45,107,0.12);
  border: 1px solid var(--pink-border);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  color: var(--pink);
  margin: 0 auto 24px;
}

.tack-title {
  font-size: 22px;
  font-weight: 700;
  color: var(--text);
  margin-bottom: 12px;
}

.tack-sub {
  font-size: 14px;
  color: var(--text-2);
  line-height: 1.65;
  margin-bottom: 10px;
}

.tack-hint {
  font-size: 12px;
  color: var(--text-3);
  line-height: 1.6;
  margin-bottom: 0;
}

.tack-divider {
  width: 100%;
  height: 1px;
  background: rgba(255,255,255,0.06);
  margin: 28px 0;
}

.tack-support {
  font-size: 12px;
  color: var(--text-3);
  line-height: 1.7;
}

.tack-support a {
  color: var(--text-2);
  text-decoration: underline;
  text-underline-offset: 3px;
}

@media (max-width: 480px) {
  .tack-card { padding: 36px 24px; }
}
</style>
