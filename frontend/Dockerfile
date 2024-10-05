FROM node:20-alpine AS dependencies

ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

WORKDIR /app
COPY package.json /
RUN npm install --legacy-peer-deps

FROM dependencies AS builder
WORKDIR /app
ADD . .
COPY --from=dependencies /node_modules /node_modules

RUN npm run build

FROM nginx:1.26-alpine
COPY ./default.conf /etc/nginx/conf.d/default.conf
EXPOSE 5174
COPY --from=builder /app/dist /usr/share/nginx/html


