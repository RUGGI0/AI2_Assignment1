(define (problem definitive-too-late)

  ;; Too-late instance for the definitive rescue strategy.
  ;;
  ;; Purpose:
  ;; - health degradation is active;
  ;; - an initial delay is forced by delay-required;
  ;; - after the wait, the patient should not survive long enough for rescue;
  ;; - the expected model-level result is failure before stabilization/transport can succeed.

  (:domain search-and-rescue-definitive-plus)

  (:objects
    rescuebot - robot
    patient1 - patient
    base corridor lab infirmary storage - room
  )

  (:init

    ;; Mission status.
    (mission-active)
    (victim-alive)

    ;; PDDL+ health degradation is active.
    (health-degrading)

    ;; The too-late instance starts with delay-required, not waited.
    ;; Therefore start-wait must happen before any operational action.
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

    ;; Assessment setup.
    ;; Even with stabilization required, the initial delay should make the rescue too late.
    (assessment-pending patient1)
    (stabilization-required patient1)

    ;; Real patient/victim location.
    (victim-at patient1 infirmary)
    (patient-at patient1 infirmary)

    ;; Numeric fluents.
    ;; Health is too low to survive the forced waiting period plus rescue chain.
    (= (victim-health) 18)
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