#!/bin/bash

set -eo pipefail

echo "Sourcing environment from ./.env..."
. ./.env
CONTAINER_TAG=`date +"%s"`
CONTAINER_NAME=hello
DOCKER_REGISTRY_URL=${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/hello

containerTag="${DOCKER_REGISTRY_URL}/${CONTAINER_NAME}:${CONTAINER_TAG}"
latestTag="${DOCKER_REGISTRY_URL}/${CONTAINER_NAME}:latest"

echo "Impersonating service account ${TERRAFORM_SERVICE_ACCOUNT}..."
gcloud config set auth/impersonate_service_account ${TERRAFORM_SERVICE_ACCOUNT}

echo "Building container image ${containerTag}..."
docker buildx build -t $containerTag -t $latestTag -f ./Dockerfile .
echo "Done."

echo "Authorising Docker with artifact repo..."
gcloud auth configure-docker ${GCP_REGION}-docker.pkg.dev --quiet
echo "Done."

echo "Pushing image to artifact repo..."
docker push --all-tags ${DOCKER_REGISTRY_URL}/${CONTAINER_NAME}
echo "Done."

echo "Deploying new revision to Cloud Run..."
gcloud run deploy hello --image ${containerTag} --region ${GCP_REGION}
echo "Done."

echo "Unsetting service account impersonation..."
gcloud config unset auth/impersonate_service_account
echo "Done."

echo "Cleaning up images..."
docker image rm -f `docker image ls | grep hello | awk '{print $3}' | grep -v IMAGE`
echo "Done."