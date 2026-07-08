# Requirements (draft)

Status: **draft**. Values marked TBD are undecided; values given without TBD
came directly from the project concept. Nothing here is frozen.

## Performance

| Requirement | Target | Notes |
|-------------|--------|-------|
| Payload | ~5 lb (~2.3 kg) | Exceeds typical small hobbyist arms (~2 lb). TBD whether this is at full reach or a rated radius. |
| Reach | **~3 ft (0.9 m)** | Chosen to be clearly beyond the ~2 ft hobbyist class while keeping counterweight mass and truss size modest. |
| Speed | Slow; TBD | Deliberately modest. Needs a concrete floor (e.g., "traverse the workspace in ≤ N seconds") so gearing can be chosen. |
| Repeatability | TBD | With closed-loop optical feedback this is set by the sensor, not the structure. Path accuracy matters for the drawing/plotting use case. |
| Absolute accuracy | TBD | May matter less than repeatability depending on use case. |

## Intended use

Primary: **general experimentation** — the arm is a platform and
proof-of-concept. It should additionally do **pick-and-place** (repeatability
across the workspace) and **drawing/plotting/marking** (smooth, accurate path
following on a surface) well. These two set the concrete performance bar:
repeatable point moves plus coordinated multi-joint path tracking.

## Architecture

| Requirement | Decision |
|-------------|----------|
| Structure | Plywood cut-out box-truss links |
| Gravity balance | Full counterbalance via **counterweights + transfer linkage** (parallelogram/four-bar style): net gravity torque ≈ 0 at every joint, in every pose, for the arm's own mass (payload is *not* balanced) |
| Actuation | NEMA 17 stepper motors with high-ratio reduction (mechanism TBD: belts, worm, cycloidal, cable/capstan…) |
| Position feedback | Closed-loop optical sensing of true position, compensating structural compliance and transmission error (concept TBD — candidates exist) |
| Degrees of freedom (arm) | 4: base yaw, shoulder pitch, elbow pitch, wrist pitch (pitch axes mutually parallel) |
| Degrees of freedom (end effector) | 2–3, as a separate module (e.g., wrist roll, gripper open/close); interface TBD |

## Cost

| Requirement | Target |
|-------------|--------|
| Total build cost | **~$500** (excluding tools already owned) — vs. the ~$2,000 hobbyist baseline. Leaves room for quality bearings, decent drivers, and sensors where they matter. |

## Explicit non-goals

- **Speed.** The arm is allowed to be slow. Slowness is a design tool, not a defect.
- **Structural rigidity as an accuracy strategy.** Compliance is accepted and measured out, not stiffened out.
- **Dynamic performance.** No requirement to manage vibration, resonance, or high-acceleration trajectories; operation is quasi-static.

## Assumptions to validate

- A geared-down NEMA 17 provides enough torque margin for 5 lb payload at the
  chosen reach and speed. (Needs a torque/gearing worksheet once reach is set.)
- The counterbalance can be made pose-independent across all three parallel
  pitch joints with acceptable added mass and inertia.
- The plywood truss's compliance is repeatable enough (low hysteresis) that
  optical feedback can servo it out.
- Slow closed-loop correction is sufficient — no destabilizing structural
  dynamics enter the control band.
