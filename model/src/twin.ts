import GUI from 'lil-gui';
import { solveIk } from './core/ik';
import { CadStats, initPerfHud } from './view/perfHud';
import { Frames, TwinPose, TwinScene } from './view/twinScene';

// The CAD twin viewer: renders the actual OpenSCAD assembly (five rigid
// bodies exported by `npm run export:cad`) posed by the four joint
// angles alone. Complements the parametric concept calculator on the
// main page: that one answers what-if on dimensions; this one shows
// what the real CAD looks like at a pose.

const status = document.getElementById('status')!;

async function main(): Promise<void> {
  const base = `${import.meta.env.BASE_URL}cad/`;
  const res = await fetch(`${base}frames.json?v=${__BUILD_ID__}`);
  if (!res.ok) {
    status.textContent =
      'cad/frames.json not found — run `npm run export:cad` first.';
    return;
  }
  const frames: Frames = await res.json();
  const pose = loadPose(frames);

  const scene = new TwinScene(document.getElementById('app')!, frames);
  let loaded = 0;
  await scene.load(base, __BUILD_ID__, () => {
    loaded++;
    status.textContent = `loading meshes ${loaded}/5`;
  });
  status.remove();

  scene.setPose(pose);
  const gui = buildPanel(frames, pose, () => {
    scene.setPose(pose);
    savePose(pose);
  });
  // what the export measured (fidelity + budget). Optional: an old
  // model/public/cad/ without stats.json still renders, just without the
  // budget column — the HUD counts the meshes itself either way.
  initPerfHud(scene, gui, await fetchStats(base));

  // Drag the end effector, IK fills in the joints. The ee pitch vs
  // horizontal (shoulder - elbow + wrist) is captured at the grab and
  // HELD through the drag — the tool keeps its attitude while azimuth
  // follows the slew — so dragging moves the tip, never the tool angle.
  let heldPitch = 0;
  scene.onEeDragStart = () => {
    heldPitch = pose.shoulder - pose.elbow + pose.wrist;
  };
  scene.onEeDrag = (tip) => {
    Object.assign(pose, solveIk(tip, heldPitch, frames, pose.yaw));
    scene.setPose(pose);
    gui.controllersRecursive().forEach((c) => c.updateDisplay());
    savePose(pose);
  };
}

async function fetchStats(base: string): Promise<CadStats | null> {
  try {
    const res = await fetch(`${base}stats.json?v=${__BUILD_ID__}`);
    return res.ok ? ((await res.json()) as CadStats) : null;
  } catch {
    return null;
  }
}

function buildPanel(frames: Frames, pose: TwinPose, onChange: () => void): GUI {
  const gui = new GUI({ title: 'big_arm CAD twin' });
  const f = gui.addFolder('Pose (deg)');
  f.add(pose, 'yaw', -frames.yaw_travel / 2, frames.yaw_travel / 2, 1);
  f.add(pose, 'shoulder', frames.shoulder_min, frames.shoulder_max, 1);
  f.add(pose, 'elbow', 0, frames.elbow_travel, 1);
  f.add(pose, 'wrist', -frames.wrist_travel / 2, frames.wrist_travel / 2, 1);
  // scoped to the pose folder, not the root: the root also carries the
  // perf-HUD switch, which has nothing to do with the pose
  f.onChange(onChange);
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
