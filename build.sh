#!/bin/bash
set -e

echo "🔧 Preparando ambiente Flutter..."

# O Netlify guarda em cache a pasta 'flutter' do build anterior.
# Para evitar conflitos de git (como branches diferentes ou estados 'detached'),
# a estratégia mais segura e rápida é remover a pasta antiga e baixar de novo.
# Como usamos '--depth 1', esse download leva menos de 40 segundos.
if [ -d "flutter" ]; then
  echo "Limpando cache antigo do Flutter para garantir um build limpo..."
  rm -rf flutter
fi

echo "Baixando Flutter (versão estável)..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

export PATH="$PATH:$PWD/flutter/bin"

echo "Configurando Flutter..."
flutter precache --web
flutter config --no-analytics

echo "Instalando dependências do projeto..."
flutter pub get

echo "Buildando o Flutter Web..."
flutter build web --release

echo "Build concluído com sucesso!"