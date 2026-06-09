(define (problem definitive-stabilize-then-transport)

  ;; Placeholder problem.
  ;; This instance will test the branch where health is too low for direct transport,
  ;; so the robot must stabilize the patient before transporting them to base.

  (:domain search-and-rescue-definitive-plus)

  (:objects
    rescuebot - robot
    patient1 - patient
    base corridor lab infirmary storage - room
  )

  (:init

    ;; Temporary placeholder fact.
    ;; It will be replaced by the real initial state after the definitive domain is implemented.
    (placeholder)

    ;; Lower health: direct transport should not be selected.
    ;; The final model should require stabilization before transport.
    (= (victim-health) 18)
  )

  (:goal

    ;; Temporary placeholder goal.
    ;; It will be replaced by the real transport-to-base rescue goal.
    (placeholder)
  )
)
