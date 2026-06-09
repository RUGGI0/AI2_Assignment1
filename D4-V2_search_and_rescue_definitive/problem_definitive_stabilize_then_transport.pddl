
(define (problem definitive-stabilize-then-transport)

  ;; Stabilize-then-transport instance for the definitive rescue strategy.
  ;;
  ;; Purpose:
  ;; - health degradation is active;
  ;; - the patient is not considered safe for direct transport;
  ;; - assessment produces the stabilization branch;
  ;; - stabilization stops health degradation;
  ;; - the patient is then loaded, transported to base, and unloaded.

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

    ;; PDDL+ health degradation is active until stabilization completes.
    (health-degrading)

    ;; No initial delay is required in this success instance.
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

    ;; Assessment setup.
    ;; stabilization-required selects the stabilization branch after assessment.
    (assessment-pending patient1)
    (stabilization-required patient1)

    ;; Real patient/victim location.
    (victim-at patient1 infirmary)
    (patient-at patient1 infirmary)

    ;; Numeric fluents.
    ;; This is low enough to justify stabilization, but high enough to survive until stabilization completes.
    (= (victim-health) 18)
    (= (activity-progress) 0)
  )

  (:goal
    (and
      (stabilized patient1)
      (rescued patient1)
      (patient-at patient1 base)
    )
  )
)