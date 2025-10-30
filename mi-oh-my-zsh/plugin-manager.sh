#!/bin/bash
# Plugin Manager Extendido
# Complemento al instalador principal para gestión avanzada de plugins

set -e

# Cargar configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/plugins.conf" 2>/dev/null || {
    echo "Warning: plugins.conf no encontrado, usando configuración por defecto"
}

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
CUSTOM_PLUGINS_DIR="$OH_MY_ZSH_DIR/custom/plugins"
ZSHRC="$HOME/.zshrc"

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
title() { echo -e "\n${BLUE}=== $1 ===${NC}\n"; }

# Mostrar perfiles disponibles
show_profiles() {
    title "Perfiles de plugins disponibles"
    
    echo -e "${BLUE}complete${NC}    - Lista completa (tu configuración actual)"
    echo "              Plugins: $COMPLETE_PLUGINS"
    echo
    echo -e "${BLUE}basic${NC}       - Lista básica para principiantes" 
    echo "              Plugins: $BASIC_PLUGINS"
    echo
    echo -e "${BLUE}dev${NC}         - Lista para desarrollo"
    echo "              Plugins: $DEV_PLUGINS"
    echo
    echo -e "${BLUE}devops${NC}      - Lista para DevOps"
    echo "              Plugins: $DEVOPS_PLUGINS"
    echo
    echo -e "${BLUE}python${NC}      - Lista para desarrollo Python"
    echo "              Plugins: $PYTHON_PLUGINS"
    echo
    echo -e "${BLUE}nodejs${NC}      - Lista para desarrollo Node.js"
    echo "              Plugins: $NODEJS_PLUGINS"
    echo
    echo -e "${BLUE}go${NC}          - Lista para desarrollo Go"
    echo "              Plugins: $GO_PLUGINS"
    echo
    echo -e "${BLUE}minimal${NC}     - Lista minimalista"
    echo "              Plugins: $MINIMAL_PLUGINS"
    echo
    echo "Uso: $0 --profile <nombre_perfil>"
}

# Aplicar perfil de plugins
apply_profile() {
    local profile="$1"
    local plugins_list=""
    
    case "$profile" in
        complete) plugins_list="$COMPLETE_PLUGINS" ;;
        basic) plugins_list="$BASIC_PLUGINS" ;;
        dev) plugins_list="$DEV_PLUGINS" ;;
        devops) plugins_list="$DEVOPS_PLUGINS" ;;
        python) plugins_list="$PYTHON_PLUGINS" ;;
        nodejs) plugins_list="$NODEJS_PLUGINS" ;;
        go) plugins_list="$GO_PLUGINS" ;;
        minimal) plugins_list="$MINIMAL_PLUGINS" ;;
        *)
            error "Perfil desconocido: $profile"
            show_profiles
            exit 1
            ;;
    esac
    
    title "Aplicando perfil: $profile"
    log "Plugins a configurar: $plugins_list"
    
    # Llamar al instalador principal con la lista de plugins
    "$SCRIPT_DIR/ohmyzsh-installer.sh" --plugins "$plugins_list"
}

# Mostrar información detallada de un plugin
show_plugin_info() {
    local plugin="$1"
    
    title "Información del plugin: $plugin"
    
    # Verificar si es plugin oficial
    if [ -d "$OH_MY_ZSH_DIR/plugins/$plugin" ]; then
        echo -e "${GREEN}✓ Plugin oficial de Oh My Zsh${NC}"
        echo "Ubicación: $OH_MY_ZSH_DIR/plugins/$plugin"
        
        if [ -f "$OH_MY_ZSH_DIR/plugins/$plugin/README.md" ]; then
            echo "Documentación disponible en: $OH_MY_ZSH_DIR/plugins/$plugin/README.md"
        fi
    fi
    
    # Verificar si es plugin custom
    if [ -d "$CUSTOM_PLUGINS_DIR/$plugin" ]; then
        echo -e "${GREEN}✓ Plugin externo instalado${NC}"
        echo "Ubicación: $CUSTOM_PLUGINS_DIR/$plugin"
        
        if [ -d "$CUSTOM_PLUGINS_DIR/$plugin/.git" ]; then
            echo "Repositorio Git:"
            (cd "$CUSTOM_PLUGINS_DIR/$plugin" && git remote get-url origin 2>/dev/null) || echo "No disponible"
            
            echo "Última actualización:"
            (cd "$CUSTOM_PLUGINS_DIR/$plugin" && git log -1 --pretty=format:"%h - %an, %ar : %s" 2>/dev/null) || echo "No disponible"
        fi
    fi
    
    # Verificar si está activo
    if grep -q "^plugins=(" "$ZSHRC" && sed -n '/^plugins=(/,/^)/p' "$ZSHRC" | grep -q "^\s*$plugin\s*$"; then
        echo -e "${GREEN}✓ Plugin activo en .zshrc${NC}"
    else
        echo -e "${YELLOW}○ Plugin no activo en .zshrc${NC}"
    fi
}

