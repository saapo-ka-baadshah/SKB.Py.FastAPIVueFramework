#!/usr/bin/env bash

########### FORMATTERS
LINE_SEPARATOR="--------------------------------------------------------------------"

stop(){
	docker compose \
		-f docker-compose.yml \
		-f docker-compose.cleanwebapi.yml \
		down
}

########### MAIN SCRIPT

echo $LINE_SEPARATOR
echo "Starting Docker Environment"
echo $LINE_SEPARATOR
# Start the dev environment here
stop
echo $LINE_SEPARATOR
echo "DONE"
echo $LINE_SEPARATOR

exit 0
