# Definitive Rescue Strategy — Search, Stabilize if Needed, Transport to Base

This folder contains an optional advanced PDDL+ extension of the D4-V2 assignment.

The main assignment remains in:

```txt
D4-V2_search_and_rescue/
```

The transport-only variant remains in:

```txt
D4-V2_search_and_rescue_variant/
```

This folder contains the definitive strategy:

```txt
D4-V2_search_and_rescue_definitive/
```

## Modelling idea

The robot does not blindly apply one rescue strategy.

Instead, after finding and detecting the patient, it evaluates the patient's health:

1. If health is sufficient, the robot transports the patient directly to the safe base.
2. If health is too low, the robot stabilizes the patient first.
3. Stabilization stops health degradation.
4. After stabilization, the robot transports the patient to the safe base.
5. If too much time passes before stabilization or rescue, the victim dies.

## Intended file structure

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

## Current status

This folder currently contains the domain and problem placeholders.

Plan files must be added only after planner validation.
