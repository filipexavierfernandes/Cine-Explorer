#!/bin/bash

echo "🚀 Gerando projeto com XcodeGen..."
xcodegen generate

if [ $? -eq 0 ]; then
  echo "✅ Projeto gerado com sucesso. Instalando Pods..."
  pod install

  if [ $? -eq 0 ]; then
    echo "✅ Pods instalados com sucesso. O workspace está pronto!"
  else
    echo "❌ Erro ao instalar os Pods."
    exit 1
  fi
else
  echo "❌ Erro ao gerar o projeto com XcodeGen."
  exit 1
fi

