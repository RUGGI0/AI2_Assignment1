(define (problem search-and-rescue-known-location)

  ;; This problem uses the Q1 classical PDDL domain.
  ;; The domain defines the general rules: movement, inspection, detection, rescue.
  (:domain search-and-rescue-q1)

  ;; Objects are the concrete instances used in this problem.
  ;; We use one robot named rescuebot and four rooms.
  (:objects
    rescuebot - robot
    entrance corridor room1 room2 - room
  )

  ;; The initial state lists all facts that are true at the beginning.
  ;; Any fact not listed here is considered false by default.
  (:init

    ;; Initial robot position.
    (robot-at rescuebot entrance)

    ;; Known building topology.
    ;; Connections are written in both directions because connected is not
    ;; automatically symmetric in PDDL.
    (connected entrance corridor)
    (connected corridor entrance)

    (connected corridor room1)
    (connected room1 corridor)

    (connected corridor room2)
    (connected room2 corridor)

    ;; Known victim location for this first simple instance.
    ;; The victim is in room1, but rescue still requires detection first.
    (victim-at room1)
  )

  ;; The goal is only that the victim is rescued.
  ;; The planner must infer the necessary intermediate actions.
  (:goal
    (and
      (rescued)
    )
  )
)