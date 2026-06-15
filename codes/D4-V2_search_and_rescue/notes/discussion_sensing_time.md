# Discussion — Sensing and Time in Q2

## Why time matters in the rescue scenario

In Q1, the search and rescue task is represented as a classical symbolic planning problem. Actions such as movement, inspection, detection, and rescue are treated as discrete transitions between symbolic states.

In Q2, this abstraction is extended with time-dependent victim health. The key idea is that the robot is not only trying to find the correct sequence of actions; it must also complete the rescue before the victim health reaches zero.

This makes the interaction between sensing and time explicit.

## Sensing as inspection

The victim location is initially unknown in the scenario. The model approximates sensing through inspection actions.

The robot cannot rescue the victim directly from the predicate:

```lisp
(victim-at infirmary)
```

Instead, the robot must first trigger a detection predicate:

```lisp
(victim-detected infirmary)
```

This means that inspection is not only a movement-related task. It is an information-acquisition step that enables rescue.

## Health degradation as a PDDL+ process

The Q2 domain introduces the numeric fluent:

```lisp
(victim-health)
```

Victim health decreases through the PDDL+ process:

```lisp
(:process health-degradation
  :parameters ()
  :precondition (and
    (mission-active)
    (victim-alive)
    (> (victim-health) 0)
  )
  :effect (and
    (decrease (victim-health) (* #t 1))
  )
)
```

The term `#t` represents elapsed time. Therefore, the longer the robot spends moving, inspecting, or waiting, the more health is lost.

## Failure as an automatic event

The domain also includes the event:

```lisp
(:event victim-dies
  :parameters ()
  :precondition (and
    (mission-active)
    (victim-alive)
    (<= (victim-health) 0)
  )
  :effect (and
    (victim-dead)
    (not (victim-alive))
    (not (mission-active))
  )
)
```

This event is not selected by the planner. It is triggered automatically by the world when the health threshold is reached.

## Fast rescue case

In the fast rescue problem, victim health starts at 10.

The visual ENHSP timeline reaches rescue at approximately `t = 8`.

The intended sequence is:

```txt
start-move entrance corridor
start-move corridor lab
start-move lab infirmary
start-inspect-victim-room infirmary
start-rescue infirmary
```

Since the total time is lower than the initial health threshold, the victim remains alive and the rescue succeeds.

## Delayed rescue case

In the delayed rescue problem, the goal also requires:

```lisp
(waited)
```

This forces an explicit waiting period before rescue. The minimum required time becomes:

```txt
wait                         = 5
move entrance -> corridor    = 2
move corridor -> lab         = 2
move lab -> infirmary        = 2
inspect victim room          = 1
rescue                       = 1
total                        = 13
```

With victim health equal to 10 and degradation rate equal to 1 per time unit, the victim should die before the rescue can be completed.

The online ENHSP service returned an inconsistent empty plan for this delayed instance. Since the goal predicates `(waited)` and `(rescued)` are not true in the initial state, the empty plan is not semantically valid. The delayed case is therefore interpreted at the model level as a failure caused by time pressure.

## Conclusion

Q2 shows that sensing and time interact directly. Inspection is needed to acquire the information required for rescue, but inspection and movement consume time. Because victim health decreases continuously, exploration delay can turn an otherwise valid rescue sequence into a failed rescue.