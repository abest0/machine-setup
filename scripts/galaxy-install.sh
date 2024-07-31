#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0";  )";  )
ansible-galaxy install -r "${SCRIPT_DIR}/../requirements.yml" --force
