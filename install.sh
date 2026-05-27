#!/usr/bin/env bash
set -euo pipefail
R="$(cd "$(dirname "$0")" && pwd)"
A="$R/avtr-1"
set -a
[[ -f "$R/.env" ]] && source "$R/.env"
[[ -f "$R/.secrets" ]] && source "$R/.secrets"
set +a
HF_TOKEN="${HF_TOKEN:-${HUGGING_FACE_HUB_TOKEN:-}}"
command -v pixi >/dev/null 2>&1 || {
  echo "pixi is required: curl -fsSL https://pixi.sh/install.sh | sh" >&2
  exit 1
}
if [[ -z "$HF_TOKEN" ]]; then
  echo "HF_TOKEN is required in .secrets (see .secrets.example)." >&2
  echo "Create a token at https://huggingface.co/settings/tokens" >&2
  echo "Accept gated access at https://huggingface.co/avaturn-live/avtr-1" >&2
  exit 1
fi
export HF_TOKEN HUGGING_FACE_HUB_TOKEN="$HF_TOKEN"
cd "$A"
pixi install
pixi run hf auth login --token "$HF_TOKEN"
pixi run python scripts/download_artifacts.py
pixi run build-trt-engines
