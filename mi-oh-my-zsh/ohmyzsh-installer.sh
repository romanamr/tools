#!/bin/bash
# Oh My Zsh Complete Installer & Plugin Manager
# Author: Roman
# Description: Instala Oh My Zsh, plugins externos y configura la lista de plugins

set -e  # Exit on any error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorios
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
CUSTOM_PLUGINS_DIR="$OH_MY_ZSH_DIR/custom/plugins"
ZSHRC="$HOME/.zshrc"
BACKUP_DIR="$HOME/.zsh_backups"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crear directorio de backups
mkdir -p "$BACKUP_DIR"

# Función para logging
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

title() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Función para crear backup
create_backup() {
    local file="$1"
    local backup_name="$(basename "$file").backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/$backup_name"
        log "Backup creado: $BACKUP_DIR/$backup_name"
    fi
}

# Verificar dependencias
check_dependencies() {
    title "Verificando dependencias"
    
    # Verificar que estamos en un sistema Unix-like
    if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "darwin"* ]]; then
        error "Este script está diseñado para Linux/macOS"
        exit 1
    fi
    
    # Verificar zsh
    if ! command -v zsh &> /dev/null; then
        error "zsh no está instalado. Por favor, instálalo primero."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "Ubuntu/Debian: sudo apt-get install zsh"
            echo "CentOS/RHEL: sudo yum install zsh"
            echo "Arch: sudo pacman -S zsh"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            echo "macOS: brew install zsh"
        fi
        exit 1
    fi
    
    # Verificar git
    if ! command -v git &> /dev/null; then
        error "git no está instalado. Por favor, instálalo primero."
        exit 1
    fi
    
    # Verificar curl
    if ! command -v curl &> /dev/null; then
        error "curl no está instalado. Por favor, instálalo primero."
        exit 1
    fi
    
    log "Todas las dependencias están disponibles"
}

# Instalar Oh My Zsh
install_ohmyzsh() {
    title "Instalando Oh My Zsh"
    
    if [ -d "$OH_MY_ZSH_DIR" ]; then
        warn "Oh My Zsh ya está instalado en $OH_MY_ZSH_DIR"
        return 0
    fi
    
    log "Descargando e instalando Oh My Zsh..."
    
    # Crear backup del .zshrc existente
    create_backup "$ZSHRC"
    
    # Instalar Oh My Zsh sin cambiar shell automáticamente
    export RUNZSH=no
    export KEEP_ZSHRC=yes
    
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
        error "Falló la instalación de Oh My Zsh"
        exit 1
    }
    
    log "Oh My Zsh instalado correctamente"
}

# Función para instalar plugin externo
install_external_plugin() {
    local plugin_name="$1"
    local repo_url="$2"
    local plugin_dir="$CUSTOM_PLUGINS_DIR/$plugin_name"
    
    if [ -d "$plugin_dir" ]; then
        warn "Plugin $plugin_name ya está instalado"
        return 0
    fi
    
    log "Instalando plugin externo: $plugin_name"
    mkdir -p "$CUSTOM_PLUGINS_DIR"
    
    if git clone "$repo_url" "$plugin_dir"; then
        log "Plugin $plugin_name instalado correctamente"
    else
        error "Falló la instalación del plugin $plugin_name"
        return 1
    fi
}

# Instalar todos los plugins externos necesarios
install_external_plugins() {
    title "Instalando plugins externos"
    
    # Lista de plugins externos con sus repositorios
    declare -A external_plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
        ["zsh-autocomplete"]="https://github.com/marlonrichert/zsh-autocomplete.git"
        ["zsh-bat"]="https://github.com/fdellwing/zsh-bat.git"
    )
    
    for plugin in "${!external_plugins[@]}"; do
        install_external_plugin "$plugin" "${external_plugins[$plugin]}"
    done
}

# Actualizar plugins externos
update_external_plugins() {
    title "Actualizando plugins externos"
    
    if [ ! -d "$CUSTOM_PLUGINS_DIR" ]; then
        warn "No hay plugins externos instalados"
        return 0
    fi
    
    for plugin_dir in "$CUSTOM_PLUGINS_DIR"/*; do
        if [ -d "$plugin_dir/.git" ]; then
            plugin_name=$(basename "$plugin_dir")
            log "Actualizando $plugin_name..."
            (cd "$plugin_dir" && git pull) || warn "Falló la actualización de $plugin_name"
        fi
    done
}

# Configurar lista de plugins en .zshrc
configure_plugins() {
    local plugins_list="$1"
    
    title "Configurando plugins en .zshrc"
    
    if [ ! -f "$ZSHRC" ]; then
        error ".zshrc no encontrado"
        exit 1
    fi
    
    # Crear backup
    create_backup "$ZSHRC"
    
    # Convertir la lista de plugins a formato de array
    local formatted_plugins=""
    if [ -n "$plugins_list" ]; then
        # Si es una lista separada por comas, convertir a formato multilinea
        formatted_plugins=$(echo "$plugins_list" | tr ',' '\n' | sed 's/^[[:space:]]*/        /' | sed 's/[[:space:]]*$//')
    else
        # Lista por defecto
        formatted_plugins="        git
        docker
        z
        zsh-autosuggestions
        zsh-syntax-highlighting
        virtualenv
        zsh-autocomplete
        colorize
        zsh-bat
        encode64
        command-not-found"
    fi
    
    # Verificar si ya existe configuración de plugins
    if grep -q "^plugins=(" "$ZSHRC"; then
        log "Actualizando configuración de plugins existente..."
        
        # Crear un archivo temporal con la nueva configuración
        awk -v new_plugins="$formatted_plugins" '
        /^plugins=\(/ {
            print "plugins=("
            print new_plugins
            # Saltar hasta el cierre del array
            while (getline && !/^\)/) {}
            print ")"
            next
        }
        { print }
        ' "$ZSHRC" > "$ZSHRC.tmp" && mv "$ZSHRC.tmp" "$ZSHRC"
    else
        log "Agregando configuración de plugins..."
        cat >> "$ZSHRC" << EOF

# Plugins configuration
plugins=(
$formatted_plugins
)
EOF
    fi
    
    log "Configuración de plugins actualizada"
}

