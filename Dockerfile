# ==========================================
# Etapa 1: Compilación de Flutter Web
# Basado en la versión exacta de FVM (.fvm/version: 3.47.7)
# ==========================================
FROM debian:bookworm-slim AS build

# Versión de Flutter sincronizada con .fvm/version
ARG FLUTTER_VERSION=3.47.7

# Instalar dependencias del sistema requeridas por Flutter
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    unzip \
    xz-utils \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Descargar Flutter SDK con shallow clone (profundidad 1) de la versión exacta de FVM
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /opt/flutter

ENV PATH="/opt/flutter/bin:${PATH}"

# Deshabilitar telemetría y habilitar soporte Web
RUN flutter config --no-analytics --enable-web

# Pre-descargar artefactos web para acelerar la compilación
RUN flutter precache --web

WORKDIR /app

# Copiar dependencias de Flutter para aprovechar el cacheo de capas Docker
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiar el código fuente completo del proyecto
COPY . .

# Compilar la aplicación web para producción
RUN flutter build web --release

# ==========================================
# Etapa 2: Servidor Web ultraligero Nginx
# ==========================================
FROM nginx:alpine

# Configuración Nginx para SPA (Single Page Application) en puerto 3030
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los artefactos web compilados desde la etapa build
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer el puerto 3030
EXPOSE 3030

# Arrancar el servidor web Nginx
CMD ["nginx", "-g", "daemon off;"]
