(define (problem search-and-rescue-fast)

  ;; Fast rescue problem for the Q2 PDDL+ model.
  ;;
  ;; The robot starts close enough to the victim to perform:
  ;; move -> inspect -> rescue
  ;; before victim-health reaches zero.
  ;;
  ;; Rescue is interpreted as in-place stabilisation, not evacuation.
  (:domain search-and-rescue-q2)

  (:objects
    rescuebot - robot
    entrance corridor infirmary - room
  )

  (:init

    ;; Initial robot position.
    (robot-at rescuebot entrance)

    ;; The victim is initially alive.
    ;; While victim-alive is true and rescued is false, the health-decrease
    ;; process in the domain continuously reduces victim-health.
    (victim-alive)

    ;; Known building topology.
    ;; Connections are explicitly bidirectional because connected is not
    ;; automatically symmetric in PDDL.
    (connected entrance corridor)
    (connected corridor entrance)

    (connected corridor infirmary)
    (connected infirmary corridor)

    ;; Real victim location in the model.
    ;; The robot still needs inspection to produce victim-detected.
    (victim-at infirmary)

    ;; Initial numeric value.
    ;; A health value of 10 is high enough for the fast rescue trace.
    (= (victim-health) 10)
  )

  ;; The goal is successful in-place rescue.
  ;; The victim must be stabilised before victim-dies is triggered.
  (:goal
    (and
      (rescued)
    )
  )
)