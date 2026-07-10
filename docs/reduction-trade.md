# Reduction mechanism trade study (Phase 1a)

Status: analysis drafted 2026-07-09; conclusions are **hypotheses until the
bench prototypes are measured**. Efficiency is the discriminator, and
published efficiency numbers for cheap/printed reductions are unreliable —
that's why Phase 1a ends in a measurement, not a catalog choice.

## What each joint needs (from the v0 design point)

Motor: 0.41 N·m pull-out (flat to 450 rpm). Capacity = 0.41 × ratio × η.

| Joint | Ratio | Worst load | Capacity @ η=0.7 | η floor for margin 1.25 |
|-------|------:|-----------:|------------------:|------------------------:|
| Shoulder | 150:1 | 26.7 N·m | 43.1 N·m (margin 1.61) | **0.54** |
| Elbow | 90:1 | 13.3 N·m | 25.8 N·m (margin 1.94) | 0.45 |
| Wrist | 40:1 | 2.9 N·m | 11.5 N·m (margin 3.90) | 0.22 |
| Yaw | 60:1 | ~0 (friction + inertia only) | — | n/a |

Constraints carried in: **single-stage strongly preferred at elbow and
wrist**; no bulky large gears; closed-loop sensing makes backlash a minor
criterion; joints are travel-limited (sectors are allowed); 3D printer and
CNC router available; nine motors on hand (dual-motor joints are a legal
move).

## Candidates

| | Ratio/stage | Efficiency (expected) | Cost | Notes |
|---|---|---|---|---|
| **Worm** | 10–150+ | **30–60%**, lead-angle dependent; worse at higher ratio | $5–15 | Perpendicular layout, compact. Threaded-rod worm (M8/M10) + printed wheel is the classic cheap build: pitch ~1.25–1.5 mm gives module ~0.4–0.5, so even a 150 T wheel is only ~Ø75 mm — "single-stage 150:1 without a bulky gear" is genuinely available here. Self-locking below ~50% η. |
| **Cycloidal (printed)** | 10–~120 | 55–80% with decent bearings | $10–25 | Compact, strong, printable. Needs eccentric bearing + pins. Some lash from print tolerance (sensing absorbs). |
| **Capstan / cable sector** | ~10–60 (sector radius ÷ capstan radius) | **90%+** | $10–20 | Zero backlash, wood-friendly: the link itself carries a large plywood sector, cable wraps a small motor drum. Travel-limited joints suit sectors. Cable stretch/creep is a slow error — exactly what the sensing system corrects. Needs tensioning/termination design. |
| **Belt (GT2)** | 3–5 | ~90%/stage | $10–20 | Can't reach these ratios alone; useful only as a primary stage feeding something else. |
| **Printed herringbone pair (radially preloaded)** | 2–5 practical | ~90% | $2–5 | Proven in the user's prior work: with a compliant mechanism keeping slight radial pressure between centers, printed herringbones run with **effectively zero backlash**. Not a high-ratio solution by itself — the preferred *primary stage* primitive. |
| **Printed spur train** | ~25/stage practical | ~75–85% compound | $5 | Multi-stage and bulky at these ratios — excluded by preference. |

## Per-joint leanings (to be tested)

- **Wrist (40:1):** **worm.** Compact, self-locking, and the margin is so
  large (η floor 0.22) that even a poor worm clears it. Threaded-rod worm +
  ~Ø50 mm printed wheel.
- **Elbow (90:1):** **worm if measured η ≥ 0.5** (margin ≥ 1.4), else
  printed cycloidal (η floor 0.45 is comfortable for a decent cycloidal).
  Both are single-stage and compact at this ratio.
