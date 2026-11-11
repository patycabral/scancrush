<script setup lang="ts">
useHead({ title: 'Termos de Uso | ScanCrush' })
</script>

<template>
<nav class="nav">
  <NuxtLink to="/" class="logo">
    <svg width="20" height="20" viewBox="0 0 28 28" fill="none">
      <circle cx="14" cy="14" r="12" stroke="#FF2D6B" stroke-width="1.2" stroke-dasharray="4 2.5" opacity="0.35"/>
      <circle cx="14" cy="14" r="7.5" stroke="#FF2D6B" stroke-width="1.4"/>
      <circle cx="14" cy="14" r="3" fill="#FF2D6B"/>
    </svg>
    Scan<span>Crush</span>
  </NuxtLink>
  <NuxtLink to="/" class="back-link">← Voltar ao início</NuxtLink>
</nav>

<div class="page-wrap">
  <span class="page-tag">// Termos</span>
  <h1>Termos de Uso</h1>
  <p class="page-date">Última atualização: 11 de novembro de 2026</p>

  <div class="notice-box">
    Ao comprar ou usar o ScanCrush, você concorda com estes termos e com a <NuxtLink to="/privacy">Política de Privacidade</NuxtLink>. Leia com calma antes de seguir.
  </div>

  <h2>O que é o ScanCrush</h2>
  <p>O ScanCrush faz uma <strong>leitura dos sinais de uma conversa</strong>, feita por inteligência artificial a partir dos prints que você envia. A análise é <strong>probabilística e interpretativa</strong>: ela olha padrões como reciprocidade, consistência e iniciativa, e só enxerga o que está nos prints.</p>
  <p>Ela não lê mente, não prevê o futuro, não diz o que a outra pessoa sente e não decide por você. Também não é terapia, aconselhamento psicológico nem diagnóstico de nenhum tipo.</p>
  <p>Se você estiver numa situação de violência ou de risco, procure ajuda agora: <strong>Ligue 180</strong> (Central de Atendimento à Mulher), <strong>190</strong> (Polícia) ou <strong>188</strong> (CVV, apoio emocional, 24 horas).</p>

  <h2>Idade mínima</h2>
  <p>O ScanCrush é só para <strong>maiores de 18 anos</strong>. Ao usar o serviço, você declara ter 18 anos ou mais.</p>

  <h2>Uso adequado</h2>
  <p>Ao usar o ScanCrush, você se compromete a:</p>
  <ul>
    <li>Enviar só conversas de que você participa</li>
    <li>Não enviar conversas com pessoas menores de 18 anos</li>
    <li>Não usar a análise para perseguir, controlar, expor ou constranger ninguém</li>
    <li>Não tentar enganar o sistema, por exemplo escondendo instruções nas imagens ou nos campos do formulário</li>
    <li>Não revender o acesso nem a análise</li>
  </ul>

  <h2>Compra e acesso</h2>
  <p>Cada compra dá direito a <strong>1 análise</strong> do plano escolhido, com o número de prints que o plano permite. O pagamento é processado pela Perfect Pay, e a cobrança aparece em nome dela na fatura do cartão.</p>
  <p>Depois da compra, você recebe por e-mail o seu acesso e tem até <strong>30 dias</strong> para gerar a análise. A análise é única: quando ela é gerada, o acesso é marcado como usado.</p>
  <p>Quando a análise fica pronta, o resultado aparece numa página, com a opção de baixar o PDF, e também vai para o seu e-mail, que permanece com você. A página e o PDF valem só enquanto a página estiver aberta. Os prints não ficam guardados.</p>
  <p>Se a análise não for concluída por um problema técnico nosso, ou se as imagens enviadas não forem de uma conversa, o seu acesso continua valendo e você pode enviar os prints de novo.</p>

  <h2>Direito de arrependimento e reembolso</h2>
  <p>Pelo Código de Defesa do Consumidor (art. 49), você pode desistir da compra em até <strong>7 dias</strong> a partir da data do pagamento e receber o valor de volta. Peça pela Perfect Pay ou pelo e-mail <strong>contato@scancrush.com</strong>, informando o e-mail usado na compra.</p>

  <h2>Limites da análise</h2>
  <p>A análise é automática e pode errar, principalmente quando os prints mostram só um pedaço da conversa. Use o relatório como mais um ponto de vista, junto com o que você conhece da sua história. As decisões sobre a sua vida e as suas relações são sempre suas.</p>
  <p>Nós respondemos pela entrega do serviço como descrito nesta página, nos termos do Código de Defesa do Consumidor.</p>

  <h2>Propriedade intelectual</h2>
  <p>A marca, o design, os textos e o código do ScanCrush são nossos. O seu relatório é para o seu uso pessoal, e você pode compartilhar o seu próprio resultado se quiser.</p>

  <h2>Mudanças nestes termos</h2>
  <p>Se estes termos mudarem, a data no topo da página muda junto. A versão que vale para a sua compra é a que estava publicada no dia do pagamento.</p>

  <h2>Lei aplicável</h2>
  <p>Estes termos seguem as leis do Brasil. Qualquer disputa pode ser levada ao foro da cidade onde você mora.</p>

  <h2>Contato</h2>
  <p>Dúvidas, pedidos ou reclamações: <strong>contato@scancrush.com</strong></p>
