sudo docker images --filter "dangling=false" --format "{{.Repository}}:{{.Tag}}" | xargs -L1 sudo docker pull
sudo ./clean_containers
sudo docker-compose up -d

