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
  Reductions: shoulder = an m2 12T/51T herringbone primary (4.25:1)
  into an INVERTED capstan (sector fixed to the left base board,
  ~35:1, drive rides the arm; 150:1 total), yaw = a two-ply slew disc
  with printed herringbone gear segments driven directly by the same
  pinion on an inverted motor, riding rim rollers and hubbed on the
  bearing-station idiom flipped onto the flat baseplate
  (`arm/hub_station.scad` is its annotated standalone detail); the
  elbow + wrist drives are being overhauled (worms dropped) and the
  model carries bare joints there. See the header of
  `arm/assembly.scad` for the architecture notes and `arm/params.scad`
  for poses and the capstan wrap math. `arm/testbench.scad` recomposes
  the same modules into the shoulder test rig (below).

  (The Phase 1a pendulum test stand that preceded the testbench, and
  its rig-specific parts, live in git history — `cad/prototype1/`.)

## Shoulder drivetrain parts (in `arm/`)

| File | Part | Make |
|------|------|------|
| `pinion.scad` | 12T herringbone, press-on 5 mm D-bore (proven grub-free fit: Ø5.1 with flat at nominal 2.0 mm); drives the shoulder primary AND the yaw ring | print |
| `gear_drum.scad` | the shoulder's gear+drum: helically grooved capstan core INBOARD (the lay is positively located; length = wrap band + its march), mid-groove anchor hole, a short neck spanning the sector band's outboard wall, and the 51T stub-addendum herringbone wheel OUTBOARD; two 608s pocket into the part's ends, spins on a fixed M8 dead axle | print |
| `sector_segment.scad` | printed channel segments, TWO-TRACK RAMPED and WEDGE-BACKED: the band seats flush on the left board's circular rim (cable tension presses print onto wood) and outboard of the board face the section fills solid down to the leg — ample radial backing; the leg screws to the outboard ply face through deep 7.5 mm counterbores (pilot circle CNC'd into the board). 45° V track slots climb at the drum groove's ~2° lead — zero fleet. Three ~180 mm prints (`-D idx=0..2`; on the end prints the anchored run's slot stops short of the arc end, and the cord knots in a recess on the end face) | print |

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

Cable (~2 m of 1.1 mm stiff aramid cord): anchor at the drum's
mid-groove radial hole (knot behind), ~14 resident wraps riding the
helical groove of the 41 mm drum, both ends terminating in the printed
END segments of the channel — each run's slot stops just short of the
arc end, the cord continues through a 2.2 mm hole in line with its
track, and the knot seats in a shallow recess on the segment's end
face (tied in the open, drawn back by tension). The wrap band MARCHES
one groove pitch per drum rev (see the wrap-math note in
`arm/params.scad`): the groove and the two ramped sector tracks make
the walk exact and fleet-free — check at assembly that the groove hand
matches the track ramp direction. Aramid is slippery and weak in
knots: figure-8 with a backup, or seize the tail. Tension by rotating
the drum before dropping the pinion into mesh — the free drum
equalizes both runs through torque balance, so a single tensioned end
pretensions the whole loop; engagement locks it, and one tooth of
re-meshing ≈ 0.8 mm of cable. Set pretension above half the max
working tension swing (~56 N + margin) so both runs stay taut at full
load; a screw tensioner in one end segment replaces the
tooth-quantized adjustment when it proves too coarse (a 20-minute
reprint).

## Rendering

With OpenSCAD on the path (or the full path to `openscad.exe`), in
`arm/`:

```sh
openscad -o build/pinion.stl pinion.scad
openscad -o build/gear_drum.stl gear_drum.scad
openscad -o build/sector_segment_1.stl -D idx=1 sector_segment.scad
   # 3 distinct segments: idx = 0..2 (0 and 2 carry the anchors)
openscad -o build/arm.png       --viewall --autocenter assembly.scad
openscad -o build/testbench.png --viewall --autocenter testbench.scad
openscad -o build/testbench_up.png -D pose_shoulder=100 --viewall --autocenter testbench.scad
```

`build/` is git-ignored; regenerate outputs from source.

## Print notes

- Gears print teeth-up as modeled; the herringbone V needs no supports.
  PETG or PLA+. The gear+drum prints gear-down (drum up): the groove's
  round bottom is a gentle enough overhang on a vertical core.
- `gear_backlash = 0` deliberately: no backlash is cut into the teeth —
  set the mesh snug by pressing the gears together before clamping the
  motor sleeve's feet.
- `drum_len` is computed from the wrap math (resident band + its march;
  ~41 mm at the current ratios) — if the ratios, cable, or groove pitch
  change, the drum groove and every sector track follow, so regenerate
  every output.
- The sector segments print INVERTED, on the wide outboard end face:
  the arc sits in the bed plane, the V walls and the wedge diagonal
  print at ≥45°, the leg's board-side land faces up, and the
  counterbores rise straight off the bed — no support anywhere.
