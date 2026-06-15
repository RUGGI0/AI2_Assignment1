# D4-V2 Search and Rescue - Definitive PDDL+ Model

This folder contains the final definitive extension of the D4-V2 Search and Rescue assignment.

The model represents a rescue robot that must search for an unknown victim, inspect rooms, detect the patient, assess the patient condition, and then autonomously choose the rescue strategy.

The final version uses PDDL+ numeric fluents, processes, and events.

## Files

- `domain_definitive_plus.pddl`
- `problem_definitive_direct_transport.pddl`
- `problem_definitive_stabilize_then_transport.pddl`
- `problem_definitive_too_late.pddl`
- `plan_definitive_direct_transport.txt`
- `plan_definitive_stabilize_then_transport.txt`
- `plan_definitive_too_late.txt`
- `notes/modelling_choices.md`
- `notes/discussion_sensing_time.md`
- `notes/discussion_partial_observability.md`

## Main idea

The robot must perform this pipeline:

`search -> inspect -> detect victim -> assess patient -> choose branch -> transport to base`

The branch is selected autonomously from the numeric value of `victim-health`.

If `victim-health` is high enough at assessment time, the model selects direct transport.

If `victim-health` is below the threshold, the model selects stabilization before transport.

If the mission starts too late or exceeds the mission deadline, the problem becomes unsolvable.

## Why mission-deadline is included

During testing, ENHSP could wait artificially before acting. Since `victim-health` decreases over time, arbitrary waiting could force the health value below the threshold and incorrectly trigger stabilization.

The final model therefore includes a mission clock and a mission deadline. This prevents unrealistic waiting and keeps the health-based branch selection meaningful.

## Validated outcomes

Direct transport:

- Problem solved.
- `start-stabilize-patient` does not appear.
- The robot assesses, loads, transports, and unloads the patient at base.

Stabilize then transport:

- Problem solved.
- `start-stabilize-patient` appears.
- The robot stabilizes the patient before transport.

Too late:

- Problem unsolvable.
- The initial delay makes rescue impossible before failure conditions.
