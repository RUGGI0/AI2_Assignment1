# D4-V2 Search and Rescue — Definitive Autonomous Assessment

This folder contains an experimental version of the definitive rescue strategy.

The validated definitive strategy uses symbolic assessment outcomes in the problem files:

```lisp
(transport-safe patient1)
```

or:

```lisp
(stabilization-required patient1)
```

This autonomous version removes those symbolic outcome predicates. The planner should select the rescue branch using the numeric value of:

```lisp
(victim-health)
```

at the end of the assessment action.

## Purpose

The purpose of this folder is to test the more elegant modelling choice:

```txt
if victim-health >= 20  -> direct transport
if victim-health < 20   -> stabilize first
```

This is conceptually closer to the PDDL+ view used in the assignment, because health is a numeric fluent affected by a continuous process, and automatic events use threshold conditions to change the discrete state.

## Files

```txt
D4-V2_search_and_rescue_definitive_autonomous/
├── domain_definitive_autonomous_plus.pddl
├── problem_autonomous_direct_transport.pddl
├── problem_autonomous_stabilize_then_transport.pddl
├── problem_autonomous_too_late.pddl
└── README.md
```

No plan files are included initially. Plan/output files should be written only after planner validation.

## Domain

The domain is:

```lisp
(define (domain search-and-rescue-definitive-autonomous-plus)
```

The main sequence is:

```txt
move
-> inspect victim room
-> detect victim
-> assess patient
-> direct transport or stabilization
-> load patient
-> move with patient
-> unload at base
-> rescued
```

## Autonomous branch selection

The assessment starts with:

```lisp
(:action start-assess-patient ...)
```

Then one of two automatic events should fire.

### Direct transport event

```lisp
(:event finish-assess-direct-transport
  :precondition (and
    (assessing ?r ?p ?loc)
    (>= (activity-progress) 1)
    (>= (victim-health) 20)
  )
  :effect (and
    (ready-for-transport ?p)
    ...
  )
)
```

If health is at least 20, the patient becomes ready for direct transport.

### Stabilization event

```lisp
(:event finish-assess-needs-stabilization
  :precondition (and
    (assessing ?r ?p ?loc)
    (>= (activity-progress) 1)
    (< (victim-health) 20)
    (> (victim-health) 0)
  )
  :effect (and
    (needs-stabilization ?p)
    ...
  )
)
```

If health is below 20 but still positive, stabilization is required before transport.

## Health degradation

Health degradation remains active:

```lisp
(:process health-degradation
  :effect (decrease (victim-health) (* #t 1))
)
```

If health reaches zero, the automatic death event fires:

```lisp
(:event victim-dies ...)
```

Stabilization stops degradation by removing:

```lisp
(health-degrading)
```

## Problem instances

### 1. Autonomous direct transport

```txt
problem_autonomous_direct_transport.pddl
```

Initial health:

```lisp
(= (victim-health) 35)
```

Expected behaviour:

```txt
assessment -> direct transport -> load -> move with patient -> unload at base
```

The plan should not include `start-stabilize-patient`.

### 2. Autonomous stabilize then transport

```txt
problem_autonomous_stabilize_then_transport.pddl
```

Initial health:

```lisp
(= (victim-health) 18)
```

Expected behaviour:

```txt
assessment -> stabilization -> load -> move with patient -> unload at base
```

The plan should include `start-stabilize-patient`.

### 3. Autonomous too late

```txt
problem_autonomous_too_late.pddl
```

Initial health:

```lisp
(= (victim-health) 18)
```

The problem also includes:

```lisp
(delay-required)
```

Expected model-level behaviour:

```txt
failure, because health reaches zero before rescue can be completed
```

## Planner note

This version is experimental. It is more elegant than the symbolic definitive version, but it depends on planner support for:

```txt
PDDL+ processes
PDDL+ events
continuous numeric effects with #t
numeric threshold conditions in event preconditions
```

If ENHSP returns a valid timeline for the first two problems and a failure/invalid-empty output for the too-late case, this autonomous version can become the preferred definitive version.

If ENHSP returns empty plans for successful instances, keep the symbolic definitive version as the validated deliverable and mention this autonomous version as an attempted but planner-sensitive extension.
