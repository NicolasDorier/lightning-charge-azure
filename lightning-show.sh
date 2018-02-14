export CURRENT_HOST=`cat $LIGHTNING_ENV_FILE | sed -n 's/^CHARGED_HOST=\(.*\)$/\1/p'`
export CHARGED_API_TOKEN=`cat $LIGHTNING_ENV_FILE | sed -n 's/^CHARGED_API_TOKEN=\(.*\)$/\1/p'`
echo "https://api-token:$CHARGED_API_TOKEN@$CURRENT_HOST"