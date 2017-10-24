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
error() { 
  printf "${red}✖ %s${reset}\n" "$@"
  exit -1
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
if [ -z "$ABS_DOCKER_PUSH_IMAGE" ]; then
  info 'Please build the image before pushing it'
  error 'A Docker image is required.'
fi

if [ -n "$ABS_DOCKER_PUSH_REGISTRY" ]; then
  REGISTRY="$ABS_DOCKER_PUSH_REGISTRY"
fi

if [ -z "$ABS_DOCKER_PUSH_USERNAME" ]; then
  error 'A username is required to login to the registry'
fi

if [ -z "$ABS_DOCKER_PUSH_PASSWORD" ]; then
  error 'A password is required to login to the registry'
fi

type_exists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

docker_login() {

  USERNAME="--username $ABS_DOCKER_PUSH_USERNAME"
  PASSWORD="--password $ABS_DOCKER_PUSH_PASSWORD"

  # Login to the registry
  info 'login to the docker registry'
  DOCKER_LOGIN="docker login $USERNAME $PASSWORD $REGISTRY"
  debug `echo $DOCKER_LOGIN | tr "$ABS_DOCKER_PUSH_PASSWORD" '***********'`
  docker login $USERNAME $PASSWORD $REGISTRY

  if [[ $? -ne 0 ]]; then
    error 'docker login errored';
  else
    success 'docker login succeed';
  fi
}

docker_logout() {
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
}

push_image() {
  # Push the docker image
  info 'pushing docker image'

  DOCKER_PUSH="docker push $ABS_DOCKER_PUSH_IMAGE"
  debug "$DOCKER_PUSH"
  docker push $ABS_DOCKER_PUSH_IMAGE

  if [[ $? -ne 0 ]];then
    docker_logout
    error 'docker push errored';
  else
    success 'docker push succeed';
  fi
}

# Check Docker is installed
if ! type_exists 'docker'; then
  info 'Please use a box with docker installed'
  error 'Docker is not installed on this box.'
fi

docker_login
push_image
docker_logout

set -e
