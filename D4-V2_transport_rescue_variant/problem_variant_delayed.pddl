(define (problem transport-variant-delayed)

  ;; Delayed problem for the alternative Q2 transport rescue variant.
  ;;
  ;; Delayed does not start with (waited).
  ;; Instead, it starts with (delay-required), so the only initially enabled mission action is wait.
  ;;
  ;; After finish-wait fires at 10 time units, (waited) becomes true and normal mission actions become enabled.
  ;;
  ;; With victim-health = 25, the forced initial wait should make transport rescue too late.

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

    ;; Delayed variant: the delay gate is active initially.
    ;; Since operational actions require (waited), the robot must wait first.
    (delay-required)

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
      (waited)
      (rescued patient1)
      (patient-at patient1 base)
    )
  )
)