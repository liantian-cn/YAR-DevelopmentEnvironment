docker build -t yar-devenv:$(date +"%Y%m%d%H%M") -t yar-devenv:latest   .

docker network create yarnet

docker create \
    -p 2222:22 \
    -p 80:80 \
    -p 443:443 \
    -p 8000:8000 \
    -p 8080:8080 \
    -p 8443:8443 \
    --tmpfs /tmp \
    --log-driver local \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    --log-opt compress=true \
    --restart always  \
    --network yarnet  \
    --network-alias devenv \
    --name YAR-DevelopmentEnvironment \
    yar-devenv:latest
    


docker start YAR-DevelopmentEnvironment
docker exec -it YAR-DevelopmentEnvironment bash



