# cad/

OpenSCAD sources. Everything parametric; shared numbers live in
`arm/params.scad`.

## House style

All OpenSCAD here uses the helper idiom in `lib/helpers.scad` instead of
raw `translate`/`rotate`/`mirror`: `tx/ty/tz`, `rx/ry/rz`, `mx/my/mz`
(list arguments replicate — e.g. `rz([0,90])` patterns two copies,
`my([0,1])` yields original + mirror), `cub`/`sq` with per-axis centering
flags (0 = from origin, 1 = centered, -1 = negative-going), and
`hull_seq()` for chained hulls.

## Layout

- `lib/helpers.scad` — the transform/primitive helpers described above.
- `lib/gears.scad` — self-contained involute gear library: 2D profiles and
  herringbone (double-helical) 3D gears. No external dependencies.
- `arm/` — the machine: a full-arm CONCEPT model (blocky, correct
  envelopes; plywood box-truss links at the v0 design point) plus the
  shoulder drivetrain's PRINTABLE detail parts (below), which the
  concept assembly draws verbatim so it cannot drift from the prints.
  Shoulder + elbow joints are paired preloaded bearing stations —
  internal preload loop, wood never in a precision fit, one design
  serves every joint; `arm/bearing_station.scad` is the annotated
  standalone detail — while the wrist keeps a dead-axle proxy.
  Reductions: shoulder = an m2 8T/51T herringbone primary (6.375:1)
  into an INVERTED capstan (sector fixed to the left base board,
  ~23.5:1, drive rides the arm; 150:1 total), yaw = a two-ply slew disc
  with printed herringbone gear segments driven directly by the same
  pinion on an inverted motor, riding rim rollers and hubbed on the
  bearing-station idiom flipped onto the flat baseplate
  (`arm/hub_station.scad` is its annotated standalone detail); the
  WRIST is a second herringbone primary + capstan cable loop with the
  motor remote-mounted on the (enlarged) elbow-CW fin, and the ELBOW
  is a third primary (the wheel grown to 66T) into a NOSE capstan
  folded into the board's own thickness: the +y fork cap grows a CNC
  lobe to r 77, a slim printed groove LINER rides its rim (cable
  centerline r 80) with ONE shared V-channel in the plate's
  mid-plane carrying both cables as complementary seated arcs, ends
  anchored at the liner's arc ends; the gear+drum stack rides the
  fin beside the wrist's, and two CROSSED 608-cored idler sheaves
  sitting ±1 mm astride the channel plane land the two tangencies a
  constant ~6.7° apart, so the liner stays travel-sized (~65:1
  total, margin ~1.67; see the elbow section in `params.scad` for
  the seat-tiling and sweep-safety arguments). The elbow counterweight
  block is TEMPORARILY not drawn while the fin hosts the two stacks
  (~1.5 kg of drive is CW credit); block + fin get resized together
  at the next mass audit. See the header of
  `arm/assembly.scad` for the architecture notes and `arm/params.scad`
  for poses and the capstan wrap math. `arm/testbench.scad` recomposes
  the same modules into the shoulder test rig (below).

  (The Phase 1a pendulum test stand that preceded the testbench, and
  its rig-specific parts, live in git history — `cad/prototype1/`.)

## Shoulder drivetrain parts (in `arm/`)

