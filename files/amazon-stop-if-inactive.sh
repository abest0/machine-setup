#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# based on AWS Cloud9
# shutdown ec2 if no ssh connections after N minutes
#  User needs sudo permission to run 'shutdown'
#

set -euo pipefail

SHUTDOWN_TIMEOUT=60     # minutes
if ! [[ $SHUTDOWN_TIMEOUT =~ ^[0-9]*$ ]]; then
    echo "shutdown timeout is invalid"
    exit 1
fi

debug(){
    if [[ "${DEBUG:-false}" == true ]]; then
        logger $1
    fi
}

is_shutting_down() {
    is_shutting_down_system_d &> /dev/null || is_shutting_down_init_d &> /dev/null
}

is_shutting_down_system_d() {
    local TIMEOUT
    TIMEOUT=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager ScheduledShutdown)
    if [ "$?" -ne "0" ]; then
        return 1
    fi
    if (( "$(echo $TIMEOUT | awk '{print $3}')" < 0 )); then
        return 1
    else
        # return 0 when shutting down
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
    ss -tpna | grep 'ESTAB.*sshd' >> /dev/null;
}

isc=$(is_ssh_connected && echo "true" || echo "false")
if [[ "$isc" == true ]]; then
    debug "auto-shutdown - ssh connected. DO NOT schedule a system shut down $0 | $isc"
else
    debug "auto-shutdown - ssh not connected. Schedule a system shut down $0 | $isc"
fi

if is_shutting_down; then
    if [[ ! $SHUTDOWN_TIMEOUT =~ ^[0-9]+$ ]] || is_vfs_connected || [[ "$isc" == true ]]; then
        debug "auto-shutdown - cancelling shutdown."
        sudo shutdown -c
    fi
else
    if [[ $SHUTDOWN_TIMEOUT =~ ^[0-9]+$ ]] && ! is_vfs_connected && [[ "$isc" == false ]]; then
        debug "auto-shutdown - initiating shutdown!!"
        sudo shutdown -h $SHUTDOWN_TIMEOUT
    fi
fi
