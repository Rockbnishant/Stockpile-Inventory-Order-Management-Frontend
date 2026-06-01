# syntax=docker/dockerfile:1.7

# ---- build stage ----
FROM node:20-alpine AS build
WORKDIR /app

ENV NODE_ENV=production \
    CI=true

COPY package*.json ./
RUN npm ci --no-audit --no-fund

COPY . .

# Vite inlines VITE_* vars at build time. Override with --build-arg in CI.
ARG VITE_API_URL=http://localhost:8000
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

# ---- runtime stage ----
FROM nginx:1.27-alpine AS runtime

# Drop default config; we ship our own template that honours $PORT.
RUN rm /etc/nginx/conf.d/default.conf \
    && apk add --no-cache curl tini

COPY nginx.conf /etc/nginx/templates/default.conf.template
COPY --from=build /app/dist /usr/share/nginx/html

# nginx:alpine already includes a non-root `nginx` user; the official image's
# entrypoint runs envsubst on /etc/nginx/templates so $PORT is honoured.
ENV PORT=80

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${PORT}/healthz" || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
