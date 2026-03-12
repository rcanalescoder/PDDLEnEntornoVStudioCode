# Mono y Banana (PDDL) con Fast Downward

Este repositorio contiene un ejemplo simple en PDDL (Planning Domain Definition Language) basado en el clásico problema del **mono que quiere alcanzar la banana** usando Fast Downward como planificador.

## 🧠 ¿De qué trata el problema?

El **mono** se encuentra en el suelo dentro de una habitación. Hay una **banana** colgando en el techo y una **caja** en el suelo. Para poder alcanzar la banana, el mono debe:

1. Moverse hacia la caja.
2. Subirse sobre la caja.
3. Alcanzar la banana desde la caja.
4. Agarrar la banana.

El objetivo del plan es que el mono termine sujetando la banana.

---

## 📁 Estructura de ficheros

```
/ (raíz del proyecto)
├── README.md
├── ejecutar.sh                    # Script para lanzar Fast Downward con este problema
├── downward/                      # Fast Downward (clonado/compilado)
└── pddl/
    ├── dominio-mono-banana.pddl   # Definición del dominio (acciones, tipos, predicados)
    └── problema-mono-banana.pddl  # Instancia del problema (objetos, estado inicial, objetivo)
```

---

## 🧩 Ficheros PDDL incluidos

### Dominio - `pddl/dominio-mono-banana.pddl`
Define:
- Tipos y predicados (ubicaciones, objetos, agente).
- Acciones del mono: moverse, empujar, subirse, bajarse, alcanzar la banana, agarrar y soltar.

### Problema - `pddl/problema-mono-banana.pddl`
Define:
- Objetos concretos (mono, caja, banano, suelo, techo).
- Estado inicial (dónde está cada cosa y que el mono no sujeta nada).
- Objetivo (el mono alcanza y sujeta la banana).

---

## ⚙️ Instalación del entorno (Fast Downward)

Fast Downward es un planificador en Python que se ejecuta desde la línea de comandos.

### Requisitos previos

- Python 3.8+ (recomendado)
- Git
- CMake (para compilar Fast Downward)
  - macOS: `brew install cmake`

### Pasos de instalación

Este proyecto asume que tienes el subdirectorio `downward/` en la raíz del repositorio.
Si no lo tienes, puedes clonarlo y compilarlo como se indica a continuación:

```bash
git clone https://github.com/aibasel/downward.git downward
cd downward
./build.py
```

> Si prefieres no compilar, también puedes usar la versión `fast-downward.py` directamente desde el árbol del repositorio (requiere Python 3).

---

## ▶️ Cómo ejecutar el planificador

### ✅ Opción recomendada: ejecutar con el script `ejecutar.sh`

Desde la raíz del proyecto:

```bash
./ejecutar.sh
```

El script ya incluye las rutas correctas a los ficheros `pddl/` y al binario compilado de Fast Downward (o al script `fast-downward.py` si no hay binario).

#### 📌 Salida esperada

- Verás en consola el plan encontrado, por ejemplo:
  - `subirse mono caja suelo`
  - `alcanzar mono caja banano`
  - `agarrar mono banano`

- Además, Fast Downward genera un archivo llamado `sas_plan` en el directorio donde se ejecutó el script (normalmente la raíz del proyecto).

### 🔧 Ejecución manual (sin script)

Desde el directorio `downward/`:

```bash
python3 fast-downward.py \
  /ruta/a/PDDLEnEntorno/pddl/dominio-mono-banana.pddl \
  /ruta/a/PDDLEnEntorno/pddl/problema-mono-banana.pddl \
  --search "astar(blind())"
```

- Sustituye `/ruta/a/PDDLEnEntorno` por la ruta real de este proyecto en tu sistema.
- Puedes probar otros algoritmos de búsqueda disponibles en Fast Downward (por ejemplo `astar(lmcut())`).

---

## 🧩 Extensiones útiles para Visual Studio Code (PDDL)

Para trabajar con PDDL desde VS Code, estas extensiones pueden ser muy útiles:

- **PDDL** (por Jeroen van der Heijden) — ofrece resaltado de sintaxis, completado y navegación básica.
- **PDDL Language Support** — añade validación, plegado y snippets.
- **PDDL Tools** — ayuda con el formateo y generación de plantillas.

> Consejo: configura tu espacio de trabajo para que `pddl/` esté en la raíz; muchas extensiones detectan automáticamente los ficheros `.pddl`.

---

## 📝 Notas adicionales

- Si quieres experimentar con variantes del problema (por ejemplo más objetos, más ubicaciones, cadenas de plataformas), simplemente crea nuevos archivos `problema-*.pddl` y ejecútalos con Fast Downward.
- El ejemplo está construido con nombres y comentarios en castellano para facilitar su comprensión.
