#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CONFIG="${1:-debug}"

"$ROOT_DIR/scripts/build.sh" "$CONFIG"
open "$ROOT_DIR/build/Scap.app"
