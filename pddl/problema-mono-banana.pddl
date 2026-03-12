(define (problem problema-mono-banana)
  (:domain mono-banana)
  (:objects
    mono - agente
    caja banano - objeto
    suelo esquina techo - ubicacion)

  (:init
    ; Posiciones iniciales
    (en mono suelo)
    (en caja suelo)
    (en banano techo)

    ; El mono comienza sin sujetar nada
    (libre mono)

    ; El banano no es alcanzable hasta que el mono esté subido
    ; y lo logre alcanzarlo desde la caja.
  )

  (:goal
    (and
      (alcanza mono banano)
      (sujeta mono banano)
    )
  )
)
