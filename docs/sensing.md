# Sensing concept: unloaded-reference optical metrology

Status: concept captured 2026-07-08; embodiments and details still evolving.

## The core principle

**Separate the force path from the measurement path.** Every measurement is
a comparison between a *loaded* member (the structure that carries force and
therefore deflects) and an *unloaded* reference member (which carries no
force and therefore faithfully represents the true geometry). The reference
is read out optically, usually with some form of amplification — mechanical
(gearing) or optical (magnification) — so that a cheap camera can resolve it.

This is the same principle behind high-end precision machines: CMMs and
wafer steppers use a separate *metrology frame*, isolated from the force
loop, precisely because the load-bearing structure cannot be trusted to
report its own position. The novelty here is doing it with plywood, printed
gears, carbon tube, and sub-$10 camera modules.

Because errors in the unloaded reference (gear tooth placement, reference-
beam gravity sag) are *systematic and repeatable* rather than load-dependent,
they can be calibrated out — which is exactly what the offline calibration
program (below) is for.

## Embodiment 1: unloaded readout gear (joint angle)

At a joint — say the elbow, driven by a worm on one side — mount a **parallel,
unloaded gear pair** on the other side:

- A **large gear** rotates with the forearm (i.e., it *is* the joint angle).
- A **small pinion**, free-spinning on its own bearings and attached to the
  upper arm, meshes with it. The pinion's rotation is the joint angle
  amplified by the gear ratio. Multi-stage trains can amplify further.
- A small **axial preload** (e.g., on a herringbone mesh) removes backlash.
- The pinion carries a **fiducial tag** (ArUco/AprilTag or a custom pattern);
  a camera reads its rotation.

Why it's faithful: the drive side is under load — the worm deflects, the
mesh deflects, the mounts deflect — so measuring anywhere in the drive train
lies. The readout gear transmits essentially zero torque (only its own
bearing friction), so it has no load-dependent error. What errors it does
have (tooth placement, eccentricity) repeat every revolution and calibrate
out.

What it measures — and doesn't: relative rotation of forearm vs. upper arm
*at the joint*, capturing gearbox windup, backlash, and drive-side
compliance. It does **not** see bending of the links themselves; that's
Embodiment 2's job. The two layers are complementary by construction.

Sizing note: tooth-placement error on the large gear enters as (linear error
at the pitch radius) ÷ (pitch radius), so a big readout gear is doubly good —
more amplification *and* proportionally less sensitivity to tooth error.
CNC-cut plywood or printed gears at 100+ mm radius are likely adequate even
before calibration.

Variant worth keeping in mind: skip the pinion and read the rim of a single
large disc directly with a close-focus camera (radius itself is the
amplifier). Fewer parts, no mesh error, but requires fine pattern printing
and macro focus instead of a coarse tag.

## Embodiment 2: unloaded reference beam (link bending)

For a long link like the forearm:

- Mount a **carbon-fiber tube** rigidly at one end (near the elbow), running
  parallel to the link, touching nothing else — a floating cantilever.
- Print a **fine, detailed pattern** on the tube's far end.
- Mount a **short-focal-length camera** (macro / near-microscope
  magnification) on the *loaded* structure at the far end, looking at the
  pattern.

Under load the arm bends; the unloaded tube doesn't. The camera — riding on
the deflecting structure — sees the pattern shift, hugely magnified by the
optics. Sub-pixel pattern correlation should resolve relative displacement
in the micron range.

What it measures: integrated bending of the link between the tube's root
mount and the camera station — the true structural deflection the joint
sensors can't see.

### Torsion (twist) measurement

Twist of the link matters for lateral/yaw accuracy under off-axis loads,
and the reference-beam setup can measure it — with a caveat about
amplification.

A single camera *can* read twist as rotation (roll) of the pattern in the
image. But roll is really a differential translation measurement across the
pattern: edge features move by (pattern radius × twist angle). The lever arm
is therefore limited to the camera's field of view — at macro magnification
only a few millimeters — so twist gets **no amplification beyond that tiny
baseline**, unlike bending, where the whole tube length works for you.
Ballpark: a ~4 mm field of view with realistic sub-pixel tracking resolves
roll to a few tenths of a milliradian ideally, likely ~1 mrad in practice.
Usable, but thin margin.

The fix is to widen the mechanical baseline so twist converts to a *large*
relative translation before the optics see it:

- **Radially spaced camera pair**: two cameras (or one camera + mirror
  tricks) looking at two points separated by baseline *b* perpendicular to
  the link axis; twist φ appears as differential displacement b·φ. An 80 mm
  baseline beats the single-camera roll readout by ~20×.
