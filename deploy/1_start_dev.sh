#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

########### FORMATTERS
LINE_SEPARATOR="--------------------------------------------------------------------"

check_dotenv_exists() {
	[[ -f "$SCRIPT_DIR/.env" ]]
}

########### MAIN SCRIPT

if check_dotenv_exists; then
	echo $LINE_SEPARATOR
	echo "Environment file found: $SCRIPT_DIR/.env"
	echo $LINE_SEPARATOR
else
	echo $LINE_SEPARATOR
	echo "Environment file not found at: $SCRIPT_DIR/.env"
	echo "Please generate the environment variables with script: 0_create_env.sh"
	echo "run: ./0_create_env.sh"
	echo "[FATAL] Exiting..."
	echo $LINE_SEPARATOR
	exit 1
fi

echo $LINE_SEPARATOR
echo "Starting Docker Environment"
echo $LINE_SEPARATOR
cd "$SCRIPT_DIR"
docker compose -f docker-compose.yml -f docker-compose.web.yml up --build -d
echo $LINE_SEPARATOR
echo "DONE"
echo $LINE_SEPARATOR

exit 0
