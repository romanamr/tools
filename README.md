# Tools Collection

Una colección de herramientas útiles para desarrollo y automatización.

## 🛠️ Herramientas disponibles

### [`Git-pr-draft/`](./Git-pr-draft/)

Herramienta para gestión de pull requests en borrador.

### [`mi-oh-my-zsh/`](./mi-oh-my-zsh/)

Instalador y gestor completo de Oh My Zsh con plugins.

- Instalación automática de Oh My Zsh
- Gestión de plugins externos
- Perfiles predefinidos para diferentes casos de uso
- Sistema de backups y recuperación

## 🚀 Inicio rápido

Cada herramienta tiene su propio directorio con documentación específica:

```bash
# Oh My Zsh Installer
cd mi-oh-my-zsh/
./setup.sh

# Git PR Draft
cd Git-pr-draft/
go run main.go
```

## 📁 Estructura del proyecto

```
tools/
├── Git-pr-draft/          # Herramienta para pull requests
│   ├── main.go
│   ├── go.mod
│   └── README.md
├── mi-oh-my-zsh/          # Instalador de Oh My Zsh
│   ├── ohmyzsh-installer.sh
│   ├── plugin-manager.sh
│   ├── plugins.conf
│   ├── setup.sh
│   └── README.md
└── README.md              # Este archivo
```

## 🤝 Contribuir

Cada herramienta es independiente y tiene su propia documentación. Para contribuir:

1. Ve al directorio de la herramienta específica
2. Lee su README para entender su funcionamiento
3. Haz tus cambios en esa carpeta
4. Actualiza la documentación si es necesario

## 📄 Licencia

Ver [LICENSE](./LICENSE) para más detalles.

Repositorio con herramientas para hacer tareas mas rapido.
