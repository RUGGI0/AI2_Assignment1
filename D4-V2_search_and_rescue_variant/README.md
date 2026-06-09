# Alternative Q2 — Rescue Variant with Transport to Base and Health Degradation

This folder contains an alternative interpretation of Q2.

The main assignment folder `D4-V2_search_and_rescue/` contains the required Q1 and Q2 models.

This folder contains a separate alternative Q2 model where rescue does not mean treating the victim in place. Instead, rescue means:

1. finding the victim through inspection;
2. detecting the victim;
3. loading the patient;
4. transporting the patient back to the safe base;
5. unloading the patient at the base before health reaches zero.

The model is kept separate because it changes the operational meaning of rescue.

## Files

- `domain_variant_plus.pddl`: PDDL+ domain for the transport-based rescue variant with victim health degradation.
- `problem_variant_fast.pddl`: fast variant instance.
- `problem_variant_delayed.pddl`: delayed variant instance.
- `plan_variant_fast.txt`: planner output, written only after validation.
- `plan_variant_delayed.txt`: planner output, written only after validation.

## Modelling idea

The patient health decreases continuously over time. Rescue succeeds only if the patient is unloaded at the safe base before the failure event is triggered.
