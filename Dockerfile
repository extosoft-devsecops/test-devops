# Base image
FROM node:20-alpine AS base

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# ให้รองรับหลาย environment ผ่าน build arg
# ค่า default = production
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# ติดตั้ง dependency ตาม NODE_ENV
# - ถ้า production จะตัด devDependencies ออก
# - ถ้า dev/test จะติดตั้งทั้งหมด
RUN if [ "$NODE_ENV" = "production" ]; then \
      npm ci --omit=dev; \
    else \
      npm install; \
    fi

# Copy source code
COPY . .

# Expose port เผื่อ app มี HTTP server (เช่น 3000)
EXPOSE 3000

# Env ที่ใช้บ่อยสำหรับส่ง metrics ไป StatsD/Graphite
ENV STATSD_HOST=graphite \
    STATSD_PORT=8125

# รันแอป
CMD ["node", "index.js"]
