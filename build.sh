#!/bin/bash

# Sai do script se qualquer comando falhar
set -e

# Define a versão estável do Flutter que vamos usar
FLUTTER_VERSION="3.24.0"  # Você pode mudar para a versão que usa localmente

echo "Baixando Flutter $FLUTTER_VERSION..."

# Baixa o Flutter (versão estável)
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Adiciona o Flutter ao PATH
export PATH="$PATH:$PWD/flutter/bin"

echo "Configurando Flutter..."

# Roda o doctor e aceita as licenças
flutter precache --web
flutter config --no-analytics

echo "Instalando dependências do projeto..."
flutter pub get

echo "Buildando o Flutter Web..."
flutter build web --release

echo "Build concluído!"