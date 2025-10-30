# Oh My Zsh Complete Installer & Plugin Manager

Un conjunto completo de herramientas para instalar, configurar y gestionar Oh My Zsh con plugins.

## 📦 Archivos incluidos

- **`ohmyzsh-installer.sh`** - Script principal de instalación
- **`plugin-manager.sh`** - Gestor avanzado de plugins
- **`plugins.conf`** - Configuración de perfiles predefinidos
- **`setup.sh`** - Script de configuración rápida

## 🚀 Instalación rápida

```bash
# Hacer ejecutables los scripts
chmod +x *.sh

# Configuración interactiva (recomendado)
./setup.sh

# O instalación directa completa
./ohmyzsh-installer.sh
```

## 🔧 Uso del instalador principal

### Comandos básicos

```bash
# Instalación completa (incluye Oh My Zsh + plugins + configuración)
./ohmyzsh-installer.sh

# Instalación con plugins específicos
./ohmyzsh-installer.sh install "git,docker,z"

# Solo configurar plugins (sin reinstalar)
./ohmyzsh-installer.sh --plugins "git,docker,z"

# Actualizar plugins externos
./ohmyzsh-installer.sh --update

# Mostrar plugins configurados
./ohmyzsh-installer.sh --list

# Restaurar desde backup
./ohmyzsh-installer.sh --restore
```

### Características principales

- ✅ **Instalación automática** de Oh My Zsh
- ✅ **Gestión de plugins externos** (zsh-autosuggestions, zsh-syntax-highlighting, etc.)
- ✅ **Configuración automática** del archivo .zshrc
- ✅ **Sistema de backups** automático
- ✅ **Validación de sintaxis** antes de aplicar cambios
- ✅ **Recuperación automática** en caso de errores

## 🎯 Uso del gestor avanzado

### Perfiles predefinidos

```bash
# Mostrar perfiles disponibles
./plugin-manager.sh --profiles

# Aplicar perfil completo (tu configuración)
./plugin-manager.sh --profile complete

# Aplicar perfil básico
./plugin-manager.sh --profile basic

# Aplicar perfil para desarrollo
./plugin-manager.sh --profile dev

# Aplicar perfil para DevOps
./plugin-manager.sh --profile devops
```

### Gestión de plugins

```bash
# Información detallada de un plugin
./plugin-manager.sh --info zsh-autosuggestions

# Buscar plugins
./plugin-manager.sh --search docker

# Instalar plugin personalizado
./plugin-manager.sh --install-plugin mi-plugin https://github.com/user/mi-plugin

# Generador de configuración personalizada
./plugin-manager.sh --custom
```

## 🛠️ Perfiles disponibles

### `complete` - Tu configuración actual

```text
git, docker, z, zsh-autosuggestions, zsh-syntax-highlighting, 
virtualenv, zsh-autocomplete, colorize, zsh-bat, encode64, 
command-not-found
```

### `basic` - Para principiantes

```text
git, z, zsh-autosuggestions, zsh-syntax-highlighting
```

### `dev` - Para desarrollo

```text
git, docker, z, zsh-autosuggestions, zsh-syntax-highlighting, 
virtualenv, colorize, encode64
```

### `devops` - Para DevOps

```text
git, docker, kubectl, terraform, aws, z, zsh-autosuggestions, 
zsh-syntax-highlighting, colorize
```

### `python` - Para desarrollo Python

```text
git, z, zsh-autosuggestions, zsh-syntax-highlighting, 
virtualenv, pip, python, colorize
```

### `nodejs` - Para desarrollo Node.js

```text
git, node, npm, yarn, z, zsh-autosuggestions, 
zsh-syntax-highlighting, colorize
```

### `minimal` - Configuración mínima

```text
git, z, zsh-autosuggestions
```

## 🔌 Plugins soportados

### Oficiales de Oh My Zsh

- git, docker, z, virtualenv, colorize, encode64, command-not-found
- kubectl, terraform, aws, pip, python, node, npm, yarn, golang

### Externos (se instalan automáticamente)

- **zsh-autosuggestions** - Sugerencias basadas en historial
- **zsh-syntax-highlighting** - Resaltado de sintaxis
- **zsh-autocomplete** - Autocompletado mejorado
- **zsh-bat** - Integración con bat (better cat)

## 📚 Ejemplos de uso

### Instalación desde cero

```bash
# 1. Instalar Oh My Zsh con tu configuración completa
./ohmyzsh-installer.sh

# 2. Verificar instalación
./ohmyzsh-installer.sh --list

# 3. Reiniciar terminal o recargar configuración
source ~/.zshrc
```

### Cambiar a un perfil diferente

```bash
# Cambiar a perfil minimalista
./plugin-manager.sh --profile minimal

# Verificar cambios
./ohmyzsh-installer.sh --list
```

### Configuración personalizada

```bash
# Generar configuración interactiva
./plugin-manager.sh --custom

# O directamente especificar plugins
./ohmyzsh-installer.sh --plugins "git,docker,kubectl,zsh-autosuggestions"
```

### Mantenimiento

```bash
# Actualizar plugins externos
./ohmyzsh-installer.sh --update

# Crear backup manual
cp ~/.zshrc ~/.zshrc.backup.manual

# Restaurar en caso de problemas
./ohmyzsh-installer.sh --restore
```

## 📁 Estructura de directorios

```text
~/.oh-my-zsh/
├── plugins/                    # Plugins oficiales
└── custom/
    └── plugins/                # Plugins externos
        ├── zsh-autosuggestions/
        ├── zsh-syntax-highlighting/
        ├── zsh-autocomplete/
        └── zsh-bat/

~/.zsh_backups/                 # Backups automáticos
├── .zshrc.backup.20241010_120000
└── .zshrc.backup.20241010_130000
```

## ⚠️ Solución de problemas

### Error de sintaxis en .zshrc

```bash
# El script restaura automáticamente el último backup válido
./ohmyzsh-installer.sh --restore
```

### Plugin no funciona

```bash
# Verificar información del plugin
./plugin-manager.sh --info nombre-plugin

# Reinstalar plugins externos
./ohmyzsh-installer.sh --update
```

### Resetear a configuración por defecto

```bash
# Aplicar perfil básico
./plugin-manager.sh --profile basic
```

## 📋 Requisitos

- **Sistema**: Linux/macOS
- **Shell**: zsh
- **Dependencias**: git, curl
- **Permisos**: Escritura en el directorio home

## ⚡ Características avanzadas

- **Detección automática** de dependencias
- **Instalación no interactiva** para scripts automatizados
- **Validación robusta** de configuración
- **Gestión de versiones** de plugins externos
- **Backups automáticos** con timestamp
- **Recuperación inteligente** de errores

## 🤝 Contribuir

Para agregar nuevos perfiles o plugins, edita el archivo `plugins.conf`:

```bash
# Agregar nuevo perfil
NEW_PROFILE_PLUGINS="git,plugin1,plugin2"

# Agregar nuevo plugin externo
EXTERNAL_PLUGINS+=(
    "nuevo-plugin:https://github.com/user/nuevo-plugin"
)
```

## 📄 Licencia

Ver [../LICENSE](../LICENSE) para más detalles.
