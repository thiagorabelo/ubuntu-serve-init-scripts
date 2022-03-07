#!/bin/bash

# TODO: Install 1.29.2 as optional and install 2+ as default.


function print_help {
    cat <<EOF
Install Docker and Docker Compose (1.29.2)

Usage:
    sudo ./install-docker.sh

Optional args:

  --help                    Print this message and exit.

EOF
}


for arg in "$@"
do
    case $arg in
        "--help")
        print_help
        exit 0
        ;;
    esac
done


function install_docker {
    #wget "${GET_DOCKER_URL}" -O- | bash
    curl "${GET_DOCKER_URL}" | bash
}


function install_compose {
    echo
    echo "Downloading in: ${TMP_DIR}"
    cd "${TMP_DIR}" && wget -c --progress="dot:binary" "${COMPOSE_URI}" -O "${COMPOSE_FILE_NAME}"
    cd "${TMP_DIR}" && chmod +x "${COMPOSE_FILE_NAME}"

    echo "Moving compose to: ${COMPOSE_PATH_DIR}"
    sudo mv "${TMP_DIR}/${COMPOSE_FILE_NAME}" "${COMPOSE_PATH_DIR}/${COMPOSE_FILE_NAME}"

    # Completion
    echo "Downloading completion (Bash) in: ${TMP_DIR}"
    cd "${TMP_DIR}" && wget -c --progress="dot:binary" "${COMPOSE_URI_COMPLETION}" -O "${COMPOSE_FILE_NAME_COMPLETION}"

    echo "Moving completion to: ${COMPOSE_COMPLETION_PATH_DIR}"
    sudo mv "${TMP_DIR}/${COMPOSE_FILE_NAME_COMPLETION}" "${COMPOSE_COMPLETION_PATH_DIR}/${COMPOSE_FILE_NAME_COMPLETION}"
}


if [[ "$(id -ru)" != "0" ]]
then
    echo "Run this script with root privileges." 1>&2
    exit 1
fi


# Global vars
user=${SUDO_USER:-$USER}

TMP_DIR="/tmp"
GET_DOCKER_URL="https://get.docker.com/"
COMPOSE_VERSION="1.29.2"
COMPOSE_URI="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
COMPOSE_PATH_DIR="/usr/local/bin/"
COMPOSE_FILE_NAME="docker-compose"
COMPOSE_FILE_NAME_COMPLETION="docker-compose"
COMPOSE_URI_COMPLETION="https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose"
COMPOSE_COMPLETION_PATH_DIR="/etc/bash_completion.d"


#################################################################


install_docker
install_compose


if [[ "${user}" != "root" ]]
then
    echo "Adding ${user} to docker group"
    usermod -aG docker "${user}"
fi
