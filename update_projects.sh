#!/bin/bash

# FILE com a lista de projetos
FILE="projects.txt"

# Diretório onde os projetos serão armazenados
BASE_DIR="$HOME/projects"

# Criar o diretório base se não existir
mkdir -p "$BASE_DIR"

while IFS=',' read -r name project_git folder port
do
    # Ignorar linhas vazias ou comentários
    [[ -z "$name" || "$name" == "#"* ]] && continue

    echo "=============================="
    echo "Processing: $name"
    echo "=============================="

    PROJECT_DIR="$BASE_DIR/$folder"

    if [ ! -d "$PROJECT_DIR" ]; then
        echo "Cloning repository from $project_git para $PROJECT_DIR..."
        git clone "$project_git" "$PROJECT_DIR"
    else
        echo "Project $name already exists. Updating..."
        cd "$PROJECT_DIR" || exit
        git pull origin development
    fi

    # Verificar se o script update_container.sh existe
    UPDATE_SCRIPT="#PROJECT_DIR/script/update_container.sh"

    if [ -f "$UPDATE_SCRIPT" ]; then
        echo "Running update script for $name..."
        chmod +x "$UPDATE_SCRIPT"
        "$UPDATE_SCRIPT" "$name" "$port"
    else
        echo "❌ update_container.sh not found in $PROJECTO_DIR!"
    fi

    echo "$name updated successfully!"
processed
done < "$FILE"

echo "All projects have been updated!"
