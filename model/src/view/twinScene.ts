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
  plate_t: number;
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

// What one rigid body costs to draw. OpenSCAD counts the same triangles
// at export time (scripts/export-cad.mjs enforces a budget on them); this
// is the count that actually reached the GPU, so a loader that splits or
// merges geometry can't hide a regression from us.
export interface BodyCost {
  triangles: number;
  drawCalls: number;
  // vertices SUBMITTED, which is 3x the triangles: the 3MF loader's
  // basematerials path de-indexes the mesh (see measure()), so the shared
  // vertices arrive tripled. The unique count — the one that matches the
  // export's stats.json — is partVertices(), computed on demand because
  // deduplicating positions isn't free.
  vertices: number;
  parts: PartCost[]; // biggest first
}

// One PART of a body. OpenSCAD unions a group into a single solid, so the
// 3MF has no per-part objects — but export.scad already declares that
// "the color key IS part semantics here", and the 3MF carries each
// color() through as a base material. The loader then splits the object
// into one mesh PER MATERIAL, so a part == a color == a mesh == a draw
// call, and its triangles are exactly the ones that draw call submits.
// (This is how the drums show up as 84% of `upper`.)
export interface PartCost {
  color: string; // '#4682b4' — the key, and what the swatch shows
  name: string; // the color()'s CSS name where we know it, else the hex
  triangles: number;
}

// The CSS colors cad/ actually paints with, so the inspector can say
// "steelblue" instead of "#4682b4". Display nicety only — an unlisted
// color falls back to its hex and everything else still works.
const COLOR_NAMES: Record<string, string> = {
  '#4682b4': 'steelblue',
  '#ff6347': 'tomato',
  '#c0c0c0': 'silver',
  '#deb887': 'burlywood',
  '#f0e68c': 'khaki',
  '#696969': 'dimgray',
  '#ffffff': 'white',
  '#a0522d': 'sienna',
  '#2e8b57': 'seagreen',
  '#f5deb3': 'wheat',
  '#708090': 'slategray',
  '#ffdead': 'navajowhite',
  '#bc8f8f': 'rosybrown',
  '#ff4500': 'orangered',
  '#e9967a': 'darksalmon',
  '#fa8072': 'salmon',
  '#ffd700': 'gold',
  '#9acd32': 'yellowgreen',
  '#da70d6': 'orchid',
  '#ff0000': 'red',
  '#00bfff': 'deepskyblue',
};

// The meshes a part's triangles live in — recolored for the highlight,
// bounded for the camera focus. Normally one, but a body could carry the
// same color in more than one 3MF object, so keep a list.
interface PartRef {
  meshes: THREE.Mesh[];
}

const DEG = Math.PI / 180;

// what the UNSELECTED parts keep of their own opacity while one part is
// isolated — a 30% cut, enough to see through without losing the arm
const DIM_OPACITY = 0.7;

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
      // the part highlight recolors and fades materials in place; keep the
      // export's color and opacity so it can put them back exactly
      const pm = m as THREE.MeshPhongMaterial;
      pm.userData.baseColor = pm.color.clone();
      pm.userData.baseOpacity = pm.opacity;
      m.needsUpdate = true;
    }
  });
}

