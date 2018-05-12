BUILD_VERSION=$(
  VERSION=`cat version.txt`
  if [ -n "$CIRCLECI" ]; then
    if [ "$CIRCLE_BRANCH" != "master" ]; then
            PRERELEASE_ID="-$CIRCLE_BRANCH"
    fi
    BUILD_ID="$PRERELEASE_ID+$CIRCLE_BUILD_NUM"
  else
    BUILD_ID="-$USER"
  fi
  echo "$VERSION$BUILD_ID"
)
TAG_VERSION=${BUILD_VERSION%%+*}
