#!/usr/bin/env bash

########### FORMATTERS
LINE_SEPARATOR="--------------------------------------------------------------------"

check_dotenv_exists() {
  if [ -f ".env" ]; then
    return 0 # .env exists and is a regular file
  else
    return 1 # .env does not exist or is not a regular file
  fi
}

start_docker_environment_in_dev(){
	docker compose up -d
}

########### MAIN SCRIPT

if check_dotenv_exists; then
	echo $LINE_SEPARATOR
	echo "Environment file found: $PWD/.env"
	echo $LINE_SEPARATOR
else
	echo $LINE_SEPARATOR
	echo "Environment file not found at: $PWD/.env"
	echo "Please generate the environment variables with script: 0_create_env.sh"
	echo "run: ./0_create_env.sh"
	echo "[FATAL] Exiting..."
	echo $LINE_SEPARATOR
	exit 1
fi

echo $LINE_SEPARATOR
echo "Starting Docker Environment"
echo $LINE_SEPARATOR
# Start the dev environment here
start_docker_environment_in_dev
echo $LINE_SEPARATOR
echo "DONE"
echo $LINE_SEPARATOR

exit 0