// What a loaded body costs to draw, broken down by part.
//
// The 3MF loader's basematerials path (3MFLoader.js, buildBasematerials)
// splits one 3MF object into ONE MESH PER BASE MATERIAL, each with a
// single material and a NON-INDEXED geometry — it re-emits every triangle
// as three loose vertices. Two consequences we rely on:
//
//   - a part (a color()) is already its own mesh and its own draw call,
//     so nothing here has to slice index ranges apart; and
//   - `position.count` is 3x the triangles, NOT the 3MF's shared-vertex
//     count. Every triangle the CAD emits therefore costs three vertices
//     on the GPU, not one — which is one more reason the triangle budget
//     is the number to hold down.
function measure(group: THREE.Group, refs: Map<string, PartRef>): BodyCost {
  const cost: BodyCost = { triangles: 0, drawCalls: 0, vertices: 0, parts: [] };
  const byColor = new Map<string, PartCost>();

  group.traverse((obj) => {
    if (!(obj instanceof THREE.Mesh)) return;
    const geo = obj.geometry as THREE.BufferGeometry;
    const posCount = geo.getAttribute('position')?.count ?? 0;
    const index = geo.getIndex();
    const triangles = (index?.count ?? posCount) / 3;
    const mat = (Array.isArray(obj.material) ? obj.material[0] : obj.material) as
      | THREE.MeshPhongMaterial
      | undefined;
    if (!mat) return;

    cost.triangles += triangles;
    cost.vertices += posCount;
    cost.drawCalls += 1;

    const color = `#${mat.color.getHexString()}`;
    const part = byColor.get(color) ?? {
      color,
      name: COLOR_NAMES[color] ?? color,
      triangles: 0,
    };
    part.triangles += triangles;
    byColor.set(color, part);

    const ref = refs.get(color) ?? { meshes: [] };
    ref.meshes.push(obj);
    refs.set(color, ref);
  });

  cost.parts = [...byColor.values()].sort((a, b) => b.triangles - a.triangles);
  return cost;
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

  // ee-mesh drag → IK (wired by twin.ts): onEeDragStart fires at the
  // grab (the caller captures the ee pitch to hold), then onEeDrag
  // streams tip targets in the CAD frame (mm, Z-up) as the pointer
  // moves on a camera-facing plane through the grab point.
  onEeDragStart: (() => void) | null = null;
  onEeDrag: ((tip: { x: number; y: number; z: number }) => void) | null = null;

  private root = new THREE.Group();
  private eeBody: THREE.Group | null = null;
  private eeLen: number;
  private raycaster = new THREE.Raycaster();

  // filled by load(); read by the perf HUD
  readonly cost: Record<string, BodyCost> = {};
  private refs: Record<string, Map<string, PartRef>> = {};
  private highlighted: { body: string; color: string } | null = null;
  private vertexCache: Record<string, Map<string, number>> = {};
  // where the camera was before the first focusPart(), so dropping the
  // selection can put the whole arm back in frame
  private savedView: { target: THREE.Vector3; position: THREE.Vector3 } | null = null;

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

    // OpenSCAD mm / Z-up -> display meters / Y-up. The CAD datum is
    // the bench plate's TOP (the plate spans z -plate_t..0), so lift
    // the whole model by plate_t: the plate's BOTTOM sits on the
    // display grid instead of the grid slicing through it.
    const root = this.root;
    root.rotation.x = -Math.PI / 2;
    root.scale.setScalar(0.001);
    root.position.y = frames.plate_t * 0.001;
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

    this.eeLen = frames.ee_len;
    this.initEeDrag();

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

  // version cache-busts the fixed-URL meshes (see vite.config.ts)
  async load(
    baseUrl: string,
    version: string,
    onProgress: (msg: string) => void,
  ): Promise<void> {
    const loader = new ThreeMFLoader();
    await Promise.all(
      Object.entries(this.bodyParents).map(async ([body, parent]) => {
        const group = await loader.loadAsync(`${baseUrl}${body}.3mf?v=${version}`);
        fixMaterials(group);
        const refs = new Map<string, PartRef>();
        this.cost[body] = measure(group, refs);
        this.refs[body] = refs;
        parent.add(group);
        if (body === 'ee') this.eeBody = group;
        onProgress(body);
      }),
    );
  }

  // Live per-frame cost. renderer.info counts what the last render()
  // actually submitted — after frustum culling — so it moves with the
  // pose and the camera, unlike the static per-body totals. `frame` is
  // the renderer's own frame counter — difference it over wall time for FPS.
  frameCost(): { calls: number; triangles: number; frame: number } {
    const r = this.renderer.info.render;
    return { calls: r.calls, triangles: r.triangles, frame: r.frame };
  }

  // Isolate one part: the selected color keeps exactly what the 3MF
  // shipped, every other material sinks halfway to the background AND
  // drops to 70% of its own opacity, so the rest of the arm reads as a
  // ghost you can see the selection THROUGH. Dimming the rest rather than
  // glowing the selection is what makes a part buried inside the arm (the
  // drums are, mostly) findable at all. null puts every material back —
  // color, brightness and opacity — to its export value.
  setHighlight(sel: { body: string; color: string } | null): void {
    this.highlighted = sel;
    const bg = this.scene.background as THREE.Color;
    for (const [body, refs] of Object.entries(this.refs)) {
      for (const [color, ref] of refs) {
        const lit = !sel || (sel.body === body && sel.color === color);
        for (const mesh of ref.meshes) {
          const mats = (
            Array.isArray(mesh.material) ? mesh.material : [mesh.material]
          ) as THREE.MeshPhongMaterial[];
          for (const m of mats) {
            const baseColor = m.userData.baseColor as THREE.Color;
            const baseOpacity = (m.userData.baseOpacity as number) ?? 1;
            m.color.copy(baseColor);
            m.opacity = lit ? baseOpacity : baseOpacity * DIM_OPACITY;
            if (!lit) m.color.lerp(bg, 0.5);
            // three draws opaque first, so the lit part is already in the
            // frame buffer by the time the ghosts blend over it
            const transparent = m.opacity < 1;
            if (m.transparent !== transparent) {
              m.transparent = transparent;
              m.needsUpdate = true;
            }
          }
        }
      }
    }
  }

  get highlight(): { body: string; color: string } | null {
    return this.highlighted;
  }

  // Unique vertices per part — what the 3MF actually stores, and what the
  // export's stats.json counts. The loader de-indexed the mesh, so the
  // only way back is to deduplicate positions, which costs a pass over
  // every vertex of the body. Done on demand (opening the overlay) rather
  // than at load, and cached: nobody should pay for it just to see the arm.
  partVertices(body: string): Map<string, number> {
    const hit = this.vertexCache[body];
    if (hit) return hit;

    const out = new Map<string, number>();
    for (const [color, ref] of this.refs[body] ?? []) {
      const seen = new Set<string>();
      for (const mesh of ref.meshes) {
        const pos = (mesh.geometry as THREE.BufferGeometry).getAttribute('position');
        if (!pos) continue;
        // exact: the loader copied these floats out of one shared array,
        // so a repeated vertex is bit-identical, not merely close
        for (let i = 0; i < pos.count; i++) {
          seen.add(`${pos.getX(i)},${pos.getY(i)},${pos.getZ(i)}`);
        }
      }
      out.set(color, seen.size);
    }
    this.vertexCache[body] = out;
    return out;
  }

  // Frame one part: bound its meshes in WORLD space (the body is posed, so
  // a local box would aim the camera at the wrong place), then pull back
  // along the CURRENT view direction, so the focus reads as a zoom rather
  // than a teleport.
  focusPart(body: string, color: string): void {
    const ref = this.refs[body]?.get(color);
    if (!ref?.meshes.length) return;

    // save the WIDE view, not the last part we flew to: hopping part to
    // part should still return to where the user was looking before any
    // of it, so only the first focus of a run records the pose
    if (!this.savedView) {
      this.savedView = {
        target: this.controls.target.clone(),
        position: this.camera.position.clone(),
      };
    }

    this.scene.updateMatrixWorld(true);
    const box = new THREE.Box3();
    for (const mesh of ref.meshes) box.expandByObject(mesh);
    if (box.isEmpty()) return;

    const center = box.getCenter(new THREE.Vector3());
    const radius = Math.max(box.getSize(new THREE.Vector3()).length() / 2, 0.02);
    // fit the part's bounding sphere in the vertical FOV, with room to spare
    const dist = (1.9 * radius) / Math.sin((this.camera.fov * DEG) / 2);
    const dir = this.camera.position.clone().sub(this.controls.target).normalize();
    this.tweenCamera(center, center.clone().addScaledVector(dir, dist));
  }

  // Back to the view we had before the first focusPart(). No-op if we
  // never flew anywhere, so an orbit the user did themselves is never
  // undone by closing the overlay.
  resetView(): void {
    const view = this.savedView;
    if (!view) return;
    this.savedView = null;
    this.tweenCamera(view.target, view.position);
  }

  // A short ease into the new camera pose. Snapping loses the user's
  // sense of where the part sits in the arm, which is the whole point.
  private tweenCamera(target: THREE.Vector3, position: THREE.Vector3): void {
    const t0 = performance.now();
    const fromT = this.controls.target.clone();
    const fromP = this.camera.position.clone();
    const step = () => {
      const k = Math.min((performance.now() - t0) / 450, 1);
      const e = k * k * (3 - 2 * k); // smoothstep
      this.controls.target.lerpVectors(fromT, target, e);
      this.camera.position.lerpVectors(fromP, position, e);
      if (k < 1) requestAnimationFrame(step);
    };
    step();
  }

  // Click-drag the end effector: grab it with a raycast, then slide
  // the tip target on a camera-facing plane through the grab point.
  // The pointer's 2 DOF are enough because IK projects the target
  // onto the arm's reachable envelope — orbit the camera to approach
  // from another direction. OrbitControls sleeps while dragging.
  private initEeDrag(): void {
    const el = this.renderer.domElement;
    const ndc = new THREE.Vector2();
    const plane = new THREE.Plane();
    const grabToTip = new THREE.Vector3();
    const hit = new THREE.Vector3();
    let dragging = false;

    const setRay = (ev: PointerEvent) => {
      ndc.set(
        (ev.clientX / window.innerWidth) * 2 - 1,
        -(ev.clientY / window.innerHeight) * 2 + 1,
      );
      this.raycaster.setFromCamera(ndc, this.camera);
    };
    const pick = (ev: PointerEvent): THREE.Intersection | null => {
      if (!this.eeBody) return null;
      setRay(ev);
      return this.raycaster.intersectObject(this.eeBody, true)[0] ?? null;
    };
    // the dragged tip = the ee flange center, ee_len out along the
    // wrist frame's +x (the IK target point in core/ik.ts)
    const tipWorld = (): THREE.Vector3 =>
      this.wristGroup.localToWorld(new THREE.Vector3(this.eeLen, 0, 0));

    el.addEventListener('pointerdown', (ev) => {
      const h = pick(ev);
      if (!h) return;
      dragging = true;
      this.controls.enabled = false;
      el.setPointerCapture(ev.pointerId);
      el.style.cursor = 'grabbing';
      grabToTip.copy(tipWorld()).sub(h.point);
      plane.setFromNormalAndCoplanarPoint(
        this.camera.getWorldDirection(new THREE.Vector3()),
        h.point,
      );
      this.onEeDragStart?.();
    });
    el.addEventListener('pointermove', (ev) => {
      if (!dragging) {
        el.style.cursor = pick(ev) ? 'grab' : '';
        return;
      }
      setRay(ev);
      if (!this.raycaster.ray.intersectPlane(plane, hit)) return;
      const mm = this.root.worldToLocal(hit.add(grabToTip).clone());
      this.onEeDrag?.({ x: mm.x, y: mm.y, z: mm.z });
    });
    const drop = (ev: PointerEvent) => {
      if (!dragging) return;
      dragging = false;
      this.controls.enabled = true;
      el.releasePointerCapture(ev.pointerId);
      el.style.cursor = '';
    };
    el.addEventListener('pointerup', drop);
    el.addEventListener('pointercancel', drop);
  }

  // Signs mirror assembly.scad: rz(yaw), ry(-shoulder), ry(elbow), ry(-wrist)
  setPose(pose: TwinPose): void {
    this.yawGroup.rotation.z = pose.yaw * DEG;
    this.shoulderGroup.rotation.y = -pose.shoulder * DEG;
    this.elbowGroup.rotation.y = pose.elbow * DEG;
    this.wristGroup.rotation.y = -pose.wrist * DEG;
  }
}