- **L-bracket variant** (equivalent formulation): one camera at the vertex
  of an L on the tube end sees pure bending; a second at the tip of the L
  sees bending + twist×L. The *difference* isolates torsion; the common
  signal is the bending measurement you wanted anyway.
- **Disc/rim variant**: a disc on the tube end with the camera reading its
  rim — the disc radius is the baseline, same math as the readout gear.

Since bending and twist mix in any off-axis measurement point, the
two-measurement-point difference scheme is the natural design: common mode =
bending, differential mode = torsion. Quasi-static operation means the two
readings need no tight synchronization.

Known error sources (all systematic, all modelable):

- **Gravity sag of the reference tube itself.** The tube is externally
  unloaded but not massless; its cantilever sag varies with arm pitch angle.
  For a stiff CF tube this is small and a smooth function of pose —
  calibratable.
- **Root-mount fidelity.** The tube reports deflection *relative to its
  mounting patch*; local deformation under that patch is invisible. Mount on
  a low-stress region of the link.
- **Cantilever vibration.** A free tube will ring at low amplitude; the
  quasi-static regime plus frame averaging should bury this.
- CFRP's near-zero thermal expansion is a bonus for a wooden machine.

Geometry may need rethinking for the upper arm (shorter, and the elbow
hardware is in the way) — open detail.

## Global workspace camera (low priority)

A camera watching the whole workspace and the end effector directly. Its
resolution is divided across the workspace (~a meter or more per ~1000 px),
so even with sub-pixel fiducial tracking it's a coarse instrument —
millimeter-class at best. Expected role: not precision feedback but a
**gross cross-check** — catching model divergence, verifying the
self-calibration hasn't drifted, detecting anomalies. Deliberately third in
priority.

## From sensor readings to end-effector position: the model

The readings do not simply add up. Some compliances are unmeasured — the
bench deflects under load, the base yaw platform deflects, joints have local
compliance outside any sensor's view. So the architecture is:

> Many local measurements (joint angles, link deflections, twists) feed a
> **fitted structural model** that predicts end-effector position, with
> unmeasured compliances represented as calibrated stiffness terms.

The layered redundancy (joint sensing + bending sensing + any endpoint
observation) over-determines the state, which is what lets the model be
*trained* rather than derived: apply known loads in known poses, measure the
true end-effector position by an independent method, and fit.

### Offline calibration

The precision anchor of the whole system. Procedure sketch: place the arm in
a grid of poses × payloads, measure true tip position externally, fit the
model that maps sensor readings → tip pose. Candidate external measurement
methods (undecided):

- **Laser pointer on the wrist, spot on a distant wall** — distance is the
  amplifier; cheap and very much in the spirit of the project. Measures
  angles superbly, position less directly.
- **Dial indicators** against the tip for local, single-axis truth.
- **Printed fiducial board + one more ESP32-CAM** at close range where the
  tip visits — the same sensing tech turned into a bench reference.
- **Plumb line / straightedge / touch-off jigs** with known geometry —
  measures repeatability and known-point accuracy.

## Sensor platform: cheap camera modules

The enabling economics: **ESP32-CAM class modules cost well under $10** —
cheaper than a single decent optical encoder plus its readout circuit, yet
arranged as a microscope over a fine pattern (or watching an amplified tag)
they resolve position extraordinarily finely. The plan is to sprinkle
several of them over the machine: one per readout gear, one per reference
beam, possibly one global.

Practical notes to validate:

- Stock lenses focus-adjust by unscrewing; macro distances are achievable.
- Rolling shutter and low frame rate don't matter in a quasi-static machine;
  even ~10 Hz of correction is likely plenty.
- Per-camera LED illumination (the module has one onboard) makes readings
  lighting-independent.
- On-board pattern detection (sending only pose data) vs. streaming video to
  a host (which centralizes processing but may congest Wi-Fi with several
  cameras) is an open architecture choice; wired serial from each module is
  a third option.

## Open questions (sensing-specific)

1. Sensor count and placement for v1 — e.g., readout gear per pitch joint
   (3) + forearm reference beam + one spare = ~5 cameras?
2. Does the base yaw joint get a readout gear too, and does yaw need a
   reference-beam analog (the column/base twisting under lateral load)?
3. Reference-beam geometry for the upper arm.
4. Camera data path: on-board detection vs. host streaming vs. wired serial.
5. External calibration method choice (see candidates above).
6. Required resolution per sensor — flows down from the (still unset)
   end-effector repeatability target.
