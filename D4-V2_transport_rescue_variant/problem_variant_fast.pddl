
(define (problem transport-variant-fast)

  ;; Fast problem for the alternative Q2 transport rescue variant.
  ;;
  ;; Fast starts with (waited), so no initial delay is required.
  ;; Victim health starts at 25, which is enough for the intended fast transport rescue.

  (:domain search-and-rescue-variant-plus)

  (:objects
    rescuebot - robot
    patient1 - patient
    base corridor lab infirmary storage - room
  )

  (:init

    ;; Mission status.
    (mission-active)
    (victim-alive)

    ;; Fast variant: the initial delay gate is already satisfied.
    ;; This allows the robot to start exploration immediately.
    (waited)

    ;; Robot initial status.
    (available rescuebot)
    (hands-free rescuebot)
    (robot-at rescuebot base)

    ;; Safe evacuation point.
    (safe-base base)

    ;; Known building topology.
    (connected base corridor)
    (connected corridor base)

    (connected corridor lab)
    (connected lab corridor)

    (connected lab infirmary)
    (connected infirmary lab)

    (connected corridor storage)
    (connected storage corridor)

    ;; Inspection state.
    (uninspected infirmary)

    ;; Real patient/victim location.
    (victim-at patient1 infirmary)
    (patient-at patient1 infirmary)

    ;; Numeric fluents.
    (= (victim-health) 25)
    (= (activity-progress) 0)
  )

  (:goal
    (and
      (rescued patient1)
      (patient-at patient1 base)
    )
  )
)