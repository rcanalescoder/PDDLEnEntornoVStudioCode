(define (domain mono-banana)
  (:requirements :strips :typing :negative-preconditions)
  (:types
    objeto ubicacion
    agente - objeto)

  (:predicates
    ; Relaciones de ubicación
    (en ?x - objeto ?l - ubicacion)         ; el objeto ?x está en la ubicación ?l
    (sobre ?x - objeto ?y - objeto)         ; el objeto ?x está sobre el objeto ?y
    (alcanza ?a - agente ?o - objeto)       ; el agente puede alcanzar el objeto
    (sujeta ?a - agente ?o - objeto)        ; el agente está sujetando el objeto
    (subido ?a - agente ?o - objeto)        ; el agente está subido sobre el objeto
    (libre ?a - agente)                    ; el agente no está sujetando nada
    (banano-alcanzable))                    ; el banano está al alcance

  ; Acción: moverse a una ubicación
  (:action moverse
    :parameters (?a - agente ?desde - ubicacion ?hasta - ubicacion)
    :precondition (and (en ?a ?desde))
    :effect (and (not (en ?a ?desde)) (en ?a ?hasta)))

  ; Acción: empujar un objeto (ej. caja) de una ubicación a otra
  (:action empujar
    :parameters (?a - agente ?o - objeto ?desde - ubicacion ?hasta - ubicacion)
    :precondition (and (en ?a ?desde) (en ?o ?desde) (libre ?a))
    :effect (and (not (en ?o ?desde)) (en ?o ?hasta)))

  ; Acción: subirse encima de un objeto (ej. caja)
  (:action subirse
    :parameters (?a - agente ?o - objeto ?l - ubicacion)
    :precondition (and (en ?a ?l) (en ?o ?l) (libre ?a))
    :effect (and (subido ?a ?o) (not (en ?a ?l))))

  ; Acción: bajarse del objeto
  (:action bajarse
    :parameters (?a - agente ?o - objeto ?l - ubicacion)
    :precondition (subido ?a ?o)
    :effect (and (not (subido ?a ?o)) (en ?a ?l)))

  ; Acción: agarrar un objeto (ej. banano)
  (:action agarrar
    :parameters (?a - agente ?o - objeto)
    :precondition (and (alcanza ?a ?o) (libre ?a))
    :effect (and (sujeta ?a ?o) (not (libre ?a))))

  ; Acción: soltar el objeto que sostiene
  (:action soltar
    :parameters (?a - agente ?o - objeto ?l - ubicacion)
    :precondition (and (sujeta ?a ?o) (en ?a ?l))
    :effect (and (not (sujeta ?a ?o)) (libre ?a) (en ?o ?l)))

  ; Acción: alcanzar un objeto desde la plataforma (ej. alcanzar la banana estando subido en la caja)
  (:action alcanzar
    :parameters (?a - agente ?pl - objeto ?o - objeto)
    :precondition (and (subido ?a ?pl) (not (alcanza ?a ?o)))
    :effect (alcanza ?a ?o))
)
