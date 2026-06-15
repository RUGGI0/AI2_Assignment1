# Discussion - Sensing and Time

Sensing is modelled through explicit inspection and assessment actions.

Inspection makes the victim detected.

Assessment then uses the current numeric health value to decide which rescue branch becomes applicable.

Time is represented with PDDL+ processes and events.

The health-degradation process decreases `victim-health` while the mission is active.

The mission-clock process increases `mission-time`.

The mission-timeout event makes the mission fail if the deadline is reached before rescue.

This is important because search-and-rescue domains are time-critical and the planner should not exploit arbitrary waiting.
