FROM node:20-alpine AS dependencies

WORKDIR /app
COPY package.json /
RUN npm install --legacy-peer-deps

FROM dependencies AS builder
WORKDIR /app
ADD . .
RUN npm --version
COPY --from=dependencies /node_modules /node_modules
RUN npm run build

FROM nginx:1.26-alpine
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./init-config.sh /docker-entrypoint.d/90-init-config.sh
RUN chmod +x /docker-entrypoint.d/90-init-config.sh

EXPOSE 80
COPY --from=builder /app/dist /usr/share/nginx/html
