#!/usr/bin/env bash
set -euo pipefail
R="$(cd "$(dirname "$0")" && pwd)"; cd "$R"; ulimit -n 1048576 2>/dev/null||ulimit -n 65536 2>/dev/null||true
set -a; [[ -f .env ]]&&source .env; [[ -f .secrets ]]&&source .secrets; set +a
P="${PORT:-3040}"; RP="${RENDERER_PORT:-8000}"; A="$R/avtr-1"; L="$R/logs/avtr-3040.log"
if command -v fuser >/dev/null 2>&1;then fuser -k "${P}/tcp" >/dev/null 2>&1||true; fuser -k "${RP}/tcp" >/dev/null 2>&1||true; fi
command -v lsof >/dev/null&&lsof -t -i:"${P}" -sTCP:LISTEN | xargs -r kill 2>/dev/null || true
command -v lsof >/dev/null&&lsof -t -i:"${RP}" -sTCP:LISTEN | xargs -r kill 2>/dev/null || true
[[ -d "$A/.pixi" && -z "${REINSTALL:-}" ]]||"$R/install.sh"
mkdir -p "$R/logs"; cd "$A"
export STREAMER_HOST="${STREAMER_HOST:-0.0.0.0}" STREAMER_PORT="$P" RENDERER_PORT="$RP"
nohup pixi run -e streamer interactive-demo >>"$L" 2>&1 & echo $! >"$R/logs/avtr-3040.pid"; cd "$R"
echo "PID $(<"$R/logs/avtr-3040.pid") log $L streamer :$P renderer :$RP"
