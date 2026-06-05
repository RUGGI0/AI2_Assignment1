# D4-V2 — Search and Rescue: Unknown Victim Location [PROVISORY SKELETON VERSION]

## Scenario

This assignment models a search and rescue task in a damaged building. A single rescue robot operates in a known topology, but the victim location is initially unknown. The robot must explore the environment, inspect rooms, detect the victim, and then perform rescue operations.

## Assignment structure

```txt
D4-V2_search_and_rescue/
├── Q1_basic_pddl/
│   ├── domain.pddl
│   ├── problem_known_location.pddl
│   ├── problem_exploration.pddl
│   ├── plan_known_location.txt
│   └── plan_exploration.txt
├── Q2_pddl_plus/
│   ├── domain_plus.pddl
│   ├── problem_fast_rescue.pddl
│   ├── problem_delayed_rescue.pddl
│   ├── plan_fast_rescue.txt
│   └── plan_delayed_rescue.txt
├── notes/
│   ├── modelling_choices.md
│   ├── discussion_partial_observability.md
│   └── discussion_sensing_time.md
└── README.md
```

## Q1 — Basic PDDL model

The Q1 model provides a classical PDDL approximation of exploration and information acquisition.

Required outputs:

- a domain file;
- one problem instance with known victim location;
- one problem instance requiring exploration;
- valid plans for both instances.

## Q2 — PDDL+ model

The Q2 model extends the rescue scenario with time-dependent victim health degradation.

Required outputs:

- a PDDL+ domain file;
- a fast rescue problem;
- a delayed rescue problem;
- a comparison showing how delay affects success or failure.

## Discussion

The final discussion focuses on:

- the limitations of classical PDDL for partial observability;
- how explicit inspection approximates sensing;
- the interaction between sensing, exploration time, and victim health degradation.