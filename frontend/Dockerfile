FROM node:20-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /app

FROM base AS dependencies
COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

FROM base AS builder
WORKDIR /app
COPY . .
COPY --from=dependencies /app/node_modules ./node_modules

RUN pnpm exec vite build

FROM nginx:1.26-alpine
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./init-config.sh /docker-entrypoint.d/90-init-config.sh
RUN chmod +x /docker-entrypoint.d/90-init-config.sh

EXPOSE 80
COPY --from=builder /app/dist /usr/share/nginx/html
