# Interpretación del dominio “mono-banana” (PDDL)

Este repositorio contiene un dominio PDDL llamado **`mono-banana`** que modela un problema clásico: un mono quiere alcanzar y sujetar un banano usando una caja como plataforma.

El objetivo de este documento es explicar de forma clara cómo está estructurado el dominio, qué significan sus tipos, predicados y acciones, y cómo el problema específico define instancias y objetivos para que un planificador resuelva la tarea.

---

## 1) Tipos (`:types`)

Los tipos definen las **categorías de objetos** que hay en el dominio.

```pddl
(:types
  objeto ubicacion
  agente - objeto)
```

- `objeto`: tipo general para cualquier cosa que pueda moverse o colocarse (caja, banano, etc.).
- `ubicacion`: tipo para los lugares físicos donde puede estar algo (suelo, techo, esquina, ...).
- `agente - objeto`: aquí `agente` es un **subtipo de `objeto`**, es decir:
  - Todo `agente` también es un `objeto`.
  - No todo `objeto` es un `agente`.

Esto permite reutilizar predicados basados en `objeto` (como `en`) para agentes sin tener que duplicar definiciones.

---

## 2) Predicados (`:predicates`)

Los predicados describen relaciones o propiedades que pueden ser verdaderas o falsas en un estado.

```pddl
(:predicates
  ; Relaciones de ubicación
  (en ?x - objeto ?l - ubicacion)         ; el objeto ?x está en la ubicación ?l
  (sobre ?x - objeto ?y - objeto)         ; el objeto ?x está sobre el objeto ?y

  ; Relaciones de agarre / alcance
  (alcanza ?a - agente ?o - objeto)       ; el agente puede alcanzar el objeto
  (sujeta ?a - agente ?o - objeto)        ; el agente está sujetando el objeto
  (subido ?a - agente ?o - objeto)        ; el agente está subido sobre el objeto
  (libre ?a - agente)                    ; el agente no está sujetando nada
  (banano-alcanzable))                    ; el banano está al alcance
```

### Qué significan (en palabras)

- **`(en ?x ?l)`**: posiciona un objeto en una ubicación.
- **`(sobre ?x ?y)`**: un objeto está sobre otro.
- **`(alcanza ?a ?o)`**: el agente puede alcanzar el objeto.
- **`(sujeta ?a ?o)`**: el agente está sujetando el objeto.
- **`(subido ?a ?o)`**: el agente está encima de ese objeto.
- **`(libre ?a)`**: el agente no sujeta nada y puede actuar.
- **`(banano-alcanzable)`**: un predicado global (sin parámetros) que indica si el banano es alcanzable.

---

## 3) Acciones (`:action`)

Cada acción describe un posible movimiento o interacción que cambia el estado del mundo.

### 3.1) Acción `moverse`

```pddl
(:action moverse
  :parameters (?a - agente ?desde - ubicacion ?hasta - ubicacion)
  :precondition (and (en ?a ?desde))
  :effect (and (not (en ?a ?desde)) (en ?a ?hasta)))
```

- **Parámetros**
  - `?a`: agente que se mueve.
  - `?desde`, `?hasta`: ubicaciones origen/destino.
- **Precondición**: el agente debe estar en la ubicación de origen.
- **Efecto**: el agente deja la ubicación de origen y llega a la ubicación destino.

### 3.2) Acción `empujar`

```pddl
(:action empujar
  :parameters (?a - agente ?o - objeto ?desde - ubicacion ?hasta - ubicacion)
  :precondition (and (en ?a ?desde) (en ?o ?desde) (libre ?a))
  :effect (and (not (en ?o ?desde)) (en ?o ?hasta)))
```

- **Parámetros**
  - `?a`: agente que empuja.
  - `?o`: objeto que se empuja (por ejemplo, la caja).
  - `?desde`, `?hasta`: ubicaciones de inicio y destino del objeto.
- **Precondiciones**
  - El agente y el objeto están en la misma ubicación (`?desde`).
  - El agente está libre (no sujeta nada).
- **Efecto**
  - El objeto se mueve de `?desde` a `?hasta`.

### 3.3) Acción `subirse`

```pddl
(:action subirse
  :parameters (?a - agente ?o - objeto ?l - ubicacion)
  :precondition (and (en ?a ?l) (en ?o ?l) (libre ?a))
  :effect (and (subido ?a ?o) (not (en ?a ?l))))
```

- El agente y el objeto (por ejemplo, una caja) deben estar en la misma ubicación.
- El agente debe estar libre.
- El efecto es que el agente queda “subido” al objeto y ya no está en la ubicación.

### 3.4) Acción `bajarse`

```pddl
(:action bajarse
  :parameters (?a - agente ?o - objeto ?l - ubicacion)
  :precondition (subido ?a ?o)
  :effect (and (not (subido ?a ?o)) (en ?a ?l)))
```

- Requiere que el agente esté subido sobre el objeto.
- El agente baja y pasa a estar en la ubicación `?l`.

### 3.5) Acción `agarrar`

```pddl
(:action agarrar
  :parameters (?a - agente ?o - objeto)
  :precondition (and (alcanza ?a ?o) (libre ?a))
  :effect (and (sujeta ?a ?o) (not (libre ?a))))
```

- Requiere que el agente pueda alcanzar el objeto y que esté libre.
- Resultado: el agente sujeta el objeto y deja de estar libre.

### 3.6) Acción `soltar`

