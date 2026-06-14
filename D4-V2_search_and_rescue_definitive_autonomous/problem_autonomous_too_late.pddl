(define (problem autonomous-too-late)

  ;; Autonomous too-late failure instance.
  ;;
  ;; This instance forces an initial wait while health degradation remains active.
  ;; The patient starts with low health, so the victim should die before the robot
  ;; can complete assessment, stabilization, transport, and unload at base.
  ;;
  ;; As with the other autonomous instances, no symbolic branch predicate is provided.
  ;; The model relies on victim-health and the automatic victim-dies event.

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

    ;; The robot must wait first in this failure instance.
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

    ;; Inspection and assessment setup.
    (uninspected infirmary)
    (assessment-pending patient1)

    ;; Real patient/victim location in the planning model.
    (victim-at patient1 infirmary)
    (patient-at patient1 infirmary)

    ;; Numeric fluents.
    ;; With health 18 and a forced wait duration of 10, the rescue should be too late.
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
