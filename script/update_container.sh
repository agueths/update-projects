#!/bin/bash

PROJECT_NAME=$1
PORT=$2

echo "=============================="
echo "Starting $PROJECT_NAME on port $PORT"
echo "=============================="



git fetch origin
git diff --quiet origin/development || {
    echo "Updates found in $PROJECT_NAME! Updating the container..."

    # Realizar o pull da última versão da branch development
    git pull origin development

    # Construir a imagem do Docker (não usaremos docker-compose.yml, então fazemos isso manualmente)
    docker build -t image_$PROJECT_NAME .

    # Parar e remover o container antigo
    docker stop $PROJECT_NAME || true
    docker rm $PROJECT_NAME || true

    # Rodar o container com a imagem recém construída
    docker run -d -p 3000:$PORT --name $PROJECT_NAME image_$PROJECT_NAME

    echo "Container for $PROJECT_NAME updated successfully!"
}
