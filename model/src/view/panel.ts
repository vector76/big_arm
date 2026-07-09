import GUI from 'lil-gui';
import { AppState } from './urlState';

const DEG = Math.PI / 180;

// lil-gui works in degrees for pose sliders; the state stays in radians.
export function buildPanel(state: AppState, onChange: () => void): GUI {
  const gui = new GUI({ title: 'big_arm model' });
  const p = state.params;

  const poseDeg = {
    get yaw() { return state.pose.yaw / DEG; },
    set yaw(v: number) { state.pose.yaw = v * DEG; },
    get shoulder() { return state.pose.shoulder / DEG; },
    set shoulder(v: number) { state.pose.shoulder = v * DEG; },
    get elbow() { return state.pose.elbow / DEG; },
    set elbow(v: number) { state.pose.elbow = v * DEG; },
    get wrist() { return state.pose.wrist / DEG; },
    set wrist(v: number) { state.pose.wrist = v * DEG; },
  };

  const pose = gui.addFolder('Pose (deg)');
  pose.add(poseDeg, 'yaw', -120, 120, 1);
  pose.add(poseDeg, 'shoulder', -30, 90, 1);
  pose.add(poseDeg, 'elbow', -135, 0, 1);
  pose.add(poseDeg, 'wrist', -90, 90, 1);

  const geom = gui.addFolder('Geometry (m)');
  geom.add(p.upperArm, 'length', 0.2, 0.8, 0.01).name('upper arm');
  geom.add(p.forearm, 'length', 0.15, 0.7, 0.01).name('forearm');
  geom.add(p.wristLink, 'length', 0.05, 0.25, 0.01).name('wrist link');
  geom.add(p, 'shoulderStubFraction', 0.15, 1, 0.05).name('shoulder stub frac');
  geom.add(p, 'elbowStubFraction', 0.15, 1, 0.05).name('elbow stub frac');
  geom.add(p, 'columnHeight', 0.2, 0.8, 0.01).name('column height');

  const mass = gui.addFolder('Masses (kg, kg/m)');
  mass.add(p.upperArm, 'linearDensity', 0.3, 3, 0.05).name('upper arm kg/m');
  mass.add(p.forearm, 'linearDensity', 0.3, 3, 0.05).name('forearm kg/m');
  mass.add(p.wristLink, 'linearDensity', 0.1, 2, 0.05).name('wrist link kg/m');
  mass.add(p, 'stubLinearDensity', 0.3, 3, 0.05).name('stub kg/m');
  mass.add(p, 'elbowHardwareMass', 0, 2.5, 0.05).name('elbow hardware');
  mass.add(p, 'wristHardwareMass', 0, 2, 0.05).name('wrist hardware');
  mass.add(p, 'endEffectorMass', 0, 2.5, 0.05).name('end effector');
  mass.add(p, 'payloadMass', 0, 5, 0.05).name('payload');
  mass.add(p, 'counterweightMargin', 0, 1.2, 0.01).name('balance fraction');

  const drives = gui.addFolder('Drives');
  for (const j of ['yaw', 'shoulder', 'elbow', 'wrist'] as const) {
    const f = drives.addFolder(j);
    f.add(p[j], 'ratio', 5, 400, 1);
    f.add(p[j], 'efficiency', 0.2, 1, 0.01);
    f.close();
  }

  const motor = gui.addFolder('Motor (NEMA 17)');
  motor.add(p.motor, 'holdingTorque', 0.1, 0.8, 0.01).name('holding N·m');
  motor.add(p.motor, 'pullOutTorque', 0.1, 0.6, 0.01).name('pull-out N·m');
  motor.add(p.motor, 'cornerSpeed', 1, 12, 0.1).name('corner rev/s');
  motor.add(p.motor, 'maxSpeed', 5, 30, 0.1).name('max rev/s');
  motor.add(p.motor, 'torqueAtMax', 0.02, 0.4, 0.01).name('N·m @ max');
  motor.close();

  gui.onChange(onChange);
  return gui;
}
