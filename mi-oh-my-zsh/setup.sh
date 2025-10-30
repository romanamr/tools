#!/usr/bin/env bash
# Quick Setup Script
# Configuración rápida de los scripts para uso inmediato

echo "=== Oh My Zsh Installer - Configuración rápida ==="
echo

# Hacer ejecutables los scripts
echo "Haciendo ejecutables los scripts..."
chmod +x ohmyzsh-installer.sh 2>/dev/null || echo "⚠ No se pudieron cambiar permisos de ohmyzsh-installer.sh (se puede ignorar en Windows)"
chmod +x plugin-manager.sh 2>/dev/null || echo "⚠ No se pudieron cambiar permisos de plugin-manager.sh (se puede ignorar en Windows)"

echo "✓ Scripts configurados"
echo

# Si se pasaron argumentos, ejecutar directamente el plugin-manager
if [ $# -gt 0 ]; then
    exec ./plugin-manager.sh "$@"
fi

echo

# Mostrar opciones disponibles
echo "Opciones disponibles:"
echo
echo "1. INSTALACIÓN COMPLETA (recomendado)"
echo "   ./ohmyzsh-installer.sh"
echo "   - Instala Oh My Zsh completo"
echo "   - Instala todos los plugins externos"
echo "   - Configura tu lista de plugins actual"
echo
echo "2. PERFIL ESPECÍFICO"
echo "   ./plugin-manager.sh --profile NOMBRE"
echo "   Perfiles disponibles:"
echo "   - complete  (tu configuración actual)"
echo "   - basic     (minimalista para principiantes)"
echo "   - dev       (desarrollo general)"
echo "   - devops    (DevOps/infraestructura)"
echo "   - python    (desarrollo Python)"
echo "   - nodejs    (desarrollo Node.js)"
echo
echo "3. CONFIGURACIÓN PERSONALIZADA"
echo "   ./plugin-manager.sh --custom"
echo "   - Selector interactivo de plugins"
echo
echo "4. VER PERFILES DISPONIBLES"
echo "   ./plugin-manager.sh --profiles"
echo

# Preguntar qué hacer
# Compatible con bash y zsh
if [ -n "$BASH_VERSION" ]; then
    read -p "¿Qué deseas hacer? (1-4, o 'q' para salir): " choice
else
    # Zsh
    echo -n "¿Qué deseas hacer? (1-4, o 'q' para salir): "
    read choice
fi

case "$choice" in
    1)
        echo
        echo "Iniciando instalación completa..."
        ./ohmyzsh-installer.sh
        ;;
    2)
        echo
        ./plugin-manager.sh --profiles
        echo
        if [ -n "$BASH_VERSION" ]; then
            read -p "Ingresa el nombre del perfil: " profile
        else
            echo -n "Ingresa el nombre del perfil: "
            read profile
        fi
        ./plugin-manager.sh --profile "$profile"
        ;;
    3)
        echo
        ./plugin-manager.sh --custom
        ;;
    4)
        echo
        ./plugin-manager.sh --profiles
        ;;
    q|Q)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo "Opción no válida"
        exit 1
        ;;
esac

echo
echo "=== Configuración completada ==="
echo "Para aplicar los cambios:"
echo "1. Reinicia tu terminal, o"
echo "2. Ejecuta: source ~/.zshrc"
echo
echo "Comandos útiles:"
echo "• Ver plugins activos: ./ohmyzsh-installer.sh --list"
echo "• Actualizar plugins: ./ohmyzsh-installer.sh --update"
echo "• Cambiar perfil: ./plugin-manager.sh --profile NOMBRE"
echo "• Ayuda: ./ohmyzsh-installer.sh --help"