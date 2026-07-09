# Roadmap

Drafted 2026-07-08. Phases run roughly in order, but 1a/1b/1c are parallel
tracks, and detailed design (3) can start while the testbed (2) is still
teaching lessons. Each phase has an exit gate — a thing that must be true
before committing money and effort to the next.

## Phase 0 — Converge the concept (in the model) ✅ complete 2026-07-09

Settled: the v0 design point (see requirements.md) — ratios 60/150/90/40,
conservative 0.41 N·m motor model, margins 1.61/1.94/3.90, traverse ~2.9 s
unloaded / ~6.8 s loaded — and the repeatability target (±1 mm mandatory,
±0.1 mm stretch).

## Phase 1 — Retire the risks on the bench (parallel tracks, all cheap) ← we are here

### 1a. Reduction mechanism trade + prototype

Paper-compare belts / worm / cycloidal / capstan-cable for the shoulder
(~27 N·m worst case, ~150–200:1). Prototype the leading candidate with one
NEMA 17: measure efficiency, backlash, friction, self-locking behavior.
Efficiency directly moves the shoulder margin, so this number matters more
than any catalog spec.

### 1b. Sensing bench prototype

Desk experiment, no arm needed: ESP32-CAM + printed fiducial/pattern at
macro focus. Measure achievable resolution, noise, and rate; prototype the
readout-gear tag reading and the pattern-correlation pipeline; try the
camera data-path options (on-board detection vs. streaming vs. wired).
This validates the entire sensing concept for ~$20.

### 1c. Structure coupon test

CNC-cut one truss section in candidate materials (plywood vs. pine).
Load-test: stiffness, strength, and — critically — **hysteresis**, because
"compliance is repeatable enough to servo out" is a core project assumption.
Also settles the tab-and-slot vs. gusset joint question and the material
trade. Pick the counterweight material/form here too.

**Exit gate:** chosen reduction mechanism with measured efficiency; measured
sensing resolution that supports the repeatability target; structure
material/joint style chosen with measured, repeatable compliance.

## Phase 2 — Single-joint testbed (shoulder-scale)

One complete **shoulder** joint integrating all four pillars: a full-length
wooden beam (~0.9 m) loaded with 5 lb at the tip to replicate the worst-case
~27 N·m, stub + counterweight at real scale (~6.5 kg), NEMA 17 through the
chosen reduction, unloaded readout gear + reference beam + cameras,
closed-loop control on one axis.

Shoulder-scale deliberately: it is the margin-critical joint, its
counterweight is the structurally demanding one, the biggest bending moments
live there, and hardware that survives the testbed becomes the real shoulder
in Phase 4. Hang dummy masses along the beam to replicate the articulated
arm's mass distribution, so counterweight sizing, residual imbalance, and
swing inertia are representative and the control tuning transfers.

Measure: positioning repeatability under varying load, residual imbalance,
friction/efficiency at full torque, deflection and its repeatability,
thermal drift over a session.

**Exit gate:** the shoulder joint meets the repeatability target at rated
load. This is the commit/no-commit point for the full build. (Fallback: if
the shoulder-scale reduction becomes the long pole, sensing and structure
can integrate on a lighter rig in parallel while the drive matures.)

## Phase 3 — Detailed design (OpenSCAD)

Full-arm CAD: links, joints, base and yaw bearing, counterweight mounts,
sensor and camera mounts, cable routing, end-effector interface plate.
Design to the CNC's 3×2 ft envelope. Outputs: cut files, printed-part STLs,
drawings, and a complete BOM rolled up against the $500 target.

The end-effector module (2–3 DOF) is a separate design workstream that can
trail the arm by one phase.

## Phase 4 — Build and bring-up

Cut, print, assemble. Electronics: 24 V supply, drivers, controller board;
decide the firmware split (likely: step generation and safety on the MCU,
kinematics/planning and the camera feedback loop on a host PC). Bring-up
open-loop first: motion, limits, balance verification (does it hold pose
unpowered?).

**Exit gate:** arm moves through its workspace open-loop, gravity-neutral,
carrying rated payload without skipped steps.

## Phase 5 — Sensing integration and calibration

Install readout gears, reference beams, cameras. Build the data pipeline.
Run the offline calibration program: grid of poses × payloads, external
truth measurement (laser-on-wall + touch-off jigs, per sensing.md), fit the
structural model — this is where Python enters. Then close the loop and
measure end-to-end accuracy.

**Exit gate:** closed-loop repeatability at the target, demonstrated across
the workspace and payload range.

## Phase 6 — Applications

Pick-and-place and drawing/plotting demos (the two committed use cases).
End-effector iterations. Write up results — the project exists to prove a
thesis; the demo and the numbers are the proof.
