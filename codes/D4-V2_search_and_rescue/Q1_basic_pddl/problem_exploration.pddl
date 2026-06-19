(define (problem search-and-rescue-exploration)

  ;; This problem uses the Q1 classical PDDL domain.
  ;; The domain defines movement, room inspection, victim detection, and rescue.
  ;; The victim location is encoded in the initial state because classical PDDL
  ;; requires a complete symbolic state, but the model still approximates
  ;; unknown victim location by forcing explicit exploration and inspection.

  (:domain search-and-rescue-q1)

  ;; Objects are the concrete instances used in this exploration problem.
  ;; We use one robot named rescuebot and five rooms.
  (:objects
    rescuebot - robot
    entrance corridor lab infirmary storage - room
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

    (connected corridor lab)
    (connected lab corridor)

    (connected lab infirmary)
    (connected infirmary lab)

    (connected corridor storage)
    (connected storage corridor)

    ;; Real victim location in the complete planner state.
    ;; Rescue cannot use this directly because the rescue action requires
    ;; victim-detected, which is produced only by inspect-victim-room.
    (victim-at infirmary)
  )

  ;; The goal requires both exploration and rescue.
  ;; Since the Q1 domain disables movement and inspection after rescue,
  ;; lab and storage must be inspected before the final rescue action.
  (:goal
    (and
      (inspected lab)
      (inspected storage)
      (rescued)
    )
  )
)
