# D4-V2 Search and Rescue — Optional Transport-to-Base Variant

This folder contains an optional interpretation of the D4-V2 scenario.

## Purpose

In the core assignment, rescue is modelled as an on-site rescue action. In this variant, rescue is interpreted as evacuation: the patient must be detected, loaded, transported back to base, and unloaded at the safe location.

This folder is **not a replacement** for the core Q1/Q2 deliverable. It is an additional model that explores a richer interpretation of rescue.

## Main modelling choices

The variant preserves the PDDL+ health degradation idea and adds transport-specific actions:

- `start-load-patient`;
- `start-move-with-patient`;
- `start-unload-patient-at-base`.

The final goal requires both:

- the patient is rescued;
- the patient is physically located at the base.

## Files

```txt
domain_variant_plus.pddl
problem_variant_fast.pddl
problem_variant_delayed.pddl
plan_variant_fast.txt
plan_variant_delayed.txt
notes/variant_transport_to_base_notes.md
README.md
```

## Planner

The model was tested with ENHSP. The fast case is documented as successful. The delayed case is kept as a documented failure/unsupported-output case, because the delay should make the rescue impossible before health reaches zero.
