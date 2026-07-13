# big_arm

A large, inexpensive, slow-but-accurate robot arm.

The thesis: hobbyist robot arms today cluster around **~2 ft reach, ~2 lb payload,
~$2,000**. By trading away speed — and only speed — we aim to beat that on every
other axis: longer reach, higher payload, much lower cost, built from plywood and
NEMA 17 stepper motors, with closed-loop optical feedback making up for the
compliance of a lightweight structure.

## Documents

| Doc | Contents |
|-----|----------|
| [docs/vision.md](docs/vision.md) | The design thesis and its four pillars |
| [docs/requirements.md](docs/requirements.md) | Draft requirements (unknowns marked TBD) |
| [docs/sensing.md](docs/sensing.md) | Sensing concept: unloaded-reference optical metrology |
| [docs/tooling.md](docs/tooling.md) | Modeling & CAD tooling: TS/three.js engineering model, OpenSCAD, Python analysis |
| [docs/roadmap.md](docs/roadmap.md) | Phased plan from concept convergence to working demos |
| [docs/reduction-trade.md](docs/reduction-trade.md) | Phase 1a: reduction mechanism trade study and measurement plan |
| [docs/open-questions.md](docs/open-questions.md) | Decisions and details still to be resolved |

## Engineering model

[`model/`](model/) holds the interactive concept model (TypeScript +
three.js, fully client-side — see [docs/tooling.md](docs/tooling.md)):
counterweight sizing, joint torques and margins, and traverse times,
computed live over a crude 3D view with sliders. A second page, the
**CAD twin** (`twin.html`), renders the actual OpenSCAD assembly —
rigid-body meshes exported from [`cad/arm/`](cad/) — posed live by the
four joint angles.

Both pages are live:

- [Concept calculator](https://vector76.github.io/big_arm/index.html) —
  the parametric design model
- [CAD twin](https://vector76.github.io/big_arm/twin.html) — the
  OpenSCAD assembly, posable

```sh
cd model
npm install
npm run export:cad  # render cad/arm/ into the twin's meshes (needs OpenSCAD)
npm run dev    # interactive, http://localhost:5173
npm test       # model-core unit tests
npm run build  # static site in model/dist/
```

The twin's meshes render at **twin fidelity** (`$twin` in
[`cad/arm/params.scad`](cad/arm/params.scad)): features that exist to make a
part *work* rather than to be *seen* — the drums' helical cable groove, the
gears' involute flanks — get coarse tessellation, because on screen they are
worth a few pixels and cost six figures of triangles. Print and cut exports
never go through `export.scad`, so they keep full manufacturing fidelity.

`export:cad` reports each body's triangle count against a budget and fails if
one is blown, so a CAD edit can't quietly make the twin unrenderable. The
viewer has a matching **mesh-stats HUD** (the pose panel's *mesh stats*
switch, or `?stats=1`): triangles per rigid body, then per part — click one to
isolate it in the scene, or focus the camera on it.

```sh
npm run export:cad:full  # same assembly at FULL print fidelity, for comparison
```

That render deliberately overruns the budget and the viewer labels it; it is a
measurement, not something to deploy. Today: 447k triangles at full fidelity
vs 99k at twin fidelity, for no visible difference.

## Status

Concept stage (July 2026). Documents are drafts; the engineering model is
scaffolded and working; no hardware is built yet.
