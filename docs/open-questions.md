# Open questions

The ⭐ items block the most downstream work. Answers get folded into
[requirements.md](requirements.md) and new design docs as they arrive.

## Still open

1. ⭐ **Optical feedback concepts.** Reserved for a dedicated discussion —
   the user has candidate concepts to capture. The layered architecture is
   decided (joint angles + link bending + approximate endpoint camera, with
   cross-layer redundancy used for self-calibration); the specific sensing
   mechanisms are not.
2. ⭐ **CAD / modeling tooling.** In discussion. Constraints: no paid
   software (SolidWorks, Fusion are out). User's preference order: OpenSCAD
   (daily driver), FreeCAD (never used, willing), OnShape (web-based, free
   tier requires open-sourcing the design — acceptable, but third choice).
   Also on the table: a custom lightweight model in Python or
   TypeScript/three.js for early concept spitballing — visualizing shapes,
   weights, and gearing before committing to detailed CAD.
3. **Reduction mechanism trade.** Belts (cheap, low backlash, limited ratio
   per stage), worm (huge ratio, self-locking, friction), cycloidal
   (printable, compact), cable/capstan (zero backlash, very cheap,
   wood-friendly). Closed-loop feedback relaxes backlash concerns, so
   friction, cost, and printability likely dominate. The shoulder joint's
   ~20 N·m payload torque makes this the pacing decision for the torque
   worksheet.
4. **Required feedback resolution and rate.** Follows from the repeatability
   target and the ~10 s traverse speed. Slow motion means even ~10 Hz
   correction may be plenty.
5. **Repeatability target number.** What accuracy do pick-and-place and
   drawing/plotting actually demand? (e.g., ±1 mm? ±3 mm?)
6. **Material trade: plywood box-truss vs. inexpensive pine boards.** Nothing
   purchased yet. Pine boards are cheap and need no sheet-cutting; plywood
   trusses have better strength-to-weight and suit the CNC. Could mix.
7. **Counterweight material and form.** Cheap dense mass: steel bar stock,
   concrete, sand-filled boxes, scrap? How weights mount and adjust (fixed
   vs. positionable along the stub)? Joint-mounted motors contribute some
   mass but nowhere near enough on their own. Note the stub-length limit
   (~half link length) roughly doubles the required mass vs. a full-length
   stub.
8. **First milestone.** Deferred until the tooling discussion (Q2) lands.
   Candidates: (a) torque/counterbalance math worksheet, (b) concept
   spitball model (Python/three.js) to compare gearing and balance schemes,
   (c) single-joint testbed, (d) full-arm CAD. The worksheet needs no
   tooling decision and could start immediately.

## Resolved

### 2026-07-08 (third round)

- **Wrist link:** no counterweight. Short, light, and dominated by
  end-effector mass; the resulting imbalance is accepted and absorbed by the
  motors. Possibly an attachment point for an optional counterweight for
  very heavy end effectors.
- **Exactness of balance:** perfect neutrality is *not* required — the
  unbalanced wrist link settles this in principle; the motors' torque budget
  absorbs residual imbalance.
- **Counterweight stub length:** limited to ~half the length of the parent
  link, to avoid collisions and workspace restriction.
- **CNC work envelope:** ~3 ft × ~2 ft.

### 2026-07-08 (second round)

- **Payload rating convention:** 5 lb is the minimum over the entire
  workspace, including full extension; more is expected closer in.
- **Speed floor:** any pose to any pose, unloaded, in ~10 s. Soft — may be
  relaxed if counterweight inertia demands.
- **Mounting:** bolted to a bench; base need not be self-ballasting.
- **Base yaw travel:** limited rotation is fine (±90° may suffice, up to
  ~240° if useful); no continuous rotation or slip ring.
- **Counterweight topology:** masses live on the members — bar behind the
  elbow balances the forearm about the elbow axis; the upper arm extends
  behind the shoulder with mass balancing the whole arm. Multiplicative
  counterweight growth accepted; slow acceleration makes the inertia
  tolerable.
- **End-effector swaps:** tentative plan for auxiliary counterweight
  positions (extra pins behind elbow/shoulder) to rebalance heavy end
  effectors.
- **Sensing architecture:** all three layers — joint angles, link bending,
  and approximate endpoint position (e.g., camera) — with redundancy across
  layers used to self-calibrate the motion/deflection model.
- **Stepper drivers:** open-loop. Dominant error enters downstream of the
  motor; design for torque margin instead of skip-step detection.
- **Fabrication tools:** CNC router and a 3D printer for supporting parts.
- **Controller:** spare 3D-printer-class boards on hand (Marlin today,
  reflashable; custom firmware is in scope). Drives NEMA 17s natively.
- **Parts on hand:** nine NEMA 17 stepper motors.

### 2026-07-08 (first round)

- **Target reach:** ~3 ft (0.9 m).
- **Cost target:** ~$500, excluding tools already owned.
- **Use:** general experimentation platform first; must also do pick-and-place
  and drawing/plotting well.
- **Counterbalance approach:** counterweights (not springs).
