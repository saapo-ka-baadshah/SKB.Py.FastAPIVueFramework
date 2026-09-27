#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
umask 077
GITHUB_TOKEN=""
GITHUB_USERNAME=""
KAFKA_CLUSTER_ID=""
COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-}"
ENABLE_GITHUB_CREDENTIALS=false

if [[ "${1:-}" == "--github" ]]; then
  ENABLE_GITHUB_CREDENTIALS=true
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--github]"
  exit 2
fi

########### FORMATTERS
LINE_SEPERATOR="--------------------------------------------------------------------"

# Function that appends or updates to the environment fild
_update_or_append_env_var() {
  local key="$1"
  local value="$2"
  local env_file="$3"

  # Ensure env_file exists
  touch "$env_file"

  # Escape special characters in value for sed if necessary, but for simple tokens/usernames, direct substitution is usually fine.
  # For very complex values, more robust escaping might be needed.
  # Here, we're quoting the value in the .env file, which helps.

  if grep -q "^${key}=" "$env_file"; then
    # If it exists, replace the line (works for BSD and GNU sed)
    # Using a different delimiter for sed to handle potential slashes in values, though less likely for tokens/usernames.
    sed -i.bak "s|^${key}=.*|${key}=\"${value}\"|" "$env_file"
    rm -f "${env_file}.bak" # Remove backup file on success
  else
    # If it doesn't exist, append it
    echo "${key}=\"${value}\"" >> "$env_file"
  fi
}

# Generate randomly generated passwords
generate_random_passwords(){
  if ! grep -q '^GRAFANA_ADMIN_PASSWORD=' "$ENV_FILE"; then
    _update_or_append_env_var "GRAFANA_ADMIN_PASSWORD" "$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')" "$ENV_FILE"
  fi
  if ! grep -q '^KEYCLOAK_ADMIN_PASSWORD=' "$ENV_FILE"; then
    _update_or_append_env_var "KEYCLOAK_ADMIN_PASSWORD" "$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')" "$ENV_FILE"
  fi
}

read_existing_kafka_cluster_id() {
  local project_name volume_name metadata cluster_id

  if ! command -v docker >/dev/null 2>&1; then
    return 0
  fi
  if ! docker info >/dev/null 2>&1; then
    echo "Error: start Docker so existing Kafka data can be checked before generating a cluster ID." >&2
    return 1
  fi

  project_name="${COMPOSE_PROJECT_NAME:-$(basename "$SCRIPT_DIR")}"
  volume_name="$(docker volume ls \
    --filter "label=com.docker.compose.project=$project_name" \
    --filter "label=com.docker.compose.volume=kafka_data" \
    --format '{{.Name}}' | head -n 1)"
  if [ -z "$volume_name" ]; then
    return 0
  fi

  if ! docker image inspect apache/kafka:3.9.1 >/dev/null 2>&1; then
    echo "Error: Kafka volume '$volume_name' exists, but apache/kafka:3.9.1 is unavailable to read its cluster ID." >&2
    return 1
  fi

  metadata="$(docker run --rm --volume "$volume_name:/kafka-data:ro" \
    --entrypoint /bin/cat apache/kafka:3.9.1 /kafka-data/meta.properties 2>/dev/null)" || return 0
  cluster_id="$(printf '%s\n' "$metadata" | sed -n 's/^cluster.id=//p' | head -n 1)"
  if [[ "$cluster_id" =~ ^[A-Za-z0-9_-]{22}$ ]]; then
    printf '%s' "$cluster_id"
  fi
}

