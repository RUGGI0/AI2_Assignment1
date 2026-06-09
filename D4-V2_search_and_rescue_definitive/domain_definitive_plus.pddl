(define (domain search-and-rescue-definitive-plus)

  ;; Definitive PDDL+ rescue strategy.
  ;;
  ;; This file combines the two rescue interpretations developed in the assignment:
  ;; - rescue as immediate on-site intervention / stabilization;
  ;; - rescue as transport of the patient back to base.
  ;;
  ;; Final intended logic:
  ;; 1. The robot searches the building.
  ;; 2. The robot explicitly inspects rooms.
  ;; 3. Inspection detects the victim.
  ;; 4. The robot assesses whether the patient's health allows direct transport.
  ;; 5. If health is sufficient, the robot transports the patient to base.
  ;; 6. If health is too low, the robot stabilizes the patient first.
  ;; 7. Stabilization stops health degradation.
  ;; 8. The robot then transports the stabilized patient to base.
  ;;
  ;; This is a placeholder domain file.
  ;; The complete PDDL+ domain will be written and tested in the next step.

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

    ;; Temporary placeholder predicate.
    ;; It keeps the file syntactically complete while the definitive model is still being designed.
    (placeholder)
  )

  (:functions

    ;; Numeric fluent that will later be used by the health degradation process.
    (victim-health)
  )
)
