(define (domain search-and-rescue-q2)

  ;; Q2 PDDL+ model for the Search and Rescue assignment.
  ;;
  ;; The assignment requires:
  ;; - a process modelling victim health degradation;
  ;; - an event representing failure or discovery conditions;
  ;; - a comparison showing how exploration delay affects rescue success.
  ;;
  ;; The ENHSP service did not accept :durative-action syntax in our previous tests.
  ;; Therefore, action duration is represented with a PDDL+ pattern:
  ;;
  ;;   start action -> continuous progress process -> automatic finish event
  ;;
  ;; This keeps time meaningful:
  ;; - the planner chooses start actions;
  ;; - processes evolve continuously while their preconditions hold;
  ;; - events fire automatically when numeric thresholds are reached.
  ;;
  ;; The model avoids ADL-style negative preconditions.
  ;; Instead of requiring (not (busy ?r)), it uses the positive predicate (available ?r).
  ;; Instead of requiring (not (victim-dead)), it uses (victim-alive).
  ;; Instead of requiring (not (inspected ?loc)), it uses (uninspected ?loc).

  (:requirements
    :strips
    :typing
    :numeric-fluents
    :continuous-effects
  )

  (:types
    robot
    room
  )

  (:predicates

    ;; The robot is currently located in a room.
    (robot-at ?r - robot ?loc - room)

    ;; The robot is free to start a new activity.
    ;; This avoids negative preconditions such as (not (busy ?r)).
    (available ?r - robot)

    ;; The robot is currently executing an activity.
    (busy ?r - robot)

    ;; Known topology of the building.
    ;; Connections are not automatically symmetric, so both directions must be
    ;; explicitly listed in the problem file.
    (connected ?from - room ?to - room)

    ;; A room has already been inspected.
    (inspected ?loc - room)

    ;; A room has not yet been inspected.
    ;; This avoids using (not (inspected ?loc)) as a precondition.
    (uninspected ?loc - room)

    ;; A room that does not contain the victim.
    ;; This avoids using (not (victim-at ?loc)) as a precondition.
    (empty-room ?loc - room)

    ;; Real victim location in the model.
    ;; Rescue cannot use this directly: detection is required first.
    (victim-at ?loc - room)

    ;; The victim has been detected after inspection.
    (victim-detected ?loc - room)

    ;; The victim is still alive.
    (victim-alive)

    ;; The mission is still active.
    ;; This becomes false after rescue or death.
    (mission-active)

    ;; Successful rescue condition.
    (rescued)

    ;; Failure condition.
    (victim-dead)

    ;; Activity-specific predicates.
    ;; They identify which activity is currently progressing.
    (moving ?r - robot ?from - room ?to - room)
    (inspecting-empty ?r - robot ?loc - room)
    (inspecting-victim ?r - robot ?loc - room)
    (rescuing ?r - robot ?loc - room)
    (waiting ?r - robot ?loc - room)

    ;; Used by the delayed problem to force an explicit waiting period.
    (waited)
  )

  (:functions

    ;; Victim health decreases continuously while the mission is active.
    (victim-health)

    ;; Progress of the current activity.
    ;; Since the assignment uses one robot, one global progress fluent is enough.
    (activity-progress)
  )

  ;; ---------------------------------------------------------------------------
  ;; START MOVE
  ;; ---------------------------------------------------------------------------
  ;; Starts a movement activity.
  ;; Movement completion is handled by the finish-move event after progress >= 2.
  (:action start-move
    :parameters (?r - robot ?from - room ?to - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (available ?r)
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
  ;; Starts inspection of a room that does not contain the victim.
  ;; The room becomes inspected only when the finish-inspect-empty-room event fires.
  (:action start-inspect-empty-room
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (available ?r)
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
  ;; Starts inspection of the room that contains the victim.
  ;; Detection is produced only by the finish-inspect-victim-room event.
  (:action start-inspect-victim-room
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (available ?r)
      (robot-at ?r ?loc)
      (uninspected ?loc)
      (victim-at ?loc)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (inspecting-victim ?r ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START RESCUE
  ;; ---------------------------------------------------------------------------
  ;; Starts the rescue activity.
  ;; The actual rescued predicate is produced by the finish-rescue event.
  (:action start-rescue
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (available ?r)
      (robot-at ?r ?loc)
      (victim-detected ?loc)
      (> (victim-health) 0)
    )
    :effect (and
      (not (available ?r))
      (busy ?r)
      (rescuing ?r ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; START WAIT
  ;; ---------------------------------------------------------------------------
  ;; Starts an explicit delay.
  ;; This is used in the delayed-rescue problem to show that waiting can make
  ;; rescue fail because victim health keeps decreasing.
  (:action start-wait
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
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
  ;; This process gives duration to move, inspect, rescue, and wait.
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
  ;; This is the core PDDL+ process required by the assignment.
  ;; While the mission is active and the victim is alive, health decreases
  ;; continuously at rate 1 per time unit.
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
  ;; Move duration = 2 time units.
  ;; The event fires automatically when activity-progress reaches 2.
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
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (inspecting-victim ?r ?loc)
      (>= (activity-progress) 1)
    )
    :effect (and
      (not (inspecting-victim ?r ?loc))
      (not (busy ?r))
      (available ?r)
      (inspected ?loc)
      (not (uninspected ?loc))
      (victim-detected ?loc)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH RESCUE EVENT
  ;; ---------------------------------------------------------------------------
  ;; Rescue duration = 1 time unit.
  ;; If this event fires before victim-dies, rescue succeeds.
  (:event finish-rescue
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (rescuing ?r ?loc)
      (>= (activity-progress) 1)
    )
    :effect (and
      (not (rescuing ?r ?loc))
      (not (busy ?r))
      (available ?r)
      (rescued)
      (not (mission-active))
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; FINISH WAIT EVENT
  ;; ---------------------------------------------------------------------------
  ;; Wait duration = 5 time units.
  ;; This event marks the explicit delay as completed.
  (:event finish-wait
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (mission-active)
      (victim-alive)
      (waiting ?r ?loc)
      (>= (activity-progress) 5)
    )
    :effect (and
      (not (waiting ?r ?loc))
      (not (busy ?r))
      (available ?r)
      (waited)
      (assign (activity-progress) 0)
    )
  )

  ;; ---------------------------------------------------------------------------
  ;; VICTIM DIES EVENT
  ;; ---------------------------------------------------------------------------
  ;; If health reaches zero before rescue, failure is triggered automatically.
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