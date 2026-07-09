# Tooling

Decided 2026-07-08. Constraints: no paid software; must be collaboration-
friendly for both a human (OpenSCAD daily driver) and an AI assistant
(text-based, scriptable, headless-renderable tools).

## The three tools and their jobs

| Tool | Job | Phase |
|------|-----|-------|
| **TypeScript + three.js engineering model** | Converge on the concept: masses, counterweights, torques, gear ratios, traverse times — with a deliberately crude 3D visualization | Trade study / spitballing |
| **OpenSCAD** | Geometry source of truth: the parts that actually get CNC-cut and printed | Detailed design |
| **Python scripts** | Offline analysis over measured data (calibration fitting, load-deflection tests) | Build & calibration |

## The engineering model (`model/`)

Not CAD — a calculator with a 3D view attached.

**Architecture: fully client-side, no server.** All computations (static
torques, counterweight sizing, motor margin, traverse time) are closed-form
arithmetic; nothing needs numpy or a backend. A FastAPI/client split was
considered and rejected: it adds a process to run and two languages to keep
in sync while earning nothing computationally. Static files mean the tool
can be hosted on GitHub Pages straight from this repo and works forever with
zero setup.

Structure:

- **Model core** — a pure-function TypeScript module: design parameters in
  (link lengths, stub lengths, densities, payload, gear ratios, motor
  torque curve) → derived quantities out (counterweight masses, CoMs, joint
  torque vs. pose, margin vs. motor capability, traverse time). No three.js
  imports allowed here; unit-tested independently.
- **View** — three.js boxes/cylinders posed by the kinematics, counterweight
  blobs sized by computed mass, joints color-coded by torque margin, slider
  panel, numeric readout table, worst-case pose sweep mode.
- **State sharing** — parameter sets serialize into the URL; a configuration
  is just a link. No persistence layer.
- **Build** — Vite; TypeScript strict.

## OpenSCAD

Chosen because it is ideal for *both* collaborators: the user's preferred
CAD, and for the assistant it is plain text (writable, git-diffable) and
renders headlessly from the CLI to PNG/STL for self-checking. Takes over
once the concept model's numbers settle.

## Held in reserve / rejected

- **FreeCAD** — scriptable via Python and viable, but GUI-centric; reserved
  for needs OpenSCAD can't meet (STEP export, FEM).
- **OnShape** — web-based, impractical for the assistant; free tier would
  require open-sourcing the design (acceptable, but moot). Third choice.
- **SolidWorks / Fusion** — paid; out.
