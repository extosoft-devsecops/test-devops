# ==========================================
# Stage 0: Base Dependencies (Cache Optimized)
# ==========================================
FROM node:18-alpine AS base
WORKDIR /app

# Improve native module compatibility
RUN apk add --no-cache libc6-compat

# Copy only package metadata first to leverage caching
COPY package.json package-lock.json* ./

ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

# Install dependencies (prod or full)
RUN if [ "$NODE_ENV" = "production" ]; then \
        npm ci --omit=dev && npm cache clean --force; \
    else \
        npm ci && npm cache clean --force; \
    fi

# Copy only required app source
COPY . .


# ==========================================
# Stage 1: Development Runtime
# For localhost development only
# ==========================================
FROM node:18-alpine AS development
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

COPY . .

EXPOSE 3000
CMD ["npm", "run", "dev"]


# ==========================================
# Stage 2: Production Runtime
# Clean, secure, minimal
# ==========================================
FROM node:18-alpine AS production
WORKDIR /app

# Add minimal tools needed for healthcheck
RUN apk add --no-cache wget

# Copy application from build stage
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app ./

# Environment
ENV NODE_ENV=production

# Security: add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# ==========================================
# Healthcheck (using wget instead of curl for smaller footprint) 
# ==========================================
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/healthz >/dev/null || exit 1

EXPOSE 3000

# Start Production App
CMD ["node", "index.js"]
