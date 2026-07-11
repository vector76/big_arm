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
  pinion, elbow + wrist = worms inside the truss hollows. For iterating
  the big-picture structure before detailed design; see the header of
  `arm/assembly.scad` for the architecture notes and `arm/params.scad`
  for poses.
- `prototype1/` — Phase 1a shoulder drivetrain prototype: herringbone
  primary (12T/51T, module 2, 4.25:1; wheel tips stubbed to 0.65 addendum
  so they clear the small pinion's base circle at 20° PA) + capstan cable
  sector (Ø12 mm drum core, 238 mm effective sector radius, ~35:1) =
  150:1 total, mounted on a complete pendulum test stand (below).

## prototype1 parts

| File | Part | Make |
|------|------|------|
| `pinion.scad` | 12T herringbone, press-on 5 mm D-bore (proven grub-free fit: Ø5.1 with flat at nominal 2.0 mm) | print |
| `gear_drum.scad` | 51T stub-addendum herringbone with integrated cable drum (length from the wrap math); two 608 bearings press in, spins on a fixed M8 dead axle | print |
| `motor_mount.scad` | rigid slotted plate; the motor plunges through the board and hangs from it; mesh set by press-and-clamp | print |
| `bridge.scad` | spans the gear+drum tangent to the arc; picks up the axle top so the drum axle is simply supported | print |
| `sector.scad` | sector core: a SINGLE 12 mm ply plate with a polygonal rim; pivot bore fits the hub tube | CNC |
| `sector_segment.scad` | printed channel segments: flat inside (clip over one rim facet, two M4s), true cable arc with groove walls outside; print 7 plain + 2 end variants with integral cable anchors | print |
| `hub_tube.scad` | sector pivot bearing tube: two 608s at its ends, slides through the sector stack | print |
| `arm.scad` | 0.48 m pendulum arm, bolts across the sector hub; weight holes every 50 mm out to 450 mm | CNC |
| `baseplate.scad` | vertical rig board (`layer=1`), bench base (`layer=2`), gusset ×2 (`layer=3`), pivot bridge beam (`layer=4`), tab-and-slot | CNC |
| `spacers.scad` | axle standoffs, inner-race spacers, top washer, stop/post sleeves, pivot pilot bushing — one print plate | print |
| `assembly.scad` | full test-stand sanity model; `-D pose=<deg>` sets the arm angle | — |

Gear width follows the one-tooth phase rule (`gear_phase_width`): each
herringbone half advances exactly one tooth of helix phase from center to
edge (~27 mm at m2 / 25°), so systematic tooth errors average out at every
rotation angle — and the extra width adds strength.

## Test stand

A vertical 12 mm ply board stands at the bench edge (horizontal base + two
gussets clamp flat to the bench). The motor plunges through a cutout in
the board — radially outboard of the drum, opposite the sector arc — and
hangs from a rigid slotted plate at its face, which puts the gear plane
~10 mm off the board and keeps the axle cantilever moments small; the
motor body sticks ~35 mm out the back. Mesh is set by sliding the plate
along its slots, pressing the gears together, and tightening (no preload
flexure on the test rig). The drum axle is simply supported: a printed
bridge spans the gear+drum tangent to the arc, its legs offset 15 mm
outboard so the cable runs pass clear, and the axle nyloc on the beam
clamps the whole stack into one rigid column; the arm swings ~7 mm under
the beam. The sector pivots on two 608s in the printed hub tube — a plain
ply-on-bolt pivot would put friction directly inside the efficiency
measurement — and the arm bolts across the sector hub on the six M4×50
hub bolts, at the real 0.45 m upper-arm scale.

The pivot axle gets a bridge too — high loads and lateral force would
otherwise tilt a cantilevered joint. The two travel-stop posts sit at
angles the arm and spoke can never sweep, so their sleeves simply extend
up to +30 and a CNC ply boomerang beam spans their tops and the pivot,
passing over the swinging arm (2 mm above its bolt heads). A printed
pilot bushing drops from the beam through the arm's center hole onto the
outboard 608's inner race, so the axle nyloc on the beam gives the same
light axial preload as the drum bridge.

Weights hang in the arm holes: **τ = m·g·r·sin(θ)**, θ measured from
straight-down. Travel is **−25°…+95°**, deliberately asymmetric so the
horizontal pose (sin θ = 1) is covered: **6.05 kg at the 450 mm hole gives
26.7 N·m**, the worst-case shoulder torque. One hung mass sweeps torque
from −42 % to +100 % of max across travel, and the zero crossing at θ = 0
exposes backlash as the load transfers between gear flanks. Weigh the arm
and include its own first moment in the torque math. The whole mechanism
is tilted `travel_mid` = 35° on the board so this travel fits the sector's
130° arc with 5° margin per end; two M8 posts with printed sleeves catch
the sector spoke just past nominal travel.

All four long bolts are M8×120 (sector, drum, two stop posts — or rod),
each a preloaded stack: fender washer behind the board → board → printed
standoff or sleeve → bearings/part with inner-race spacer (race-tip steps
and pilots bear only on inner races) → bridge or beam → nyloc. Torqued
up, each stack acts as one rigid, lightly axially-preloaded column;
everything rotating spins clear of the bridges' underside pockets.

Cable (~2 m of 1.5 mm Dyneema): anchor at the drum's radial hole (knot
behind), ~14 resident wraps on the 24 mm drum, both ends terminating in
the printed END segments of the channel — the cable passes through the
2.2 mm hole in the anchor wall and knots in the cavity behind it, in line
with the groove. Tension by rotating the drum before dropping the pinion
into mesh; engagement locks it, and one tooth of re-meshing ≈ 0.8 mm of
cable. If that proves too coarse, a screw tensioner can be built into an
end segment (it's a 20-minute reprint).

Bench notes: the arm rides ~75 mm proud of the board, so the bench face
below the clamp line must be clear; at −25° the weights hang ~340 mm below
bench level. Clamp the base firmly — a horizontal arm puts ~27 N·m of roll
on it.

Hardware: 4× 608 bearings, 4× M8×120 + nuts/washers, 6× M4×35 (arm/hub),
18× M4×20 + nuts (channel segments), misc M4×20–25 + nuts (standoff feet,
motor plate, bridge feet), 4× M3×8 (motor), Dyneema.

## Rendering

With OpenSCAD on the path (or the full path to `openscad.exe`):

```sh
openscad -o build/pinion.stl pinion.scad
openscad -o build/gear_drum.stl gear_drum.scad
openscad -o build/hub_tube.stl hub_tube.scad
openscad -o build/motor_mount.stl motor_mount.scad
openscad -o build/bridge.stl bridge.scad
openscad -o build/spacers.stl spacers.scad
openscad -o build/sector_core.dxf     -D layer=1 sector.scad
openscad -o build/sector_segment.stl  sector_segment.scad   # 7 + 2 ends
openscad -o build/arm.dxf             -D layer=1 arm.scad
openscad -o build/rig_board.dxf     -D layer=1 baseplate.scad
openscad -o build/rig_base.dxf      -D layer=2 baseplate.scad
openscad -o build/rig_gusset.dxf    -D layer=3 baseplate.scad   # cut 2
openscad -o build/rig_pivot_beam.dxf -D layer=4 baseplate.scad
openscad -o build/rig.png --viewall --autocenter assembly.scad
openscad -o build/rig_horiz.png -D pose=90 --viewall --autocenter assembly.scad
```

`build/` is git-ignored; regenerate outputs from source.

## Print notes

- Gears print teeth-up as modeled; the herringbone V needs no supports.
  PETG or PLA+.
- Standoffs print flange-down; hub tube and sleeves print tube-vertical;
  the motor plate prints flat; the bridge prints lying on its outboard
  back (the 45° flare under the beam makes it support-free).
- `gear_backlash = 0` deliberately: no backlash is cut into the teeth —
  set the mesh snug by pressing the gears together before tightening the
  motor plate.
- `drum_len` is computed from the wrap math (full-travel turns + dead
  wraps; ~24 mm at the current ratios) — if the ratios change, the drum,
  sector, and board geometry all follow, so regenerate every output.
