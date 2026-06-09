# D4-V2 Search and Rescue — Definitive Rescue Strategy

This folder contains an optional advanced extension of the D4-V2 assignment.

The core assignment remains in:

```txt
D4-V2_search_and_rescue/
```

The transport-only optional variant remains in:

```txt
D4-V2_search_and_rescue_variant/
```

This folder contains the definitive rescue strategy:

```txt
D4-V2_search_and_rescue_definitive/
```

## Purpose

The definitive strategy combines the two rescue interpretations developed during the assignment:

1. locating and assisting the victim after inspection;
2. transporting the patient back to a safe base.

The robot does not blindly apply a single rescue procedure. Instead, after finding and detecting the patient, it performs an assessment and then chooses the appropriate rescue branch.

The intended high-level behaviour is:

```txt
search
→ inspect
→ detect victim
→ assess patient
→ either direct transport or stabilization
→ load patient
→ transport patient to base
→ unload patient at base
→ rescued
```

## Assignment relevance

The original D4-V2 scenario requires a rescue robot operating in a damaged building with known topology but unknown victim location. The robot must explore, inspect rooms, detect the victim, and perform rescue operations.

This definitive version keeps those requirements:

- the topology is known;
- the victim location is not assumed operationally before inspection;
- inspection is explicit;
- detection enables later rescue actions;
- rescue cannot happen before detection;
- victim health degrades over time;
- late rescue can fail.

The PDDL+ part is used to model continuous health degradation and automatic failure when health reaches zero.

## Files

```txt
D4-V2_search_and_rescue_definitive/
├── domain_definitive_plus.pddl
├── problem_definitive_direct_transport.pddl
├── problem_definitive_stabilize_then_transport.pddl
├── problem_definitive_too_late.pddl
├── plan_definitive_direct_transport.txt
├── plan_definitive_stabilize_then_transport.txt
├── plan_definitive_too_late.txt
└── README.md
```

## Domain overview

The domain is:

```txt
search-and-rescue-definitive-plus
```

The main predicates model:

- robot position;
- patient position;
- known topology;
- room inspection state;
- victim detection;
- patient assessment;
- stabilization;
- carrying/loading state;
- mission status;
- health degradation;
- final rescue.

The main numeric fluent is:

```lisp
(victim-health)
```

The domain also uses:

```lisp
(activity-progress)
```

to model the progress of timed activities through PDDL+ processes and events.

## Main modelling choices

### 1. Inspection is explicit

The robot cannot rescue or load the patient directly. It must inspect the correct room first.

The important chain is:

```txt
start-inspect-victim-room
→ finish-inspect-victim-room
→ victim-detected
```

The predicate `victim-detected` is required before later rescue actions.

### 2. Assessment is explicit

After detection, the robot performs:

```txt
start-assess-patient
```

The assessment result is represented symbolically in the problem file:

```lisp
(transport-safe patient1)
```

or:

```lisp
(stabilization-required patient1)
```

This keeps the assessment explicit while avoiding planner instability caused by complex numeric branching inside events.

### 3. Health degradation remains active

The definitive version keeps PDDL+ health degradation:

```lisp
(:process health-degradation
  ...
  :effect (decrease (victim-health) (* #t 1))
)
```

This means time matters. The longer the robot waits or moves, the lower the patient health becomes.

### 4. Stabilization stops health degradation

If the patient requires stabilization, the robot must execute:

```txt
start-stabilize-patient
```

The corresponding finish event removes:

```lisp
(health-degrading)
```

This models stabilization as stopping further health loss, not as instantly rescuing the patient.

### 5. Rescue means transport to base

In this definitive version, rescue is completed only when the patient is unloaded at the safe base.

The final goal requires:

```lisp
(rescued patient1)
(patient-at patient1 base)
```

This prevents a plan from counting the patient as rescued while still being in the victim room.

## Problem instances

### 1. Direct transport

File:

```txt
problem_definitive_direct_transport.pddl
```

This problem marks the patient as safe for direct transport:

```lisp
(transport-safe patient1)
```

Expected behaviour:

```txt
move to infirmary
inspect victim room
assess patient
load patient
transport patient to base
unload patient at base
```

Planner result:

```txt
success
```

The saved output is:

```txt
plan_definitive_direct_transport.txt
```

### 2. Stabilize then transport

File:

```txt
problem_definitive_stabilize_then_transport.pddl
```

This problem marks the patient as requiring stabilization:

```lisp
(stabilization-required patient1)
```

Expected behaviour:

```txt
move to infirmary
inspect victim room
assess patient
stabilize patient
load patient
transport patient to base
unload patient at base
```

Planner result:

```txt
success
```

The saved output is:

```txt
plan_definitive_stabilize_then_transport.txt
```

### 3. Too late

File:

```txt
problem_definitive_too_late.pddl
```

This problem combines:

```lisp
(delay-required)
(stabilization-required patient1)
(health-degrading)
```

The intended behaviour is failure: the robot is delayed, health keeps decreasing, and the victim should die before the rescue can be completed.

Planner output observed:

```txt
Plan found:
Metric: 0
Makespan: 0
States evaluated: 254
Planner found 1 plan(s).
```

This empty plan is not semantically valid because the goal requires:

```lisp
(rescued patient1)
(patient-at patient1 base)
```

and these facts are not true in the initial state.

Therefore, the output is documented as an inconsistent/unsupported ENHSP online output for this PDDL+ failure case. The model-level interpretation remains expected failure due to health reaching zero before rescue completion.

The saved output is:

```txt
plan_definitive_too_late.txt
```

## How to run

Use the VS Code PDDL extension with ENHSP.

### Direct transport

```txt
Planner:
ENHSP

Domain:
D4-V2_search_and_rescue_definitive/domain_definitive_plus.pddl

Problem:
D4-V2_search_and_rescue_definitive/problem_definitive_direct_transport.pddl
```

### Stabilize then transport

```txt
Planner:
ENHSP

Domain:
D4-V2_search_and_rescue_definitive/domain_definitive_plus.pddl

Problem:
D4-V2_search_and_rescue_definitive/problem_definitive_stabilize_then_transport.pddl
```

### Too late

```txt
Planner:
ENHSP

Domain:
D4-V2_search_and_rescue_definitive/domain_definitive_plus.pddl

Problem:
D4-V2_search_and_rescue_definitive/problem_definitive_too_late.pddl
```

## Validation status

| Instance | Expected result | Observed result | Interpretation |
|---|---|---|---|
| Direct transport | Success | Timeline with transport to base | Valid |
| Stabilize then transport | Success | Timeline includes stabilization and transport | Valid |
| Too late | Failure | Empty planner output | Invalid planner output, documented as expected model-level failure |

## Notes on planner behaviour

ENHSP via Planning Domains sometimes reports only the first action in the textual output, while the visual timeline shows the full sequence.

For successful cases, the saved plan files reconstruct the sequence from the validated timeline.

For failure cases, an empty plan is not accepted as a valid plan unless the goal is already true in the initial state. In `problem_definitive_too_late.pddl`, the goal is not initially true, so the empty output is documented as an unsupported/inconsistent planner result.

## Final interpretation

The definitive strategy demonstrates a more complete rescue model:

```txt
unknown victim location
+ explicit inspection
+ detection before rescue
+ health degradation over time
+ assessment-based rescue strategy
+ stabilization when needed
+ transport to base
+ failure when rescue is too late
```

This folder should be read as an advanced optional extension, not as a replacement for the required core assignment.