FROM node:20-alpine AS frontend-builder

WORKDIR /app

COPY . .