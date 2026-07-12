import GUI from 'lil-gui';
import { Frames, TwinPose, TwinScene } from './view/twinScene';

// The CAD twin viewer: renders the actual OpenSCAD assembly (five rigid
// bodies exported by `npm run export:cad`) posed by the four joint
// angles alone. Complements the parametric concept calculator on the
// main page: that one answers what-if on dimensions; this one shows
// what the real CAD looks like at a pose.

const status = document.getElementById('status')!;

async function main(): Promise<void> {
  const base = `${import.meta.env.BASE_URL}cad/`;
  const res = await fetch(`${base}frames.json`);
  if (!res.ok) {
    status.textContent =
      'cad/frames.json not found — run `npm run export:cad` first.';
    return;
  }
  const frames: Frames = await res.json();
  const pose = loadPose(frames);

  const scene = new TwinScene(document.getElementById('app')!, frames);
  let loaded = 0;
  await scene.load(base, () => {
    loaded++;
    status.textContent = `loading meshes ${loaded}/5`;
  });
  status.remove();

  scene.setPose(pose);
  buildPanel(frames, pose, () => {
    scene.setPose(pose);
    savePose(pose);
  });
}

function buildPanel(frames: Frames, pose: TwinPose, onChange: () => void): GUI {
  const gui = new GUI({ title: 'big_arm CAD twin' });
  const f = gui.addFolder('Pose (deg)');
  f.add(pose, 'yaw', -frames.yaw_travel / 2, frames.yaw_travel / 2, 1);
  f.add(pose, 'shoulder', frames.shoulder_min, frames.shoulder_max, 1);
  f.add(pose, 'elbow', 0, frames.elbow_travel, 1);
  f.add(pose, 'wrist', -frames.wrist_travel / 2, frames.wrist_travel / 2, 1);
  gui.onChange(onChange);
  return gui;
}

// The pose serializes into the URL so a view is shareable as a link.
function loadPose(frames: Frames): TwinPose {
  const pose = { ...frames.pose };
  const raw = new URLSearchParams(window.location.search).get('pose');
  if (!raw) return pose;
  const parts = raw.split(',').map(Number);
  const keys: (keyof TwinPose)[] = ['yaw', 'shoulder', 'elbow', 'wrist'];
  keys.forEach((k, i) => {
    if (Number.isFinite(parts[i])) pose[k] = parts[i];
  });
  return pose;
}

function savePose(pose: TwinPose): void {
  const s = [pose.yaw, pose.shoulder, pose.elbow, pose.wrist].join(',');
  window.history.replaceState(null, '', `?pose=${s}`);
}

main();
