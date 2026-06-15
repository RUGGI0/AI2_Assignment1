(define (problem search-and-rescue-exploration)

  ;; This problem uses the Q1 classical PDDL domain.
  ;; It represents the exploration-oriented instance of the assignment.
  (:domain search-and-rescue-q1)

  ;; Objects are the concrete entities of this problem.
  ;; The robot is named rescuebot.
  ;; The building is represented as a small graph of rooms.
  (:objects
    rescuebot - robot
    entrance corridor storage lab infirmary - room
  )

  ;; The initial state lists all facts that are true at the beginning.
  ;; Facts not listed here are false by default.
  (:init

    ;; Initial robot position.
    (robot-at rescuebot entrance)

    ;; Known building topology.
    ;; Connections are explicitly listed in both directions because
    ;; connected is not automatically symmetric in PDDL.
    (connected entrance corridor)
    (connected corridor entrance)

    (connected corridor storage)
    (connected storage corridor)

    (connected corridor lab)
    (connected lab corridor)

    (connected lab infirmary)
    (connected infirmary lab)

    ;; Real victim location in the model.
    ;; This is needed because classical PDDL requires a fully specified state.
    ;; However, rescue cannot use this fact directly: the robot must inspect
    ;; the room and produce victim-detected first.
    (victim-at infirmary)
  )

  ;; The goal requires both rescue and evidence that some exploration occurred.
  ;; The inspected predicates force the plan to include explicit inspection
  ;; before reaching the final rescue condition.
  (:goal
    (and
      (inspected storage)
      (inspected lab)
      (rescued)
    )
  )
)