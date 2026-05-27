#!/usr/bin/env bash
# Follow live AVTR-1 output written by run-3040.sh (logs/avtr-3040.log).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$ROOT/logs/avtr-3040.log"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Log file not found: $LOG_FILE" >&2
  echo "Start the app with ./run-3040.sh first (it creates logs/avtr-3040.log)." >&2
  exit 1
fi

echo "Tailing $LOG_FILE (Ctrl+C to stop watching)" >&2
tail -f "$LOG_FILE"
