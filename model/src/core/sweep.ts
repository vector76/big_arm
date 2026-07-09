import { Counterweights } from './balance';
import { DesignParams, PITCH_JOINTS, PitchJoint, POSE_RANGES, Pose } from './params';
import { gravityTorques } from './statics';

export interface WorstCase {
  torque: Record<PitchJoint, number>; // N*m, max |holding torque| over the sweep
  pose: Record<PitchJoint, Pose>;     // pose where each joint's worst case occurs
}

// Grid-sweep the pitch pose space for the worst-case holding torque at each
// joint (yaw sees no gravity torque).
export function worstCaseTorques(
  p: DesignParams,
  cw: Counterweights,
  steps = 13,
): WorstCase {
  const lin = (range: [number, number], i: number) =>
    range[0] + ((range[1] - range[0]) * i) / (steps - 1);

  const torque: Record<PitchJoint, number> = { shoulder: 0, elbow: 0, wrist: 0 };
  const base: Pose = { yaw: 0, shoulder: 0, elbow: 0, wrist: 0 };
  const pose: Record<PitchJoint, Pose> = { shoulder: base, elbow: base, wrist: base };

  for (let i = 0; i < steps; i++) {
    for (let j = 0; j < steps; j++) {
      for (let k = 0; k < steps; k++) {
        const q: Pose = {
          yaw: 0,
          shoulder: lin(POSE_RANGES.shoulder, i),
          elbow: lin(POSE_RANGES.elbow, j),
          wrist: lin(POSE_RANGES.wrist, k),
        };
        const t = gravityTorques(p, cw, q);
        for (const joint of PITCH_JOINTS) {
          if (Math.abs(t[joint]) > Math.abs(torque[joint])) {
            torque[joint] = t[joint];
            pose[joint] = q;
          }
        }
      }
    }
  }
  return { torque, pose };
}
