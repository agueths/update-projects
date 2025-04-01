echo "Searching for updates..."
echo "------------------------------"


# Monta o nome do container (espaços para _ e tudo minusculo)
container_name="office"
git fetch origin

# Verifica se existe um container do projeto rodando
container_id=$(docker ps -a -q -f name=$container_name)
if [ -n "$container_id" ]; then
    # Verifica se houve atualização no projeto
    LAST_COMMIT_BEFORE=$(git rev-parse HEAD)
    git pull origin development > /dev/null 2>&1
    LAST_COMMIT_AFTER=$(git rev-parse HEAD)
    
    if [ "$LAST_COMMIT_BEFORE" != "$LAST_COMMIT_AFTER" ]; then
        echo "Updates found in Container! Updating the container"
        echo "------------------------------"
        
        # Construir a imagem do Docker
        docker build -t image_$container_name .

        # Parar e remover o container antigo
        docker stop $container_name || true
        docker rm $container_name || true
        
        # Load na chave mestre do rails
        MASTER_KEY=$(cat config/master.key)
        
        db_host=$(ip addr show docker0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)

        # Montar chamada docker
        docker_run="docker run -d -p 80:$1  -e RAILS_MASTER_KEY=$MASTER_KEY --name $container_name image_$container_name"
        if [ -n "$db_host" ]; then
            docker_run="$docker_run -e DATABASE_HOST=$db_host"
        fi
        # Rodar o container com a imagem recém construída
        eval $docker_run

        echo "------------------------------"
        echo "Container for Container updated successfully!"
        echo "------------------------------"
    else
        echo "No updates required in Container. Skipping."
        echo "------------------------------"
    fi
fi