- **Shoulder (150:1): leading hypothesis (2026-07-09) — herringbone
  primary + capstan cable sector.** A 4.25:1 printed herringbone pair
  (12T/51T m2; the wheel's addendum stubbed to 0.65 so its tips clear the
  small pinion's base circle at 20° PA — the herringbone's full-tooth face
  overlap keeps contact continuous) drives a small cable drum; the cable
  wraps a plywood sector fixed to the upper arm (~35:1 — 238 mm sector
  radius over 6.75 mm effective drum radius; the higher primary ratio
  keeps the sector compact, 2026-07-10). Expected η ≈ 0.9 × 0.95 ≈
  **0.85 → margin ~1.96**. Worst-case cable tension ≈ 26.7 N·m / 0.238 m ≈
  **112 N** — mild for wire rope or Dyneema in a wooden groove. Capstan drift (an accumulating *relative*
  error) is made irrelevant by the *absolute* optical joint sensing; cable
  stretch under load is a slow systematic the calibration absorbs. Zero
  backlash end to end. **This is the first prototype; if it measures well
  it can simply become the final design.** Fallbacks, in order: worm (if
  it measures η ≥ 0.54), belt/herringbone primary + coarser worm, dual
  motors (nine on hand; doubles capacity, costs a driver channel).
- **Yaw (60:1):** lowest risk, no gravity load. Whatever wins elsewhere;
  a capstan sector or belt stack both fine.

## Power-off behavior (a real design input)

The arm's own mass is balanced, but the **payload is not**. On power loss:

- **Self-locking worm** joints freeze — the arm holds its payload. Free.
- Cycloidal and capstan joints back-drive under payload torque — the arm
  settles slowly (quasi-static, counterweighted, so "sags" rather than
  "falls," but it moves).

Self-locking at wrist + elbow + shoulder would make power-off completely
safe with a full gripper. This quietly favors worms anywhere the measured
efficiency clears the margin floor — a self-locking joint is *below* 50%
efficient by definition, so the shoulder cannot be both self-locking and
margin-1.6; elbow and wrist can.

## Prototype & measurement plan

Build one test rig, swap mechanisms through it:

- **Rig:** vertical plywood board at the bench edge, mechanism under test
  driving a 0.45 m pendulum arm (real upper-arm scale); weights hang
  directly in calibrated arm holes, so τ = m·g·r·sin(θ) is known exactly
  with no pulley friction in the load path. Travel −25°…+95° from
  straight-down: asymmetric so the horizontal pose is covered (6.05 kg at
  450 mm = 26.7 N·m, the worst-case shoulder torque), while one hung mass
  still sweeps torque from −42% to +100% of max across travel and the
  zero crossing at θ = 0 exposes lash as load transfers between flanks.
  Failure-safe: rest is a stable equilibrium and torque ramps with the
  commanded angle during bring-up. The gear mesh is set by press-and-clamp
  (no radial-preload flexure on the rig); if the plain snug mesh shows
  measurable lash at the zero crossing, the preload mechanism gets added
  back and re-measured. Drive from a spare Marlin board.
- **Measurements per mechanism:**
  1. Lifting efficiency: max weight raised without stalling at slow speed →
     η = (torque out) / (0.41 × ratio).
  2. Lowering behavior: back-drive or self-lock, and lowering efficiency.
  3. Starting friction / stiction (matters for ±0.1 mm stretch goal —
     stick-slip limits fine positioning authority).
  4. Lash: output movement range with motor held (informative, not
     disqualifying).
  5. Repeat lifting test at speed (e.g., 300 rpm motor) to spot-check the
     torque curve interaction.
- **CAD:** the complete test stand — drivetrain parts, pendulum arm, rig
  board/base/gussets, bearing hub, axle standoffs, and travel stops — is
  in [`cad/prototype1/`](../cad/prototype1/) (parametric OpenSCAD; see
  [`cad/README.md`](../cad/README.md) for geometry, cable, and bench
  notes).
- **Build order:** (1) herringbone-primary + capstan-sector at shoulder
  scale — the leading shoulder hypothesis, and it doubles as the start of
  the Phase 2 testbed drivetrain if it measures well; (2) threaded-rod worm
  ~90:1 (informs elbow, and wrist by extension); (3) printed cycloidal only
  if the worm disappoints at the elbow.
- **Synergy:** put a fiducial tag on the output arm and point an ESP32-CAM
  at it — the torque rig doubles as the first Phase 1b sensing experiment,
  measuring lash and stiction with the very sensor technology the arm will
  use.

## Decision criteria

For each joint, in order: (1) measured η clears the margin floor with ≥25%
to spare; (2) single-stage and compact (hard preference at elbow/wrist);
(3) power-off behavior; (4) cost and build simplicity; (5) stiction low
enough not to threaten the stretch goal. Backlash is explicitly last.
