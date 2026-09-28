#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
VENV_DIR="$REPO_ROOT/venv"

# Check if the virtual environment directory exists, if not create it
if [[ ! -d "$VENV_DIR" ]]; then
	python3 -m venv "$VENV_DIR"
fi

export OTEL_SERVICE_NAME="aaaaaa"
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"

# Enable implicit logging context injection
export OTEL_PYTHON_LOG_AUTO_INSTRUMENTATION="true"
export OTEL_PYTHON_LOG_CORRELATION="true"

source "$VENV_DIR/bin/activate"