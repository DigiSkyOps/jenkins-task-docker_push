#!/bin/bash
#!/bin/sh
set -e

if [ -z "$ABS_DOCKER_PUSH_IMAGE" ]; then
  fail 'A Docker image is required.'
  info 'Please build the image before pushing it'
fi

if [ -n "$ABS_DOCKER_PUSH_REGISTRY" ]; then
  REGISTRY="$ABS_DOCKER_PUSH_REGISTRY"
fi

if [ -z "$ABS_DOCKER_PUSH_USERNAME" ]; then
  fail 'A username is required to login to the registry'
fi

if [ -z "$ABS_DOCKER_PUSH_PASSWORD" ]; then
  fail 'A password is required to login to the registry'
fi

if [ -z "$ABS_DOCKER_PUSH_EMAIL" ]; then
  fail 'An email is required to login to the registry'
fi


type_exists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

# Check Docker is installed
if ! type_exists 'docker'; then
  fail 'Docker is not installed on this box.'
  info 'Please use a box with docker installed'
  exit 1
fi

set +e

USERNAME="--username $ABS_DOCKER_PUSH_USERNAME"
PASSWORD="--password $ABS_DOCKER_PUSH_PASSWORD"
EMAIL="--email $ABS_DOCKER_PUSH_EMAIL"

# Login to the registry
info 'login to the docker registry'
DOCKER_LOGIN="docker login $USERNAME $PASSWORD $EMAIL $REGISTRY"
debug `echo $DOCKER_LOGIN | tr "$PASSWORD" '***********'`
DOCKER_LOGIN_OUTPUT=$($DOCKER_LOGIN)

if [[ $? -ne 0 ]]; then
  warn $DOCKER_LOGIN_OUTPUT
  fail 'docker login failed';
else
  success 'docker login succeed';
fi

# Push the docker image
info 'pushing docker image'

DOCKER_PUSH="docker push $ABS_DOCKER_PUSH_IMAGE"
debug "$DOCKER_PUSH"
DOCKER_PUSH_OUTPUT=$($DOCKER_PUSH)

if [[ $? -ne 0 ]];then
  warn $DOCKER_PUSH_OUTPUT
  fail 'docker push failed';
else
  success 'docker push succeed';
fi

# Logout from the registry
info 'logout to the docker registry'
DOCKER_LOGOUT="docker logout $REGISTRY"
debug "$DOCKER_LOGOUT"
DOCKER_LOGOUT_OUTPUT=$($DOCKER_LOGOUT)

if [[ $? -ne 0 ]];then
  warn $DOCKER_LOGOUT_OUTPUT
  fail 'docker logout failed';
else
  success 'docker logout succeed';
fi

set -e
