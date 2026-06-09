(define (domain search-and-rescue-definitive-plus)

  ;; Definitive PDDL+ rescue strategy with symbolic health assessment.
  ;;
  ;; This domain keeps the important PDDL+ part:
  ;; - victim-health decreases continuously while health-degrading is true;
  ;; - victim-dies is an automatic event triggered when health reaches zero;
  ;; - stabilization stops health degradation;
  ;; - rescue succeeds only when the patient is unloaded at the safe base.
  ;;
  ;; The assessment result is modelled symbolically through problem predicates:
  ;; - (transport-safe ?p) selects the direct-transport branch;
  ;; - (stabilization-required ?p) selects the stabilization branch.
  ;;
  ;; This mirrors the assignment abstraction used for unknown victim location:
  ;; the model explicitly represents sensing/assessment outcomes with predicates,
  ;; while continuous health degradation remains numeric and time-dependent.

  (:requirements
    :strips
    :typing
    :numeric-fluents
    :continuous-effects
  )

  (:types
    robot
    room
    patient
  )

  (:predicates

    ;; Robot location.
    (robot-at ?r - robot ?loc - room)

    ;; Patient physical location when not loaded.
    (patient-at ?p - patient ?loc - room)

    ;; Known building topology.
    ;; Connections are explicitly declared in both directions in the problem file.
    (connected ?from - room ?to - room)

    ;; Room inspection state.
    (inspected ?loc - room)
    (uninspected ?loc - room)
    (empty-room ?loc - room)

    ;; Real patient/victim location.
    ;; The planner cannot rescue directly from this fact: detection is still required.
    (victim-at ?p - patient ?loc - room)

    ;; Produced by inspecting the room containing the victim.
    (victim-detected ?p - patient ?loc - room)

    ;; Health assessment state.
    ;; assessment-pending is initially true and is removed after assessment.
    (assessment-pending ?p - patient)
    (assessing ?r - robot ?p - patient ?loc - room)
    (assessed ?p - patient)

    ;; Symbolic assessment outcomes.
    ;; These are set in each problem instance to select the intended branch.
    (transport-safe ?p - patient)
    (stabilization-required ?p - patient)

    ;; Branch results.
    ;; ready-for-transport can be produced either by direct assessment or stabilization.
    (needs-stabilization ?p - patient)
    (stabilized ?p - patient)
    (ready-for-transport ?p - patient)

    ;; Robot activity state.
    (available ?r - robot)
    (busy ?r - robot)

    ;; Carrying state.
    (hands-free ?r - robot)
    (carrying ?r - robot ?p - patient)
    (patient-loaded ?p - patient)

    ;; Safe base.
    (safe-base ?loc - room)

    ;; Mission and patient status.
    (mission-active)
    (victim-alive)
    (victim-dead)

    ;; Health degradation control.
    ;; While this predicate is true, the health-degradation process is active.
    ;; Stabilization removes it.
    (health-degrading)

    ;; Optional delay control used in too-late scenarios.
    ;; Normal problems start with waited already true.
    (delay-required)
    (waited)

    ;; Timed activity markers.
    (moving ?r - robot ?from - room ?to - room)
    (inspecting-empty ?r - robot ?loc - room)
    (inspecting-victim ?r - robot ?p - patient ?loc - room)
    (stabilizing ?r - robot ?p - patient ?loc - room)
    (loading ?r - robot ?p - patient ?loc - room)
    (transporting ?r - robot ?p - patient ?from - room ?to - room)
    (unloading ?r - robot ?p - patient ?base - room)
    (waiting ?r - robot ?loc - room)

    ;; Final goal predicate.
    ;; In this definitive version, rescued means safely unloaded at base.
    (rescued ?p - patient)
  )

  (:functions

    ;; Patient health decreases continuously while health-degrading is true.
    (victim-health)

    ;; Shared progress counter for the current robot activity.
    ;; One global progress fluent is sufficient because the domain uses one robot.
    (activity-progress)
  )

  ;; ---------------------------------------------------------------------------
  ;; START MOVE
  ;; ---------------------------------------------------------------------------
  ;; Normal movement without carrying the patient.
  (:action start-move
    :parameters (?r - robot ?from - room ?to - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (waited)
      (available ?r)
      (hands-free ?r)
      (robot-at ?r ?from)
      (connected ?from ?to)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (moving ?r ?from ?to)
      (not (robot-at ?r ?from))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START INSPECT EMPTY ROOM
  ;; ---------------------------------------------------------------------------
  ;; Inspection of a known empty room.
  (:action start-inspect-empty-room
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (waited)
      (available ?r)
      (hands-free ?r)
      (robot-at ?r ?loc)
      (uninspected ?loc)
      (empty-room ?loc)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (inspecting-empty ?r ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START INSPECT VICTIM ROOM
  ;; ---------------------------------------------------------------------------
  ;; Inspection of the room containing the victim.
  ;; Detection is produced only by the finish event.
  (:action start-inspect-victim-room
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (waited)
      (available ?r)
      (hands-free ?r)
      (robot-at ?r ?loc)
      (uninspected ?loc)
      (victim-at ?p ?loc)
      (patient-at ?p ?loc)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (inspecting-victim ?r ?p ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START ASSESS PATIENT
  ;; ---------------------------------------------------------------------------
  ;; Medical assessment is explicit and consumes time.
  ;; Its outcome is represented by symbolic predicates in the problem file.
  (:action start-assess-patient
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (waited)
      (available ?r)
      (hands-free ?r)
      (robot-at ?r ?loc)
      (patient-at ?p ?loc)
      (victim-detected ?p ?loc)
      (assessment-pending ?p)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (assessing ?r ?p ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START STABILIZE PATIENT
  ;; ---------------------------------------------------------------------------
  ;; Stabilization is required when assessment produced needs-stabilization.
  (:action start-stabilize-patient
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (waited)
      (available ?r)
      (hands-free ?r)
      (robot-at ?r ?loc)
      (patient-at ?p ?loc)
      (needs-stabilization ?p)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (stabilizing ?r ?p ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START LOAD PATIENT
  ;; ---------------------------------------------------------------------------
  ;; Loading requires ready-for-transport.
  ;; This can be produced by either direct assessment or stabilization.
  (:action start-load-patient
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (waited)
      (available ?r)
      (hands-free ?r)
      (robot-at ?r ?loc)
      (patient-at ?p ?loc)
      (victim-detected ?p ?loc)
      (ready-for-transport ?p)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (loading ?r ?p ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START MOVE WITH PATIENT
  ;; ---------------------------------------------------------------------------
  ;; Movement while carrying the patient is slower than normal movement.
  (:action start-move-with-patient
    :parameters (?r - robot ?p - patient ?from - room ?to - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (waited)
      (available ?r)
      (robot-at ?r ?from)
      (connected ?from ?to)
      (carrying ?r ?p)
      (patient-loaded ?p)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (transporting ?r ?p ?from ?to)
      (not (robot-at ?r ?from))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START UNLOAD PATIENT AT BASE
  ;; ---------------------------------------------------------------------------
  ;; Rescue completes only when the patient is unloaded at a safe base.
  (:action start-unload-patient-at-base
    :parameters (?r - robot ?p - patient ?base - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (waited)
      (available ?r)
      (robot-at ?r ?base)
      (safe-base ?base)
      (carrying ?r ?p)
      (patient-loaded ?p)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (unloading ?r ?p ?base)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START WAIT
  ;; ---------------------------------------------------------------------------
  ;; Optional delay used only by too-late problem instances.
  (:action start-wait
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (delay-required)
      (available ?r)
      (robot-at ?r ?loc)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (waiting ?r ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; ACTIVITY PROGRESS PROCESS
  ;; ---------------------------------------------------------------------------
  ;; While the robot is busy, the current activity progresses continuously.
  (:process activity-progress-process
    :parameters (?r - robot)
    :precondition (and
      (mission-active)
      (victim-alive)
      (busy ?r)
    )
    :effect (and
      (increase (activity-progress) (* #t 1))
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; HEALTH DEGRADATION PROCESS
  ;; ---------------------------------------------------------------------------
  ;; Health decreases continuously until stabilization removes health-degrading.
  (:process health-degradation
    :parameters ()
    :precondition (and
      (mission-active)
      (victim-alive)
      (health-degrading)
      (> (victim-health) 0)
    )
    :effect (and
      (decrease (victim-health) (* #t 1))
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH MOVE EVENT
  ;; ---------------------------------------------------------------------------
  ;; Normal movement duration = 2 time units.
  (:event finish-move
    :parameters (?r - robot ?from - room ?to - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (moving ?r ?from ?to)
      (>= (activity-progress) 2)
    )
    :effect (and
      (not (moving ?r ?from ?to))
      (not (busy ?r))
      (available ?r)
      (robot-at ?r ?to)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH INSPECT EMPTY ROOM EVENT
  ;; ---------------------------------------------------------------------------
  ;; Empty-room inspection duration = 1 time unit.
  (:event finish-inspect-empty-room
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (inspecting-empty ?r ?loc)
      (>= (activity-progress) 1)
    )
    :effect (and
      (not (inspecting-empty ?r ?loc))
      (not (busy ?r))
      (available ?r)
      (inspected ?loc)
      (not (uninspected ?loc))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH INSPECT VICTIM ROOM EVENT
  ;; ---------------------------------------------------------------------------
  ;; Victim-room inspection duration = 1 time unit.
  ;; Detection is produced here.
  (:event finish-inspect-victim-room
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (inspecting-victim ?r ?p ?loc)
      (>= (activity-progress) 1)
    )
    :effect (and
      (not (inspecting-victim ?r ?p ?loc))
      (not (busy ?r))
      (available ?r)
      (inspected ?loc)
      (not (uninspected ?loc))
      (victim-detected ?p ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH ASSESSMENT: DIRECT TRANSPORT
  ;; ---------------------------------------------------------------------------
  ;; Assessment duration = 1 time unit.
  ;; Direct transport is selected by the symbolic predicate transport-safe.
  (:event finish-assess-direct-transport
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (assessing ?r ?p ?loc)
      (transport-safe ?p)
      (>= (activity-progress) 1)
    )
    :effect (and
      (not (assessing ?r ?p ?loc))
      (not (busy ?r))
      (available ?r)
      (assessed ?p)
      (ready-for-transport ?p)
      (not (assessment-pending ?p))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH ASSESSMENT: STABILIZATION REQUIRED
  ;; ---------------------------------------------------------------------------
  ;; Assessment duration = 1 time unit.
  ;; Stabilization is selected by the symbolic predicate stabilization-required.
  (:event finish-assess-needs-stabilization
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (assessing ?r ?p ?loc)
      (stabilization-required ?p)
      (>= (activity-progress) 1)
    )
    :effect (and
      (not (assessing ?r ?p ?loc))
      (not (busy ?r))
      (available ?r)
      (assessed ?p)
      (needs-stabilization ?p)
      (not (assessment-pending ?p))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH STABILIZE PATIENT EVENT
  ;; ---------------------------------------------------------------------------
  ;; Stabilization duration = 4 time units.
  ;; Stabilization stops health degradation and makes the patient transport-ready.
  (:event finish-stabilize-patient
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (stabilizing ?r ?p ?loc)
      (> (victim-health) 0)
      (>= (activity-progress) 4)
    )
    :effect (and
      (not (stabilizing ?r ?p ?loc))
      (not (busy ?r))
      (available ?r)
      (stabilized ?p)
      (ready-for-transport ?p)
      (not (needs-stabilization ?p))
      (not (health-degrading))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH LOAD PATIENT EVENT
  ;; ---------------------------------------------------------------------------
  ;; Loading duration = 1 time unit.
  (:event finish-load-patient
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (loading ?r ?p ?loc)
      (> (victim-health) 0)
      (>= (activity-progress) 1)
    )
    :effect (and
      (not (loading ?r ?p ?loc))
      (not (busy ?r))
      (available ?r)
      (carrying ?r ?p)
      (patient-loaded ?p)
      (not (hands-free ?r))
      (not (patient-at ?p ?loc))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH MOVE WITH PATIENT EVENT
  ;; ---------------------------------------------------------------------------
  ;; Transport movement duration = 3 time units.
  (:event finish-move-with-patient
    :parameters (?r - robot ?p - patient ?from - room ?to - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (transporting ?r ?p ?from ?to)
      (> (victim-health) 0)
      (>= (activity-progress) 3)
    )
    :effect (and
      (not (transporting ?r ?p ?from ?to))
      (not (busy ?r))
      (available ?r)
      (robot-at ?r ?to)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH UNLOAD PATIENT AT BASE
  ;; ---------------------------------------------------------------------------
  ;; Unloading duration = 1 time unit.
  ;; This event produces the final rescued predicate.
  (:event finish-unload-patient-at-base
    :parameters (?r - robot ?p - patient ?base - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (unloading ?r ?p ?base)
      (> (victim-health) 0)
      (>= (activity-progress) 1)
    )
    :effect (and
      (not (unloading ?r ?p ?base))
      (not (busy ?r))
      (available ?r)
      (hands-free ?r)
      (patient-at ?p ?base)
      (rescued ?p)
      (not (carrying ?r ?p))
      (not (patient-loaded ?p))
      (not (mission-active))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH WAIT EVENT
  ;; ---------------------------------------------------------------------------
  ;; Optional delay duration = 10 time units.
  (:event finish-wait
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (delay-required)
      (waiting ?r ?loc)
      (>= (activity-progress) 10)
    )
    :effect (and
      (not (waiting ?r ?loc))
      (not (busy ?r))
      (available ?r)
      (waited)
      (not (delay-required))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; VICTIM DIES EVENT
  ;; ---------------------------------------------------------------------------
  ;; If health reaches zero while degradation is active, the mission fails.
  (:event victim-dies
    :parameters ()
    :precondition (and
      (mission-active)
      (victim-alive)
      (health-degrading)
      (<= (victim-health) 0)
    )
    :effect (and
      (victim-dead)
      (not (victim-alive))
      (not (mission-active))
    )
  )
)