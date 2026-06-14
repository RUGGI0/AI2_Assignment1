(define (problem autonomous-direct-transport)

  ;; Autonomous direct-transport instance.
  ;;
  ;; The patient health is high enough that, when the timed assessment finishes,
  ;; victim-health is still above the numeric transport threshold.
  ;; Therefore the domain should autonomously select the direct-transport branch.
  ;;
  ;; No transport-safe predicate is provided here.
  ;; The branch must be selected only by the numeric condition in finish-assess-direct-transport.

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
    ;; This keeps the PDDL+ time-dependent behaviour meaningful.
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
    ;; Connections are explicitly bidirectional because PDDL does not assume symmetry.
    (connected base corridor)
    (connected corridor base)

    (connected corridor lab)
    (connected lab corridor)

    (connected lab infirmary)
    (connected infirmary lab)

    (connected corridor storage)
    (connected storage corridor)

    ;; Inspection state.
    ;; The robot must inspect the victim room before detection is produced.
    (uninspected infirmary)

    ;; Assessment is pending, but no symbolic branch outcome is given.
    ;; The domain must decide using victim-health at assessment completion.
    (assessment-pending patient1)

    ;; Real patient/victim location in the planning model.
    ;; Later actions still require victim-detected, so this fact does not by itself rescue the patient.
    (victim-at patient1 infirmary)
    (patient-at patient1 infirmary)

    ;; Numeric fluents.
    ;; With health 60, the patient should remain above the direct-transport threshold
    ;; when assessment completes, even with the small idle time observed in ENHSP timelines.
    (= (victim-health) 60)
    (= (activity-progress) 0)
  )

  ;; Rescue means that the patient has been transported and unloaded at base.
  (:goal
    (and
      (rescued patient1)
      (patient-at patient1 base)
    )
  )
)
