#!/usr/bin/env bash
set -euo pipefail

# Script para ejecutar Fast Downward con el dominio y problema del mono y la banana
# Uso:
#   ./ejecutar.sh

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOWNWARD_BIN="$BASE_DIR/downward/builds/release/bin/downward"
FAST_DOWNWARD_PY="$BASE_DIR/downward/fast-downward.py"
DOMINIO="$BASE_DIR/pddl/dominio-mono-banana.pddl"
PROBLEMA="$BASE_DIR/pddl/problema-mono-banana.pddl"

if [ -f "$FAST_DOWNWARD_PY" ]; then
  CMD=(python3 "$FAST_DOWNWARD_PY")
elif [ -x "$DOWNWARD_BIN" ]; then
  # El binario "downward" espera una entrada en formato SAS.
  # El script fast-downward.py se encarga de traducir PDDL a SAS y luego ejecuta el binario.
  CMD=("$DOWNWARD_BIN")
else
  echo "ERROR: No se encontró Fast Downward. Ejecuta './downward/build.py' desde el directorio 'downward' primero." >&2
  exit 1
fi

echo "Ejecutando Fast Downward sobre el problema del mono y la banana..."
"${CMD[@]}" "$DOMINIO" "$PROBLEMA" --search "astar(blind())"