| File | Part | Make |
|------|------|------|
| `pinion.scad` | 8T herringbone, cut opposite-hand to mesh the +helix wheels, press-on 5 mm D-bore (proven grub-free fit: Ø5.1 with flat at nominal 2.0 mm); drives the shoulder primary AND the yaw ring | print |
| `gear_drum.scad` | the shoulder's gear+drum, FLIPPED stack: the 51T stub-addendum herringbone wheel INBOARD (straddling the boom plate through its kidney cutout), a short neck, the helically grooved capstan core across the sector band's lane (the lay is positively located; TWO cables share the one groove — length = travel + gap + end dead wraps), an anchor hole near each core end, and a bearing BOSS outboard; two 608s pocket into the ends (wheel face + boss, full-shoulder floors with inner-race reliefs), spins on a fixed M8 dead axle between two printed supports | print |
| `drive_housing.scad` | the shoulder drive's TWO printed housings, one per boom-plate face, staggered wood screws (d 3 pilots) clamping the ply from opposite sides — INBOARD: motor-face slab trimmed to the box wall's own footprint (NEMA boss hole + M3 pattern; mesh center distance printed-exact) with a kidney-tracing shear wall + four screw bosses; OUTBOARD: a wide-Y of walls — two arms + a spine meeting just past the drum, bay open toward the sector for the cable take-offs — under a triangular roof over the bearing end. The M8 dead axle is a THROUGH-BOLT clamping the pair across inner-race shoulders (d 13 ring each side, running recess around the outboard one) — light bearing preload, and no face ever touches both races. Top level = an annotated three-view diagram (assembled / exploded in install order / two-axle section); `-D 'piece="inboard"'` or `"outboard"` emits one housing bed-oriented | print ×2 |
| `wrist_drive.scad` | the WRIST's gear+capstan — gear_drum's stack at wrist scale: 51T wheel, neck, FAT helically grooved capstan (Ø32 core, ~10 mm wall over the bore), bearing boss; rides the enlarged elbow-CW fin on an M8 dead axle, driven by another print of the same 8T pinion (remote motor = free counterweight). ~20:1 wrist total (6.375 × 50/16), margin ~2.4 | print |
| `wrist_drum.scad` | the wrist DRUM: full-circle ring on the EE fork's left plate, cable centerline r 50 (the nose-cap radius — nothing protrudes at any pose), TWO PLAIN circular V-grooves (fleet ~0.2°, no ramps needed), radial knot anchors, open center around the joint's green flange, 6 wood screws into the ply disc. Two straight tangent runs (~650 mm, drawn as rods in the assembly) connect it to the capstan — no idlers, no joint crossing | print |
| `elbow_drive.scad` | the ELBOW's gear+capstan — gear_drum's stack with the wheel grown to 66T (primary 8.25; same 0.45 stub addendum, riding the same 0.1 inside the 8T interference limit at C = 74) and the shoulder-size grooved core (eff_r 10.125 — the 1.1 cord's bend floor); two-cable end anchors, 608s, M8 dead axle off the fin, a third print of the same 8T pinion. ~65:1 elbow total (8.25 × 80/10.125), margin ~1.67 with the idler losses | print |
| `elbow_nose.scad` | the elbow NOSE, inside the board's thickness: a slim ~152° printed groove LINER riding the +y cap's grown CNC lobe (r 77), cable centerline r 80, ONE shared plain V-channel in the plate's mid-plane carrying BOTH cables as complementary seated arcs with a constant ~6.7° bare gap (the crossed sheaves' doing — the march never reaches the liner). Both cable ends anchor in tangential feeds at its arc ends; the radial load presses liner onto the wood rim dead-center in the plane, and three thin tabs on the 55 face (two carrying the anchors' tangential pull, one retention) are the only material outboard of the board. One print | print |
| `sector_segment.scad` | printed channel segments, TWO-TRACK RAMPED and WEDGE-BACKED: the band seats flush on the left board's circular rim (cable tension presses print onto wood) and outboard of the board face the section fills solid down to the leg — ample radial backing; the leg screws to the outboard ply face through deep 7.5 mm counterbores (pilot circle CNC'd into the board). 45° V track slots climb at the drum groove's ~1.4° lead — zero fleet. Three ~180 mm prints (`-D idx=0..2`; on the end prints the anchored run's slot stops short of the arc end, and the cord knots in a recess on the end face) | print |

Gear width follows the one-tooth phase rule: each herringbone half
advances exactly one tooth of helix phase from center to edge (~27 mm
at m2 / 25°), so systematic tooth errors average out at every rotation
angle — and the extra width adds strength.

## Testbench

The drivetrain is proven on the **real base + upper arm**
(`arm/testbench.scad`), with the sector fixed to the left base board
(the phase-1a capstan inverted) and the drive riding the arm — the
test article IS the final hardware, and graduating the rig means
installing the parts it deliberately leaves off, without disassembling
anything that was tested.

- The two-ply slew disc lies flat on the desk, clamped dead (generic
  hold-down bars in the model). Gear segments, rim rollers, hold-downs,
  the hub station, and the yaw motor are simply not installed yet.
- No forearm and no elbow bearings: printed bushings fill the empty
  28.5 mm elbow pilot bores, and standard weight plates ride
  barbell-style on the ends of an M8 rod through them. Because the
  elbow counterweight is designed to put the forearm+CW CG on the elbow
  axis, a mass whose CG *is* the elbow axis is a statically exact
  stand-in for the whole forearm assembly at every shoulder pose:
  **τ = m·g·450·cos(pose)**, max at the horizontal, zero crossing at
  90° exposing backlash as the load swaps gear flanks.

