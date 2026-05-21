# ── Stage 1: build ───────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app

COPY scancrush/package*.json ./
RUN npm ci

COPY scancrush/ .

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
