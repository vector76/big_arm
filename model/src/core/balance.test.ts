import { describe, expect, it } from 'vitest';
import { computeCounterweights } from './balance';
import { defaultParams, DesignParams, Pose } from './params';
import { gravityTorques } from './statics';

// With the wrist link massless and no end effector or payload, the computed
// counterweights must make the shoulder and elbow gravity-neutral in EVERY
// pose. This exercises the balance math and the statics together.
function balancedOnly(): DesignParams {
  return {
    ...defaultParams,
    wristLink: { ...defaultParams.wristLink, linearDensity: 0 },
    endEffectorMass: 0,
    payloadMass: 0,
  };
}

const poses: Pose[] = [];
for (const shoulder of [-0.5, 0, 0.4, 1.2]) {
  for (const elbow of [-2, -0.7, 0, 1.5]) {
    for (const wrist of [-1.2, 0, 0.9]) {
      poses.push({ yaw: 0, shoulder, elbow, wrist });
    }
  }
}

describe('computeCounterweights', () => {
  it('zeroes shoulder and elbow gravity torque in every pose', () => {
    const p = balancedOnly();
    const cw = computeCounterweights(p);
    for (const pose of poses) {
      const t = gravityTorques(p, cw, pose);
      expect(Math.abs(t.shoulder)).toBeLessThan(1e-9);
      expect(Math.abs(t.elbow)).toBeLessThan(1e-9);
      expect(t.wrist).toBe(0);
    }
  });

  it('halving the stub fraction roughly doubles the counterweight', () => {
    const p = balancedOnly();
    const full = computeCounterweights({ ...p, elbowStubFraction: 0.5 });
    const half = computeCounterweights({ ...p, elbowStubFraction: 0.25 });
    expect(half.elbowMass).toBeGreaterThan(1.8 * full.elbowMass);
  });

  it('under-balance margin scales the masses', () => {
    const p = balancedOnly();
    const exact = computeCounterweights(p);
    const under = computeCounterweights({ ...p, counterweightMargin: 0.9 });
    expect(under.elbowMass).toBeCloseTo(0.9 * exact.elbowMass, 10);
  });
});
