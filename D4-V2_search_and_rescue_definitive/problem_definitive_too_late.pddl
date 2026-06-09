(define (problem definitive-too-late)

  ;; Placeholder problem.
  ;; This instance will test the failure case where the victim dies
  ;; before stabilization or transport can complete.

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

    ;; Very low health: the expected definitive model-level result will be failure.
    (= (victim-health) 8)
  )

  (:goal

    ;; Temporary placeholder goal.
    ;; It will be replaced by the real transport-to-base rescue goal.
    (placeholder)
  )
)
