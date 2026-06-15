# Partial Observability in Q1

The assignment scenario assumes that the victim location is unknown. In a real robotic system, the robot would not know the true state of the world and would have to gather observations while exploring the environment.

However, the Q1 model is written in classical PDDL. Classical PDDL represents the world as a set of symbolic predicates that are either true or false. This means that the planning problem must contain an explicit initial state. As a consequence, the real victim location is still encoded in the problem file through the predicate:

```lisp
(victim-at infirmary)
```

This does not mean that the robot can immediately rescue the victim. The model separates the real state of the world from the information acquired by the robot.

## Separation between reality and detected information

The predicate:

```lisp
(victim-at ?loc)
```

represents where the victim actually is in the modelled world.

The predicate:

```lisp
(victim-detected ?loc)
```

represents the information acquired by the robot after inspecting the correct room.

The rescue action depends on `victim-detected`, not directly on `victim-at`. Therefore, even if the victim location is present in the model, the robot must perform an inspection action before rescue becomes possible.

## Explicit inspection

Inspection is modelled through two actions:

```lisp
inspect-empty-room
inspect-victim-room
```

The first one marks an empty room as inspected. The second one marks the victim room as inspected and also produces the detection predicate. This is a classical PDDL approximation of sensing.

## Limitation

This model does not implement true partial observability. There is no belief state, no probability distribution over possible victim locations, and no real sensing uncertainty. The planner still operates over a fully specified symbolic state.

The model is therefore a controlled abstraction. It is useful for showing the causal structure:

```txt
move → inspect → detect → rescue
```

but it is not equivalent to a POMDP or to a full belief-space planning model.

## Why the approximation is acceptable for Q1

The assignment asks for a Basic PDDL model and explicitly allows exploration to be approximated using explicit predicates. The model satisfies this requirement by making inspection mandatory and by ensuring that rescue is possible only after detection.
