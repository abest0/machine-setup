#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# based on AWS Cloud9
# shutdown ec2 if no ssh connections after 1/2 hour
#  Add to cron to run every minute
#  User needs sudo permission to run 'shutdown'
#

set -euo pipefail

SHUTDOWN_TIMEOUT=30     # minutes
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
    shutdown_status=$(systemctl status systemd-shutdownd | grep -i 'status:' | tr -d '"' | awk '{print $2}')
    [[ $shutdown_status == Shut* ]]
}

is_vfs_connected() {
    pgrep vfs-worker >/dev/null
}

is_ssh_connected() {
    netstat -tpna | grep 'ESTABLISHED.*sshd' >> /dev/null;
}


isc=$(is_ssh_connected && echo "true" || echo "false")
if [[ "$isc" == true ]]; then
    debug "cron - ssh connected. DO NOT schedule a system shut down $0 | $isc"
else
    debug "cron - ssh not connected. Schedule a system shut down $0 | $isc"
fi

if is_shutting_down; then
    if is_vfs_connected || [[ "$isc" == true ]]; then
        debug "cron - cancelling shutdown."
        sudo shutdown -c
    fi
else
    if is_vfs_connected || [[ "$isc" == false ]]; then
        debug "cron - initiating shutdown!!"
        sudo shutdown -h $SHUTDOWN_TIMEOUT
    fi
fi
