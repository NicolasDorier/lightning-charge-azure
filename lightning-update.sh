cd "`dirname $LIGHTNING_DOCKER_COMPOSE`"  
git pull
 cd "`dirname $LIGHTNING_ENV_FILE`"
docker-compose -f $LIGHTNING_DOCKER_COMPOSE down
docker-compose -f $LIGHTNING_DOCKER_COMPOSE up -d