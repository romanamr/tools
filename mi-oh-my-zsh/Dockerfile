# Dockerfile para probar Oh My Zsh Installer
FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar prerequisitos básicos
RUN apt-get update && apt-get install -y \
    curl \
    git \
    zsh \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no-root para la prueba
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Cambiar al usuario de prueba
USER testuser
WORKDIR /home/testuser

# Copiar los scripts
COPY --chown=testuser:testuser . /home/testuser/oh-my-zsh-installer/

# Hacer ejecutables los scripts
RUN chmod +x /home/testuser/oh-my-zsh-installer/*.sh

# Punto de entrada
CMD ["/bin/bash"]