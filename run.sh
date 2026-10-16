#!/usr/bin/env bash
# Start the Diffusers engine with the venv install.sh made (or DIFFUSERS_VENV).
set -euo pipefail
ENGINE_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ENGINE_DIR"

# A venv counts only when its Python runs: a venv moved or left behind by an older install has
# scripts pointing at an interpreter that is gone.
venv_ok() {
  [[ -x "$1/bin/uvicorn" ]] && "$1/bin/python" -c '' >/dev/null 2>&1
}

resolve_venv() {
  if [[ -n "${DIFFUSERS_VENV:-}" ]] && venv_ok "${DIFFUSERS_VENV}"; then
    printf '%s\n' "$DIFFUSERS_VENV"
    return 0
  fi
  # install.sh's venv, next to this script
  if venv_ok "${ENGINE_DIR}/.venv"; then
    printf '%s\n' "${ENGINE_DIR}/.venv"
    return 0
  fi
  # Older Castcut installs kept it in the XDG cache
  local cache_venv="${XDG_CACHE_HOME:-$HOME/.cache}/comfyui-prompt-studio/diffusers-engine/.venv"
  if venv_ok "${cache_venv}"; then
    printf '%s\n' "$cache_venv"
    return 0
  fi
  return 1
}

if ! VENV="$(resolve_venv)"; then
  echo "No working Diffusers venv — run $ENGINE_DIR/install.sh (or set DIFFUSERS_VENV=/path/to/venv)." >&2
  exit 1
fi

export COMFYUI_ROOT="${COMFYUI_ROOT:-/opt/comfyui}"
HOST="${DIFFUSERS_LISTEN_HOST:-127.0.0.1}"
PORT="${DIFFUSERS_LISTEN_PORT:-8190}"
# Allow: ./run.sh --port 8191
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST="$2"
      shift 2
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done
exec "$VENV/bin/uvicorn" app.main:app --host "$HOST" --port "$PORT"
