#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0";  )";  )
PROJECT_DIR="${SCRIPT_DIR}/.."

if [ $# -lt 1 ]; then
    echo "Usage: $0 <machine_name> [ansible-playbook options...]"
    echo "Example: $0 psr-ultra -e dev_user=dev -u ubuntu"
    exit 1
fi

machine_name=$1
shift 1

echo "Setting up machine: ${machine_name}"

cd "${PROJECT_DIR}"
uv run ansible-playbook playbook.yml -i "${machine_name}," -u ${dev_user:-ec2-user} $@
