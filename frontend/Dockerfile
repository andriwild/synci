FROM node:20-alpine AS dependencies

ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

ARG STAGE=prod
ENV VITE_STAGE=$STAGE

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
EXPOSE 5173
COPY --from=builder /app/dist /usr/share/nginx/html
