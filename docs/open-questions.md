# Open questions

The ⭐ items block the most downstream work. Answers get folded into
[requirements.md](requirements.md) and new design docs as they arrive.

## Still open

1. **Sensing details.** The core concept is now captured in
   [sensing.md](sensing.md) — unloaded-reference optical metrology (readout
   gears for joint angles, floating reference beams for link bending, cheap
   camera modules as the universal readout). Remaining sensing-specific
   questions (sensor count/placement, camera data path, calibration method,
   upper-arm beam geometry) live at the bottom of that document.
2. **Reduction mechanism trade.** Belts (cheap, low backlash, limited ratio
   per stage), worm (huge ratio, self-locking, friction), cycloidal
   (printable, compact), cable/capstan (zero backlash, very cheap,
   wood-friendly). Closed-loop feedback relaxes backlash concerns, so
   friction, cost, and printability likely dominate. The shoulder joint's
   ~20 N·m payload torque makes this the pacing decision for the torque
   worksheet.
3. **Required feedback resolution and rate.** Follows from the repeatability
   target and the ~10 s traverse speed. Slow motion means even ~10 Hz
   correction may be plenty.
4. **Repeatability target number.** What accuracy do pick-and-place and
   drawing/plotting actually demand? (e.g., ±1 mm? ±3 mm?)
5. **Material trade: plywood box-truss vs. inexpensive pine boards.** Nothing
   purchased yet. Pine boards are cheap and need no sheet-cutting; plywood
   trusses have better strength-to-weight and suit the CNC. Could mix.
6. **Counterweight material and form.** Cheap dense mass: steel bar stock,
   concrete, sand-filled boxes, scrap? How weights mount and adjust (fixed
   vs. positionable along the stub)? Joint-mounted motors contribute some
   mass but nowhere near enough on their own. Note the stub-length limit
   (~half link length) roughly doubles the required mass vs. a full-length
   stub.
7. **First milestone.** Tooling is now decided; the concept model is the
   presumptive next step, with the torque/counterbalance math as its core.
   Later milestones: single-joint testbed, then full-arm CAD in OpenSCAD.

## Resolved

### 2026-07-08 (fifth round)

- **Modeling/CAD tooling:** documented in [tooling.md](tooling.md).
  A self-contained client-side **TypeScript + three.js engineering model**
  (no server — all math is closed-form and runs in the browser; Vite build;
  hostable as static files) for the concept/trade-study phase, with a pure
  model-core module separated from rendering. **OpenSCAD** as the geometry
  source of truth for detailed design. **Python** reserved for offline
  analysis scripts once measured data exists (e.g., calibration fitting) —
  not a live server. FreeCAD held in reserve for STEP/FEM needs; OnShape and
  paid CAD out.

### 2026-07-08 (fourth round)

- **Optical feedback concept:** captured in [sensing.md](sensing.md). Core
  principle: compare loaded members against unloaded optical references —
  an unloaded anti-backlash readout gear pair per joint (amplified rotation
  read by camera via fiducial tag), and a free-floating carbon-fiber
  reference beam alongside long links (deflection read by a macro-focus
  camera on the loaded structure). ESP32-CAM-class modules (<$10) as the
  readout everywhere. Global workspace camera demoted to coarse cross-check.
  Precision comes from offline load/pose calibration fitting a structural
  model that includes unmeasured compliances (bench, base).

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
