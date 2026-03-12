#!/usr/bin/env python3
"""Run Fast Downward on the Mono+Banana PDDL problem.

This script is intended for this project (PDDL example "mono y banana").
It locates the Fast Downward installation under `downward/` and runs it with
reasonable defaults.

Usage:
    ./run_fast_downward.py
    ./run_fast_downward.py --domain pddl/dominio-mono-banana.pddl --problem pddl/problema-mono-banana.pddl
    ./run_fast_downward.py --search "astar(lmcut())" --output plan.txt

The script uses `fast-downward.py` (translator + planner) when available.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys


def localizar_fast_downward(raiz: str) -> str | None:
    """Localiza el script `fast-downward.py` en el árbol del proyecto."""
    candidato = os.path.join(raiz, "downward", "fast-downward.py")
    if os.path.isfile(candidato):
        return candidato
    return None


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Ejecuta Fast Downward con el problema mono/banana.")
    parser.add_argument(
        "--domain",
        default="pddl/dominio-mono-banana.pddl",
        help="Fichero PDDL de dominio (por defecto: pddl/dominio-mono-banana.pddl)",
    )
    parser.add_argument(
        "--problem",
        default="pddl/problema-mono-banana.pddl",
        help="Fichero PDDL de problema (por defecto: pddl/problema-mono-banana.pddl)",
    )
    parser.add_argument(
        "--search",
        default="astar(blind())",
        help="Estrategia de búsqueda para Fast Downward (por defecto: astar(blind()))",
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Archivo donde guardar el plan generado (por defecto: muestra en stdout)",
    )
    parser.add_argument(
        "--keep-sas",
        action="store_true",
        help="Conservar el fichero intermedio output.sas generado por el traductor.",
    )
    argumentos = parser.parse_args(argv)

    raiz = os.path.dirname(os.path.abspath(__file__))
    fast_downward = localizar_fast_downward(raiz)

    if fast_downward is None:
        print("ERROR: No se encuentra fast-downward.py. Asegúrate de clonar el subdirectorio 'downward'.", file=sys.stderr)
        return 2

    dominio = os.path.join(raiz, argumentos.domain)
    problema = os.path.join(raiz, argumentos.problem)

    if not os.path.isfile(dominio) or not os.path.isfile(problema):
        print(
            f"ERROR: No se encuentran los ficheros PDDL:\n  dominio: {dominio}\n  problema: {problema}",
            file=sys.stderr,
        )
        return 3

    comando = [sys.executable, fast_downward, dominio, problema, "--search", argumentos.search]

    print("Ejecutando Fast Downward:")
    print("  ", " ".join(comando))

    entorno = os.environ.copy()
    entorno["PYTHONUNBUFFERED"] = "1"

    proceso = subprocess.Popen(comando, env=entorno)
    codigo_salida = proceso.wait()

    if codigo_salida != 0:
        print(f"Fast Downward terminó con código {codigo_salida}", file=sys.stderr)
        return codigo_salida

    if argumentos.output:
        # Si se pide volcar el plan, copiamos sas_plan (generado por fast-downward)
        origen_plan = os.path.join(raiz, "sas_plan")
        if os.path.isfile(origen_plan):
            try:
                with open(origen_plan, "r", encoding="utf-8") as fsrc, open(argumentos.output, "w", encoding="utf-8") as fdst:
                    fdst.write(fsrc.read())
                print(f"Plan guardado en {argumentos.output}")
            except OSError as e:
                print(f"ERROR al copiar el plan: {e}", file=sys.stderr)
                return 4
        else:
            print("Aviso: no se encontró el fichero 'sas_plan' para copiar.", file=sys.stderr)

    if not argumentos.keep_sas:
        ruta_sas = os.path.join(raiz, "output.sas")
        if os.path.exists(ruta_sas):
            try:
                os.remove(ruta_sas)
            except OSError:
                pass

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
