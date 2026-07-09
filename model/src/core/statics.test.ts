import { describe, expect, it } from 'vitest';
import { computeCounterweights } from './balance';
import { defaultParams, DesignParams, G, Pose } from './params';
import { armGeometry, gravityTorques } from './statics';

const horizontal: Pose = { yaw: 0, shoulder: 0, elbow: 0, wrist: 0 };

describe('gravityTorques', () => {
  it('wrist torque at horizontal is the unbalanced distal moment', () => {
    const p = defaultParams;
    const cw = computeCounterweights(p);
    const lw = p.wristLink.length;
    const expected =
      G *
      (p.wristLink.linearDensity * lw * (lw / 2) +
        (p.endEffectorMass + p.payloadMass) * lw);
    expect(gravityTorques(p, cw, horizontal).wrist).toBeCloseTo(expected, 10);
  });

  it('with a balanced arm, shoulder torque is payload+EE+wristlink moment at full reach', () => {
    const p: DesignParams = defaultParams;
    const cw = computeCounterweights(p);
    const rWrist = p.upperArm.length + p.forearm.length;
    const lw = p.wristLink.length;
    const expected =
      G *
      (p.wristLink.linearDensity * lw * (rWrist + lw / 2) +
        (p.endEffectorMass + p.payloadMass) * (rWrist + lw));
    expect(gravityTorques(p, cw, horizontal).shoulder).toBeCloseTo(expected, 10);
  });

  it('tip position matches link lengths when extended', () => {
    const p = defaultParams;
    const geo = armGeometry(p, computeCounterweights(p), horizontal);
    expect(geo.tip.r).toBeCloseTo(
      p.upperArm.length + p.forearm.length + p.wristLink.length,
      12,
    );
    expect(geo.tip.z).toBeCloseTo(0, 12);
  });
});
