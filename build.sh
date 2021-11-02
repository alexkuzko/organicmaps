#!/bin/bash

echo "This script is for manual build of the base/release images, should be run by Docker Hub repository owner only! Press Ctrl+C to exit if you run it by mistake. Execution starts in 5 seconds."
sleep 5;
if [[ -z "${1}" ]]; then echo "Use release-XXX-base or release-XXX as first param in order to build either base image or release images, for additional debug images pass anything as second param."; exit 1; fi;
if [[ "${1}" =~ "-base" ]]; then echo -n "Building base image"; export DOCKERFILE_PATH=Dockerfile; else echo -n "Building release images"; export DOCKERFILE_PATH=Dockerfile.release; fi;
echo ", press Ctrl+C to exit if you selected wrong image. Executing starts in 5 seconds."
sleep 5;
export DOCKER_REPO=index.docker.io/alexkuzko/organicmaps
export DOCKER_TAG="${1}"
export SOURCE_BRANCH="${1}"
bash hooks/build && \
bash hooks/post_build "${2}" && \
bash hooks/post_push "${2}" && \
echo "Pushing to Docker Hub" && \
docker push "${DOCKER_REPO}:${DOCKER_TAG}" && \
echo "DONE" || { echo "ERROR"; exit 1; }
