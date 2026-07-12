import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { ThreeMFLoader } from 'three/addons/loaders/3MFLoader.js';

// Joint frame numbers + travel limits, echoed out of cad/arm/params.scad
// by `npm run export:cad` (frames.json) — never duplicated in TS.
export interface Frames {
  shoulder_h: number;
  upper_len: number;
  fore_len: number;
  ee_len: number;
  yaw_travel: number;
  shoulder_min: number;
  shoulder_max: number;
  elbow_travel: number;
  wrist_travel: number;
  pose: TwinPose;
}

// Degrees, matching the pose_* variables in params.scad.
export interface TwinPose {
  yaw: number;
  shoulder: number;
  elbow: number;
  wrist: number;
}

const DEG = Math.PI / 180;

// OpenSCAD's 3MF export writes displaycolor as #RRGGBBAA with AA = 00,
// which the loader reads as opacity 0 — force every material opaque.
// flatShading because the exported meshes share vertices across sharp
// edges: smoothed normals would read as blobs, facets read as CAD.
function fixMaterials(group: THREE.Group): void {
  group.traverse((obj) => {
    if (!(obj instanceof THREE.Mesh)) return;
    const mats = Array.isArray(obj.material) ? obj.material : [obj.material];
    for (const m of mats) {
      m.opacity = 1;
      m.transparent = false;
      if ('flatShading' in m) (m as THREE.MeshPhongMaterial).flatShading = true;
      m.needsUpdate = true;
    }
  });
}

// The CAD twin: the five rigid-body meshes exported from
// cad/arm/export.scad, hung on the same kinematic tree as
// assembly.scad's top level —
//   rz(yaw) { yawBody; tz(shoulder_h) ry(-shoulder) { upperBody;
//     tx(upper_len) ry(elbow) { foreBody;
//       tx(fore_len) ry(-wrist) eeBody } } }
// Meshes stay in OpenSCAD coordinates (mm, Z-up); the root group maps
// them into the display world (meters, Y-up).
export class TwinScene {
  private renderer: THREE.WebGLRenderer;
  private scene = new THREE.Scene();
  private camera: THREE.PerspectiveCamera;
  private controls: OrbitControls;

  private yawGroup = new THREE.Group();
  private shoulderGroup = new THREE.Group();
  private elbowGroup = new THREE.Group();
  private wristGroup = new THREE.Group();

  constructor(container: HTMLElement, frames: Frames) {
    this.renderer = new THREE.WebGLRenderer({ antialias: true });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setPixelRatio(window.devicePixelRatio);
    container.appendChild(this.renderer.domElement);

    this.scene.background = new THREE.Color(0x1a1d21);
    this.camera = new THREE.PerspectiveCamera(
      50,
      window.innerWidth / window.innerHeight,
      0.01,
      50,
    );
    this.camera.position.set(1.6, 1.1, 1.6);
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.target.set(0, 0.4, 0);

    this.scene.add(new THREE.HemisphereLight(0xffffff, 0x33383f, 1.1));
    const sun = new THREE.DirectionalLight(0xffffff, 1.4);
    sun.position.set(2, 4, 1);
    this.scene.add(sun);
    const fill = new THREE.DirectionalLight(0xffffff, 0.5);
    fill.position.set(-3, 2, -2);
    this.scene.add(fill);
    this.scene.add(new THREE.GridHelper(3, 30, 0x3a414b, 0x272c33));

    // OpenSCAD mm / Z-up -> display meters / Y-up
    const root = new THREE.Group();
    root.rotation.x = -Math.PI / 2;
    root.scale.setScalar(0.001);
    this.scene.add(root);

    root.add(this.yawGroup);
    this.shoulderGroup.position.z = frames.shoulder_h;
    this.yawGroup.add(this.shoulderGroup);
    this.elbowGroup.position.x = frames.upper_len;
    this.shoulderGroup.add(this.elbowGroup);
    this.wristGroup.position.x = frames.fore_len;
    this.elbowGroup.add(this.wristGroup);

    // the static body hangs off the root directly
    this.bodyParents = {
      static: root,
      yaw: this.yawGroup,
      upper: this.shoulderGroup,
      fore: this.elbowGroup,
      ee: this.wristGroup,
    };

    window.addEventListener('resize', () => {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
    });

    const animate = () => {
      requestAnimationFrame(animate);
      this.controls.update();
      this.renderer.render(this.scene, this.camera);
    };
    animate();
  }

  private bodyParents: Record<string, THREE.Object3D>;

  async load(baseUrl: string, onProgress: (msg: string) => void): Promise<void> {
    const loader = new ThreeMFLoader();
    await Promise.all(
      Object.entries(this.bodyParents).map(async ([body, parent]) => {
        const group = await loader.loadAsync(`${baseUrl}${body}.3mf`);
        fixMaterials(group);
        parent.add(group);
        onProgress(body);
      }),
    );
  }

  // Signs mirror assembly.scad: rz(yaw), ry(-shoulder), ry(elbow), ry(-wrist)
  setPose(pose: TwinPose): void {
    this.yawGroup.rotation.z = pose.yaw * DEG;
    this.shoulderGroup.rotation.y = -pose.shoulder * DEG;
    this.elbowGroup.rotation.y = pose.elbow * DEG;
    this.wristGroup.rotation.y = -pose.wrist * DEG;
  }
}
