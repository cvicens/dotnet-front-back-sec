#!/bin/sh

export APP_NAME=Backend02
export REGISTRY=quay.io
export REGISTRY_USER_ID=cvicens
export IMAGE_NAME=$(echo ${APP_NAME}  | tr '[:upper:]' '[:lower:]')
export IMAGE_VERSION=3.1
export BUILD_IMAGE=mcr.microsoft.com/dotnet/core/sdk:${IMAGE_VERSION}
export RUNTIME_IMAGE=mcr.microsoft.com/dotnet/core/aspnet:${IMAGE_VERSION}