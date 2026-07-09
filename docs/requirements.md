# Requirements (draft)

Status: **draft**. Values marked TBD are undecided; everything else came from
project decisions (latest: 2026-07-08). Nothing is frozen.

## Performance

| Requirement | Target | Notes |
|-------------|--------|-------|
| Payload | **≥ 5 lb (~2.3 kg) at full extension** | 5 lb is the minimum capability over the *entire* workspace; higher payload is expected at reduced reach. |
| Reach | ~3 ft (0.9 m) | Clearly beyond the ~2 ft hobbyist class while keeping counterweight mass and truss size modest. |
| Speed | **Any pose to any pose, unloaded, in ~10 s** | Soft requirement: if counterweight inertia makes this hard, it may be relaxed. Loaded moves may be slower — the traverse spec applies unloaded. |
| Repeatability | TBD | Set by the sensing system, not the structure. Path accuracy matters for the drawing/plotting use case. |
| Absolute accuracy | TBD | May matter less than repeatability depending on use case. |

## Installation

| Requirement | Decision |
|-------------|----------|
| Mounting | Bolted to a bench (base does not need to be self-ballasting, though the arm counterweights will make it roughly balanced anyway) |
| Base yaw travel | Limited rotation — no continuous rotation, no slip ring. ±90° may be enough; up to ~240° if beneficial. |

## Architecture

| Requirement | Decision |
|-------------|----------|
| Structure | Plywood cut-out box-truss links. (Inexpensive pine boards are an open alternative — see open questions.) |
| Gravity balance | Counterweights **mounted on the members themselves**: a bar extending behind the elbow carries mass placing the forearm's center of mass at the elbow axis; the upper arm extends behind the shoulder and carries mass balancing the entire arm. The multiplicative growth of counterweight mass is accepted — slow accelerations make the added inertia tolerable. Payload is *not* balanced. |
| Counterweight stubs | Rearward extensions limited to **~half the length of their link** to avoid clumsiness, collisions, and workspace restriction. (Shorter lever → proportionally more counterweight mass.) Motors mounted at the joints can contribute counterweight mass but are expected to be far too light to serve alone. |
| Wrist link balance | **Not counterbalanced.** The wrist link is short and light, and the end effector dominates its mass anyway — so the arm's balance is deliberately imperfect, and shoulder/elbow see a small moment shift as the wrist pitches. Motors absorb this residual. Possibly an attachment point for an optional counterweight if a very heavy end effector demands it. |
| End-effector swaps | Provision for auxiliary counterweight positions (e.g., extra pins behind elbow/shoulder) to rebalance when a heavy end effector is fitted. (Tentative.) |
| Actuation | NEMA 17 stepper motors with high-ratio reduction (mechanism TBD: belts, worm, cycloidal, cable/capstan…) |
| Stepper drivers | **Open-loop** — no closed-loop stepper drivers. The dominant errors enter downstream of the motor (transmission, structure), so motor-shaft encoders add little; instead design with torque margin so skipped steps are not a realistic risk. |
| Position feedback | **Layered sensing** per the unloaded-reference optical metrology concept ([sensing.md](sensing.md)): (1) joint angles via unloaded anti-backlash readout gears with camera-read fiducials, (2) link bending via free-floating reference beams read by macro-focus cameras, (3) coarse cross-check via a global workspace camera. ESP32-CAM-class modules as the universal readout; precision anchored by offline load/pose calibration of a structural model. |
| Degrees of freedom (arm) | 4: base yaw, shoulder pitch, elbow pitch, wrist pitch (pitch axes mutually parallel) |
| Degrees of freedom (end effector) | 2–3, as a separate module (e.g., wrist roll, gripper open/close); interface TBD |

## Cost

| Requirement | Target |
|-------------|--------|
| Total build cost | ~$500 (excluding tools already owned) — vs. the ~$2,000 hobbyist baseline. Leaves room for quality bearings, decent drivers, and sensors where they matter. |

## Fabrication & on-hand resources

The design should build around what's already available:

- **CNC router** — work envelope roughly **3 ft × 2 ft**. Primary tool for
  plywood truss parts; panels must fit within this envelope.
- **3D printer** — for joints, brackets, gears, and other supporting parts.
- **Controller boards** — several spare 3D-printer-class boards currently
  running Marlin; can be reflashed, and writing custom firmware is in scope.
  These boards drive NEMA 17s natively — part of why NEMA 17 is the chosen
  motor class.
- **Motors** — nine NEMA 17 steppers on hand.
- **Wood stock** — not yet purchased; plywood vs. inexpensive pine boards is
  an open trade.

## Explicit non-goals

- **Speed.** The arm is allowed to be slow. Slowness is a design tool, not a defect.
- **Structural rigidity as an accuracy strategy.** Compliance is accepted and measured out, not stiffened out.
- **Dynamic performance.** No requirement to manage vibration, resonance, or high-acceleration trajectories; operation is quasi-static.
- **Continuous base rotation.** Limited yaw travel avoids slip rings and simplifies cable management.

## Assumptions to validate

- **Shoulder torque margin is the tightest number in the project.** 5 lb at
  3 ft is ~20 N·m of payload torque at the shoulder. A NEMA 17 through a
  100:1 reduction at realistic efficiency delivers roughly that with little
  margin — the torque/gearing worksheet needs to confirm ratio, loaded speed,
  and margin against skipped steps (which the open-loop-driver decision
  depends on).
- The ~10 s unloaded traverse is achievable given the inertia of
  member-mounted counterweights (soft requirement, may be relaxed).
- The residual imbalance from the unbalanced wrist link (and any unbalanced
  end-effector mass) stays comfortably inside the shoulder/elbow motors'
  torque budget across all poses.
- The wood structure's compliance is repeatable enough (low hysteresis) that
  the sensing system can servo it out.
- Slow closed-loop correction is sufficient — no destabilizing structural
  dynamics enter the control band.
