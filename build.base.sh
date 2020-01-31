#!/bin/bash

echo "This script is for manual build of the base image, should be run by Docker Hub repository owner only! Press Ctrl+C to exit if you run it by mistake. Execution starts in 5 seconds."
sleep 5;
if [[ -z $1 ]]; then echo "Use release-XXX-base as first param in order to build base image"; exit 1; fi;
export DOCKER_REPO=index.docker.io/alexkuzko/omim
export DOCKERFILE_PATH=Dockerfile
export DOCKER_TAG=$1
export SOURCE_BRANCH=$1
bash hooks/build

echo "Pushing to Docker Hub"
docker push "${DOCKER_REPO}:${DOCKER_TAG}"
