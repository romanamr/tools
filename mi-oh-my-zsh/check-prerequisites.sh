#!/bin/bash
# Script de verificación de prerequisitos para Oh My Zsh Installer
# Este script debe ejecutarse antes de la instalación

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
}

title() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Variables
missing_deps=()
install_commands=()

# Detectar sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            OS="ubuntu"
            INSTALL_CMD="sudo apt-get install -y"
        elif command -v yum &> /dev/null; then
            OS="centos"
            INSTALL_CMD="sudo yum install -y"
        elif command -v dnf &> /dev/null; then
            OS="fedora"
            INSTALL_CMD="sudo dnf install -y"
        elif command -v pacman &> /dev/null; then
            OS="arch"
            INSTALL_CMD="sudo pacman -S"
        else
            OS="linux"
            INSTALL_CMD="# Instalar manualmente"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        INSTALL_CMD="brew install"
    else
        OS="unknown"
        INSTALL_CMD="# Sistema no soportado"
    fi
}

# Verificar prerequisito individual
check_dependency() {
    local dep_name="$1"
    local dep_command="$2"
    local package_name="$3"
    
    if command -v "$dep_command" &> /dev/null; then
        local version=$($dep_command --version 2>/dev/null | head -1)
        log "$dep_name está instalado: $version"
        return 0
    else
        error "$dep_name NO está instalado"
        missing_deps+=("$dep_name")
        install_commands+=("$INSTALL_CMD $package_name")
        return 1
    fi
}

# Verificar todos los prerequisitos
check_all_dependencies() {
    title "Verificando prerequisitos del sistema"
    
    local all_ok=true
    
    # Verificar ZSH
    check_dependency "ZSH" "zsh" "zsh" || all_ok=false
    
    # Verificar Git
    check_dependency "Git" "git" "git" || all_ok=false
    
    # Verificar curl
    check_dependency "curl" "curl" "curl" || all_ok=false
    
    if $all_ok; then
        return 0
    else
        return 1
    fi
}

# Mostrar información del sistema
show_system_info() {
    title "Información del sistema"
    
    echo "Sistema operativo: $OSTYPE"
    echo "Distribución detectada: $OS"
    echo "Comando de instalación: $INSTALL_CMD"
    echo "Usuario actual: $USER"
    echo "Directorio home: $HOME"
    echo "Shell actual: $SHELL"
}

# Mostrar comandos de instalación
show_install_commands() {
    if [ ${#missing_deps[@]} -eq 0 ]; then
        return 0
    fi
    
    title "Comandos para instalar dependencias faltantes"
    
    echo "Dependencias faltantes: ${missing_deps[*]}"
    echo
    
    case "$OS" in
        ubuntu)
            echo "Ejecuta este comando para instalar todas las dependencias:"
            echo "sudo apt-get update && sudo apt-get install -y zsh git curl"
            ;;
        centos)
            echo "Ejecuta este comando para instalar todas las dependencias:"
            echo "sudo yum install -y zsh git curl"
            ;;
        fedora)
            echo "Ejecuta este comando para instalar todas las dependencias:"
            echo "sudo dnf install -y zsh git curl"
            ;;
        arch)
            echo "Ejecuta este comando para instalar todas las dependencias:"
            echo "sudo pacman -S zsh git curl"
            ;;
        macos)
            echo "Instala Homebrew si no lo tienes:"
            echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
            echo
            echo "Luego ejecuta:"
            echo "brew install zsh git curl"
            ;;
        *)
            echo "Sistema no reconocido. Instala manualmente:"
            echo "- zsh"
            echo "- git" 
            echo "- curl"
            ;;
    esac
    
    echo
    echo "Después de la instalación, ejecuta este script nuevamente para verificar."
}

# Verificar permisos
check_permissions() {
    title "Verificando permisos"
    
    # Verificar escritura en home
    if [ -w "$HOME" ]; then
        log "Permisos de escritura en $HOME: OK"
    else
        error "Sin permisos de escritura en $HOME"
        return 1
    fi
    
    # Verificar si .zshrc existe y es escribible
    if [ -f "$HOME/.zshrc" ]; then
        if [ -w "$HOME/.zshrc" ]; then
            log "Archivo .zshrc existe y es escribible"
        else
            error "Archivo .zshrc existe pero no es escribible"
            return 1
        fi
    else
        log "Archivo .zshrc no existe (se creará durante la instalación)"
    fi
    
    return 0
}

# Verificar conexión a internet
check_internet() {
    title "Verificando conexión a internet"
    
    if curl -s --head --request GET https://github.com 2>/dev/null | grep "200 OK" > /dev/null; then
        log "Conexión a GitHub: OK"
    else
        error "No se puede conectar a GitHub"
        echo "Verifica tu conexión a internet"
        return 1
    fi
    
    return 0
}

# Función principal
main() {
    echo "Oh My Zsh Installer - Verificación de Prerequisitos"
    echo "=================================================="
    
    # Detectar OS
    detect_os
    
    # Mostrar info del sistema
    show_system_info
    
    local all_checks_passed=true
    
    # Verificar dependencias
    check_all_dependencies || all_checks_passed=false
    
    # Verificar permisos
    check_permissions || all_checks_passed=false
    
    # Verificar internet
    check_internet || all_checks_passed=false
    
    echo
    echo "=================================================="
    
    if $all_checks_passed; then
        title "¡Todos los prerequisitos están listos!"
        echo -e "${GREEN}✓ Sistema listo para instalar Oh My Zsh${NC}"
        echo
        echo "Puedes proceder con la instalación:"
        echo "./ohmyzsh-installer.sh"
        exit 0
    else
        title "Faltan prerequisitos"
        echo -e "${RED}✗ El sistema NO está listo para la instalación${NC}"
        echo
        show_install_commands
        echo
        echo "Después de instalar las dependencias, ejecuta:"
        echo "./check-prerequisites.sh"
        exit 1
    fi
}

# Manejo de argumentos
case "${1:-check}" in
    check)
        main
        ;;
    --help)
        echo "Verificador de prerequisitos para Oh My Zsh Installer"
        echo
        echo "Uso: $0 [comando]"
        echo
        echo "Comandos:"
        echo "  check        Verificar todos los prerequisitos (por defecto)"
        echo "  --help       Mostrar esta ayuda"
        echo
        echo "Este script verifica:"
        echo "  - ZSH instalado"
        echo "  - Git instalado"
        echo "  - curl instalado"
        echo "  - Permisos de escritura"
        echo "  - Conexión a internet"
        ;;
    *)
        echo "Comando no reconocido: $1"
        echo "Usa '$0 --help' para ver los comandos disponibles"
        exit 1
        ;;
esac