#!/bin/bash

echo "=============================="
echo "Updating Projects"
echo "=============================="
echo ""

# FILE com a lista de projetos
FILE=$(grep -oP '^projects_list_file: \K.+' config.yml)
if [ -z $FILE ]; then
    FILE="projects.txt"
fi

# Diretório onde os projetos serão armazenados
BASE_DIR=$(grep -oP '^base_dir: \K.+' config.yml)
if [ -z $BASE_DIR ]; then
    BASE_DIR="$HOME/projects"
fi

# Criar o diretório base se não existir
mkdir -p "$BASE_DIR"

# Percorrer pelo arquivo de projetos
while IFS=';' read -r name folder project_git port db_host
do
    # Ignorar linhas vazias ou comentários
    [[ -z "$name" || "$name" == "#"* ]] && continue

    # Caso não seja informado o DB HOST, será considerado o ip do docker0
    if [ -z "$db_host" ]; then
        db_host=$(ip addr show docker0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    fi
    
    echo "------------------------------"
    echo "Checking: $name"
    echo "------------------------------"

    PROJECT_DIR="$BASE_DIR/$folder"

    # Caso o projeto não esteja baixado do git ainda
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "Cloning repository from $project_git para $PROJECT_DIR"
        echo "------------------------------"
        
        git clone "$project_git" "$PROJECT_DIR"
    fi
    
    cd $PROJECT_DIR

    # Verificar se o script update_container.sh existe
    UPDATE_SCRIPT="$PROJECT_DIR/script/update_container.sh"
    if [ -f "$UPDATE_SCRIPT" ]; then
        # Se existir, roda ele
        echo "Running update script in the project $name"
        echo "------------------------------"
        chmod +x "$UPDATE_SCRIPT"
        eval "$UPDATE_SCRIPT $port"    
    else
        # Caso não exista, roda a atualização padrão
        echo "No update script found on $name, running default script"
        echo "------------------------------"
        echo "Searching for updates..."
        echo "------------------------------"
        
        
        # Monta o nome do container (espaços para _ e tudo minusculo)
        container_name=${name// /_}
        container_name=${container_name,,}
        git fetch origin

        # Verifica se existe um container do projeto rodando
        container_id=$(docker ps -a -q -f name=$container_name)
        if [ -n "$container_id" ]; then
            # Verifica se houve atualização no projeto
            LAST_COMMIT_BEFORE=$(git rev-parse HEAD)
            git pull origin development > /dev/null 2>&1
            LAST_COMMIT_AFTER=$(git rev-parse HEAD)
            
            if [ "$LAST_COMMIT_BEFORE" != "$LAST_COMMIT_AFTER" ]; then
                echo "Updates found in $name! Updating the container"
                echo "------------------------------"
                
                # Construir a imagem do Docker
                docker build -t image_$container_name .

                # Parar e remover o container antigo
                docker stop $container_name || true
                docker rm $container_name || true
                
                # Load na chave mestre do rails
                MASTER_KEY=$(cat config/master.key)

                # Montar chamada docker
                docker_run="docker run -d -p 80:$port  -e RAILS_MASTER_KEY=$MASTER_KEY --name $container_name image_$container_name"
                if [ -n "$db_host" ]; then
                    docker_run="$docker_run -e DATABASE_HOST=$db_host"
                fi
                # Rodar o container com a imagem recém construída
                eval $docker_run

                echo "------------------------------"
                echo "Container for $name updated successfully!"
                echo "------------------------------"
            else
                echo "No updates required in $name. Skipping."
                echo "------------------------------"
            fi
        else
            # Caso não haja container buildado 
            # Construir a imagem do Docker
            docker build -t image_$container_name .
                
            # Load na chave mestre do rails
            MASTER_KEY=$(cat config/master.key)

            
            # Montar chamada docker
            docker_run="docker run -d -p 80:$port  -e RAILS_MASTER_KEY=$MASTER_KEY --name $container_name image_$container_name"
            if [ -n "$db_host" ]; then
                docker_run="$docker_run -e DATABASE_HOST=$db_host"
            fi
            # Rodar o container com a imagem recém construída
            eval $docker_run
    
            echo "------------------------------"
            echo "Container for $name started successfully!"
            echo "------------------------------"
        fi
    fi
    echo ""
    echo ""

done < "$FILE"

echo "=============================="
echo "All projects have been updated!"
echo "=============================="
