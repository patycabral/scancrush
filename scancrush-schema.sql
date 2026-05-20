-- ================================================================
-- ScanCrush — Supabase Schema  (versão QA-aprovada)
-- Execute no SQL Editor do Supabase
-- ================================================================


-- ── 0. ZERAR TUDO ───────────────────────────────────────────────
-- Cole este bloco SEPARADO e execute PRIMEIRO.
-- Ordem importa: filhas antes de pai; views antes de tabelas.

DROP VIEW     IF EXISTS customer_token_summary;
DROP VIEW     IF EXISTS customers_full;

DROP TABLE IF EXISTS messages_history  CASCADE;
DROP TABLE IF EXISTS payments          CASCADE;
DROP TABLE IF EXISTS sessions          CASCADE;
DROP TABLE IF EXISTS customers         CASCADE;

DROP INDEX IF EXISTS idx_customers_email;
DROP INDEX IF EXISTS idx_customers_fullname;
DROP INDEX IF EXISTS idx_sessions_token;
DROP INDEX IF EXISTS idx_sessions_order;
DROP INDEX IF EXISTS idx_sessions_active;
DROP INDEX IF EXISTS idx_payments_external;
DROP INDEX IF EXISTS idx_payments_customer;
DROP INDEX IF EXISTS idx_messages_history_session;
DROP INDEX IF EXISTS idx_messages_history_customer;

-- DROP TRIGGER não é necessário: DROP TABLE ... CASCADE já remove triggers.
DROP FUNCTION IF EXISTS update_customer_age() CASCADE;
DROP FUNCTION IF EXISTS cleanup_expired_sessions();

-- Depois cole e execute o restante deste arquivo para recriar tudo.


-- ================================================================
-- TABELA: customers
-- Perfil do usuário — pagantes (via Kiwify) e usuários do plano free.
--
-- Campos preenchidos por fluxo:
--   WF01 (pago via Kiwify): full_name, first_name, email, mobile,
--                            cpf, country, ip
--   WF04 (free):            nenhum — análise free não cria customer
--
-- birth_date e age: preenchidos somente se o fluxo de análise (WF03)
--   incluir nó de UPDATE com os dados do formulário de scan.
--   Atualmente não há esse nó — campos existem para uso futuro.
-- ================================================================

