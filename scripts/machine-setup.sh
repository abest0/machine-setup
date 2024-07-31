#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0";  )";  )


machine_name=$1
shift 1

echo "Setting up machine: ${machine_name}"

ansible-playbook "${SCRIPT_DIR}/../playbook.yml" -i "${machine_name}," -u ${dev_user:-ec2-user} $@
