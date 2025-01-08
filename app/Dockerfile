# Etapa de construcción
FROM node:20-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Etapa de producción
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app .
EXPOSE 80

# Healthcheck para verificar que la aplicación está funcionando
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:80/health || exit 1

# Comando para iniciar la aplicación
CMD ["npm", "start"]