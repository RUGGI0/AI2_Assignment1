(define (domain search-and-rescue-q1)

  ;; We use ADL with typed objects.
  ;; ADL is appropriate here because the model uses negative preconditions,
  ;; such as (not (inspected ?loc)) and (not (victim-at ?loc)).
  ;; The domain remains classical and symbolic: no time, no numeric fluents,
  ;; and no real partial observability are represented in Q1.
  (:requirements :adl :typing)

  (:types
    robot
    room
  )

  (:predicates

    ;; The robot is currently located in a specific room.
    (robot-at ?r - robot ?loc - room)

    ;; Known topology of the building.
    ;; Connections are not automatically symmetric.
    (connected ?from - room ?to - room)

    ;; The robot has already inspected a room.
    (inspected ?loc - room)

    ;; Real victim location in the model.
    ;; Rescue cannot use this directly: detection is required first.
    (victim-at ?loc - room)

    ;; Information acquired by inspection.
    (victim-detected ?loc - room)

    ;; Final mission condition.
    (rescued)
  )

  ;; The robot can move only before the rescue is completed.
  ;; This prevents plans where the robot rescues the victim and then continues exploring.
  (:action move
    :parameters (?r - robot ?from - room ?to - room)
    :precondition (and
      (not (rescued))
      (robot-at ?r ?from)
      (connected ?from ?to)
    )
    :effect (and
      (not (robot-at ?r ?from))
      (robot-at ?r ?to)
    )
  )

  ;; The robot can inspect an empty room only before the rescue is completed.
  (:action inspect-empty-room
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (not (rescued))
      (robot-at ?r ?loc)
      (not (inspected ?loc))
      (not (victim-at ?loc))
    )
    :effect (and
      (inspected ?loc)
    )
  )

  ;; The robot can inspect the victim room only before the rescue is completed.
  ;; This action produces the detection fact needed for rescue.
  (:action inspect-victim-room
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (not (rescued))
      (robot-at ?r ?loc)
      (not (inspected ?loc))
      (victim-at ?loc)
    )
    :effect (and
      (inspected ?loc)
      (victim-detected ?loc)
    )
  )

  ;; Rescue is the final action.
  ;; Once rescued becomes true, move and inspect actions are no longer applicable.
  (:action rescue
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (robot-at ?r ?loc)
      (victim-detected ?loc)
    )
    :effect (and
      (rescued)
    )
  )
)