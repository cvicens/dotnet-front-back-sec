#!/bin/sh

. ./image-env.sh

docker run -it --rm -p 5003:5000 -e BACKEND_HOST=$(hostname) $REGISTRY/$REGISTRY_USER_ID/$IMAGE_NAME:$IMAGE_VERSION