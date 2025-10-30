#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0";  )";  )
PROJECT_DIR="${SCRIPT_DIR}/.."

cd "${PROJECT_DIR}"
uv run ansible-galaxy install -r requirements.yml --force
