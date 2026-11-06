# Multi-stage Dockerfile for Deal One Backend (Railway Monorepo Root)

# Stage 1: Build & Dependencies
FROM node:20-alpine AS builder

WORKDIR /app

COPY backend/package*.json ./
COPY backend/tsconfig*.json ./
COPY backend/prisma ./prisma/

RUN npm ci
RUN npx prisma generate

COPY backend/src ./src
RUN npm run build

# Stage 2: Production Runtime
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY backend/package*.json ./
RUN npm ci --only=production

COPY --from=builder /app/node_modules/@prisma/client ./node_modules/@prisma/client
COPY --from=builder /app/dist ./dist
COPY backend/prisma ./prisma

USER node

EXPOSE 3000

CMD ["node", "dist/src/main.js"]

