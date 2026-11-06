#!/usr/bin/env bash
# Regenerates requirements-lock.txt: exact versions of every dependency in pyproject.toml
# (including the dev extra) except PyTorch, which CI installs separately from PyTorch's
# CPU-only index at the version pinned in .github/workflows/ci.yml.
#
# Usage, from anywhere in the repo:  bash scripts/update_lock.sh
set -euo pipefail
cd "$(dirname "$0")/.."

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

python3 - "$tmp" <<'PY'
import sys
import tomllib

with open("pyproject.toml", "rb") as f:
    project = tomllib.load(f)["project"]
deps = project["dependencies"] + project["optional-dependencies"]["dev"]
with open(sys.argv[1], "w") as out:
    out.write("\n".join(d for d in deps if not d.lower().startswith("torch")) + "\n")
PY

uv pip compile "$tmp" \
  --python-version 3.11 \
  --python-platform x86_64-unknown-linux-gnu \
  --no-annotate \
  --custom-compile-command "bash scripts/update_lock.sh" \
  --output-file requirements-lock.txt
