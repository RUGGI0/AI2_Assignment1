# Optional Extension — Rescue as Transport to Base

This folder contains an optional interpretation of the rescue task.

In the main assignment model, rescue means completing the rescue operation in the room where the victim is detected.

In this variant, rescue means evacuating the patient back to a safe base after detection.

This variant is intentionally separated from the main `D4-V2_search_and_rescue` folder, because it changes the operational meaning of rescue and should not replace the required Q1/Q2 deliverables.

## Intended action sequence

1. Move through the known topology.
2. Inspect rooms until the victim is detected.
3. Load the patient.
4. Transport the patient back to base.
5. Unload the patient at base.

## Files

- `domain_transport.pddl`: alternative domain where rescue is modelled as transport.
- `problem_transport_to_base.pddl`: problem instance for evacuating the patient to base.
- `plan_transport_to_base.txt`: planner output, to be written only after validation.
