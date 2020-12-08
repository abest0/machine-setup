#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CONFIG=$(cat /home/ubuntu/.c9/autoshutdown-configuration)
SHUTDOWN_TIMEOUT=${CONFIG#*=}
if ! [[ $SHUTDOWN_TIMEOUT =~ ^[0-9]*$ ]]; then
    echo "shutdown timeout is invalid"
    exit 1
fi
is_shutting_down() {
    is_shutting_down_system_d &> /dev/null || is_shutting_down_init_d &> /dev/null
}

is_shutting_down_system_d() {
    local TIMEOUT
    TIMEOUT=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager ScheduledShutdown)
    if [ "$?" -ne "0" ]; then
        return 1
    fi
    if [ "$(echo $TIMEOUT | awk "{print \$3}")" == "0" ]; then
        return 1
    else
        return 0
    fi
}

is_shutting_down_init_d() {
    pgrep shutdown
}

is_vfs_connected() {
    pgrep vfs-worker >/dev/null
}

is_ssh_connected() {
    netstat -tpna | grep 'ESTABLISHED.*sshd' >> /dev/null;
}

isc=$(is_ssh_connected && echo "true" || echo "false")
if is_shutting_down; then
    if [[ ! $SHUTDOWN_TIMEOUT =~ ^[0-9]+$ ]] || is_vfs_connected || [[ "$isc" == true ]]; then
        sudo shutdown -c
    fi
else
    if [[ $SHUTDOWN_TIMEOUT =~ ^[0-9]+$ ]] && ! is_vfs_connected && [[ "$isc" == false ]]; then
        sudo shutdown -h $SHUTDOWN_TIMEOUT
    fi
fi
