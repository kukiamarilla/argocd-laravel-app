FROM node:20-alpine AS frontend-builder

WORKDIR /app

COPY package*.json ./
COPY resources/js ./resources/js
COPY resources/css ./resources/css
COPY vite.config.js ./