See the header of `arm/testbench.scad` for what the rig exercises
as-final, the clamp zoning around the counterweight sweep, and the
torque math; `-D pose_shoulder=<deg>` (−20…100) poses it.

Cable: TWO separate lengths (~0.8 m each) of 1.1 mm stiff aramid
cord sharing the drum's one helical groove (see the two-cable
wrap-math note in `arm/params.scad`). Each cable knots at a radial
hole near its OWN end of the drum core (knot or crimp in the bore
annulus behind it) and at its own end of the sector channel — the
run's slot stops just short of the arc end, the cord continues
through a 2.2 mm hole in line with its track, and the knot seats in a
shallow recess on the segment's end face (tied in the open, drawn
back by tension). One cable winds on exactly as the other pays off,
so the resident wraps total a constant ~10 turns and the empty groove
between the two take-offs never changes width; both take-offs MARCH
one groove pitch per drum rev, exact and fleet-free against the two
ramped sector tracks — check at assembly that the groove hand matches
the track ramp direction, and install each cable at its NOMINAL wrap
count (the groove quantizes it; a miscounted turn shows up as ~1.4°
of fleet on that run, not a position error). Aramid is slippery and
weak in knots: figure-8 with a backup, or seize the tail. Tension by
rotating the drum before dropping the pinion into mesh — the free
drum equalizes the two cables through torque balance, so a single
tensioned sector end pretensions both; engagement locks it, and one
tooth of re-meshing ≈ 0.8 mm of cable. Set pretension above half the
max working tension swing (~56 N + margin) so both runs stay taut at
full load; a screw tensioner in one end segment replaces the
tooth-quantized adjustment when it proves too coarse (a 20-minute
reprint).

## Rendering

With OpenSCAD on the path (or the full path to `openscad.exe`), in
`arm/`:

```sh
openscad -o build/pinion.stl pinion.scad
openscad -o build/gear_drum.stl gear_drum.scad
openscad -o build/drive_housing_in.stl  -D 'piece="inboard"'  drive_housing.scad
openscad -o build/drive_housing_out.stl -D 'piece="outboard"' drive_housing.scad
openscad -o build/sector_segment_1.stl -D idx=1 sector_segment.scad
   # 3 distinct segments: idx = 0..2 (0 and 2 carry the anchors)
openscad -o build/wrist_drive.stl wrist_drive.scad
openscad -o build/wrist_drum.stl  wrist_drum.scad
openscad -o build/elbow_drive.stl elbow_drive.scad
openscad -o build/elbow_nose.stl  elbow_nose.scad
openscad -o build/arm.png       --viewall --autocenter assembly.scad
openscad -o build/testbench.png --viewall --autocenter testbench.scad
openscad -o build/testbench_up.png -D pose_shoulder=100 --viewall --autocenter testbench.scad
```

`build/` is git-ignored; regenerate outputs from source.

## CAD twin viewer

`arm/export.scad` emits the assembly one RIGID BODY at a time (static /
yaw / upper / fore / ee — the bodies between the pose transforms in
`assembly.scad`'s top level), each in its own joint frame at zero pose,
as colored 3MF; a sixth `frames` group echoes the joint offsets, travel
limits and default pose as JSON straight out of `params.scad`. The
three.js twin viewer (`model/twin.html`) loads those meshes onto the
same kinematic tree and poses them with the four joint angles alone —
`npm run export:cad` in `model/` regenerates everything into
`model/public/cad/` (git-ignored). Keep `assembly.scad`'s pose
transforms at the top level only: a pose rotation buried inside a body
module would silently freeze that joint in the viewer.

## Print notes

- Gears print teeth-up as modeled; the herringbone V needs no supports.
  PETG or PLA+. The gear+drum prints gear-down (drum up): the groove's
  round bottom is a gentle enough overhang on a vertical core.
- `gear_backlash = 0` deliberately: no backlash is cut into the teeth —
  set the mesh snug by pressing the gears together before clamping the
  motor sleeve's feet.
- `drum_len` is computed from the wrap math (travel + the shared
  two-cable gap + both end dead zones; 25 mm at the current ratios) —
  if the ratios, cable, or groove pitch change, the drum groove and
  every sector track follow, so regenerate every output.
- The sector segments print INVERTED, on the wide outboard end face:
  the arc sits in the bed plane, the V walls and the wedge diagonal
  print at ≥45°, the leg's board-side land faces up, and the
  counterbores rise straight off the bed — no support anywhere.
