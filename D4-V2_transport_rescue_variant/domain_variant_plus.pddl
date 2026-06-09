
(define (domain search-and-rescue-variant-plus)

  ;; Alternative Q2 model: rescue as transport to base with health degradation.
  ;;
  ;; This domain is separate from the main assignment folder.
  ;;
  ;; In this alternative Q2:
  ;; - the robot must inspect the victim room before loading the patient;
  ;; - rescue means transporting the patient back to a safe base;
  ;; - victim health decreases continuously over time;
  ;; - if health reaches zero before unloading at the base, the victim dies;
  ;; - delayed instances must wait before starting exploration.
  ;;
  ;; The key modelling gate is (waited):
  ;; - all operational actions require (waited);
  ;; - the fast problem has (waited) in the initial state;
  ;; - the delayed problem has (delay-required), so start-wait must happen first.

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
    ;; PDDL does not assume that connected is symmetric.
    (connected ?from - room ?to - room)

    ;; Inspection state.
    (inspected ?loc - room)
    (uninspected ?loc - room)

    ;; Rooms known not to contain the patient.
    ;; This avoids negative victim-location preconditions.
    (empty-room ?loc - room)

    ;; Hidden symbolic victim location.
    ;; It is not enough to load the patient: detection is required first.
    (victim-at ?p - patient ?loc - room)

    ;; Produced by inspecting the correct room.
    (victim-detected ?p - patient ?loc - room)

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

    ;; Final goal predicate.
    ;; In this variant, rescued means unloaded at the safe base.
    (rescued ?p - patient)

    ;; Timed activity markers.
    (moving ?r - robot ?from - room ?to - room)
    (transporting ?r - robot ?p - patient ?from - room ?to - room)
    (inspecting-empty ?r - robot ?loc - room)
    (inspecting-victim ?r - robot ?p - patient ?loc - room)
    (loading ?r - robot ?p - patient ?loc - room)
    (unloading ?r - robot ?p - patient ?base - room)
    (waiting ?r - robot ?loc - room)

    ;; Delay-control predicates.
    ;; waited enables normal mission actions.
    ;; delay-required enables the wait action in delayed problems.
    (waited)
    (delay-required)
  )

  (:functions

    ;; Patient health decreases continuously while the mission is active.
    (victim-health)

    ;; Progress of the current timed activity.
    ;; One global fluent is enough because the model uses one robot.
    (activity-progress)
  )

  ;; ---------------------------------------------------------------------------
  ;; START MOVE
  ;; ---------------------------------------------------------------------------
  ;; Starts normal movement while the robot is not carrying the patient.
  ;; Requires (waited), so delayed instances cannot move before waiting.
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
  ;; Starts inspection of a room that does not contain the patient.
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
  ;; Detection is produced only by the finish-inspect-victim-room event.
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
  ;; START LOAD PATIENT
  ;; ---------------------------------------------------------------------------
  ;; Starts loading the patient.
  ;; Loading is allowed only after victim-detected has been produced.
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
  ;; Starts movement while carrying the patient.
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
  ;; Starts unloading at the safe base.
  ;; Rescue is completed only by the finish-unload-patient-at-base event.
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
  ;; Starts an intentional delay.
  ;; Only delayed instances have (delay-required) initially.
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
  ;; Core PDDL+ process.
  ;; Health decreases continuously while the mission is active and the victim is alive.
  (:process health-degradation
    :parameters ()
    :precondition (and
      (mission-active)
      (victim-alive)
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
  ;; FINISH LOAD PATIENT EVENT
  ;; ---------------------------------------------------------------------------
  ;; Loading duration = 1 time unit.
  ;; After loading, the robot is available again but not hands-free.
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
  ;; Rescue succeeds only if this event fires before victim-dies.
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
  ;; Waiting duration = 10 time units.
  ;; This event enables normal mission actions by adding (waited).
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
  ;; If health reaches zero before the patient is unloaded at base, rescue fails.
  (:event victim-dies
    :parameters ()
    :precondition (and
      (mission-active)
      (victim-alive)
      (<= (victim-health) 0)
    )
    :effect (and
      (victim-dead)
      (not (victim-alive))
      (not (mission-active))
    )
  )
)