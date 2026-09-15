#!/usr/bin/env bash
# Regenerate every figure and compare the bytes to the committed manifest.
# CXPLOT overrides the command (e.g. "docker run --rm -v $PWD:/work ghcr.io/neuhausi/cxplot:68.8" or
# "node /path/to/tools/cxplot/bin/cxplot.js"). Exit 1 on any mismatch.
set -euo pipefail
cd "$(dirname "$0")/.."
CXPLOT="${CXPLOT:-cxplot}"
mkdir -p out
for f in figures/*.json; do
  $CXPLOT validate "$f" >/dev/null
  $CXPLOT render "$f" -o "out/$(basename "${f%.json}").png"
done
$CXPLOT hash figures/*.json --compare figures.manifest.json
