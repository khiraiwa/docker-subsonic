#! /bin/bash
set -io pipefail

DIR="$( cd -- "$( dirname -- "$0" )" && pwd )"
echo $DIR
cd -- "$DIR"

. getversion.sh

echo "docker tagversion ${TAG_VERSION}"

DOCKER_TAG="${DOCKER_REPO}"

docker build --tag="$DOCKER_TAG" "$@" .

# And tag it with the version number
docker tag "$DOCKER_TAG" "$DOCKER_TAG:$TAG_VERSION"

# If running on Circle, add a branch label, too.
if [ -n "$CIRCLE_BRANCH" ]; then
  docker tag "$DOCKER_TAG" "$DOCKER_TAG:${CIRCLE_BRANCH}_latest"
fi
