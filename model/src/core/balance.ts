import { DesignParams } from './params';

export interface Counterweights {
  elbowMass: number;         // kg on the elbow stub tip
  shoulderMass: number;      // kg on the shoulder stub tip
  elbowStubLength: number;   // m
  shoulderStubLength: number;// m
}

// Counterweights sized so the arm's own mass is gravity-neutral at the elbow
// and shoulder in every pose. The wrist link, end effector, and payload are
// deliberately unbalanced (see docs/requirements.md); their torque falls on
// the motors.
export function computeCounterweights(p: DesignParams): Counterweights {
  const lf = p.forearm.length;
  const lu = p.upperArm.length;

  const elbowStubLength = p.elbowStubFraction * lf;
  const forearmMass = p.forearm.linearDensity * lf;
  const elbowStubMass = p.stubLinearDensity * elbowStubLength;
  const momentAboutElbow =
    forearmMass * (lf / 2) +
    p.wristHardwareMass * lf -
    elbowStubMass * (elbowStubLength / 2);
  const elbowMass =
    Math.max(0, momentAboutElbow / elbowStubLength) * p.counterweightMargin;

  const elbowAssemblyMass =
    forearmMass + p.wristHardwareMass + elbowStubMass + elbowMass + p.elbowHardwareMass;

  const shoulderStubLength = p.shoulderStubFraction * lu;
  const upperArmMass = p.upperArm.linearDensity * lu;
  const shoulderStubMass = p.stubLinearDensity * shoulderStubLength;
  const momentAboutShoulder =
    elbowAssemblyMass * lu +
    upperArmMass * (lu / 2) -
    shoulderStubMass * (shoulderStubLength / 2);
  const shoulderMass =
    Math.max(0, momentAboutShoulder / shoulderStubLength) * p.counterweightMargin;

  return { elbowMass, shoulderMass, elbowStubLength, shoulderStubLength };
}

export function totalArmMass(p: DesignParams, cw: Counterweights): number {
  return (
    p.upperArm.linearDensity * p.upperArm.length +
    p.forearm.linearDensity * p.forearm.length +
    p.wristLink.linearDensity * p.wristLink.length +
    p.stubLinearDensity * (cw.elbowStubLength + cw.shoulderStubLength) +
    cw.elbowMass +
    cw.shoulderMass +
    p.elbowHardwareMass +
    p.wristHardwareMass +
    p.endEffectorMass
  );
}
