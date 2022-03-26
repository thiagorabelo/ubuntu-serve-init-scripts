#!/bin/bash


function print_help {
    cat <<EOF
Initial configurations for Ubuntu Server.
Add user to sudores without use of password. If user is root skip.

Usage:
    sudo ./initial-config.sh  [OPTIONAL_ARGS]

Optional args:

  --disable-ipv6            Disable IPv6 adding entry in Grub configuration.
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


function sudoer {
    # Adiciona configuração que permite o uso de sudo sem senha.

    local file_path="/etc/sudoers.d/90-init-users"
    echo "# User rules for ${1}" > "${file_path}"
    echo "${1} ALL=(ALL) NOPASSWD:ALL" >> "${file_path}"
    usermod -aG sudo "${1}" 2>/dev/null
}


function disable_ipv6 {
    # Adiciona configuração no grub que desabilita o ipv6

    local grub_path="/etc/default/grub"
    local new_grub_content=$(cat "${grub_path}" \
        | sed -E 's/GRUB_CMDLINE_LINUX_DEFAULT="([^"]*)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 ipv6.disable=1"/' \
        | sed -E 's/GRUB_CMDLINE_LINUX="([^"]*)"/GRUB_CMDLINE_LINUX="\1 ipv6.disable=1"/')
    echo "${new_grub_content}" > "${grub_path}"
    update-grub
}


# TODO: Use me
function npt_br {
    local tmpfile="/tmp/timesyncd.conf"
    local timesyncdpath="/etc/systemd/timesyncd.conf"

    local timezone="America/Fortaleza"
    local ntpserver="pool.ntp.br"
    local ntpserverfallback="ntp.ubuntu.com"

    timedatectl set-timezone "${timezone}"

    cat "${timesyncdpath}" \
        | sed -E "s/^#NTP=.*$/NTP=${ntpserver}/" \
        | sed -E "s/^#FallbackNTP=.*$/FallbackNTP=${ntpserverfallback}/" > "${timesyncdpath}"

    mv "${tmpfile}" "${timesyncdpath}"

    timedatectl set-ntp true

    systemctl restart systemd-timesyncd.service
}


#################################################################


# Global vars
user=${SUDO_USER:-$USER}


# Run by default
if [[ "${user}" != "root" ]]
then
    echo "Adding ${user} to passwordless sudoers"
    sudoer ${user}
fi


for arg in "$@"
do
    case $arg in
        "--disable-ipv6")
        disable_ipv6
        ;;
    esac
done
