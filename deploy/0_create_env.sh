#!/usr/bin/env bash

ENV_FILE=".env"
GITHUB_TOKEN=""
GITHUB_USERNAME=""

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
	# Generate password for GRAFANA ADMIN
	_update_or_append_env_var "GRAFANA_ADMIN_PASSWORD" "$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')" "$ENV_FILE"
	# Generate password for RABBIT ADMIN
	_update_or_append_env_var "RABBIT_ADMIN_PASSWORD" "$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')" "$ENV_FILE"
	# Generate password for KEYCLOAK ADMIN
	_update_or_append_env_var "KEYCLOAK_ADMIN_PASSWORD" "$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')" "$ENV_FILE"
}

# Generate project root and fix it
fix_project_root(){
	_update_or_append_env_var "PROJECT_ROOT" "$(git rev-parse --show-toplevel)" "$ENV_FILE"
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
      elif [ "$key" = "GITHUB_USERNAME" ]; then
        GITHUB_USERNAME="$value"
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
    echo "$ENV_FILE not found. Will prompt for credentials."
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

NEEDS_SAVE=false

# Fix the project root
echo $LINE_SEPERATOR
echo "Fixing project root"
fix_project_root
echo $LINE_SEPERATOR
echo "DONE"
echo $LINE_SEPERATOR

# Prompt for Username if not loaded
if [ -z "$GITHUB_USERNAME" ]; then
  prompt_for_username
  if [ -n "$GITHUB_USERNAME" ]; then
    NEEDS_SAVE=true
  # If username prompt is skipped or results in empty, we might still proceed if token is good.
  # else
  #   echo "No GitHub username was provided. Proceeding without it for saving."
  fi
fi

# Prompt for PAT if not loaded
if [ -z "$GITHUB_TOKEN" ]; then
  prompt_for_pat
  if [ -n "$GITHUB_TOKEN" ]; then
    NEEDS_SAVE=true
  else
    echo "No GitHub token was provided. Exiting."
    exit 1
  fi
fi

# Save to .env if any new information was prompted for
if [ "$NEEDS_SAVE" = true ]; then
  save_credentials_to_env
fi

echo ""
test_github_token
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
  echo "You are now authenticated with GitHub using the credentials in $ENV_FILE."
  echo "You can now use these in other scripts or applications by sourcing $ENV_FILE or reading it."
  echo "Example (in bash/zsh): source $ENV_FILE && echo \$GITHUB_TOKEN"
else
  echo "Authentication failed. Please check the token (and username if relevant) and try again."
  echo "If credentials were just saved to $ENV_FILE, you might need to correct them manually or re-run the script."
  exit 1
fi


echo $LINE_SEPERATOR
echo "Generating Random Passwords"
echo $LINE_SEPERATOR
generate_random_passwords


echo $LINE_SEPERATOR
echo "DONE"
echo $LINE_SEPERATOR
exit 0
