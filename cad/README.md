# cad/

OpenSCAD sources. Everything parametric; shared numbers live in each
project's `params.scad`.

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
- `arm/` — full-arm CONCEPT model (blocky, correct envelopes): plywood
  box-truss links at the v0 design point. Shoulder + elbow joints are
  paired preloaded bearing stations — internal preload loop, wood never
  in a precision fit; `arm/bearing_station.scad` is the annotated
  standalone detail — while the wrist keeps a dead-axle proxy.
  Reductions: shoulder = the prototype1 capstan INVERTED (sector fixed
  to the base, drive rides the arm), yaw = a two-ply slew disc with
  printed herringbone gear segments driven directly by the m2 12T
  pinion; the elbow + wrist drives are being overhauled (worms
  dropped) and the model carries bare joints there. For iterating
  the big-picture structure before detailed design; see the header of
  `arm/assembly.scad` for the architecture notes and `arm/params.scad`
  for poses. `arm/testbench.scad` recomposes the same part modules into
  the shoulder test rig (below).
- `prototype1/` — Phase 1a shoulder drivetrain: herringbone primary
  (12T/51T, module 2, 4.25:1; wheel tips stubbed to 0.65 addendum so
  they clear the small pinion's base circle at 20° PA) + capstan cable
  sector (Ø12 mm drum core, 238 mm effective sector radius, ~35:1) =
  150:1 total. The pendulum test stand that originally carried these
  parts is superseded by `arm/testbench.scad` (stand files removed; git
  history has them); the drivetrain part files remain as the seed of
  the real shoulder's detail design.

## prototype1 parts

| File | Part | Make |
|------|------|------|
| `pinion.scad` | 12T herringbone, press-on 5 mm D-bore (proven grub-free fit: Ø5.1 with flat at nominal 2.0 mm) | print |
| `gear_drum.scad` | 51T stub-addendum herringbone with integrated cable drum (length from the wrap math); two 608 bearings press in, spins on a fixed M8 dead axle | print |
| `motor_mount.scad` | rigid slotted plate; the motor plunges through the board and hangs from it; mesh set by press-and-clamp | print |
| `bridge.scad` | spans the gear+drum tangent to the arc; picks up the axle top so the drum axle is simply supported | print |
| `sector.scad` | sector core with the polygonal facet rim the segments clip over — superseded as a part (the fixed sector is one CNC piece with the left base board); kept as the rim-construction reference | reference |
| `sector_segment.scad` | printed channel segments: flat inside (clip over one rim facet, two M4s), true cable arc with groove walls outside; print 7 plain + 2 end variants with integral cable anchors | print |

Gear width follows the one-tooth phase rule (`gear_phase_width`): each
herringbone half advances exactly one tooth of helix phase from center to
edge (~27 mm at m2 / 25°), so systematic tooth errors average out at every
rotation angle — and the extra width adds strength.

## Testbench

The pendulum test stand originally designed here was superseded before
it was built: the drivetrain is now proven on the **real base + upper
arm** (`arm/testbench.scad`), with the sector fixed to the left base
board (the prototype1 capstan inverted) and the drive riding the arm —
the test article IS the final hardware, and graduating the rig means
installing the parts it deliberately leaves off, without disassembling
anything that was tested.

- The two-ply slew disc lies flat on the desk, clamped dead (generic
  hold-down bars in the model). Gear segments, rim rollers, hold-downs,
  the central 608 housing, and the yaw motor are simply not installed
  yet.
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

Cable (~2 m of 1.5 mm Dyneema): anchor at the drum's radial hole (knot
behind), ~14 resident wraps on the 24 mm drum, both ends terminating in
the printed END segments of the channel — the cable passes through the
2.2 mm hole in the anchor wall and knots in the cavity behind it, in line
with the groove. Tension by rotating the drum before dropping the pinion
into mesh; engagement locks it, and one tooth of re-meshing ≈ 0.8 mm of
cable. If that proves too coarse, a screw tensioner can be built into an
end segment (it's a 20-minute reprint).

## Rendering

With OpenSCAD on the path (or the full path to `openscad.exe`):

In `prototype1/`:

```sh
openscad -o build/pinion.stl pinion.scad
openscad -o build/gear_drum.stl gear_drum.scad
openscad -o build/motor_mount.stl motor_mount.scad
openscad -o build/bridge.stl bridge.scad
openscad -o build/sector_segment.stl  sector_segment.scad   # 7 + 2 ends
```

In `arm/`:

```sh
openscad -o build/arm.png       --viewall --autocenter assembly.scad
openscad -o build/testbench.png --viewall --autocenter testbench.scad
openscad -o build/testbench_up.png -D pose_shoulder=100 --viewall --autocenter testbench.scad
```

`build/` is git-ignored; regenerate outputs from source.

## Print notes

- Gears print teeth-up as modeled; the herringbone V needs no supports.
  PETG or PLA+.
- The motor plate prints flat; the bridge prints lying on its outboard
  back (the 45° flare under the beam makes it support-free).
- `gear_backlash = 0` deliberately: no backlash is cut into the teeth —
  set the mesh snug by pressing the gears together before tightening the
  motor plate.
- `drum_len` is computed from the wrap math (full-travel turns + dead
  wraps; ~24 mm at the current ratios) — if the ratios change, the drum,
  sector, and board geometry all follow, so regenerate every output.
