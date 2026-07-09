import { PITCH_JOINTS, Pose } from '../core/params';
import { Summary } from '../core/summary';

const KG_TO_LB = 2.20462;

function fmt(x: number, digits = 2): string {
  return Number.isFinite(x) ? x.toFixed(digits) : '∞';
}

function marginClass(m: number): string {
  if (m < 1) return 'margin-bad';
  if (m < 1.5) return 'margin-thin';
  return 'margin-good';
}

export function renderReadout(el: HTMLElement, s: Summary, pose: Pose): void {
  const cw = s.counterweights;
  const joints = PITCH_JOINTS.map((j) => {
    const r = s.joints[j];
    return `<tr>
      <td>${j}</td>
      <td>${fmt(r.torqueHere, 1)}</td>
      <td>${fmt(Math.abs(r.worstTorque), 1)}</td>
      <td>${fmt(r.staticCapacity, 1)}</td>
      <td>${fmt(r.holdingCapacity, 1)}</td>
      <td class="${marginClass(r.margin)}">${fmt(r.margin)}</td>
    </tr>`;
  }).join('');

  const joints4 = Object.keys(s.traverseUnloaded.perJoint);
  const traverse = joints4
    .map(
      (j) =>
        `<tr><td>${j}</td><td>${fmt(s.traverseUnloaded.perJoint[j as never], 1)} s</td><td>${fmt(s.traverseLoaded.perJoint[j as never], 1)} s</td></tr>`,
    )
    .join('');

  el.innerHTML = `
    <h3>Mass budget</h3>
    <table>
      <tr><td>reach</td><td>${fmt(s.reach)} m</td></tr>
      <tr><td>shoulder counterweight</td><td>${fmt(cw.shoulderMass)} kg (${fmt(cw.shoulderMass * KG_TO_LB, 1)} lb)</td></tr>
      <tr><td>elbow counterweight</td><td>${fmt(cw.elbowMass)} kg (${fmt(cw.elbowMass * KG_TO_LB, 1)} lb)</td></tr>
      <tr><td>total arm (no payload)</td><td>${fmt(s.totalArmMass)} kg (${fmt(s.totalArmMass * KG_TO_LB, 1)} lb)</td></tr>
    </table>
    <h3>Joint torques (N·m)</h3>
    <table>
      <tr><th>joint</th><th>here</th><th>worst</th><th>move cap</th><th>hold cap</th><th>margin</th></tr>
      ${joints}
    </table>
    <h3>Residual imbalance at pose (no EE/payload)</h3>
    <table>
      <tr><td>shoulder</td><td>${fmt(s.residualImbalance.shoulder, 3)} N·m</td>
          <td>elbow</td><td>${fmt(s.residualImbalance.elbow, 3)} N·m</td></tr>
    </table>
    <h3>Full-travel traverse</h3>
    <table>
      <tr><th>joint</th><th>unloaded</th><th>loaded</th></tr>
      ${traverse}
      <tr><td><b>worst</b></td><td><b>${fmt(s.traverseUnloaded.worst, 1)} s</b></td><td><b>${fmt(s.traverseLoaded.worst, 1)} s</b></td></tr>
    </table>
    <h3>Pose</h3>
    <table>
      <tr><td>yaw / shoulder / elbow / wrist</td>
      <td>${[pose.yaw, pose.shoulder, pose.elbow, pose.wrist]
        .map((a) => ((a * 180) / Math.PI).toFixed(0) + '°')
        .join(' / ')}</td></tr>
    </table>`;
}
