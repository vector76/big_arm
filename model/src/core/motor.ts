import { JointDrive, MotorParams } from './params';

// Stepper pull-out torque model matching the 24 V datasheet curve: flat at
// pullOutTorque up to cornerSpeed, then linear down to torqueAtMax at
// maxSpeed, zero beyond (the datasheet ends there). Speeds in rev/s.
// Note: while stepping, capacity is pull-out torque, NOT holding torque;
// holding torque applies only to a stationary, energized motor.
export function motorTorqueAt(motor: MotorParams, revPerSec: number): number {
  const s = Math.abs(revPerSec);
  if (s >= motor.maxSpeed) return 0;
  if (s <= motor.cornerSpeed) return motor.pullOutTorque;
  const slope =
    (motor.pullOutTorque - motor.torqueAtMax) / (motor.maxSpeed - motor.cornerSpeed);
  return motor.pullOutTorque - slope * (s - motor.cornerSpeed);
}

// Inverse of the curve: the fastest speed (rev/s) at which the motor still
// delivers the requested torque.
export function speedAtTorque(motor: MotorParams, torque: number): number {
  if (torque >= motor.pullOutTorque) return motor.cornerSpeed;
  if (torque <= motor.torqueAtMax) return motor.maxSpeed;
  const slope =
    (motor.pullOutTorque - motor.torqueAtMax) / (motor.maxSpeed - motor.cornerSpeed);
  return motor.cornerSpeed + (motor.pullOutTorque - torque) / slope;
}

// Torque available at the joint while it moves at jointRadPerSec.
export function jointTorqueCapacity(
  drive: JointDrive,
  motor: MotorParams,
  jointRadPerSec: number,
): number {
  const motorRevPerSec = (Math.abs(jointRadPerSec) * drive.ratio) / (2 * Math.PI);
  return motorTorqueAt(motor, motorRevPerSec) * drive.ratio * drive.efficiency;
}

// Torque the joint can hold while stationary (energized, not stepping).
export function jointHoldingCapacity(drive: JointDrive, motor: MotorParams): number {
  return motor.holdingTorque * drive.ratio * drive.efficiency;
}

// Joint speed at the motor's corner point: the fastest speed with full torque.
export function jointCornerSpeed(drive: JointDrive, motor: MotorParams): number {
  return (motor.cornerSpeed * 2 * Math.PI) / drive.ratio;
}
