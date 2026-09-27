#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

########### FORMATTERS
LINE_SEPARATOR="--------------------------------------------------------------------"

stop(){
	cd "$SCRIPT_DIR"
	docker compose -f docker-compose.yml -f docker-compose.web.yml down
}

########### MAIN SCRIPT

echo $LINE_SEPARATOR
echo "Stopping Docker Environment"
echo $LINE_SEPARATOR
# Start the dev environment here
stop
echo $LINE_SEPARATOR
echo "DONE"
echo $LINE_SEPARATOR

exit 0
