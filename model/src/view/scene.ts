import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { Counterweights } from '../core/balance';
import { DesignParams, PitchJoint, Pose } from '../core/params';
import { Summary } from '../core/summary';

const STEEL_DENSITY = 7800; // counterweight blobs drawn as if solid steel

const COLORS = {
  wood: 0xb08d57,
  stub: 0x8a6f45,
  counterweight: 0x555c66,
  column: 0x6a7280,
  payload: 0xcc4444,
  jointGood: 0x3fae5e,
  jointThin: 0xd99a2b,
  jointBad: 0xd9442b,
};

function marginColor(margin: number): number {
  if (margin < 1) return COLORS.jointBad;
  if (margin < 1.5) return COLORS.jointThin;
  return COLORS.jointGood;
}

function link(length: number, thickness: number, color: number): THREE.Mesh {
  const mesh = new THREE.Mesh(
    new THREE.BoxGeometry(length, thickness, thickness),
    new THREE.MeshStandardMaterial({ color }),
  );
  mesh.position.x = length / 2;
  return mesh;
}

function blob(mass: number, color: number): THREE.Mesh {
  const r = Math.cbrt((3 * Math.max(mass, 0.001)) / (4 * Math.PI * STEEL_DENSITY));
  return new THREE.Mesh(
    new THREE.SphereGeometry(r, 20, 14),
    new THREE.MeshStandardMaterial({ color }),
  );
}

function jointBall(radius: number): THREE.Mesh {
  return new THREE.Mesh(
    new THREE.SphereGeometry(radius, 20, 14),
    new THREE.MeshStandardMaterial({ color: COLORS.jointGood }),
  );
}

export class ArmScene {
  private renderer: THREE.WebGLRenderer;
  private scene = new THREE.Scene();
  private camera: THREE.PerspectiveCamera;
  private controls: OrbitControls;
  private arm = new THREE.Group();

  constructor(container: HTMLElement) {
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
    this.scene.add(new THREE.GridHelper(3, 30, 0x3a414b, 0x272c33));
    this.scene.add(this.arm);

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

  // The scene is small; rebuilding the arm on every change keeps the code
  // simple and honest about being a calculator display, not a CAD model.
  rebuild(p: DesignParams, pose: Pose, summary: Summary): void {
    this.arm.traverse((obj) => {
      if (obj instanceof THREE.Mesh) {
        obj.geometry.dispose();
        (obj.material as THREE.Material).dispose();
      }
    });
    this.arm.clear();
    const cw: Counterweights = summary.counterweights;
    const margins: Record<PitchJoint, number> = {
      shoulder: summary.joints.shoulder.margin,
      elbow: summary.joints.elbow.margin,
      wrist: summary.joints.wrist.margin,
    };

    const column = new THREE.Mesh(
      new THREE.CylinderGeometry(0.05, 0.07, p.columnHeight, 20),
      new THREE.MeshStandardMaterial({ color: COLORS.column }),
    );
    column.position.y = p.columnHeight / 2;
    this.arm.add(column);

    const yawGroup = new THREE.Group();
    yawGroup.position.y = p.columnHeight;
    yawGroup.rotation.y = pose.yaw;
    this.arm.add(yawGroup);

    const shoulderGroup = new THREE.Group();
    shoulderGroup.rotation.z = pose.shoulder;
    yawGroup.add(shoulderGroup);

    const shoulderBall = jointBall(0.045);
    (shoulderBall.material as THREE.MeshStandardMaterial).color.set(
      marginColor(margins.shoulder),
    );
    yawGroup.add(shoulderBall);

    shoulderGroup.add(link(p.upperArm.length, 0.07, COLORS.wood));
    const shoulderStub = link(cw.shoulderStubLength, 0.05, COLORS.stub);
    shoulderStub.rotation.y = Math.PI;
    shoulderGroup.add(shoulderStub);
    const shoulderCw = blob(cw.shoulderMass, COLORS.counterweight);
    shoulderCw.position.x = -cw.shoulderStubLength;
    shoulderGroup.add(shoulderCw);

    const elbowGroup = new THREE.Group();
    elbowGroup.position.x = p.upperArm.length;
    elbowGroup.rotation.z = pose.elbow;
    shoulderGroup.add(elbowGroup);

    const elbowBall = jointBall(0.038);
    (elbowBall.material as THREE.MeshStandardMaterial).color.set(marginColor(margins.elbow));
    elbowGroup.add(elbowBall);

    elbowGroup.add(link(p.forearm.length, 0.055, COLORS.wood));
    const elbowStub = link(cw.elbowStubLength, 0.04, COLORS.stub);
    elbowStub.rotation.y = Math.PI;
    elbowGroup.add(elbowStub);
    const elbowCw = blob(cw.elbowMass, COLORS.counterweight);
    elbowCw.position.x = -cw.elbowStubLength;
    elbowGroup.add(elbowCw);

    const wristGroup = new THREE.Group();
    wristGroup.position.x = p.forearm.length;
    wristGroup.rotation.z = pose.wrist;
    elbowGroup.add(wristGroup);

    const wristBall = jointBall(0.03);
    (wristBall.material as THREE.MeshStandardMaterial).color.set(marginColor(margins.wrist));
    wristGroup.add(wristBall);

    wristGroup.add(link(p.wristLink.length, 0.04, COLORS.wood));
    const payload = blob(p.endEffectorMass + p.payloadMass, COLORS.payload);
    payload.position.x = p.wristLink.length;
    wristGroup.add(payload);
  }
}
