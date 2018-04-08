
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo -e "\e[36m\e[1mBuild triggered for PR #${TRAVIS_PULL_REQUEST} to branch \"${TRAVIS_BRANCH}\" - doing nothing."
  exit 0
fi

IMAGE=$DOCKER_USER/tdp_webhooks

if [ "$TRAVIS_TAG" ]; then
  echo -e "\e[36m\e[1mBuild triggered for tag \"${TRAVIS_TAG}\"."
else
  echo -e "\e[36m\e[1mBuild triggered for branch \"${TRAVIS_BRANCH}\"."
fi

echo $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin
docker build --pull -t $IMAGE .

if [ "$TRAVIS_TAG" ]; then
  docker tag $IMAGE $IMAGE:$TRAVIS_TAG
  docker push $IMAGE:$TRAVIS_TAG
fi

if [ "$TRAVIS_BRANCH" == "master" ]; then
  TAG=$IMAGE:latest
else
  TAG=$IMAGE:$TRAVIS_BRANCH
fi

docker tag $IMAGE $TAG
docker push $TAG