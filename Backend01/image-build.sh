#!/bin/sh

. ./image-env.sh

docker build -t $IMAGE_NAME:$IMAGE_VERSION --build-arg BUILD_IMAGE="${BUILD_IMAGE}" --build-arg RUNTIME_IMAGE="${RUNTIME_IMAGE}" --build-arg APP_NAME="${APP_NAME}" .