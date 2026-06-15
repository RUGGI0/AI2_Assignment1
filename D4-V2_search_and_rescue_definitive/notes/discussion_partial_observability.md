# Discussion - Partial Observability

Classical PDDL does not directly model partial observability as contingent planning.

The assignment scenario is approximated by requiring explicit inspection before the victim can be detected and rescued.

The definitive model also adds uncertainty about patient condition.

Instead of encoding the final branch directly in the problem file, the robot assesses the patient and the domain selects the branch from `victim-health`.

This keeps the unknown-location and patient-assessment aspects explicit in the planning model.
