# Modelling Choices

The definitive model extends the original search-and-rescue task with patient assessment and autonomous branch selection.

The victim location is not directly available as an operational rescue fact. The robot must inspect the environment, detect the victim, and only then assess the patient.

The rescue branch is selected using the numeric fluent `victim-health`, not by a symbolic predicate inserted manually in the problem file.

The direct branch is selected when `victim-health` is high enough at assessment time.

The stabilization branch is selected when `victim-health` is below the threshold but the mission is still recoverable.

A mission deadline is included because the planner must not be allowed to wait artificially until the numeric health value crosses a threshold.
