#!/bin/bash


function print_help {
    cat <<EOF
Change hostname and generate a new machine-id.

Usage:
    sudo ./hostname-mod.sh  NEW_HOSTNAME

Args:

  NEW_HOSTNAME              Change the hostname to a given parameter.

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


if [[ "$(id -ru)" != "0" ]]
then
    echo "Run this script with root privileges." 1>&2
    exit 1
fi


if [[ -z "${1}" ]]
then
    echo "Usage: ./hostname-mod.sh NEW_HOSTNAME" 1>&2
    exit 1
fi


#################################################################


# Global Vars
new_hostname="${1}"
current_hostname="$(hostname)"

IFS='\n'
HOSTS_PATH="/etc/hosts"
HOSTNAME_PATH="/etc/hostname"
MACHINE_ID_PATH="/etc/machine-id"


echo "Renaming hostname from '${current_hostname}' to '${new_hostname}'"
echo "${new_hostname}" > "${HOSTNAME_PATH}"


echo "Changing hostname entry in '${HOSTS_PATH}' to '${new_hostname}'"
etc_hosts="$(sed -E "s/${current_hostname}/${new_hostname}/" "${HOSTS_PATH}")"
echo "${etc_hosts}" > "${HOSTS_PATH}"


echo "Creating new '${MACHINE_ID_PATH}'"
rm "${MACHINE_ID_PATH}" && systemd-machine-id-setup
