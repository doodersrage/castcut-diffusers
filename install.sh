#!/usr/bin/env bash
# Set up the engine's Python environment: a venv (default: .venv next to this script) with
# requirements.txt installed. Castcut runs this after Settings → Inference engine → Install;
# run it yourself for a manual install. Needs Python 3.10+.
set -euo pipefail
ENGINE_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV="${DIFFUSERS_VENV:-$ENGINE_DIR/.venv}"
PYTHON="${PYTHON:-$(command -v python3 || command -v python || true)}"
if [[ -z "$PYTHON" ]] || ! command -v "$PYTHON" >/dev/null 2>&1; then
  echo "Python 3.10+ is needed to install the Diffusers engine (none found on PATH)." >&2
  exit 2
fi
if ! "$PYTHON" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)'; then
  echo "Python 3.10+ is needed; found $("$PYTHON" --version 2>&1)." >&2
  exit 2
fi
if [[ ! -x "$VENV/bin/pip" ]]; then
  echo "Creating venv at $VENV"
  "$PYTHON" -m venv "$VENV"
fi
"$VENV/bin/pip" install --upgrade pip
"$VENV/bin/pip" install -r "$ENGINE_DIR/requirements.txt"
echo "Diffusers engine ready. Start it with: $ENGINE_DIR/run.sh"
