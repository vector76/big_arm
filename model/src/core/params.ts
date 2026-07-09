export const G = 9.80665;

export interface LinkParams {
  length: number;        // m
  linearDensity: number; // kg/m of structure
}

export interface JointDrive {
  ratio: number;      // reduction, joint torque = motor torque * ratio * efficiency
  efficiency: number; // 0..1
  travel: number;     // rad, total range of motion
}

export interface MotorParams {
  holdingTorque: number; // N*m, stationary and energized
  pullOutTorque: number; // N*m, plateau while stepping (below holding)
  cornerSpeed: number;   // rev/s, end of the flat plateau
  maxSpeed: number;      // rev/s, end of the datasheet curve
  torqueAtMax: number;   // N*m at maxSpeed; linear decline corner -> max
}

export interface DesignParams {
  upperArm: LinkParams;
  forearm: LinkParams;
  wristLink: LinkParams;
  shoulderStubFraction: number; // stub length as fraction of upper arm length
  elbowStubFraction: number;    // stub length as fraction of forearm length
  stubLinearDensity: number;    // kg/m
  elbowHardwareMass: number;    // kg, at elbow axis
  wristHardwareMass: number;    // kg, at wrist axis
  endEffectorMass: number;      // kg, at wrist link tip
  payloadMass: number;          // kg, at wrist link tip
  counterweightMargin: number;  // 1 = exact balance, <1 under-balanced
  columnHeight: number;         // m, shoulder axis above bench
  yaw: JointDrive;
  shoulder: JointDrive;
  elbow: JointDrive;
  wrist: JointDrive;
  motor: MotorParams;
}

export interface Pose {
  yaw: number;      // rad
  shoulder: number; // rad, absolute from horizontal
  elbow: number;    // rad, relative to upper arm
  wrist: number;    // rad, relative to forearm
}

export const PITCH_JOINTS = ['shoulder', 'elbow', 'wrist'] as const;
export type PitchJoint = (typeof PITCH_JOINTS)[number];
export type JointName = 'yaw' | PitchJoint;

const deg = (d: number) => (d * Math.PI) / 180;

export const defaultParams: DesignParams = {
  upperArm: { length: 0.45, linearDensity: 1.2 },
  forearm: { length: 0.35, linearDensity: 0.9 },
  wristLink: { length: 0.1, linearDensity: 0.6 },
  shoulderStubFraction: 0.5,
  elbowStubFraction: 0.5,
  stubLinearDensity: 1.0,
  elbowHardwareMass: 0.8,
  wristHardwareMass: 0.5,
  endEffectorMass: 0.7,
  payloadMass: 2.27, // 5 lb
  counterweightMargin: 1.0,
  columnHeight: 0.4,
  yaw: { ratio: 60, efficiency: 0.8, travel: deg(180) },
  shoulder: { ratio: 150, efficiency: 0.7, travel: deg(120) },
  elbow: { ratio: 120, efficiency: 0.7, travel: deg(135) },
  wrist: { ratio: 60, efficiency: 0.7, travel: deg(180) },
  // StepperOnline 17HS19-2004S1 datasheet curve at 24 V, 2.2 A: pull-out
  // ~41 N*cm flat to ~450 rpm, then roughly linear to ~17 N*cm at 1200 rpm.
  // https://www.omc-stepperonline.com/nema-17-bipolar-59ncm-84oz-in-2a-42x48mm-4-wires-w-1m-cable-connector-17hs19-2004s1
  motor: {
    holdingTorque: 0.59,
    pullOutTorque: 0.41,
    cornerSpeed: 450 / 60,
    maxSpeed: 1200 / 60,
    torqueAtMax: 0.17,
  },
};

export const defaultPose: Pose = {
  yaw: 0,
  shoulder: deg(20),
  elbow: deg(-40),
  wrist: deg(20),
};

// Pose ranges used for worst-case sweeps. The elbow only bends downward;
// the wide-travel wrist recovers reachability (decision 2026-07-08).
export const POSE_RANGES: Record<PitchJoint, [number, number]> = {
  shoulder: [deg(-30), deg(90)],
  elbow: [deg(-135), deg(0)],
  wrist: [deg(-90), deg(90)],
};