generate_kafka_cluster_id() {
  if [ -n "$KAFKA_CLUSTER_ID" ]; then
    echo "Existing Kafka cluster ID found; preserving it."
    return 0
  fi

  local existing_cluster_id
  existing_cluster_id="$(read_existing_kafka_cluster_id)" || return 1
  if [ -n "$existing_cluster_id" ]; then
    KAFKA_CLUSTER_ID="$existing_cluster_id"
    _update_or_append_env_var "KAFKA_CLUSTER_ID" "$KAFKA_CLUSTER_ID" "$ENV_FILE"
    echo "Recovered and saved Kafka cluster ID from the existing data volume."
    return 0
  fi

  if ! command -v openssl >/dev/null 2>&1; then
    echo "Error: openssl is required to generate a Kafka cluster ID." >&2
    return 1
  fi

  KAFKA_CLUSTER_ID="$(openssl rand -base64 16 | tr '+/' '-_' | tr -d '=\n')"
  if [[ ! "$KAFKA_CLUSTER_ID" =~ ^[A-Za-z0-9_-]{22}$ ]]; then
    echo "Error: failed to generate a valid Kafka cluster ID." >&2
    return 1
  fi

  _update_or_append_env_var "KAFKA_CLUSTER_ID" "$KAFKA_CLUSTER_ID" "$ENV_FILE"
  echo "Generated and saved Kafka cluster ID."
}

# Function to load environment variables from .env file
load_env() {
  if [ -f "$ENV_FILE" ]; then
    echo "Found $ENV_FILE. Attempting to load credentials..."
    # Read line by line to avoid sourcing arbitrary code and handle comments/empty lines
    while IFS='=' read -r key value || [ -n "$key" ]; do
      # Remove leading/trailing whitespace from key and value
      key=$(echo "$key" | xargs)
      value=$(echo "$value" | xargs)
      # Remove surrounding quotes from value if present
      value="${value#\"}"
      value="${value%\"}"
      value="${value#\'}"
      value="${value%\'}"

      if [ "$key" = "GITHUB_TOKEN" ]; then
        GITHUB_TOKEN="$value"
      elif [ "$key" = "GITHUB_PACKAGES_FEED_PAT" ]; then
        GITHUB_TOKEN="$value"
      elif [ "$key" = "GITHUB_USERNAME" ]; then
        GITHUB_USERNAME="$value"
      elif [ "$key" = "KAFKA_CLUSTER_ID" ]; then
        KAFKA_CLUSTER_ID="$value"
      elif [ "$key" = "COMPOSE_PROJECT_NAME" ]; then
        COMPOSE_PROJECT_NAME="$value"
      fi
    done < "$ENV_FILE"

    if [ -n "$GITHUB_TOKEN" ]; then
      echo "GITHUB_TOKEN loaded from $ENV_FILE."
    else
      echo "GITHUB_TOKEN not found in $ENV_FILE."
    fi
    if [ -n "$GITHUB_USERNAME" ]; then
      echo "GITHUB_USERNAME loaded from $ENV_FILE."
    else
      echo "GITHUB_USERNAME not found in $ENV_FILE."
    fi
  else
    echo "$ENV_FILE not found. GitHub package authentication is optional; use --github to configure it."
  fi
}

# Function to prompt for and get the GitHub PAT
prompt_for_pat() {
  echo ""
  echo $LINE_SEPERATOR
  echo "GitHub Personal Access Token (PAT) Required"
  echo $LINE_SEPERATOR
  echo "This script needs a GitHub PAT to authenticate."
  echo "Using a PAT is more secure than using your password for scripts."
  echo ""
  echo "Please generate a PAT with the necessary scopes (e.g., 'repo' for private repositories, 'read:packages' for packages)."
  echo "You can create one here: https://github.com/settings/tokens"
  echo "Choose 'Fine-grained tokens' for better security if applicable."
  echo ""
  while true; do
    read -s -p "Enter your GitHub Personal Access Token: " INPUT_TOKEN
    echo # Newline after secret input
    if [ -n "$INPUT_TOKEN" ]; then
      GITHUB_TOKEN="$INPUT_TOKEN"
      break
    else
      echo "Token cannot be empty. Please try again."
    fi
  done
}

# Function to prompt for and get the GitHub Username
prompt_for_username() {
  echo ""
  echo "--------------------------------------------------------------------"
  echo "GitHub Username Required"
  echo "--------------------------------------------------------------------"
  while true; do
    read -p "Enter your GitHub Username: " INPUT_USERNAME
    if [ -n "$INPUT_USERNAME" ]; then
      GITHUB_USERNAME="$INPUT_USERNAME"
      break
    else
      echo "Username cannot be empty. Please try again."
    fi
  done
}

