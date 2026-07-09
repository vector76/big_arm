import { Counterweights } from './balance';
import { jointCornerSpeed, jointTorqueCapacity, speedAtTorque } from './motor';
import { DesignParams, JointName, PITCH_JOINTS, Pose } from './params';
import { armGeometry } from './statics';
import { worstCaseTorques } from './sweep';

const EXTENDED: Pose = { yaw: 0, shoulder: 0, elbow: 0, wrist: 0 };
const LOAD_SAFETY = 2;         // cruise where capacity >= 2x the load torque
const FRICTION_FLOOR = 0.05;   // assume load is never below 5% of static capacity
const SPEED_CEILING = 0.9;     // never plan right at the motor's zero-torque speed

// Moment of inertia (kg*m^2) of everything a joint must swing, in the
// worst (fully extended) pose.
export function inertiaAbout(
  joint: JointName,
  p: DesignParams,
  cw: Counterweights,
): number {
  const geo = armGeometry(p, cw, EXTENDED);
  let sum = 0;
  for (const m of geo.masses) {
    if (joint === 'yaw') {
      sum += m.mass * m.pos.r * m.pos.r;
    } else if (m.distalOf.includes(joint)) {
      const dr = m.pos.r - geo.joints[joint].r;
      const dz = m.pos.z - geo.joints[joint].z;
      sum += m.mass * (dr * dr + dz * dz);
    }
  }
  return sum;
}

export function trapezoidTime(distance: number, vmax: number, accel: number): number {
  if (distance <= 0) return 0;
  const accelDistance = (vmax * vmax) / accel;
  if (distance <= accelDistance) return 2 * Math.sqrt(distance / accel);
  return distance / vmax + vmax / accel;
}

// Fastest joint speed at which the drive still delivers LOAD_SAFETY times
// the load torque, per the motor's pull-out curve. Below the corner speed
// capacity is flat, so the corner is always achievable.
export function cruiseSpeed(
  p: DesignParams,
  joint: JointName,
  loadTorque: number,
): number {
  const drive = p[joint];
  const corner = jointCornerSpeed(drive, p.motor);
  const staticCap = jointTorqueCapacity(drive, p.motor, 0);
  const load = Math.max(Math.abs(loadTorque), FRICTION_FLOOR * staticCap);
  const ceiling = (SPEED_CEILING * p.motor.maxSpeed * 2 * Math.PI) / drive.ratio;
  const motorTorqueNeeded = (LOAD_SAFETY * load) / (drive.ratio * drive.efficiency);
  const byTorque = (speedAtTorque(p.motor, motorTorqueNeeded) * 2 * Math.PI) / drive.ratio;
  return Math.min(Math.max(corner, byTorque), ceiling);
}

export interface TraverseResult {
  perJoint: Record<JointName, number>; // s, full-travel time
  worst: number;                       // s
}

// Full-range traverse time per joint. Cruise speed adapts to the load: an
// unloaded joint rides the falling torque curve well past the corner speed,
// a loaded one stays where torque margin holds. Half the torque headroom at
// cruise is budgeted for acceleration.
export function traverseTimes(
  p: DesignParams,
  cw: Counterweights,
  loaded: boolean,
): TraverseResult {
  const params: DesignParams = loaded ? p : { ...p, payloadMass: 0 };
  const worstTorque = worstCaseTorques(params, cw);
  const perJoint = {} as Record<JointName, number>;
  const joints: JointName[] = ['yaw', ...PITCH_JOINTS];
  for (const j of joints) {
    const drive = params[j];
    const load = j === 'yaw' ? 0 : Math.abs(worstTorque.torque[j]);
    const vmax = cruiseSpeed(params, j, load);
    const capacityAtCruise = jointTorqueCapacity(drive, params.motor, vmax);
    const accelTorque = Math.max(0.5 * (capacityAtCruise - load), 1e-6);
    const accel = accelTorque / inertiaAbout(j, params, cw);
    perJoint[j] = trapezoidTime(drive.travel, vmax, accel);
  }
  const worst = Math.max(...Object.values(perJoint));
  return { perJoint, worst };
}
