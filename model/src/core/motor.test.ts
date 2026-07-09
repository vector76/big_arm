import { describe, expect, it } from 'vitest';
import {
  jointCornerSpeed,
  jointHoldingCapacity,
  jointTorqueCapacity,
  motorTorqueAt,
  speedAtTorque,
} from './motor';
import { MotorParams } from './params';

// Shaped like the 17HS19-2004S1 24 V datasheet curve.
const motor: MotorParams = {
  holdingTorque: 0.59,
  pullOutTorque: 0.4,
  cornerSpeed: 8,
  maxSpeed: 20,
  torqueAtMax: 0.16,
};

describe('motorTorqueAt', () => {
  it('is flat at pull-out torque below the corner speed', () => {
    expect(motorTorqueAt(motor, 0)).toBe(0.4);
    expect(motorTorqueAt(motor, 8)).toBe(0.4);
  });
  it('declines linearly past the corner', () => {
    expect(motorTorqueAt(motor, 14)).toBeCloseTo(0.28, 12);
    expect(motorTorqueAt(motor, 19.999)).toBeCloseTo(0.16, 3);
  });
  it('is zero at and beyond the end of the curve', () => {
    expect(motorTorqueAt(motor, 20)).toBe(0);
    expect(motorTorqueAt(motor, 99)).toBe(0);
  });
});

describe('speedAtTorque', () => {
  it('inverts the curve on the linear segment', () => {
    expect(speedAtTorque(motor, 0.28)).toBeCloseTo(14, 12);
    expect(motorTorqueAt(motor, speedAtTorque(motor, 0.3))).toBeCloseTo(0.3, 12);
  });
  it('clamps to corner and max speeds', () => {
    expect(speedAtTorque(motor, 0.5)).toBe(8);
    expect(speedAtTorque(motor, 0.01)).toBe(20);
  });
});

describe('joint capacities', () => {
  const drive = { ratio: 100, efficiency: 0.7, travel: Math.PI };
  it('moving capacity uses pull-out torque', () => {
    expect(jointTorqueCapacity(drive, motor, 0)).toBeCloseTo(28, 12);
  });
  it('holding capacity uses holding torque', () => {
    expect(jointHoldingCapacity(drive, motor)).toBeCloseTo(41.3, 12);
  });
  it('corner speed maps through the ratio', () => {
    const w = jointCornerSpeed(drive, motor);
    expect(w).toBeCloseTo((8 * 2 * Math.PI) / 100, 12);
    expect(jointTorqueCapacity(drive, motor, w)).toBeCloseTo(28, 12);
  });
});
