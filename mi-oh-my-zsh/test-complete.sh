#!/bin/bash
# Test completo de instalación de Oh My Zsh y plugins en Docker
set -e

cd /home/testuser/oh-my-zsh-installer

# Verificar prerequisitos
bash -c "source ./Prerequisitos.txt" || echo "Verifica manualmente los prerequisitos"

# Instalar Oh My Zsh y plugins
./ohmyzsh-installer.sh

# Mostrar plugins activos
./ohmyzsh-installer.sh --list

# Validar sintaxis de .zshrc
zsh -n ~/.zshrc && echo "✓ .zshrc válido" || echo "✗ Error de sintaxis en .zshrc"

# Mostrar primeras líneas de .zshrc
head -20 ~/.zshrc

echo "Test completo finalizado. Si ves ✓ y la lista de plugins, la instalación fue exitosa."