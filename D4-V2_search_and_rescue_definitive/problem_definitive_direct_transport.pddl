(define (problem definitive-direct-transport)

  ;; Direct transport instance for the definitive rescue strategy.
  ;;
  ;; Purpose:
  ;; - the robot starts at base;
  ;; - the patient is located in infirmary;
  ;; - the robot must inspect the victim room before detection;
  ;; - after detection, the robot assesses the patient;
  ;; - the symbolic assessment result says that transport is safe;
  ;; - health degradation remains active, but health is high enough for success;
  ;; - the robot loads the patient, transports them to base, and unloads them.

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

    ;; PDDL+ health degradation is active in the definitive version.
    (health-degrading)

    ;; No initial delay is required in the direct transport instance.
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
    (uninspected infirmary)

    ;; Assessment setup.
    ;; transport-safe selects the direct transport branch after assessment.
    (assessment-pending patient1)
    (transport-safe patient1)

    ;; Real patient/victim location.
    ;; The robot cannot load the patient until inspection produces victim-detected.
    (victim-at patient1 infirmary)
    (patient-at patient1 infirmary)

    ;; Numeric fluents.
    ;; Health is high enough for the direct transport plan to complete before death.
    (= (victim-health) 35)
    (= (activity-progress) 0)
  )

  ;; Goal:
  ;; Rescue means the patient has been physically transported and unloaded at base.
  (:goal
    (and
      (rescued patient1)
      (patient-at patient1 base)
    )
  )
)