# Function to save/update GITHUB_TOKEN and GITHUB_USERNAME in .env file
save_credentials_to_env() {
  echo ""
  echo "Saving credentials to $ENV_FILE..."
  if [ -n "$GITHUB_TOKEN" ]; then
    _update_or_append_env_var "GITHUB_PACKAGES_FEED_PAT" "$GITHUB_TOKEN" "$ENV_FILE"
    echo "GITHUB_TOKEN saved/updated."
  else
    echo "Warning: GITHUB_TOKEN is empty, not saving it."
  fi

  if [ -n "$GITHUB_USERNAME" ]; then
    _update_or_append_env_var "GITHUB_USERNAME" "$GITHUB_USERNAME" "$ENV_FILE"
    echo "GITHUB_USERNAME saved/updated."
  else
    echo "Note: GITHUB_USERNAME is empty, not saving/updating it."
  fi
  echo "IMPORTANT: Ensure '$ENV_FILE' is listed in your .gitignore file to prevent committing secrets!"
}

# Function to test the GitHub token
test_github_token() {
  if [ -z "$GITHUB_TOKEN" ]; then
    echo "No GitHub token available to test."
    return 1
  fi

  local user_info_for_test="user"
  if [ -n "$GITHUB_USERNAME" ]; then
    user_info_for_test="users/$GITHUB_USERNAME"
    echo "Testing GitHub token by fetching info for user '$GITHUB_USERNAME'..."
  else
    echo "Testing GitHub token by fetching general user information..."
  fi

  # Using /user endpoint is generally better for token validation as it refers to the authenticated user
  API_ENDPOINT="https://api.github.com/user"

  API_RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "$API_ENDPOINT")

  if [ "$API_RESPONSE_CODE" = "200" ]; then
    echo "GitHub token is valid. Authentication successful."
    # Optionally, fetch and display the actual username authenticated by the token
    # local authenticated_user=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$API_ENDPOINT" | jq -r .login)
    # echo "Token belongs to user: $authenticated_user"
    # if [ -n "$GITHUB_USERNAME" ] && [ "$authenticated_user" != "$GITHUB_USERNAME" ]; then
    #   echo "Warning: The provided username '$GITHUB_USERNAME' does not match the token's owner ('$authenticated_user')."
    # fi
    return 0
  elif [ "$API_RESPONSE_CODE" = "401" ];then
    echo "Error: GitHub token is invalid, expired, or lacks necessary scopes (HTTP 401)."
    echo "Please check your token and its permissions."
    return 1
  elif [ "$API_RESPONSE_CODE" = "403" ];then
    echo "Error: Access forbidden (HTTP 403). This could be due to rate limiting or insufficient token scopes for the /user endpoint."
    return 1
  else
    echo "Error: Could not verify GitHub token. HTTP status code: $API_RESPONSE_CODE"
    echo "There might be a network issue or an incorrect API endpoint."
    return 1
  fi
}

# --- Main script execution ---

load_env
generate_kafka_cluster_id || exit 1

if [ "$ENABLE_GITHUB_CREDENTIALS" = true ]; then
  NEEDS_SAVE=false

  if [ -z "$GITHUB_USERNAME" ]; then
    prompt_for_username
    NEEDS_SAVE=true
  fi

  if [ -z "$GITHUB_TOKEN" ]; then
    prompt_for_pat
    NEEDS_SAVE=true
  fi

  if [ "$NEEDS_SAVE" = true ]; then
    save_credentials_to_env
  fi

  if ! test_github_token; then
    echo "GitHub authentication failed. Check the token and try again."
    exit 1
  fi
else
  echo "Skipping optional GitHub package authentication. Use --github to configure it."
fi

echo $LINE_SEPERATOR
echo "Generating Random Passwords"
echo $LINE_SEPERATOR
generate_random_passwords


echo $LINE_SEPERATOR
echo "DONE"
echo $LINE_SEPERATOR
exit 0
