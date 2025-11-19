# ==========================================
# Stage 1: Base Builder
# ==========================================
FROM node:18-alpine AS base
WORKDIR /app

# Only copy package metadata first (cache layer)
COPY package.json package-lock.json* ./

ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

# Install dependencies (prod-only or all deps depending on env)
RUN if [ "$NODE_ENV" = "production" ]; then \
        npm install --omit=dev; \
    else \
        npm install; \
    fi

# Copy source code
COPY . .


# ==========================================
# Stage 2: Development Runner
# Only used when running locally
# ==========================================
FROM node:18-alpine AS development
WORKDIR /app

# Install full dev dependencies
COPY package.json package-lock.json* ./
RUN npm install

COPY . .

CMD ["npm", "run", "dev"]


# ==========================================
# Stage 3: Production Runner
# Clean, secure, minimal
# ==========================================
FROM node:18-alpine AS production
WORKDIR /app

# Copy ONLY needed files from builder
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app ./

ENV NODE_ENV=production

# Recommended: non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Healthcheck
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD node -e "require('dns').lookup('localhost', err => { if (err) process.exit(1) })"

CMD ["node", "index.js"]
