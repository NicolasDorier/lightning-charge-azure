
export NEW_HOST="$1"
export OLD_HOST=`cat $LIGHTNING_ENV_FILE | sed -n 's/^LIGHTNING_HOST=\(.*\)$/\1/p'`
echo "Changing domain from \"$OLD_HOST\" to \"$NEW_HOST\""

export LIGHTNING_HOST="$NEW_HOST"
export ACME_CA_URI="https://acme-v01.api.letsencrypt.org/directory"

# Modify environment file
sed -i '/^LIGHTNING_HOST/d' $LIGHTNING_ENV_FILE
sed -i '/^ACME_CA_URI/d' $LIGHTNING_ENV_FILE
echo "LIGHTNING_HOST=$LIGHTNING_HOST" >> $LIGHTNING_ENV_FILE
echo "ACME_CA_URI=$ACME_CA_URI" >> $LIGHTNING_ENV_FILE

cd "`dirname $LIGHTNING_ENV_FILE`"
docker-compose -f "$LIGHTNING_DOCKER_COMPOSE" down
docker-compose -f "$LIGHTNING_DOCKER_COMPOSE" up -d