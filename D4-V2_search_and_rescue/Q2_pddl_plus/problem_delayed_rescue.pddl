(define (problem search-and-rescue-delayed)

  ;; Delayed rescue instance for Q2.
  ;;
  ;; This problem forces an explicit delay before rescue by requiring (waited)
  ;; in the goal together with (rescued).
  ;;
  ;; Victim health starts at 10.
  ;; The minimum successful sequence with delay would require:
  ;;
  ;; wait                         = 5 time units
  ;; move entrance -> corridor    = 2 time units
  ;; move corridor -> lab         = 2 time units
  ;; move lab -> infirmary        = 2 time units
  ;; inspect victim room          = 1 time unit
  ;; rescue                       = 1 time unit
  ;;
  ;; Total required time = 13.
  ;;
  ;; Since health decreases continuously at rate 1 per time unit,
  ;; the victim should die before rescue can be completed.

  (:domain search-and-rescue-q2)

  (:objects
    rescuebot - robot
    entrance corridor lab infirmary - room
  )

  (:init

    ;; Mission status.
    ;; The mission is initially active and the victim is initially alive.
    (mission-active)
    (victim-alive)

    ;; Robot status.
    ;; The robot starts available at the entrance.
    (available rescuebot)
    (robot-at rescuebot entrance)

    ;; Known building topology.
    ;; Connections are explicitly bidirectional because PDDL does not assume
    ;; that connected is symmetric.
    (connected entrance corridor)
    (connected corridor entrance)

    (connected corridor lab)
    (connected lab corridor)

    (connected lab infirmary)
    (connected infirmary lab)

    ;; Inspection state.
    ;; Only the victim room is relevant for this delayed test.
    ;; The robot must inspect infirmary before victim-detected can be produced.
    (uninspected infirmary)

    ;; Real victim location.
    ;; Rescue cannot use this predicate directly: detection is required first.
    (victim-at infirmary)

    ;; Numeric fluents.
    ;; Health is deliberately too low for the delayed rescue to succeed.
    ;; Activity progress starts at zero and is advanced by the PDDL+ process.
    (= (victim-health) 10)
    (= (activity-progress) 0)
  )

  ;; Goal:
  ;; - waited forces the explicit wait action/event chain;
  ;; - rescued requires successful rescue after detection.
  ;;
  ;; waited and rescued must not appear in :init.
  ;; They must only appear here, otherwise a planner may return an empty plan.
  (:goal
    (and
      (waited)
      (rescued)
    )
  )
)