</div>

<footer>
  <p>
    <NuxtLink to="/">Início</NuxtLink>
    <NuxtLink to="/privacy">Privacidade</NuxtLink>
    <NuxtLink to="/terms">Termos</NuxtLink>
  </p>
  <p style="margin-top:16px">© 2026 ScanCrush. Nem sempre os sinais são óbvios.</p>
</footer>
</template>

<style scoped>
:root {
  --bg: #07070D; --surface: #0D0D1A; --card: #111120;
  --border: rgba(255,255,255,0.06);
  --pink: #FF2D6B; --purple: #9B5DE5;
  --text: #EEEEF8; --text-2: #9090B8; --text-3: #4A4A6A;
  --font: 'Sora', sans-serif; --mono: 'JetBrains Mono', monospace;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body {
  background: var(--bg); color: var(--text);
  font-family: var(--font); font-size: 16px; line-height: 1.7;
  -webkit-font-smoothing: antialiased;
}
body::before {
  content: '';
  position: fixed; inset: 0;
  background: radial-gradient(ellipse 70% 50% at 50% 0%, rgba(255,45,107,0.04) 0%, transparent 70%);
  pointer-events: none; z-index: 0;
}
.nav {
  display: flex; align-items: center; justify-content: space-between;
  padding: 20px 24px; border-bottom: 1px solid var(--border);
  background: rgba(7,7,13,0.8); backdrop-filter: blur(20px);
  position: sticky; top: 0; z-index: 10;
}
.logo {
  display: flex; align-items: center; gap: 8px;
  font-size: 18px; font-weight: 800; letter-spacing: -0.5px;
  text-decoration: none; color: var(--text);
}
.logo svg { filter: drop-shadow(0 0 6px var(--pink)); }
.logo span { color: var(--pink); }
.back-link {
  font-size: 13px; font-weight: 500; color: var(--text-2);
  text-decoration: none; transition: color 0.2s;
}
.back-link:hover { color: var(--text); }
.page-wrap {
  max-width: 680px; margin: 0 auto;
  padding: 56px 24px 80px;
  position: relative; z-index: 1;
}
.page-tag {
  font-family: var(--mono); font-size: 11px;
  text-transform: uppercase; letter-spacing: 0.16em;
  color: var(--pink); margin-bottom: 16px; display: block;
}
h1 {
  font-size: clamp(28px, 5vw, 40px); font-weight: 800;
  letter-spacing: -1.2px; margin-bottom: 8px; line-height: 1.1;
}
.page-date {
  font-size: 12px; font-family: var(--mono);
  color: var(--text-3); margin-bottom: 48px;
}
h2 {
  font-size: 18px; font-weight: 700;
  margin: 40px 0 14px; letter-spacing: -0.3px;
  padding-top: 40px; border-top: 1px solid var(--border);
}
h2:first-of-type { border-top: none; padding-top: 0; margin-top: 0; }
p { font-size: 15px; color: var(--text-2); font-weight: 300; margin-bottom: 16px; line-height: 1.8; }
strong { color: var(--text); font-weight: 600; }
ul { list-style: none; display: flex; flex-direction: column; gap: 10px; margin-bottom: 20px; }
li {
  display: flex; align-items: flex-start; gap: 10px;
  font-size: 14px; color: var(--text-2); font-weight: 300; line-height: 1.65;
}
li::before {
  content: '✦'; color: var(--pink); font-size: 10px;
  margin-top: 4px; flex-shrink: 0;
}
.notice-box {
  background: rgba(255,184,0,0.05);
  border: 1px solid rgba(255,184,0,0.15);
  border-radius: 14px;
  padding: 18px 22px;
  font-size: 14px;
  color: rgba(255,184,0,0.8);
  font-weight: 300;
  line-height: 1.7;
  margin-bottom: 32px;
}
footer {
  border-top: 1px solid var(--border);
  padding: 32px 24px; text-align: center;
  font-size: 12px; color: var(--text-3);
}
.notice-box a { color: var(--pink); text-decoration: underline; }
footer a { color: var(--text-2); text-decoration: none; margin: 0 12px; }
footer a:hover { color: var(--text); }
</style>
