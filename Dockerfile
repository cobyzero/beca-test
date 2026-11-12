# ==========================================
# Etapa 1: Compilación de Flutter Web
# ==========================================
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Aseguramos soporte web
RUN flutter config --enable-web --no-analytics

# Aprovechar caché de capas de Docker para dependencias
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiar el código fuente completo
COPY . .

# Compilar para producción Web (HTML/CanvasKit/WASM optimizado)
RUN flutter build web --release

# ==========================================
# Etapa 2: Servidor Web ultraligero Nginx
# ==========================================
FROM nginx:alpine

# Configuración personalizada de Nginx para Single Page Applications (SPA)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los artefactos estáticos compilados en la etapa 1
COPY --from=build /app/build/web /usr/share/nginx/html

# Puerto HTTP estándar
EXPOSE 80

# Iniciar Nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]

