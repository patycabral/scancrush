-- ================================================================
-- ScanCrush — Supabase Schema  (PerfectPay · v3)
-- Execute no SQL Editor do Supabase
-- ================================================================


-- ── 0. ZERAR TUDO ───────────────────────────────────────────────
-- Cole este bloco SEPARADO e execute PRIMEIRO.
-- Ordem importa: filhas antes de pai; views antes de tabelas.

DROP VIEW     IF EXISTS customer_token_summary;

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

DROP FUNCTION IF EXISTS cleanup_expired_sessions();

-- Depois cole e execute o restante deste arquivo para recriar tudo.


-- ================================================================
-- TABELA: customers
-- Perfil do comprador — criado por WF01 após pagamento via PerfectPay.
-- Usuários do plano free não geram registro em customers.
--
-- Campos preenchidos por WF01 (webhook PerfectPay):
--   full_name, first_name, email, mobile,
--   identification_type, identification_number,
--   country, ip
-- ================================================================

CREATE TABLE IF NOT EXISTS customers (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Nome completo do comprador (via PerfectPay). Obrigatório.
  full_name  TEXT NOT NULL,

  -- Primeiro nome. Usado para personalizar e-mails.
  first_name TEXT,

  -- E-mail do comprador (via PerfectPay).
  email      TEXT,

  -- Telefone do comprador, ex: +5511999999999
  mobile     TEXT,

  -- IP registrado no momento da compra.
  ip         TEXT,

  -- Tipo do documento de identificação (identification-type via PerfectPay).
  -- Ex: "CPF", "CNPJ", "Passport"
  identification_type   TEXT,

  -- Número do documento (identification-number via PerfectPay).
  -- Armazenar conforme política LGPD.
  identification_number TEXT,

  -- País do comprador, ex: "br"
  country    TEXT,

  -- Data do cadastro (= momento do webhook PerfectPay)
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
-- TABELA: sessions
-- Token de acesso para UMA análise paga.
-- Criada por WF01 após pagamento aprovado via PerfectPay.
-- Lida por WF02 (validate-token) e atualizada por WF03 (analyze).
--
-- Ciclo de vida:
--   1. WF01 cria a sessão (used=false, expires_at=now()+30d)
--   2. Frontend valida via WF02 → recebe plan e max_prints
--   3. Frontend envia prints + formulário → WF03 processa análise
--   4. WF03 atualiza: score, result_json, model, tokens_*, used=true
--
-- Campos obrigatórios na criação (WF01):
--   order_id, customer_id, plan
--
-- Campos preenchidos na análise (WF03):
--   user_age_range, crush_age_range, feelings, observations,
--   image_count, score, result_json, model, tokens_*, used=true
-- ================================================================

CREATE TABLE IF NOT EXISTS sessions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- ID do pedido PerfectPay que originou esta sessão. Obrigatório.
  order_id     TEXT NOT NULL,

  -- FK para customers.id. Obrigatório.
  customer_id  UUID NOT NULL REFERENCES customers(id),

  -- Token de 64 chars hexadecimais gerado automaticamente pelo banco.
  -- Enviado por e-mail e validado a cada request de análise.
  access_token TEXT UNIQUE NOT NULL DEFAULT encode(gen_random_bytes(32), 'hex'),

  -- true quando a análise já foi realizada.
  used         BOOLEAN NOT NULL DEFAULT false,

  -- Expiração: 30 dias após a criação da sessão.
  expires_at   TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '30 days',

  -- Nome do comprador (first_name via PerfectPay).
  user_name    TEXT,

  -- ── Contexto da análise (preenchido pelo WF03 com dados do formulário)

  -- Faixa etária do usuário. Ex: "21-25", "26-30", "não informado"
  user_age_range  TEXT,

  -- Faixa etária do crush. Ex: "18-20", "null" (não informado)
  crush_age_range TEXT,

  -- Sentimentos selecionados no formulário. Ex: "ansiosa, curiosa"
  feelings        TEXT,

  -- Observações livres digitadas pelo usuário.
  observations    TEXT,

  -- Quantidade de imagens enviadas para análise.
  image_count     INTEGER,

  -- Plano contratado. Obrigatório.
  -- Ex: "revealed", "raiox"
  -- WF02 usa este campo para determinar max_prints.
  plan         TEXT NOT NULL,

  -- ID do plano na PerfectPay (plan-id), ex: "PPLQQPF70".
  plan_id      TEXT,

  -- Nome do produto na PerfectPay (product-name), ex: "ScanCrush".
  product_name TEXT,

  -- ── Tokens do Analista Emocional (etapa de análise, salvo pelo WF03) ─
  tokens_input   INTEGER DEFAULT 0,
  tokens_output  INTEGER DEFAULT 0,
  tokens_total   INTEGER GENERATED ALWAYS AS (
                   COALESCE(tokens_input,0) + COALESCE(tokens_output,0)
                 ) STORED,

  -- Modelo de IA usado na análise principal (ex: "claude-opus-4-7").
  model        TEXT,

  -- Score de interesse (0–100) retornado pela IA. NULL até a análise.
  score        INTEGER,

  -- Resultado completo da IA em JSON. NULL até a análise.
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


-- ================================================================
-- TABELA: payments
-- Registro completo de cada pagamento recebido via webhook PerfectPay.
-- Garante idempotência: mesmo order_id não gera duplicata.
--
-- Mapeamento webhook PerfectPay → coluna:
--   status-venda          → status
--   detalhe-status-venda  → status_detail
--   data-pedido           → order_date
--   data-aprovacao        → approved_at
--   product-id            → product_id
--   product-name          → product_name
--   plan-id               → plan_id
--   plan-name             → plan_name
--   valor-venda           → amount            (NUMERIC, ex: 44.90)
--   payment-method        → payment_method
--   card-type             → card_type
--   numero-de-parcelas    → installments
--   valor-parcela         → installment_amount (NUMERIC, ex: 44.90)
--   moeda-compra          → currency
--   perfectpay_fee        → platform_fee       (NUMERIC, ex: 1.45)
--   my_commission         → commission         (NUMERIC, ex: 3.58)
-- ================================================================

CREATE TABLE IF NOT EXISTS payments (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Plataforma de pagamento. Ex: "perfectpay"
  provider     TEXT NOT NULL,

  -- ID do pedido PerfectPay. UNIQUE = idempotência garantida.
  order_id     TEXT UNIQUE,

  -- FK para sessions.id criada para este pagamento.
  session_id   UUID REFERENCES sessions(id),

  -- FK para customers.id registrado nesta compra.
  customer_id  UUID REFERENCES customers(id),

  -- ID do produto na PerfectPay (product-id).
  product_id   TEXT,

  -- Nome do produto (product-name).
  product_name TEXT,

  -- ID do plano na PerfectPay (plan-id), ex: "PPLQQPF70".
  plan_id      TEXT,

  -- Nome do plano na PerfectPay (plan-name), ex: "Raio-X do Crush".
  plan_name    TEXT,

  -- Limite de imagens para este pagamento.
  -- revealed=4 | raiox=10
  max_prints   INTEGER NOT NULL CHECK (max_prints IN (4, 10)),

  -- Valor total pago em reais (valor-venda). Ex: 44.90
  amount           NUMERIC(10,2),

  -- Moeda (moeda-compra), ex: "BRL".
  currency         TEXT DEFAULT 'BRL',

  -- Taxa da plataforma em reais (perfectpay_fee). Ex: 1.45
  platform_fee     NUMERIC(10,2),

  -- Comissão líquida em reais (my_commission). Ex: 3.58
  commission       NUMERIC(10,2),

  -- Método de pagamento: pix | credit_card | boleto
  payment_method   TEXT,

  -- Bandeira do cartão (card-type): visa | mastercard | none | etc.
  card_type        TEXT,

  -- Número de parcelas (numero-de-parcelas). 1 = à vista.
  installments     INTEGER DEFAULT 1,

  -- Valor de cada parcela em reais (valor-parcela). Ex: 44.90
  installment_amount NUMERIC(10,2),

  -- Status principal do pagamento (status-venda): approved | pending | cancelled
  status       TEXT NOT NULL DEFAULT 'approved',

  -- Detalhe do status (detalhe-status-venda): paid | waiting | etc.
  status_detail TEXT,

  -- Data/hora em que o pedido foi criado (data-pedido).
  order_date   TIMESTAMPTZ,

  -- Data/hora de aprovação do pagamento (data-aprovacao).
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
  (SELECT p.plan_name FROM payments p
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
