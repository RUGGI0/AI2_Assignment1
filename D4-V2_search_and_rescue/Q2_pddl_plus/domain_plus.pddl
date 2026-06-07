(define (domain search-and-rescue-q2)

  ;; Q2 uses PDDL+ concepts.
  ;; The model extends the Q1 symbolic rescue domain with:
  ;; - a numeric fluent for victim health;
  ;; - a continuous process that decreases health over time;
  ;; - an event that marks failure when health reaches zero.
  ;;
  ;; Rescue is interpreted as in-place stabilisation:
  ;; the robot does not evacuate or transport the victim, but stabilises the
  ;; victim in the room where the victim is detected.
  (:requirements :adl :typing :numeric-fluents)

  (:types
    robot
    room
  )

  (:predicates

    ;; The robot is currently located in a room.
    (robot-at ?r - robot ?loc - room)

    ;; Known topology of the building.
    ;; As in Q1, connected is not automatically symmetric.
    (connected ?from - room ?to - room)

    ;; The robot has inspected a room.
    (inspected ?loc - room)

    ;; The victim is actually located in a room.
    ;; This is still encoded in the model, because we are not implementing
    ;; true belief-space planning.
    (victim-at ?loc - room)

    ;; The robot has detected the victim after inspection.
    (victim-detected ?loc - room)

    ;; The victim is alive and can still be rescued.
    (victim-alive)

    ;; The victim died because rescue was too late.
    (victim-dead)

    ;; The victim has been stabilised/rescued in place.
    (rescued)
  )

  (:functions

    ;; Numeric health level of the victim.
    ;; It decreases continuously while the victim is alive and not rescued.
    (victim-health)
  )

  ;; MOVE ACTION
  ;; Movement is still discrete here.
  ;; For simplicity, each move is represented as an instantaneous symbolic step.
  (:action move
    :parameters (?r - robot ?from - room ?to - room)
    :precondition (and
      (not (rescued))
      (not (victim-dead))
      (robot-at ?r ?from)
      (connected ?from ?to)
    )
    :effect (and
      (not (robot-at ?r ?from))
      (robot-at ?r ?to)
    )
  )

  ;; INSPECT EMPTY ROOM ACTION
  ;; Inspecting an empty room marks it as inspected but does not detect the victim.
  (:action inspect-empty-room
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (not (rescued))
      (not (victim-dead))
      (robot-at ?r ?loc)
      (not (inspected ?loc))
      (not (victim-at ?loc))
    )
    :effect (and
      (inspected ?loc)
    )
  )

  ;; INSPECT VICTIM ROOM ACTION
  ;; Inspecting the victim room produces the detection predicate.
  (:action inspect-victim-room
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (not (rescued))
      (not (victim-dead))
      (robot-at ?r ?loc)
      (not (inspected ?loc))
      (victim-at ?loc)
    )
    :effect (and
      (inspected ?loc)
      (victim-detected ?loc)
    )
  )

  ;; DELAY ACTION
  ;; This action represents wasted time before rescue.
  ;; It is used in the delayed-rescue problem to make the effect of health
  ;; degradation explicit and easy to discuss.
  (:action delay
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (not (rescued))
      (not (victim-dead))
      (robot-at ?r ?loc)
    )
    :effect (and
      ;; The action has no symbolic effect.
      ;; Its role is conceptual: it represents avoidable delay.
    )
  )

  ;; RESCUE ACTION
  ;; Rescue means in-place stabilisation of the victim.
  ;; The robot must be in the detected victim room, and the victim must still be alive.
  (:action rescue
    :parameters (?r - robot ?loc - room)
    :precondition (and
      (not (victim-dead))
      (victim-alive)
      (robot-at ?r ?loc)
      (victim-detected ?loc)
    )
    :effect (and
      (rescued)
      (not (victim-alive))
    )
  )

  ;; HEALTH DEGRADATION PROCESS
  ;; While the victim is alive and not rescued, health continuously decreases.
  ;; This is the main PDDL+ extension with respect to Q1.
  (:process health-decrease
    :parameters ()
    :precondition (and
      (victim-alive)
      (not (rescued))
      (not (victim-dead))
      (> (victim-health) 0)
    )
    :effect (and
      (decrease (victim-health) (* #t 1))
    )
  )

  ;; FAILURE EVENT
  ;; When health reaches zero, the victim dies automatically.
  ;; The event models an exogenous threshold-triggered condition.
  (:event victim-dies
    :parameters ()
    :precondition (and
      (victim-alive)
      (not (rescued))
      (<= (victim-health) 0)
    )
    :effect (and
      (victim-dead)
      (not (victim-alive))
    )
  )
)