(define (problem definitive-direct-transport)

  ;; Placeholder problem.
  ;; This instance will test the branch where the victim is healthy enough
  ;; to be transported directly to base without stabilization.

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

    ;; High enough health for direct transport.
    (= (victim-health) 30)
  )

  (:goal

    ;; Temporary placeholder goal.
    ;; It will be replaced by the real transport-to-base rescue goal.
    (placeholder)
  )
)
