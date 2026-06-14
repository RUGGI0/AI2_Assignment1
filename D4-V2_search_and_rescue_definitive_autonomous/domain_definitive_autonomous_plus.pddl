(define (domain search-and-rescue-definitive-autonomous-plus)

  ;; Definitive autonomous PDDL+ rescue strategy.
  ;;
  ;; This experimental domain combines the two rescue meanings developed during the assignment:
  ;; - rescue as helping the victim after detection;
  ;; - rescue as transporting the patient back to a safe base.
  ;;
  ;; Final strategy:
  ;; 1. The robot searches the building by moving through a known topology.
  ;; 2. The robot explicitly inspects rooms.
  ;; 3. Inspection of the correct room produces victim detection.
  ;; 4. After detection, the robot assesses the patient's health.
  ;; 5. If health is sufficient, the patient becomes ready for direct transport.
  ;; 6. If health is too low, the robot must stabilize the patient first.
  ;; 7. Stabilization stops health degradation.
  ;; 8. The robot loads the patient, transports them to base, and unloads them there.
  ;;
        ;; Autonomous-assessment note:
  ;; In the symbolic definitive version, the assessment outcome was encoded in the problem
  ;; with transport-safe or stabilization-required predicates.
  ;; In this autonomous version, those symbolic outcome predicates are removed.
  ;; The finish-assess-* events select the branch using the current numeric value of victim-health.
  ;; This is conceptually closer to PDDL+, but planner support may be less stable.

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

    ;; Patient physical location when not carried.
    (patient-at ?p - patient ?loc - room)

    ;; Known building topology.
    ;; PDDL does not assume symmetry, so both directions must be listed in each problem.
    (connected ?from - room ?to - room)

    ;; Inspection state.
    (inspected ?loc - room)
    (uninspected ?loc - room)
    (empty-room ?loc - room)

    ;; Real patient location in the model.
    ;; The robot cannot rescue from this alone: detection is still required.
    (victim-at ?p - patient ?loc - room)

    ;; Produced by inspecting the correct room.
    (victim-detected ?p - patient ?loc - room)

    ;; Health assessment state.
    ;; assessment-pending is initially true and is removed after the assessment result.
    (assessment-pending ?p - patient)
    (assessed ?p - patient)
    (transportable ?p - patient)
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

    ;; Safe evacuation point.
    (safe-base ?loc - room)

    ;; Mission and patient status.
    (mission-active)
    (victim-alive)
    (victim-dead)

    ;; Health degradation control.
    ;; The health-degradation process runs only while this predicate is true.
    ;; Stabilization removes it, representing blocked health loss.
    (health-degrading)

    ;; Delay control.
    ;; Normal successful instances start with waited already true.
    ;; Too-late instances start with delay-required and must wait first.
    (waited)
    (delay-required)

    ;; Timed activity markers.
    (moving ?r - robot ?from - room ?to - room)
    (inspecting-empty ?r - robot ?loc - room)
    (inspecting-victim ?r - robot ?p - patient ?loc - room)
    (assessing ?r - robot ?p - patient ?loc - room)
    (stabilizing ?r - robot ?p - patient ?loc - room)
    (loading ?r - robot ?p - patient ?loc - room)
    (transporting ?r - robot ?p - patient ?from - room ?to - room)
    (unloading ?r - robot ?p - patient ?base - room)
    (waiting ?r - robot ?loc - room)

    ;; Final goal predicate.
    ;; In the definitive version, rescued means safely unloaded at base.
    (rescued ?p - patient)
  )

  (:functions

    ;; Patient health decreases continuously while health-degrading is true.
    (victim-health)

    ;; Shared progress counter for the current timed activity.
    ;; This model uses one robot, so one global counter is sufficient.
    (activity-progress)
  )

  ;; ---------------------------------------------------------------------------
  ;; START MOVE
  ;; ---------------------------------------------------------------------------
  ;; Starts normal movement while the robot is not carrying the patient.
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
  ;; Starts inspection of a room known not to contain the patient.
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
  ;; Starts inspection of the room containing the patient.
  ;; Detection is produced later by an automatic finish event.
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
  ;; Starts a timed health assessment after detection.
  ;; The finish-assess-* events decide whether direct transport is allowed
  ;; or stabilization is required, based on victim-health at assessment completion.
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
  ;; Starts stabilization when assessment determined that direct transport is unsafe.
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
  ;; Loading is possible only after the patient is ready for transport.
  ;; ready-for-transport can be produced either by direct assessment or by stabilization.
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
  ;; Transport movement is slower than normal movement.
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
  ;; If health is still at least 20, direct transport is considered safe.
  (:event finish-assess-direct-transport
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (assessing ?r ?p ?loc)
      (>= (activity-progress) 1)
      (>= (victim-health) 20)
    )
    :effect (and
      (not (assessing ?r ?p ?loc))
      (not (busy ?r))
      (available ?r)
      (assessed ?p)
      (transportable ?p)
      (ready-for-transport ?p)
      (not (assessment-pending ?p))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH ASSESSMENT: STABILIZATION REQUIRED
  ;; ---------------------------------------------------------------------------
  ;; Assessment duration = 1 time unit.
  ;; If health is below 20, stabilization is required before transport.
  (:event finish-assess-needs-stabilization
    :parameters (?r - robot ?p - patient ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (assessing ?r ?p ?loc)
      (>= (activity-progress) 1)
      (< (victim-health) 20)
      (> (victim-health) 0)
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
  ;; FINISH UNLOAD PATIENT AT BASE EVENT
  ;; ---------------------------------------------------------------------------
  ;; Unloading duration = 1 time unit.
  ;; This event produces the final rescued predicate.
  (:event finish-unload-patient-at-base
    :parameters (?r - robot ?p - patient ?base - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (unloading ?r ?p ?base)
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
