import { describe, expect, it } from 'vitest';
import { computeCounterweights } from './balance';
import { trapezoidTime, traverseTimes } from './motion';
import { defaultParams } from './params';

describe('trapezoidTime', () => {
  it('triangular profile when distance is short', () => {
    // accel 2, distance 1: t = 2*sqrt(1/2)
    expect(trapezoidTime(1, 100, 2)).toBeCloseTo(2 * Math.sqrt(0.5), 12);
  });
  it('trapezoidal profile when cruise is reached', () => {
    // vmax 1, accel 1, distance 10: 10/1 + 1/1 = 11
    expect(trapezoidTime(10, 1, 1)).toBeCloseTo(11, 12);
  });
  it('zero distance takes zero time', () => {
    expect(trapezoidTime(0, 1, 1)).toBe(0);
  });
});

describe('traverseTimes', () => {
  it('produces finite positive times for the default design', () => {
    const cw = computeCounterweights(defaultParams);
    const t = traverseTimes(defaultParams, cw, false);
    for (const v of Object.values(t.perJoint)) {
      expect(v).toBeGreaterThan(0);
      expect(Number.isFinite(v)).toBe(true);
    }
    expect(t.worst).toBe(Math.max(...Object.values(t.perJoint)));
  });

  it('unloaded traverse is at least as fast as loaded', () => {
    const cw = computeCounterweights(defaultParams);
    const unloaded = traverseTimes(defaultParams, cw, false);
    const loaded = traverseTimes(defaultParams, cw, true);
    for (const j of Object.keys(unloaded.perJoint) as (keyof typeof unloaded.perJoint)[]) {
      expect(unloaded.perJoint[j]).toBeLessThanOrEqual(loaded.perJoint[j] + 1e-9);
    }
  });
});
