(define (problem search-and-rescue-delayed)

  ;; Delayed rescue problem for the Q2 PDDL+ model.
  ;;
  ;; This problem represents the case where the robot loses time before
  ;; rescuing/stabilising the victim.
  ;;
  ;; Rescue is interpreted as in-place stabilisation, not evacuation.
  ;; The purpose of this instance is to show that, in PDDL+, symbolic
  ;; reachability is not enough: time and health degradation can make
  ;; rescue fail.
  (:domain search-and-rescue-q2)

  (:objects
    rescuebot - robot
    entrance corridor storage lab infirmary - room
  )

  (:init

    ;; Initial robot position.
    (robot-at rescuebot entrance)

    ;; The victim is initially alive.
    ;; While victim-alive is true and rescued is false, the health-decrease
    ;; process continuously reduces victim-health.
    (victim-alive)

    ;; Known building topology.
    ;; Connections are explicitly bidirectional because connected is not
    ;; automatically symmetric in PDDL.
    (connected entrance corridor)
    (connected corridor entrance)

    (connected corridor storage)
    (connected storage corridor)

    (connected corridor lab)
    (connected lab corridor)

    (connected lab infirmary)
    (connected infirmary lab)

    ;; Real victim location in the model.
    ;; The robot must still inspect the room before rescue can happen.
    (victim-at infirmary)

    ;; Initial numeric value.
    ;; A low health value makes the delayed rescue fail if too much time
    ;; passes before stabilisation.
    (= (victim-health) 3)
  )

  ;; In the delayed case, the desired symbolic goal would still be rescue.
  ;; However, due to health degradation, the model is expected to show that
  ;; rescue may become impossible if victim-dies is triggered first.
  (:goal
    (and
      (rescued)
    )
  )
)