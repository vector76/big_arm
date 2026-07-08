# Open questions

Grouped by topic; the ⭐ items block the most downstream work and should be
answered first. Answers get folded into [requirements.md](requirements.md) and
new design docs as they arrive.

## Resolved (2026-07-08)

- **Target reach:** ~3 ft (0.9 m).
- **Cost target:** ~$500, excluding tools already owned.
- **Use:** general experimentation platform first; must also do pick-and-place
  and drawing/plotting well.
- **Counterbalance approach:** counterweights + transfer linkage
  (parallelogram/four-bar), not springs.

## Mission & sizing

4. **Payload rating convention** — is 5 lb required at full extension, or at
   some rated radius?
5. **Speed floor** — how slow is too slow? A concrete number like "full
   workspace traverse in ≤ 30 s" would let gearing be chosen instead of guessed.
6. **Mounting** — bench, floor pedestal, wall? Does the base yaw need
   continuous rotation (slip ring / cable management question) or is ±180°
   enough?

## Counterbalance design

Direction chosen: **counterweights + transfer linkage** (see Resolved above).
Remaining details:

7. **Linkage topology.** Counterweights on a serial 3-pitch-joint chain are
   only pose-independent if each distal link's balance is preserved as
   proximal joints move. Where do the masses live — on each link directly, or
   transferred back toward the base via parallelogram/four-bar links (less
   distal inertia, more linkage)? At 3 ft reach both are viable; needs a mass
   budget comparison.
8. **How exact does "neutral" need to be?** Steppers have holding torque to
   spare at high reduction; if 90% balance is enough, the mechanism gets much
   simpler.
9. **Does the counterbalance need to adapt to end-effector swaps?** Different
   tools shift the balanced mass.

## Optical feedback

10. ⭐ **What are the candidate optical feedback concepts?** These exist but
    are undocumented. Getting them written down (even roughly) is the next
    docs task. Key architectural fork they must answer:
11. **Joint sensing vs. endpoint sensing?** Measuring true joint angles
    (after the gearbox, after mount flex) corrects transmission error but not
    link bending. Measuring the tool tip directly (e.g., camera + fiducials,
    laser + target) corrects everything but is harder to make work across the
    whole workspace. Hybrid schemes are possible.
12. **Required feedback resolution and rate?** Follows from the repeatability
    target (set by the pick-and-place and plotting use cases) and speed (Q5).
    Slow motion means even ~10 Hz correction may be plenty.

## Actuation & transmission

13. **Reduction mechanism preference?** Belts (cheap, low backlash, limited
    ratio per stage), worm (huge ratio, self-locking, friction), cycloidal
    (printable, compact, high ratio), cable/capstan (zero backlash, very cheap,
    plywood-friendly). Backlash matters less than usual thanks to closed-loop
    feedback — friction and cost may dominate the choice.
14. **Closed-loop stepper drivers (e.g., with magnetic encoders) or open-loop
    steppers with the optical system as the only feedback?**

## Fabrication & electronics

15. **What fabrication tools are available?** CNC router, laser cutter, hand
    tools only? Sheet size limits? This constrains truss joint design (tab-and-
    slot vs. glued gussets) and part sizes.
16. **Plywood stock** — thickness and grade assumptions (e.g., 1/2" Baltic
    birch vs. hardware-store sanded ply) change strength numbers ~2×.
17. **Controller preference?** Options range from a 3D-printer-class board
    running Klipper/Marlin-style firmware, to an MCU + host-PC split, to
    everything-on-a-Pi. The optical feedback path probably wants a real
    computer in the loop.
18. **Any parts already on hand** (motors, drivers, rails, cameras) that the
    design should build around?

## Scope & sequencing

19. **First milestone?** Candidates: (a) torque/counterbalance math worksheet,
    (b) single-joint testbed (one plywood link + counterweight + NEMA 17 +
    optical feedback) to retire the riskiest assumptions, (c) full-arm CAD.
    A single-joint testbed retires pillars 2–4 cheaply before committing to
    geometry.