# Buscar plugins disponibles
search_plugins() {
    local search_term="$1"
    
    title "Buscando plugins: $search_term"
    
    echo "Plugins oficiales de Oh My Zsh:"
    if [ -d "$OH_MY_ZSH_DIR/plugins" ]; then
        find "$OH_MY_ZSH_DIR/plugins" -maxdepth 1 -type d -name "*$search_term*" | 
        sed "s|$OH_MY_ZSH_DIR/plugins/||" | grep -v "^$" | sort | sed 's/^/  /'
    fi
    
    echo
    echo "Plugins externos instalados:"
    if [ -d "$CUSTOM_PLUGINS_DIR" ]; then
        find "$CUSTOM_PLUGINS_DIR" -maxdepth 1 -type d -name "*$search_term*" |
        sed "s|$CUSTOM_PLUGINS_DIR/||" | grep -v "^$" | sort | sed 's/^/  /'
    fi
}

# Instalar plugin específico desde GitHub
install_custom_plugin() {
    local plugin_name="$1"
    local repo_url="$2"
    
    if [ -z "$plugin_name" ] || [ -z "$repo_url" ]; then
        error "Uso: $0 --install-plugin <nombre> <url_repositorio>"
        exit 1
    fi
    
    title "Instalando plugin personalizado: $plugin_name"
    
    local plugin_dir="$CUSTOM_PLUGINS_DIR/$plugin_name"
    
    if [ -d "$plugin_dir" ]; then
        warn "Plugin $plugin_name ya está instalado"
        return 0
    fi
    
    mkdir -p "$CUSTOM_PLUGINS_DIR"
    
    if git clone "$repo_url" "$plugin_dir"; then
        log "Plugin $plugin_name instalado correctamente"
        log "Para activarlo, agrégalo a tu lista de plugins en .zshrc"
    else
        error "Falló la instalación del plugin $plugin_name"
        exit 1
    fi
}

# Generar configuración personalizada
generate_custom_config() {
    title "Generador de configuración personalizada"
    
    echo "Selecciona los plugins que deseas activar:"
    echo "(Escribe los números separados por espacios, ej: 1 3 5)"
    echo
    
    # Lista de todos los plugins disponibles
    local all_plugins=(
        "git" "docker" "z" "zsh-autosuggestions" "zsh-syntax-highlighting"
        "virtualenv" "zsh-autocomplete" "colorize" "zsh-bat" "encode64"
        "command-not-found" "kubectl" "terraform" "aws" "pip" "python"
        "node" "npm" "yarn" "golang"
    )
    
    for i in "${!all_plugins[@]}"; do
        printf "%2d. %s\n" $((i+1)) "${all_plugins[i]}"
    done
    
    echo
    read -p "Selecciona plugins (números): " selections
    
    local selected_plugins=()
    for num in $selections; do
        if [ "$num" -ge 1 ] && [ "$num" -le "${#all_plugins[@]}" ]; then
            selected_plugins+=("${all_plugins[$((num-1))]}")
        fi
    done
    
    if [ ${#selected_plugins[@]} -eq 0 ]; then
        error "No se seleccionaron plugins válidos"
        exit 1
    fi
    
    # Convertir array a string separado por comas
    local plugins_string=$(IFS=,; echo "${selected_plugins[*]}")
    
    echo
    log "Configuración generada: $plugins_string"
    
    read -p "¿Aplicar esta configuración? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        "$SCRIPT_DIR/ohmyzsh-installer.sh" --plugins "$plugins_string"
    else
        log "Configuración no aplicada"
        echo "Para aplicarla manualmente: $SCRIPT_DIR/ohmyzsh-installer.sh --plugins '$plugins_string'"
    fi
}

# Función principal
main() {
    case "${1:-help}" in
        --profile)
            if [ -z "$2" ]; then
                show_profiles
                exit 1
            fi
            apply_profile "$2"
            ;;
        --profiles)
            show_profiles
            ;;
        --info)
            if [ -z "$2" ]; then
                error "Especifica el nombre del plugin: $0 --info <plugin>"
                exit 1
            fi
            show_plugin_info "$2"
            ;;
        --search)
            if [ -z "$2" ]; then
                error "Especifica el término de búsqueda: $0 --search <término>"
                exit 1
            fi
            search_plugins "$2"
            ;;
        --install-plugin)
            install_custom_plugin "$2" "$3"
            ;;
        --custom)
            generate_custom_config
            ;;
        --help|help)
            echo "Plugin Manager Extendido para Oh My Zsh"
            echo
            echo "Uso: $0 [comando] [opciones]"
            echo
            echo "Comandos:"
            echo "  --profile <nombre>           Aplicar perfil predefinido"
            echo "  --profiles                   Mostrar perfiles disponibles"
            echo "  --info <plugin>              Información detallada de un plugin"
            echo "  --search <término>           Buscar plugins disponibles"
            echo "  --install-plugin <nombre> <url>  Instalar plugin desde GitHub"
            echo "  --custom                     Generador de configuración personalizada"
            echo "  --help                       Mostrar esta ayuda"
            echo
            echo "Ejemplos:"
            echo "  $0 --profile complete"
            echo "  $0 --info zsh-autosuggestions"
            echo "  $0 --search docker"
            echo "  $0 --install-plugin my-plugin https://github.com/user/my-plugin"
            echo "  $0 --custom"
            ;;
        *)
            error "Comando no reconocido: $1"
            echo "Usa '$0 --help' para ver los comandos disponibles"
            exit 1
            ;;
    esac
}

main "$@"