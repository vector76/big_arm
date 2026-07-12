import { Frames, TwinPose } from '../view/twinScene';

// Closed-form inverse kinematics for the twin's drag handle. The arm
// is a yaw about Z plus three parallel pitch joints, so IK decomposes
// exactly: yaw = the target's azimuth (the arm reaches radially), and
// shoulder/elbow are the planar two-link solution in the yawed
// vertical plane. The end effector HOLDS a caller-chosen pitch vs
// horizontal (captured when the drag starts): the wrist target is the
// tip minus the fixed ee_len vector at that pitch, and the wrist angle
// re-closes the pitch after the shoulder/elbow solve — so the held
// pitch survives even when a position clamp engages, until the wrist
// itself runs out of travel.
//
// The elbow bends DOWN only (0..elbow_travel), which picks the unique
// elbow-up branch of the two-link solution: shoulder = chord angle +
// atan2(L2 sin e, L1 + L2 cos e). Every joint clamps to its travel —
// the tip simply stops following the mouse at the envelope edge.
//
// prevYaw keeps yaw CONTINUOUS: at shoulder poses past vertical the
// tip can sit BEHIND the yaw axis, where its azimuth reads 180 off
// the arm's actual heading — so the target is solved in whichever of
// the two (azimuth, +r) / (azimuth - 180, -r) planes lies nearer the
// current yaw, instead of spinning the slew half a turn.
export function solveIk(
  tip: { x: number; y: number; z: number }, // CAD frame, mm, Z-up
  eePitch: number,                          // deg above horizontal, held
  frames: Frames,
  prevYaw = 0,
): TwinPose {
  const d2r = Math.PI / 180;
  const l1 = frames.upper_len;
  const l2 = frames.fore_len;

  const az = Math.atan2(tip.y, tip.x) / d2r;
  const flip = Math.abs(norm180(az - prevYaw)) > 90;
  const rho = (flip ? -1 : 1) * Math.hypot(tip.x, tip.y);
  const yaw = clamp(
    flip ? norm180(az - 180) : az,
    -frames.yaw_travel / 2,
    frames.yaw_travel / 2,
  );

  // wrist target in the yawed (r, z) plane, shoulder pivot at origin
  const wr = rho - frames.ee_len * Math.cos(eePitch * d2r);
  const wz =
    tip.z - frames.shoulder_h - frames.ee_len * Math.sin(eePitch * d2r);

  // two-link planar solve; cos clamp = reach clamp (D too long or short)
  const d2 = wr * wr + wz * wz;
  const ce = clamp((d2 - l1 * l1 - l2 * l2) / (2 * l1 * l2), -1, 1);
  const elbow = clamp(Math.acos(ce) / d2r, 0, frames.elbow_travel);
  const er = elbow * d2r;
  const shoulder = clamp(
    (Math.atan2(wz, wr) + Math.atan2(l2 * Math.sin(er), l1 + l2 * Math.cos(er))) / d2r,
    frames.shoulder_min,
    frames.shoulder_max,
  );
  const wrist = clamp(
    eePitch - shoulder + elbow,
    -frames.wrist_travel / 2,
    frames.wrist_travel / 2,
  );

  const r1 = (v: number) => Math.round(v * 10) / 10;
  return { yaw: r1(yaw), shoulder: r1(shoulder), elbow: r1(elbow), wrist: r1(wrist) };
}

function clamp(v: number, lo: number, hi: number): number {
  return Math.min(hi, Math.max(lo, v));
}

function norm180(a: number): number {
  return ((((a + 180) % 360) + 360) % 360) - 180;
}
