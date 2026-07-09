import { computeCounterweights, Counterweights, totalArmMass } from './balance';
import { jointHoldingCapacity, jointTorqueCapacity } from './motor';
import { DesignParams, PITCH_JOINTS, PitchJoint, Pose } from './params';
import { gravityTorques } from './statics';
import { traverseTimes, TraverseResult } from './motion';
import { worstCaseTorques, WorstCase } from './sweep';

export interface JointReport {
  torqueHere: number;      // N*m at the current pose (holding, with payload)
  worstTorque: number;     // N*m over the pose sweep
  staticCapacity: number;  // N*m while stepping slowly (pull-out based)
  holdingCapacity: number; // N*m stationary (holding-torque based)
  margin: number;          // staticCapacity / |worstTorque| — moving margin
}

export interface Summary {
  counterweights: Counterweights;
  totalArmMass: number;
  reach: number;
  joints: Record<PitchJoint, JointReport>;
  residualImbalance: Record<PitchJoint, number>; // N*m at current pose, payload & EE removed
  traverseUnloaded: TraverseResult;
  traverseLoaded: TraverseResult;
  worstCase: WorstCase;
}

export function summarize(p: DesignParams, pose: Pose): Summary {
  const cw = computeCounterweights(p);
  const here = gravityTorques(p, cw, pose);
  const worstCase = worstCaseTorques(p, cw);
  const bare: DesignParams = { ...p, payloadMass: 0, endEffectorMass: 0 };
  const residual = gravityTorques(bare, computeCounterweights(bare), pose);

  const joints = {} as Record<PitchJoint, JointReport>;
  for (const j of PITCH_JOINTS) {
    const staticCapacity = jointTorqueCapacity(p[j], p.motor, 0);
    const worstTorque = worstCase.torque[j];
    joints[j] = {
      torqueHere: here[j],
      worstTorque,
      staticCapacity,
      holdingCapacity: jointHoldingCapacity(p[j], p.motor),
      margin: worstTorque === 0 ? Infinity : staticCapacity / Math.abs(worstTorque),
    };
  }

  return {
    counterweights: cw,
    totalArmMass: totalArmMass(p, cw),
    reach: p.upperArm.length + p.forearm.length + p.wristLink.length,
    joints,
    residualImbalance: residual,
    traverseUnloaded: traverseTimes(p, cw, false),
    traverseLoaded: traverseTimes(p, cw, true),
    worstCase,
  };
}
