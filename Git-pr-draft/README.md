# git-draft-pr
El objetivo de esta app es generar un branch nuevo y generando un PR en draft de este.

git-draft-pr --help

Uso:
        git-draft-pr --branch nombre-rama --titulo "Título del Pull Request"

Opciones:
  -base string
        Nombre de la rama base (default: develop) (default "develop")
  -branch string
        Nombre de la rama a crear
  -titulo string
        Título del Pull Request


Ejemplos:
        git draft-pr --branch mi-feature-123 --titulo "Agregar validación de emails"
        git draft-pr --branch bugfix-issue-77 --titulo "Fix en login"

Notas:
        - La rama base por defecto es "develop", se puede cambiar con --base.
        - Requiere que esté seteada la variable de entorno GITHUB_TOKEN.
