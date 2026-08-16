#!/bin/zsh
set -euo pipefail
ROOT="${0:A:h}"
"$ROOT/Brightness/Uninstall.command"
echo "Power and sleep settings were not modified."
