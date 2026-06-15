FINAL VERSION TO CHECK: codes/D4-V2_search_and_rescue_definitive

# AI2 Assignment 1 — D4-V2 Search and Rescue

This repository contains the final submission for the AI2 project **D4-V2: Search and Rescue – Unknown Victim Location**.

The project models a single rescue robot operating in a damaged building. The building topology is known, but the victim location is initially unknown. The robot must explore the environment, inspect rooms, detect the victim, and complete the rescue before time-dependent health degradation makes the mission fail.

## Repository structure

```txt
AI2_Assignment1/
├── codes/
│   ├── D4-V2_search_and_rescue/
│   ├── D4-V2_search_and_rescue_variant/
│   └── D4-V2_search_and_rescue_definitive/
├── Report/
├── slide/
└── README.md
```

## What to check first

The final version to check is:

```txt
codes/D4-V2_search_and_rescue_definitive
```

This folder contains the final autonomous PDDL+ extension. It is the most complete version because it combines:

- exploration and victim detection;
- patient assessment;
- autonomous branch selection using numeric `victim-health`;
- direct transport when health is high enough;
- stabilization when health is low but recoverable;
- mission deadline logic to prevent artificial waiting;
- a too-late case that correctly becomes unsolvable.

## Core assignment deliverable

Folder:

```txt
codes/D4-V2_search_and_rescue
```

This is the core Q1/Q2 assignment deliverable.

It contains:

```txt
Q1_basic_pddl/
Q2_pddl_plus/
notes/
README.md
```

### Q1 — Basic PDDL

The Q1 model approximates the unknown victim location problem using classical PDDL.

It includes:

- one known-location problem;
- one exploration problem;
- explicit inspection actions;
- detection before rescue;
- saved valid planner outputs.

Relevant files:

```txt
codes/D4-V2_search_and_rescue/Q1_basic_pddl/domain.pddl
codes/D4-V2_search_and_rescue/Q1_basic_pddl/problem_known_location.pddl
codes/D4-V2_search_and_rescue/Q1_basic_pddl/problem_exploration.pddl
codes/D4-V2_search_and_rescue/Q1_basic_pddl/plan_known_location.txt
codes/D4-V2_search_and_rescue/Q1_basic_pddl/plan_exploration.txt
```

### Q2 — PDDL+

The Q2 model introduces time-dependent health degradation.

It includes:

- numeric fluent `victim-health`;
- process `health-degradation`;
- event `victim-dies`;
- fast rescue case;
- delayed rescue case;
- saved planner-output discussion.

Relevant files:

```txt
codes/D4-V2_search_and_rescue/Q2_pddl_plus/domain_plus.pddl
codes/D4-V2_search_and_rescue/Q2_pddl_plus/problem_fast_rescue.pddl
codes/D4-V2_search_and_rescue/Q2_pddl_plus/problem_delayed_rescue.pddl
codes/D4-V2_search_and_rescue/Q2_pddl_plus/plan_fast_rescue.txt
codes/D4-V2_search_and_rescue/Q2_pddl_plus/plan_delayed_rescue.txt
```

## Optional transport-to-base variant

Folder:

```txt
codes/D4-V2_search_and_rescue_variant
```

This folder contains an optional interpretation where rescue means physically transporting the patient back to the safe base.

It adds:

- patient loading;
- movement while carrying the patient;
- unloading at base;
- final goal requiring the patient to be at base.

This folder is an additional interpretation and does not replace the core Q1/Q2 deliverable.

## Final autonomous extension

Folder:

```txt
codes/D4-V2_search_and_rescue_definitive
```

This is the final version to check.

It models rescue as an autonomous PDDL+ strategy. The planner does not rely on symbolic branch predicates inserted manually in the problem file. Instead, the branch is selected through the numeric value of `victim-health` after assessment.

Validated cases:

```txt
problem_definitive_direct_transport.pddl
problem_definitive_stabilize_then_transport.pddl
problem_definitive_too_late.pddl
```

Saved outputs:

```txt
plan_definitive_direct_transport.txt
plan_definitive_stabilize_then_transport.txt
plan_definitive_too_late.txt
```

Expected behaviour:

- direct transport case: solved without `start-stabilize-patient`;
- stabilization case: solved with `start-stabilize-patient`;
- too-late case: reported as `Problem unsolvable`.

## Planner used

The validated setup used for the final definitive version is:

```txt
ENHSP local Docker
```

The local ENHSP setup was used because remote planner/package discovery was unreliable during development.

Older Q2 and variant delayed outputs are kept as documented observations when the planner returned unsupported empty plans for non-empty goals. In those cases, the plan files explicitly explain why the empty output is not semantically accepted and what the model-level expectation is.

## How to inspect the results

The simplest way to inspect the project is to read the saved planner outputs.

Recommended order:

```txt
codes/D4-V2_search_and_rescue/Q1_basic_pddl/plan_known_location.txt
codes/D4-V2_search_and_rescue/Q1_basic_pddl/plan_exploration.txt
codes/D4-V2_search_and_rescue/Q2_pddl_plus/plan_fast_rescue.txt
codes/D4-V2_search_and_rescue_definitive/plan_definitive_direct_transport.txt
codes/D4-V2_search_and_rescue_definitive/plan_definitive_stabilize_then_transport.txt
codes/D4-V2_search_and_rescue_definitive/plan_definitive_too_late.txt
```

## Main modelling choices

- The robot is a single mobile agent.
- The building is represented as a known graph.
- Victim location is not directly assumed in the exploration instance.
- Inspection is represented explicitly.
- Detection enables later rescue actions.
- Classical PDDL approximates sensing through explicit predicates.
- PDDL+ is used to model continuous health degradation.
- Events are used for automatic threshold-triggered effects.
- The final autonomous model uses `mission-time` and `mission-deadline` to avoid artificial waiting.

## Known limitations

Classical PDDL is not a real partial-observability framework. It does not represent belief states, probabilistic sensing, noisy perception, or uncertainty updates. The unknown victim location is approximated with explicit symbolic predicates and inspection actions.

The PDDL+ models abstract away low-level robotics details such as geometry, collision avoidance, manipulation feasibility, path execution errors, and real sensor noise.

Some planner compatibility issues were observed with delayed PDDL+ cases. These are documented in the corresponding saved output files rather than hidden.

## Report and slides

The final report is expected in:

```txt
Report/report.pdf
```

The presentation deliverable is expected in:

```txt
slide/
```
