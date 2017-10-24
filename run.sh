#!/bin/bash

set +e
set -o noglob


#
# Set Colors
#

bold=
underline=
reset=

red=
green=
white=
tan=
blue=

#
# Headers and Logging
#

underline() { printf "${underline}${bold}%s${reset}\n" "$@"
}
h1() { printf "\n${underline}${bold}${blue}%s${reset}\n" "$@"
}
h2() { printf "\n${underline}${bold}${white}%s${reset}\n" "$@"
}
debug() { printf "${white}%s${reset}\n" "$@"
}
info() { printf "${white}➜ %s${reset}\n" "$@"
}
success() { printf "${green}✔ %s${reset}\n" "$@"
}
error() { printf "${red}✖ %s${reset}\n" "$@"
}
warn() { printf "${tan}➜ %s${reset}\n" "$@"
}
bold() { printf "${bold}%s${reset}\n" "$@"
}
note() { printf "\n${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@"
}


type_exists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

# variable
# docker.push.image
# docker.push.registry
# docker.push.username
# docker.push.password
# docker.push.email
if [ -z "$ABS_DOCKER_PUSH_IMAGE" ]; then
  error 'A Docker image is required.'
  info 'Please build the image before pushing it'
  exit -1
fi

if [ -n "$ABS_DOCKER_PUSH_REGISTRY" ]; then
  REGISTRY="$ABS_DOCKER_PUSH_REGISTRY"
fi

if [ -z "$ABS_DOCKER_PUSH_USERNAME" ]; then
  error 'A username is required to login to the registry'
  exit -1
fi

if [ -z "$ABS_DOCKER_PUSH_PASSWORD" ]; then
  error 'A password is required to login to the registry'
  exit -1
fi

if [ -z "$ABS_DOCKER_PUSH_EMAIL" ]; then
  error 'An email is required to login to the registry'
  exit -1
fi


type_exists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

# Check Docker is installed
if ! type_exists 'docker'; then
  error 'Docker is not installed on this box.'
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
docker login $USERNAME $PASSWORD $EMAIL $REGISTRY

if [[ $? -ne 0 ]]; then
  error 'docker login errored';
else
  success 'docker login succeed';
fi

# Push the docker image
info 'pushing docker image'

DOCKER_PUSH="docker push $ABS_DOCKER_PUSH_IMAGE"
debug "$DOCKER_PUSH"
docker push $ABS_DOCKER_PUSH_IMAGE

if [[ $? -ne 0 ]];then
  error 'docker push errored';
else
  success 'docker push succeed';
fi

# Logout from the registry
info 'logout to the docker registry'
DOCKER_LOGOUT="docker logout $REGISTRY"
debug "$DOCKER_LOGOUT"
docker logout $REGISTRY

if [[ $? -ne 0 ]];then
  error 'docker logout errored';
else
  success 'docker logout succeed';
fi

set -e