CREATE TABLE IF NOT EXISTS customers (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Nome completo (Customer.full_name via Kiwify).
  full_name  TEXT NOT NULL,

  -- Primeiro nome (Customer.first_name via Kiwify). Personaliza emails.
  first_name TEXT,

  -- E-mail do comprador (Customer.email via Kiwify).
  -- NULL para usuários gratuitos (não há customer record no free flow).
  email      TEXT,

  -- Data de nascimento — coletada pelo formulário de scan.
  -- Atualmente nenhum fluxo n8n a salva automaticamente.
  -- Requer nó de UPDATE em WF03 para ser preenchida.
  birth_date DATE,

  -- Idade calculada pela trigger trg_customer_age ao INSERT.
  -- NULL quando birth_date não foi informado.
  age        INTEGER,

  -- Telefone (Customer.mobile via Kiwify), ex: +5511999999999
  mobile     TEXT,

  -- IP registrado no momento da compra (Customer.ip via Kiwify).
  ip         TEXT,

  -- CPF (Customer.CPF via Kiwify) — armazenar conforme política LGPD.
  cpf        TEXT,

  -- País (Customer.country via Kiwify), ex: "br"
  country    TEXT,

  -- Data do cadastro (= momento do webhook Kiwify)
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Lookup por e-mail (suporte, deduplicação)
CREATE INDEX IF NOT EXISTS idx_customers_email
  ON customers (email)
  WHERE email IS NOT NULL;

-- Lookup por nome (busca no painel de suporte)
CREATE INDEX IF NOT EXISTS idx_customers_fullname
  ON customers (full_name);


-- ================================================================
-- TRIGGER: trg_customer_age
-- Calcula age a partir de birth_date no momento do INSERT.
-- ================================================================

CREATE OR REPLACE FUNCTION update_customer_age()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.birth_date IS NOT NULL THEN
    NEW.age := DATE_PART('year', AGE(now()::DATE, NEW.birth_date))::INTEGER;
  ELSE
    NEW.age := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customer_age
  BEFORE INSERT ON customers
  FOR EACH ROW
  EXECUTE FUNCTION update_customer_age();


-- ================================================================
-- VIEW: customers_full
-- Adiciona age_at_analysis: idade do cliente no momento do cadastro
-- (congelada no histórico, diferente da idade atual).
-- ================================================================

CREATE VIEW customers_full
  WITH (security_invoker = true)
AS
SELECT
  *,
  DATE_PART('year', AGE(created_at::DATE, birth_date))::INTEGER AS age_at_analysis
FROM customers;


-- ================================================================
-- TABELA: sessions
-- Token de acesso para UMA análise paga.
-- Criada por WF01 após pagamento aprovado.
-- Lida por WF02 (validate-token) e atualizada por WF03 (analyze).
--
-- Ciclo de vida — sessão normal:
--   1. WF01 cria a sessão (used=false, expires_at=now()+6h)
--   2. Frontend valida via WF02 → recebe plan e max_images
--   3. Frontend envia prints → WF03 processa análise
--   4. WF03 atualiza: score, result_json, model, tokens_*, used=true
--
-- Ciclo de vida — sessão upsell (is_upsell=true):
--   1. Usuário clica no botão upsell → frontend chama /api/mark-upsell-intent
--      → marca upsell_intent=true na sessão original
--   2. Usuário compra no Kiwify → WF01 detecta produto upsell
--   3. WF01 busca sessão original por email + upsell_intent=true
--   4. WF01 cria sessão upsell (is_upsell=true, upsell_tier, parent_session_id)
--   5. Email enviado com novo token upsell
--   6. WF03 ao receber token upsell: busca result_json da sessão pai,
--      retorna o tier mais profundo sem rodar OCR nem IA
--   7. Sessão pai: upsell_completed=true
--
-- Campos preenchidos na criação (WF01):
--   order_id, customer_id, user_name, plan, is_full, used, expires_at
--   is_upsell, upsell_tier, parent_session_id (sessões upsell)
--   access_token (gerado automaticamente pelo banco)
--
-- Campos preenchidos na análise (WF03):
--   crush_name, crush_age_range, feelings, behavior_notes
--   score, result_json, model, tokens_input, tokens_output, used
-- ================================================================

CREATE TABLE IF NOT EXISTS sessions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- ID do pedido Kiwify (order_id) que originou esta sessão.
  order_id     TEXT,

  -- FK para customers.id — preenchido na criação pelo WF01.
  customer_id  UUID REFERENCES customers(id),

  -- Token de 64 chars hexadecimais gerado automaticamente pelo banco.
  -- Enviado por email e validado a cada request de análise.
  access_token TEXT UNIQUE NOT NULL DEFAULT encode(gen_random_bytes(32), 'hex'),

  -- true quando a análise (ou entrega do upsell) já foi realizada.
  used         BOOLEAN NOT NULL DEFAULT false,

  -- Expiração automática: now() + 6 horas.
  expires_at   TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '6 hours',

  -- Nome do comprador (Customer.first_name via Kiwify).
  user_name    TEXT,

  -- ── Contexto da análise (preenchido quando o usuário envia o formulário)
  crush_name      TEXT,
  crush_age_range TEXT,
  feelings        TEXT,
  behavior_notes  TEXT,

  -- Plano contratado: basic | plus | full
  -- basic = 5 imgs | plus = 10 imgs | full = 20 imgs
  -- Sessões upsell também têm plan (herdado do produto upsell comprado).
  plan         TEXT NOT NULL CHECK (plan IN ('basic', 'plus', 'full')),

  -- true quando o cliente adquiriu o ScanCrush Full (order bump).
  -- Impede exibição de upsell no frontend quando já comprado.
  is_full      BOOLEAN NOT NULL DEFAULT false,

  -- ── Upsell ──────────────────────────────────────────────────────
  -- true = esta sessão é um upsell (não roda nova análise).
  -- WF03 detecta isso e entrega o tier mais profundo da sessão pai.
  is_upsell         BOOLEAN NOT NULL DEFAULT false,

  -- Qual tier de aprofundamento foi comprado neste upsell.
  -- upsell_free → 'basic' | upsell_basic → 'plus' | upsell_revealed → 'full'
  -- NULL em sessões normais (não upsell).
  upsell_tier       TEXT CHECK (upsell_tier IN ('basic', 'plus', 'full')),

  -- FK para a sessão original cujo result_json será reutilizado.
  -- NULL em sessões normais.
  parent_session_id UUID REFERENCES sessions(id),

  -- Marcado pelo frontend quando o usuário clica no botão de upsell.
  -- WF01 usa esse flag para identificar qual sessão vincular à compra.
  upsell_intent     BOOLEAN NOT NULL DEFAULT false,

  -- Quando o botão foi clicado. Usado para o reset automático após 7 dias.
  upsell_intent_at  TIMESTAMPTZ,

  -- true quando o upsell foi pago e entregue com sucesso.
  -- Setado pelo WF03 ao retornar o tier mais profundo.
  upsell_completed  BOOLEAN NOT NULL DEFAULT false,

  -- ── Tokens do Analista Emocional (etapa de análise, salvo pelo WF03) ─
  -- Estes são os tokens usados pela chamada principal ao Claude/GPT
  -- (nó "Analista Emocional"). Tokens de OCR ficam em messages_history.
  tokens_input   INTEGER DEFAULT 0,
  tokens_output  INTEGER DEFAULT 0,
  tokens_total   INTEGER GENERATED ALWAYS AS (
                   COALESCE(tokens_input,0) + COALESCE(tokens_output,0)
                 ) STORED,

  -- Modelo de IA usado na análise principal (ex: "claude-opus-4-7").
  -- NULL na criação (WF01); preenchido ao concluir a análise (WF03).
  model        TEXT,

  -- Score de interesse (0–100) retornado pela IA. NULL até a análise.
  score        INTEGER,

  -- Resultado completo da IA em JSON. NULL até a análise.
  -- Preenchido pelo WF03 junto com used=true.
  result_json  TEXT,

  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sessions_token
  ON sessions (access_token);

CREATE INDEX IF NOT EXISTS idx_sessions_order
  ON sessions (order_id);

-- Só sessões ainda não consumidas (consulta mais frequente)
CREATE INDEX IF NOT EXISTS idx_sessions_active
  ON sessions (expires_at)
  WHERE used = false;

-- Busca de intenção de upsell por customer (usada pelo WF01 ao receber compra upsell)
CREATE INDEX IF NOT EXISTS idx_sessions_upsell_intent
  ON sessions (customer_id, upsell_intent_at DESC)
  WHERE upsell_intent = true AND upsell_completed = false;


-- ================================================================
-- TABELA: payments
-- Registro completo de cada pagamento recebido via webhook Kiwify.
-- Garante idempotência: mesmo order_id não gera duplicata.
--
-- Campos preenchidos pelo WF01 "Registrar Pagamento":
--   provider, customer_id, session_id, plan, product_id, product_name,
--   amount_cents, currency, kiwify_fee_cents, payment_method, card_type,
--   installments, status, webhook_event_type, estimated_deposit_date,
--   approved_at, max_prints, order_id, order_bump
-- ================================================================

CREATE TABLE IF NOT EXISTS payments (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Plataforma de pagamento. Atualmente só 'kiwify'.
  provider     TEXT NOT NULL CHECK (provider IN ('kiwify', 'stripe')),

  -- ID do pedido Kiwify (order_id). UNIQUE = idempotência garantida.
  order_id     TEXT UNIQUE,

  -- FK para sessions.id criada para este pagamento.
  session_id   UUID REFERENCES sessions(id),

  -- FK para customers.id registrado nesta compra.
  customer_id  UUID REFERENCES customers(id),

  -- Plano contratado: basic | plus | full
  plan         TEXT NOT NULL CHECK (plan IN ('basic', 'plus', 'full')),

  -- ID do produto no Kiwify (Product.product_id).
  -- Usado para mapear produto → plano após BUG-01 ser corrigido.
  product_id   TEXT,

  -- Nome do produto (Product.product_name) ou da oferta
  -- (Product.product_offer_name) — salvo como informação legível.
  product_name TEXT,

  -- true quando o cliente comprou o order bump (upgrade full).
  order_bump   BOOLEAN,

  -- Limite de imagens para este pagamento.
  -- basic=5 | plus=10 | full=20
  max_prints   INTEGER NOT NULL CHECK (max_prints IN (5, 10, 20)),

  -- Valor pago, em centavos (Commissions.charge_amount).
  -- Ex: 2990 = R$29,90
  amount_cents INTEGER,

  -- Moeda (Commissions.currency). Normalmente "BRL".
  currency     TEXT DEFAULT 'BRL',

  -- Taxa Kiwify, em centavos (Commissions.kiwify_fee).
  kiwify_fee_cents INTEGER,

  -- Método: credit_card | pix | boleto
  payment_method TEXT,

  -- Bandeira do cartão: visa | mastercard | elo | etc.
  card_type    TEXT,

  -- Número de parcelas (1 = à vista).
  installments INTEGER DEFAULT 1,

  -- Status do pagamento: approved | refunded | cancelled
  status       TEXT NOT NULL DEFAULT 'approved',

  -- Tipo do evento Kiwify que disparou este registro.
  -- Ex: "order_approved", "order_refunded"
  webhook_event_type TEXT,

  -- Data estimada de depósito (Commissions.estimated_deposit_date).
  estimated_deposit_date TIMESTAMPTZ,

  -- Data/hora de aprovação do pagamento (approved_date do payload).
  approved_at  TIMESTAMPTZ,

  -- Quando este registro foi inserido (≈ momento do webhook recebido)
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_payments_external
  ON payments (provider, customer_id);

CREATE INDEX IF NOT EXISTS idx_payments_customer
  ON payments (customer_id);


-- ================================================================
-- TABELA: messages_history
-- Histórico de mensagens extraídas por OCR por imagem.
-- Um registro por imagem processada no loop de OCR (WF03).
-- Tokens aqui = tokens gastos no OCR (GPT-4.1-mini vision).
-- Tokens da análise principal ficam em sessions.tokens_*.
-- ================================================================

CREATE TABLE IF NOT EXISTS messages_history (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Sessão que originou esta extração.
  session_id    UUID NOT NULL REFERENCES sessions(id),

  -- customer_id denormalizado para queries sem join extra.
  customer_id   UUID REFERENCES customers(id),

  -- Mensagens extraídas como JSON string.
  -- Formato: [{ "author": "user|crush", "side": "left|right",
  --             "text": "...", "timestamp": "HH:MM|null" }]
  messages_json TEXT NOT NULL,

  -- ── Tokens do OCR (etapa de extração de texto por imagem) ────────
  tokens_input  INTEGER DEFAULT 0,
  tokens_output INTEGER DEFAULT 0,
  tokens_total  INTEGER GENERATED ALWAYS AS (
                  COALESCE(tokens_input,0) + COALESCE(tokens_output,0)
                ) STORED,

  -- Modelo de IA usado no OCR (ex: "gpt-4.1-mini").
  model         TEXT NOT NULL,

  -- Total de mensagens extraídas desta imagem.
  messages_count INTEGER DEFAULT 0,

  -- Índice do print (1 para primeira imagem, 2 para segunda, etc.)
  print_count    INTEGER DEFAULT 0,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_messages_history_session
  ON messages_history (session_id);

CREATE INDEX IF NOT EXISTS idx_messages_history_customer
  ON messages_history (customer_id);


-- ================================================================
-- VIEW: customer_token_summary
-- Agrega consumo de tokens por cliente separando duas etapas:
--   ocr_*      → tokens do loop de OCR         (messages_history)
--   analysis_* → tokens do Analista Emocional  (sessions)
--   total_*    → soma das duas etapas
-- ================================================================

CREATE VIEW customer_token_summary
  WITH (security_invoker = true)
AS
SELECT
  c.id                                              AS customer_id,
  c.full_name,
  c.email,

  -- Plano mais recente (última compra registrada)
  (SELECT p.plan FROM payments p
   WHERE p.customer_id = c.id
   ORDER BY p.created_at DESC LIMIT 1)              AS latest_plan,

  -- ── Tokens de OCR (messages_history) ────────────────────────
  COALESCE(SUM(mh.tokens_input),  0)::INTEGER       AS ocr_tokens_input,
  COALESCE(SUM(mh.tokens_output), 0)::INTEGER       AS ocr_tokens_output,
  COALESCE(SUM(mh.tokens_total),  0)::INTEGER       AS ocr_tokens_total,

  -- ── Tokens do Analista Emocional (sessions) ──────────────────
  COALESCE(SUM(s.tokens_input),  0)::INTEGER        AS analysis_tokens_input,
  COALESCE(SUM(s.tokens_output), 0)::INTEGER        AS analysis_tokens_output,
  COALESCE(SUM(s.tokens_total),  0)::INTEGER        AS analysis_tokens_total,

  -- ── Totais combinados ────────────────────────────────────────
  (COALESCE(SUM(mh.tokens_input),  0) +
   COALESCE(SUM(s.tokens_input),   0))::INTEGER     AS total_tokens_input,
  (COALESCE(SUM(mh.tokens_output), 0) +
   COALESCE(SUM(s.tokens_output),  0))::INTEGER     AS total_tokens_output,
  (COALESCE(SUM(mh.tokens_total),  0) +
   COALESCE(SUM(s.tokens_total),   0))::INTEGER     AS total_tokens,

  -- ── Contadores de uso ────────────────────────────────────────
  COUNT(DISTINCT mh.id)::INTEGER                    AS images_processed,
  COUNT(DISTINCT CASE WHEN s.used = true
                      THEN s.id END)::INTEGER       AS analyses_completed,
  MAX(CASE WHEN s.used = true THEN s.created_at END) AS last_analysis_at

FROM customers c
LEFT JOIN sessions         s  ON s.customer_id  = c.id
LEFT JOIN messages_history mh ON mh.customer_id = c.id
GROUP BY c.id, c.full_name, c.email;


-- ================================================================
-- FUNÇÃO: cleanup_expired_upsell_intents
-- Reseta upsell_intent=false em sessões onde o usuário clicou no
-- botão de upsell mas não completou o pagamento em 7 dias.
-- Execute via pg_cron diariamente ou no WF01 ao detectar upsell.
-- ================================================================

CREATE OR REPLACE FUNCTION cleanup_expired_upsell_intents()
RETURNS INTEGER AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE sessions
  SET upsell_intent    = false,
      upsell_intent_at = NULL
  WHERE upsell_intent    = true
    AND upsell_completed = false
    AND upsell_intent_at < now() - INTERVAL '7 days';
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$ LANGUAGE plpgsql;


-- ================================================================
-- FUNÇÃO: cleanup_expired_sessions
-- Remove sessões expiradas e não usadas.
-- Execute via pg_cron ou manualmente:
--   SELECT cleanup_expired_sessions();
-- ================================================================

CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM sessions
  WHERE used = false
    AND expires_at < now() - INTERVAL '24 hours';
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;


-- ================================================================
-- SEGURANÇA: Row Level Security (RLS)
-- Bloqueia acesso via anon key (frontend direto).
-- n8n usa service_role key → bypassa RLS automaticamente.
-- ================================================================

ALTER TABLE customers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions          ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments          ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages_history  ENABLE ROW LEVEL SECURITY;

-- Remove policies antigas antes de criar
DROP POLICY IF EXISTS "deny_all_customers"           ON customers;
DROP POLICY IF EXISTS "deny_all_sessions"            ON sessions;
DROP POLICY IF EXISTS "deny_all_payments"            ON payments;
DROP POLICY IF EXISTS "deny_all_messages_history"    ON messages_history;
DROP POLICY IF EXISTS "allow_insert_customers"       ON customers;
DROP POLICY IF EXISTS "allow_insert_sessions"        ON sessions;
DROP POLICY IF EXISTS "allow_insert_payments"        ON payments;
DROP POLICY IF EXISTS "allow_insert_messages_history" ON messages_history;

-- Bloquear tudo para anon (todo acesso real é via service_role no n8n)
CREATE POLICY "deny_all_customers"        ON customers        FOR ALL USING (false);
CREATE POLICY "deny_all_sessions"         ON sessions         FOR ALL USING (false);
CREATE POLICY "deny_all_payments"         ON payments         FOR ALL USING (false);
CREATE POLICY "deny_all_messages_history" ON messages_history FOR ALL USING (false);


-- ================================================================
-- REALTIME
-- Habilita Supabase Realtime para todas as tabelas.
-- Views não suportam Realtime — subscreva diretamente nas tabelas.
-- ================================================================

ALTER PUBLICATION supabase_realtime ADD TABLE
  customers,
  sessions,
  payments,
  messages_history;
