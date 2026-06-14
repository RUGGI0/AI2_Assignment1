(define (problem autonomous-stabilize-then-transport)

  ;; Autonomous stabilize-then-transport instance.
  ;;
  ;; The patient health is low enough that, when the timed assessment finishes,
  ;; victim-health should be below the numeric direct-transport threshold but still above zero.
  ;; Therefore the domain should autonomously select the stabilization branch.
  ;;
  ;; No stabilization-required predicate is provided here.
  ;; The branch must be selected only by the numeric condition in finish-assess-needs-stabilization.

  (:domain search-and-rescue-definitive-autonomous-plus)

  (:objects
    rescuebot - robot
    patient1 - patient
    base corridor lab infirmary storage - room
  )

  (:init

    ;; Mission status.
    (mission-active)
    (victim-alive)

    ;; Health degradation is active from the beginning.
    (health-degrading)

    ;; This successful instance has no forced initial delay.
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

    ;; Inspection and assessment setup.
    (uninspected infirmary)
    (assessment-pending patient1)

    ;; Real patient/victim location in the planning model.
    (victim-at patient1 infirmary)
    (patient-at patient1 infirmary)

    ;; Numeric fluents.
    ;; With health 18, the patient should be below the direct-transport threshold
    ;; when assessment completes, so stabilization should be required.
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
