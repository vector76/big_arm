# Vision

## The problem with the status quo

Robot arms are expensive because they are designed to be **stiff, strong, and
fast simultaneously**. Industrial arms achieve accuracy through massive rigid
structures and precision gearboxes, then run open loop (or joint-encoder-only),
trusting the structure to put the tool where the math says it is. That approach
scales cost brutally with size: doubling reach roughly quadruples the required
stiffness-to-weight budget, and the motors must carry the arm's own weight at
every moment.

Even "hobbyist" arms inherit this design philosophy in miniature. The typical
offering is around **2 ft of reach, 2 lb of payload, and a $2,000 price tag** —
small, and not cheap.

## The thesis

Give up speed. Keep everything else. Specifically:

> A deliberately slow arm can be **large, strong, accurate, and cheap** at the
> same time, because slowness dissolves the very problems that make big arms
> expensive.

Slowness pays for itself three times over:

1. **Motor torque.** Slow motion means gearing can be aggressive. A geared-down
   NEMA 17 stepper is surprisingly strong — strong enough to move a multi-pound
   payload if it never has to fight gravity on the arm's own mass.
2. **Structure.** Quasi-static motion means no vibration, no dynamic loads, no
   resonance management. The structure only has to be strong, not
   dynamically stiff — and strong is cheap.
3. **Control.** Compliance control of a flexible structure is hard *when the
   system is dynamic*. In the quasi-static regime, deflection under load is
   just a slowly-varying position error — exactly what closed-loop feedback
   handles well.

## The four pillars

### 1. Plywood box-truss structure

Arm links are built as cut-out plywood box/truss sections. Plywood is cheap,
widely available, easily CNC-cut or hand-cut, and a well-designed box truss
gives excellent strength per dollar. The structure does not need to be
perfectly rigid (see pillar 4) — it needs to be strong and *predictably*
compliant.

### 2. Full gravity counterbalance

The arm is counterweighted such that it is **weight-neutral in every pose**:
no matter the joint configuration, gravity exerts (approximately) zero net
torque on any joint from the arm's own mass. Consequences:

- Motors size to **payload + friction + (small) acceleration loads** only,
  never to the arm's own weight.
- Power-off is safe: the arm stays where it is instead of collapsing.
- Holding torque demands drop dramatically — a big deal for steppers, whose
  torque budget is otherwise consumed just holding position.

The counterbalance mechanism itself (weights vs. springs, and the linkage
needed to keep balance valid across elbow motion) is an open design problem —
see [open-questions.md](open-questions.md).

### 3. High reduction, cheap motors

NEMA 17 stepper motors driving high-ratio reductions. Target payload on the
order of **5 lb** — more than most small hobbyist arms — at speeds that are
admittedly modest. Steppers are cheap, simple to drive, and their main
weakness (torque falls off a cliff at speed) is irrelevant to a slow arm.

### 4. Closed-loop optical position feedback

Traditional arms are stiff so they can run open loop. This arm inverts that:
it accepts structural compliance and **actively measures the true position**
optically, closing the loop on where the arm actually is rather than where
the motors think it is. Deflection under payload, gear backlash, and truss
flex all become correctable disturbances instead of accuracy losses.

Because motion is slow, the feedback loop operates in a quasi-static regime:
no need to model or damp structural dynamics, just servo out the
slowly-varying error.

Sensing is **layered and redundant**: joint angles, link bending, and an
approximate end-effector position measurement (e.g., a camera watching the
tool). Any one layer has blind spots — joint sensing misses link flex,
endpoint sensing alone is coarse — but together they over-determine the arm's
state, and that redundancy lets the system *self-calibrate* its internal
model of motion and deflection. (Specific optical sensing concepts are to be
documented — see open questions.)

## Kinematic layout

The base arm has **4 degrees of freedom**:

| # | Joint | Axis |
|---|-------|------|
| 1 | Base yaw | Vertical (azimuth rotation of the whole arm) |
| 2 | Shoulder pitch | Horizontal |
| 3 | Elbow pitch | Parallel to shoulder axis |
| 4 | Wrist pitch | Parallel to shoulder and elbow axes |

All three pitch axes are parallel, so joints 2–4 move the arm in a vertical
plane that joint 1 rotates about the base. This is a classic articulated
layout, and the parallel-axis chain is what makes a clean gravity
counterbalance tractable.

The **end effector is a separate module** with its own 2–3 degrees of freedom
(e.g., wrist roll/twist, and gripper open–close). Wrist rotation is
explicitly *not* part of the base arm — anything beyond the wrist pitch joint
belongs to the end-effector subsystem.

## What success looks like

An arm that is, relative to the ~$2k / 2 ft / 2 lb hobbyist baseline:

- **Larger** — reach beyond the hobbyist class (target TBD),
- **Stronger** — ~5 lb payload,
- **Cheaper** — cost target TBD, but decisively below $2k,
- **Accurate** — closed-loop optical feedback delivering repeatability
  competitive with much stiffer arms,
- and unapologetically **slower** than all of them.