```pddl
(:action soltar
  :parameters (?a - agente ?o - objeto ?l - ubicacion)
  :precondition (and (sujeta ?a ?o) (en ?a ?l))
  :effect (and (not (sujeta ?a ?o)) (libre ?a) (en ?o ?l)))
```

- Requiere que el agente sujete el objeto y esté en una ubicación.
- Efecto: el agente deja el objeto en la ubicación y queda libre.

### 3.7) Acción `alcanzar`

```pddl
(:action alcanzar
  :parameters (?a - agente ?pl - objeto ?o - objeto)
  :precondition (and (subido ?a ?pl) (not (alcanza ?a ?o)))
  :effect (alcanza ?a ?o))
```

- El agente debe estar subido sobre algún objeto (`?pl`).
- Solo funciona si aún no alcanza el objeto destino (`?o`).
- El efecto pone al objeto como alcanzable.

---

## 4) Cómo “resuelve” el planificador el problema (`problema-mono-banana`)

El problema define instancias concretas y el objetivo final.

### Objetos del problema

```pddl
(:objects
  mono - agente
  caja banano - objeto
  suelo esquina techo - ubicacion)
```

- `mono` es un agente (y por herencia un objeto).
- `caja`, `banano` son objetos normales.
- `suelo`, `esquina`, `techo` son ubicaciones.

### Estado inicial (`:init`)

El enunciado deja claro que:

- El mono y la caja están en el suelo.
- El banano está en el techo.
- El mono está libre (no sujeta nada).
- No hay nada que indique que el banano sea alcanzable aún.

### Objetivo (`:goal`)

```pddl
(:goal
  (and
    (alcanza mono banano)
    (sujeta mono banano)
  ))
```

El planificador debe buscar una secuencia de acciones que termine con: 
- el mono **alcanzando** el banano, y
- el mono **sujetando** el banano.

### ¿Qué pasa en una solución típica?

Una solución plausible es:

1. **Empujar la caja** a una ubicación útil (si no está ya bajo el banano).
2. **Subirse a la caja** (la caja se convierte en “plataforma”).
3. **Alcanzar** el banano desde la caja (`alcanzar` hace que el banano sea alcanzable).
4. **Bajar** si hace falta (no obligatorio) y/o **agarrar** el banano.

El planificador convierte esas acciones en una secuencia que satisface todas las precondiciones y termina cumpliendo el objetivo.

---

## 5) ¿Por qué este dominio es útil?

- Es un ejemplo clásico de planificación donde el agente debe usar el entorno para alcanzar un objetivo.
- Permite mostrar cómo las acciones cambian el estado (ubicación, agarre, alcance) y cómo se pueden combinar para lograr metas que no son triviales de forma directa.

---

> Si quieres, puedo incluir también un diagrama de estados o un ejemplo de plan completo (paso a paso) que resuelva este problema y mostrar cómo cambia el estado tras cada acción.

---

## 6) Algoritmo seguido (visión general)

Los planificadores típicos que resuelven dominios PDDL trabajan con una **búsqueda en el espacio de estados**.

1. Se parte del **estado inicial** definido en `:init`.
2. Se generan (expanden) sucesivos estados aplicando acciones válidas (aquellas cuyas precondiciones se cumplen).
3. Cada acción produce un nuevo estado (modifica predicados según los efectos).
4. El proceso continúa hasta alcanzar un estado que satisface el **objetivo** `:goal`.

Para no explorar todos los estados posibles (explosión de combinaciones), se usan heurísticas que guían la búsqueda (por ejemplo, estimar cuántos pasos faltan para alcanzar el objetivo). Un algoritmo común en planificadores como Fast Downward es **A\*** con heurísticas basadas en “relajaciones” del problema (como `lmcut`).

En este dominio concreto, una búsqueda heurística suele encontrar un plan muy rápido porque:
- El espacio de estados es pequeño.
- Las acciones tienen efectos claros y no hay muchas interacciones complejas.

---

## 7) Comandos de ejecución y otras variantes

Este repositorio incluye una copia de Fast Downward (`downward/`), un planificador clásico.

### 7.1) Ejecutar Fast Downward (modo básico)

Desde la raíz del repo:

```bash
./run_fast_downward.py pddl/dominio-mono-banana.pddl pddl/problema-mono-banana.pddl
```

Esto invoca Fast Downward con una configuración por defecto (a menudo A\* + heurística `lmcut`).

### 7.2) Elegir un algoritmo/heurística concreta

Fast Downward permite especificar el motor de búsqueda.

Ejemplo usando un motor de portafolio (serie SAT):

```bash
./downward/fast-downward.py --alias seq-sat-fdss-2018 \
  pddl/dominio-mono-banana.pddl pddl/problema-mono-banana.pddl
```

Ejemplo usando A\* con heurística `lmcut` explícita:

```bash
./downward/fast-downward.py \
  --search "astar(lmcut())" \
  pddl/dominio-mono-banana.pddl pddl/problema-mono-banana.pddl
```

### 7.3) Otros planificadores / enfoques

También puedes comparar con otros planificadores que soporten PDDL, como:

- **LAMA** (heurísticas de landmarks / coste).
- **FF (Fast-Forward)** (búsqueda en grafo de planificación con heurística de relajación).

La idea general es siempre:
1. Proveer el dominio y el problema.
2. Elegir el algoritmo/heurística.
3. Ejecutar y analizar el plan resultante.

---

> Nota: en este repositorio ya está configurado Fast Downward, pero cualquier planificador compatible con PDDL estándar puede resolver el mismo dominio.
