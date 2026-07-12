import { describe, expect, it } from 'vitest';
import { solveIk } from './ik';
import { Frames, TwinPose } from '../view/twinScene';

const FRAMES: Frames = {
  shoulder_h: 392,
  upper_len: 450,
  fore_len: 450,
  ee_len: 90,
  plate_t: 12,
  yaw_travel: 180,
  shoulder_min: -20,
  shoulder_max: 100,
  elbow_travel: 135,
  wrist_travel: 180,
  pose: { yaw: 0, shoulder: 40, elbow: 70, wrist: -10 },
};

const DEG = Math.PI / 180;

// forward kinematics of the tip, mirroring assembly.scad's tree
function tip(p: TwinPose, f: Frames): { x: number; y: number; z: number } {
  const s = p.shoulder * DEG;
  const e = (p.shoulder - p.elbow) * DEG;
  const w = (p.shoulder - p.elbow + p.wrist) * DEG;
  const r =
    f.upper_len * Math.cos(s) + f.fore_len * Math.cos(e) + f.ee_len * Math.cos(w);
  const z =
    f.shoulder_h +
    f.upper_len * Math.sin(s) + f.fore_len * Math.sin(e) + f.ee_len * Math.sin(w);
  const ya = p.yaw * DEG;
  return { x: r * Math.cos(ya), y: r * Math.sin(ya), z };
}

function eePitch(p: TwinPose): number {
  return p.shoulder - p.elbow + p.wrist;
}

describe('solveIk', () => {
  it('round-trips poses through forward kinematics', () => {
    const poses: TwinPose[] = [
      { yaw: 0, shoulder: 40, elbow: 70, wrist: -10 },
      { yaw: 55, shoulder: 80, elbow: 120, wrist: 30 },
      { yaw: -80, shoulder: -10, elbow: 20, wrist: -45 },
      { yaw: 12, shoulder: 100, elbow: 5, wrist: 60 },
    ];
    for (const p of poses) {
      const got = solveIk(tip(p, FRAMES), eePitch(p), FRAMES, p.yaw);
      expect(got.yaw).toBeCloseTo(p.yaw, 0.5);
      expect(got.shoulder).toBeCloseTo(p.shoulder, 0.5);
      expect(got.elbow).toBeCloseTo(p.elbow, 0.5);
      expect(got.wrist).toBeCloseTo(p.wrist, 0.5);
    }
  });

  it('holds the ee pitch when a target clamps at the reach limit', () => {
    // way out of reach, straight ahead: arm extends flat toward it
    const got = solveIk({ x: 5000, y: 0, z: 392 }, -20, FRAMES);
    expect(got.elbow).toBe(0);
    expect(eePitch(got)).toBeCloseTo(-20, 1);
  });

  it('keeps yaw continuous when the tip crosses behind the mast', () => {
    // shoulder past vertical: the tip sits behind the yaw axis, where
    // raw azimuth reads ~180 off -- prevYaw must pick the near branch
    const p = { yaw: 12, shoulder: 100, elbow: 5, wrist: 60 };
    const got = solveIk(tip(p, FRAMES), eePitch(p), FRAMES, 12);
    expect(got.yaw).toBeCloseTo(12, 0.5);
    expect(got.shoulder).toBeCloseTo(100, 0.5);
  });

  it('clamps every joint to its travel', () => {
    const targets = [
      { x: -300, y: 900, z: 50 },   // behind + far left: yaw clamps
      { x: 100, y: 0, z: 1400 },    // high overhead: shoulder clamps
      { x: 120, y: 0, z: 420 },     // hugging the mast: elbow clamps
    ];
    for (const t of targets) {
      const got = solveIk(t, 0, FRAMES);
      expect(got.yaw).toBeGreaterThanOrEqual(-90);
      expect(got.yaw).toBeLessThanOrEqual(90);
      expect(got.shoulder).toBeGreaterThanOrEqual(FRAMES.shoulder_min);
      expect(got.shoulder).toBeLessThanOrEqual(FRAMES.shoulder_max);
      expect(got.elbow).toBeGreaterThanOrEqual(0);
      expect(got.elbow).toBeLessThanOrEqual(FRAMES.elbow_travel);
      expect(got.wrist).toBeGreaterThanOrEqual(-90);
      expect(got.wrist).toBeLessThanOrEqual(90);
    }
  });
});
