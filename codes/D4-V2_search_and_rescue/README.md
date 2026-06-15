# D4-V2 Search and Rescue — Core Assignment Deliverable

This folder contains the core assignment solution for **D4-V2: Search and Rescue – Unknown Victim Location**.

## Purpose

The scenario models a single rescue robot operating in a damaged building. The topology is known, but the victim location is not directly assumed in the exploration instance. The robot must move through the building, inspect rooms, detect the victim, and perform rescue.

## Q1 — Basic PDDL

Folder:

```txt
Q1_basic_pddl/
```

This part uses classical PDDL to approximate the unknown victim location problem.

Main modelling choices:

- the building is represented as a graph of rooms;
- movement is represented by `move`;
- sensing is approximated through explicit inspection actions;
- the victim can only be rescued after detection;
- the exploration problem forces the robot to inspect rooms before rescue.

Files:

```txt
domain.pddl
problem_known_location.pddl
problem_exploration.pddl
plan_known_location.txt
plan_exploration.txt
```

## Q2 — PDDL+

Folder:

```txt
Q2_pddl_plus/
```

This part extends the model with time-dependent victim health degradation.

Main modelling choices:

- `victim-health` is a numeric fluent;
- `health-degradation` continuously decreases health over time;
- `victim-dies` is an event triggered when health reaches zero;
- fast rescue and delayed rescue illustrate the interaction between sensing, time, and rescue success.

Files:

```txt
domain_plus.pddl
problem_fast_rescue.pddl
problem_delayed_rescue.pddl
plan_fast_rescue.txt
plan_delayed_rescue.txt
```

## Planner

The validated planner setup used during the project was **ENHSP local Docker**.

Some older delayed PDDL+ outputs are kept as documented planner-output observations. When the planner returned an empty plan for a non-empty goal, the file explicitly marks that output as semantically unsupported and explains the expected model-level result.

## Limitations

Classical PDDL does not model real partial observability. The unknown victim location is approximated by explicit predicates and inspection actions. Real sensing, probabilistic belief updates, noisy perception, and execution uncertainty are outside this model.
