#!/bin/sh

. ./image-env.sh

docker run -it --rm -p 5002:5000 $REGISTRY/$REGISTRY_USER_ID/$IMAGE_NAME:$IMAGE_VERSION