# Validar sintaxis de .zshrc
validate_zshrc() {
    title "Validando configuración"
    
    if zsh -n "$ZSHRC" 2>/dev/null; then
        log "✓ Sintaxis de .zshrc válida"
        return 0
    else
        error "✗ Error de sintaxis en .zshrc"
        warn "Restaurando backup automáticamente..."
        
        # Buscar el backup más reciente
        latest_backup=$(ls -t "$BACKUP_DIR"/.zshrc.backup.* 2>/dev/null | head -1)
        if [ -n "$latest_backup" ]; then
            cp "$latest_backup" "$ZSHRC"
            log "Backup restaurado desde: $latest_backup"
        fi
        return 1
    fi
}

# Mostrar información post-instalación
show_post_install_info() {
    title "Instalación completada"
    
    echo -e "${GREEN}✓ Oh My Zsh instalado${NC}"
    echo -e "${GREEN}✓ Plugins externos instalados${NC}"
    echo -e "${GREEN}✓ Configuración aplicada${NC}"
    echo
    echo -e "${BLUE}Próximos pasos:${NC}"
    echo "1. Reinicia tu terminal o ejecuta: source ~/.zshrc"
    echo "2. Cambia tu shell por defecto (si no lo has hecho): chsh -s $(which zsh)"
    echo "3. Los backups están en: $BACKUP_DIR"
    echo
    echo -e "${BLUE}Comandos útiles:${NC}"
    echo "• Actualizar plugins: $0 --update"
    echo "• Mostrar plugins: $0 --list"
    echo "• Restaurar backup: $0 --restore"
    echo
}

# Mostrar lista de plugins activos
show_plugins() {
    title "Plugins configurados"
    
    if [ ! -f "$ZSHRC" ]; then
        error ".zshrc no encontrado"
        exit 1
    fi
    
    if ! grep -q "^plugins=(" "$ZSHRC"; then
        warn "No se encontró configuración de plugins"
        exit 1
    fi
    
    echo "Plugins activos en .zshrc:"
    sed -n '/^plugins=(/,/^)/p' "$ZSHRC" | grep -v "plugins=(" | grep -v "^)$" | sed 's/^[[:space:]]*//' | nl -v1 -s'. '
    
    echo
    echo "Estado de plugins externos:"
    for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete zsh-bat; do
        if [ -d "$CUSTOM_PLUGINS_DIR/$plugin" ]; then
            echo -e "  ${GREEN}✓${NC} $plugin"
        else
            echo -e "  ${RED}✗${NC} $plugin"
        fi
    done
}

# Restaurar desde backup
restore_backup() {
    title "Restaurando desde backup"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        error "No hay backups disponibles"
        exit 1
    fi
    
    echo "Backups disponibles:"
    ls -lt "$BACKUP_DIR"/.zshrc.backup.* 2>/dev/null | nl -v1 -s'. '
    
    echo
    read -p "Selecciona el número de backup a restaurar (o 'q' para cancelar): " choice
    
    if [ "$choice" = "q" ]; then
        log "Operación cancelada"
        exit 0
    fi
    
    backup_file=$(ls -t "$BACKUP_DIR"/.zshrc.backup.* 2>/dev/null | sed -n "${choice}p")
    
    if [ -n "$backup_file" ] && [ -f "$backup_file" ]; then
        create_backup "$ZSHRC"  # Backup del estado actual
        cp "$backup_file" "$ZSHRC"
        log "Backup restaurado desde: $backup_file"
    else
        error "Backup no válido"
        exit 1
    fi
}

# Función principal
main() {
    case "${1:-install}" in
        install)
            check_dependencies
            install_ohmyzsh
            install_external_plugins
            configure_plugins "$2"
            validate_zshrc
            show_post_install_info
            ;;
        --update)
            update_external_plugins
            log "Plugins actualizados. Reinicia tu terminal."
            ;;
        --list)
            show_plugins
            ;;
        --restore)
            restore_backup
            ;;
        --plugins)
            if [ -z "$2" ]; then
                error "Especifica la lista de plugins: $0 --plugins 'git,docker,z'"
                exit 1
            fi
            configure_plugins "$2"
            validate_zshrc
            log "Configuración de plugins actualizada"
            ;;
        --help)
            echo "Oh My Zsh Complete Installer & Plugin Manager"
            echo
            echo "Uso: $0 [comando] [opciones]"
            echo
            echo "Comandos:"
            echo "  install [plugins]    Instalación completa (por defecto)"
            echo "  --update            Actualizar plugins externos"
            echo "  --list              Mostrar plugins configurados"
            echo "  --restore           Restaurar desde backup"
            echo "  --plugins 'lista'   Configurar lista específica de plugins"
            echo "  --help              Mostrar esta ayuda"
            echo
            echo "Ejemplos:"
            echo "  $0                                    # Instalación con plugins por defecto"
            echo "  $0 install 'git,docker,z'           # Instalación con plugins específicos"
            echo "  $0 --plugins 'git,docker,z'         # Solo configurar plugins"
            echo "  $0 --update                         # Actualizar plugins"
            ;;
        *)
            error "Comando no reconocido: $1"
            echo "Usa '$0 --help' para ver los comandos disponibles"
            exit 1
            ;;
    esac
}

# Ejecutar función principal con todos los argumentos
main "$@"