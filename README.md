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
| [docs/open-questions.md](docs/open-questions.md) | Decisions and details still to be resolved |

## Engineering model

[`model/`](model/) holds the interactive concept model (TypeScript +
three.js, fully client-side — see [docs/tooling.md](docs/tooling.md)):
counterweight sizing, joint torques and margins, and traverse times,
computed live over a crude 3D view with sliders.

```sh
cd model
npm install
npm run dev    # interactive, http://localhost:5173
npm test       # model-core unit tests
npm run build  # static site in model/dist/
```

## Status

Concept stage (July 2026). Documents are drafts; the engineering model is
scaffolded and working; no hardware is built yet.
