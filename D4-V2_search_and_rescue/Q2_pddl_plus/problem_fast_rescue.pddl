(define (problem search-and-rescue-fast)

  ;; Fast rescue instance for Q2.
  ;; The robot must reach the infirmary, inspect the victim room,
  ;; detect the victim, and rescue before health reaches zero.

  (:domain search-and-rescue-q2)

  (:objects
    rescuebot - robot
    entrance corridor lab infirmary - room
  )

  (:init

    ;; Mission status.
    (mission-active)
    (victim-alive)

    ;; Robot status.
    (available rescuebot)
    (robot-at rescuebot entrance)

    ;; Known building topology.
    (connected entrance corridor)
    (connected corridor entrance)

    (connected corridor lab)
    (connected lab corridor)

    (connected lab infirmary)
    (connected infirmary lab)

    ;; Only the victim room needs to be inspectable in the fast instance.
    ;; This avoids irrelevant empty-room inspections in the fast rescue plan.
    (uninspected infirmary)

    ;; Real victim location.
    (victim-at infirmary)

    ;; Numeric fluents.
    ;; Health is high enough for the fast rescue to succeed:
    ;; move 2 + move 2 + move 2 + inspect 1 + rescue 1 = 8 time units.
    (= (victim-health) 10)
    (= (activity-progress) 0)
  )

  (:goal
    (and
      (rescued)
    )
  )
)