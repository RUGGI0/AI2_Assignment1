# D4-V2 Search and Rescue

## Scenario

A single rescue robot operates in a damaged building. The topology of the building is known, but the victim location is unknown. The robot must explore the environment, inspect rooms, detect the victim, and then perform rescue operations.

## Classical PDDL approximation

Classical PDDL assumes that the planning state is explicitly represented through predicates. This is problematic for unknown victim location, because true partial observability is not directly represented in a classical planning problem.

For this reason, the Q1 model approximates unknown victim location through explicit exploration predicates. The robot does not initially act as if it already knows where the victim is. Instead, it must inspect rooms and acquire a symbolic detection fact before rescue becomes possible.

## Main modelling choices

The environment is represented as a graph of rooms. Movement is possible only between connected rooms.

The robot is represented by its current room.

Inspection is represented explicitly through an `inspect` action.

Detection is represented as a symbolic state change caused by inspection.

Rescue is only possible after the victim has been detected.

The model abstracts away geometry, motion constraints, sensing noise, rubble, uncertainty probabilities, and execution failures.

## Q1 limitation

The exploration problem is still an approximation. The planner is not genuinely reasoning under partial observability. Instead, the domain encodes a simplified form of information acquisition using predicates and action effects.

## Q2 extension

The PDDL+ model introduces a numeric fluent representing victim health. A process decreases health over time. Events are used to model failure conditions when the rescue is too late. This makes it possible to discuss how exploration delay affects rescue success.