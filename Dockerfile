# ── Stage 1: build ───────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app

COPY scancrush/package*.json ./
RUN npm ci

COPY scancrush/ .

# Copia o public/ legado (privacy/terms/ai-policy/acesso + locales) para o public/ do Nuxt.
# NÃO inclui index.html — a home é a index.vue do Nuxt (multi-idioma via useAppI18n).
COPY public/ ./public/

ARG GIT_SHA
RUN echo "Building commit: $GIT_SHA" && npm run build

# ── Stage 2: runtime ─────────────────────────────────────────────
FROM node:20-alpine
WORKDIR /app

COPY --from=builder /app/.output ./.output

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
