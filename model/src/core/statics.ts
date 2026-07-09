import { Counterweights } from './balance';
import { DesignParams, G, PitchJoint, Pose } from './params';

// All statics are computed in the arm's vertical plane: r = radial distance
// from the shoulder axis, z = height. Yaw rotates the plane but does not
// change gravity torques.
export interface PlanarPoint {
  r: number;
  z: number;
}

export interface MassPoint {
  name: string;
  mass: number;
  pos: PlanarPoint;
  distalOf: PitchJoint[];
}

export interface ArmGeometry {
  joints: Record<PitchJoint, PlanarPoint>;
  tip: PlanarPoint;
  masses: MassPoint[];
}

export function armGeometry(p: DesignParams, cw: Counterweights, pose: Pose): ArmGeometry {
  const a2 = pose.shoulder;
  const a3 = a2 + pose.elbow;
  const a4 = a3 + pose.wrist;
  const along = (from: PlanarPoint, angle: number, dist: number): PlanarPoint => ({
    r: from.r + Math.cos(angle) * dist,
    z: from.z + Math.sin(angle) * dist,
  });

  const shoulder: PlanarPoint = { r: 0, z: 0 };
  const elbow = along(shoulder, a2, p.upperArm.length);
  const wrist = along(elbow, a3, p.forearm.length);
  const tip = along(wrist, a4, p.wristLink.length);

  const masses: MassPoint[] = [
    {
      name: 'shoulder counterweight',
      mass: cw.shoulderMass,
      pos: along(shoulder, a2, -cw.shoulderStubLength),
      distalOf: ['shoulder'],
    },
    {
      name: 'shoulder stub',
      mass: p.stubLinearDensity * cw.shoulderStubLength,
      pos: along(shoulder, a2, -cw.shoulderStubLength / 2),
      distalOf: ['shoulder'],
    },
    {
      name: 'upper arm',
      mass: p.upperArm.linearDensity * p.upperArm.length,
      pos: along(shoulder, a2, p.upperArm.length / 2),
      distalOf: ['shoulder'],
    },
    {
      name: 'elbow hardware',
      mass: p.elbowHardwareMass,
      pos: elbow,
      distalOf: ['shoulder'],
    },
    {
      name: 'elbow counterweight',
      mass: cw.elbowMass,
      pos: along(elbow, a3, -cw.elbowStubLength),
      distalOf: ['shoulder', 'elbow'],
    },
    {
      name: 'elbow stub',
      mass: p.stubLinearDensity * cw.elbowStubLength,
      pos: along(elbow, a3, -cw.elbowStubLength / 2),
      distalOf: ['shoulder', 'elbow'],
    },
    {
      name: 'forearm',
      mass: p.forearm.linearDensity * p.forearm.length,
      pos: along(elbow, a3, p.forearm.length / 2),
      distalOf: ['shoulder', 'elbow'],
    },
    {
      name: 'wrist hardware',
      mass: p.wristHardwareMass,
      pos: wrist,
      distalOf: ['shoulder', 'elbow'],
    },
    {
      name: 'wrist link',
      mass: p.wristLink.linearDensity * p.wristLink.length,
      pos: along(wrist, a4, p.wristLink.length / 2),
      distalOf: ['shoulder', 'elbow', 'wrist'],
    },
    {
      name: 'end effector + payload',
      mass: p.endEffectorMass + p.payloadMass,
      pos: tip,
      distalOf: ['shoulder', 'elbow', 'wrist'],
    },
  ];

  return { joints: { shoulder, elbow, wrist }, tip, masses };
}

// Torque the motor must supply at each pitch joint to hold the pose (N*m).
// Positive means gravity is pulling the distal side down.
export function gravityTorques(
  p: DesignParams,
  cw: Counterweights,
  pose: Pose,
): Record<PitchJoint, number> {
  const geo = armGeometry(p, cw, pose);
  const torque = (joint: PitchJoint): number => {
    let sum = 0;
    for (const m of geo.masses) {
      if (m.distalOf.includes(joint)) {
        sum += m.mass * G * (m.pos.r - geo.joints[joint].r);
      }
    }
    return sum;
  };
  return { shoulder: torque('shoulder'), elbow: torque('elbow'), wrist: torque('wrist') };
}
