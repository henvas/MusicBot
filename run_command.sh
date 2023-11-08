#!/bin/bash
# set -e
# Enable for debugging
# set -x

show_help() {
cat << EOF
Usage: ${0##*/} [COMMAND]
Run a command in the docker container.
    -h|--help              Display this help and exit.
    --notty                Run Docker without -it arguments
    --detached             Run Docker detached with -d
    --noname               Give the Docker container a random name

Example usage:
${0} tmux
EOF
exit 1
}

# The last argument is the command we want to run in docker container
DOCKER_BASH_COMMAND="${@: -1}"
if [[ "$DOCKER_BASH_COMMAND" =~ ^- ]]; then
    show_help
fi

# Parse command line arguments
while [[ "$#" > 1 ]]; do case $1 in
    -h|--help) show_help; break;;
    --notty) NOTTY="y";;
    --detached) DETACHED="y";;
    --noname) NONAME="y";;
    *) echo -e "Unknown parameter passed: $1\n"; show_help; exit 1;;
esac; shift; done

if [ "$#" -ne 1 ]; then
    show_help
fi

# Mount git repo's root folder
TOPDIR="$(dirname $(readlink -f $0))"
MOUNTDIR=${TOPDIR}

DOCKER_CONTAINER_NAME="pythonbot"

# Location of repo inside docker container
REPO_LOCATION="/musicbot"

if [ "$NOTTY" != "y" ]; then
    DOCKER_OPTIONS="${DOCKER_OPTIONS} \
        -it"
fi
if [ "$DETACHED" == "y" ]; then
    DOCKER_OPTIONS="${DOCKER_OPTIONS} -d"
fi
if [ "$NONAME" != "y" ]; then
    DOCKER_OPTIONS="${DOCKER_OPTIONS} --name $DOCKER_CONTAINER_NAME"
fi

DOCKER_OPTIONS="
${DOCKER_OPTIONS} \
--rm \
--privileged \
--ipc=host \
--hostname=$HOSTNAME \
--env TZ=Europe/Oslo \
--workdir="${REPO_LOCATION}" \
--volume $MOUNTDIR:${REPO_LOCATION} \
"

DOCKER_COMMAND="docker run"
DOCKER_IMAGE_NAME="musicbot3.8"

echo ""
set -x
${DOCKER_COMMAND} ${DOCKER_OPTIONS} ${DOCKER_IMAGE_NAME} bash -c "${DOCKER_BASH_COMMAND}"
