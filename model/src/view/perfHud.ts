import GUI from 'lil-gui';
import { BodyCost, TwinScene } from './twinScene';

// model/public/cad/stats.json, written by scripts/export-cad.mjs. `detail`
// is which fidelity the meshes were rendered at — it's shown in the HUD so
// that a SCREENSHOT of the stats says which render produced them, without
// which a before/after pair is just two pictures of an arm.
export interface CadStats {
  detail: 'twin' | 'print';
  bodies: Record<string, { triangles: number; vertices: number; bytes: number }>;
  budget: Record<string, number>;
}

// The mesh-cost inspector. The arm is FIVE rigid bodies today, but the
// real machine is many more moving parts and every one of them is redrawn
// every frame, so the thing worth watching is the triangle bill — not the
// frame rate on whichever dev box happens to be fast enough to hide it.
//
// Two levels. The BODY list is the standing readout: what each rigid body
// costs, and what the GPU actually drew last frame after culling. Click a
// body and the PART overlay opens: the same accounting one level down,
// per color() — which is per part, because export.scad's colors ARE the
// part semantics. Click a part and it is isolated in the scene AND flown
// to by the camera, one row lit at a time. That pairing is the point — a
// big number only means something once you can SEE which part it bought,
// which is how the
// drums' cable groove got caught costing 84% of `upper` to draw a feature
// that reads as a handful of pixels.
//
// Off by default; ?stats=1 or the panel's "mesh stats" switch turns it on.
export function initPerfHud(scene: TwinScene, gui: GUI, stats: CadStats | null): void {
  const bodies = Object.entries(scene.cost).sort(
    // biggest first — and the meshes load concurrently, so insertion order
    // is whichever fetch won the race; sorting also pins the table
    ([, a], [, b]) => b.triangles - a.triangles,
  );
  const total = bodies.reduce((n, [, c]) => n + c.triangles, 0);
  const budget = stats?.budget ?? null;

  const hud = el('div', 'perf');
  const parts = new PartsOverlay(scene);
  document.body.append(hud, parts.el);

  // the banner: which render these numbers came from
  if (stats) {
    const head = el('div', '', 'perf-head');
    const print = stats.detail === 'print';
    head.innerHTML =
      `<b>${print ? 'FULL' : 'twin'}</b> fidelity` +
      (print ? ' <span class="margin-bad">reference render</span>' : '');
    hud.append(head);
  }

  const table = el('table');
  const tbody = el('tbody');
  table.append(tbody);
  for (const [body, cost] of bodies) {
    const row = bodyRow(body, cost, total, budget?.[body]);
    row.addEventListener('click', () => parts.open(body, cost, hud));
    tbody.append(row);
  }
  const parts_n = bodies.reduce((n, [, c]) => n + c.parts.length, 0);
  const budgetTotal = budget
    ? Object.values(budget).reduce((a, b) => a + b, 0)
    : undefined;
  tbody.append(
    tr('perf-total', [
      td('total'),
      td(k(total), 'perf-num'),
      td(`${parts_n} parts`, 'perf-bar'),
      budgetPct(total, budgetTotal),
    ]),
  );

  // fps + post-cull cost, sampled on a timer rather than every frame —
  // reading renderer.info every frame would itself be part of the problem
  const live = el('div', '', 'perf-live');
  let last = scene.frameCost();
  let lastT = performance.now();
  const tick = (): void => {
    const now = performance.now();
    const f = scene.frameCost();
    const fps = ((f.frame - last.frame) * 1000) / (now - lastT);
    last = f;
    lastT = now;
    live.innerHTML =
      `<b>${fps.toFixed(0)} fps</b> · ${f.calls} draw calls · ` +
      `${k(f.triangles)} tris drawn`;
  };
  const timer = window.setInterval(tick, 500);
  tick();

  hud.append(table, live);

  const show = { stats: new URLSearchParams(window.location.search).has('stats') };
  const apply = (): void => {
    hud.classList.toggle('on', show.stats);
    if (!show.stats) parts.close();
  };
  gui.add(show, 'stats').name('mesh stats').onChange(apply);
  apply();

  window.addEventListener('beforeunload', () => window.clearInterval(timer));
  console.table(scene.cost);
}

// ---- the draggable per-part overlay ----

class PartsOverlay {
  readonly el = el('div', 'parts');
  private title = el('span', '', 'parts-title');
  private list = el('tbody');
  private body = '';
  // once the user has dragged the overlay it stays where they put it;
  // until then every open() re-anchors it above the stats window
  private moved = false;

  constructor(private scene: TwinScene) {
    const close = el('button', '', 'parts-close');
    close.textContent = '×';
    close.title = 'close';
    close.addEventListener('click', () => this.close());

    const bar = el('div', '', 'parts-bar');
    bar.append(this.title, close);
    const table = el('table');
    table.append(this.list);
    this.el.append(bar, table);
    dragBy(bar, this.el, () => {
      this.moved = true;
    });
  }

  open(body: string, cost: BodyCost, anchor: HTMLElement): void {
    // a body switch starts clean — the old body's part would otherwise
    // stay isolated with no lit row anywhere to say so
    this.scene.setHighlight(null);
    this.scene.resetView();

    this.body = body;
    this.title.textContent = `${body} — ${k(cost.triangles)} tris, ${cost.parts.length} parts`;
    this.list.replaceChildren();
    this.list.append(
      tr('parts-head', [
        td(''),
        td('part'),
        td('tris', 'perf-num'),
        td('verts', 'perf-num'),
        td('%', 'perf-num'),
        td(''),
      ]),
    );

    const verts = this.scene.partVertices(body);
    const top = cost.parts[0].triangles;
    for (const p of cost.parts) {
      const row = tr('parts-row', [
        td('', 'parts-swatch'),
        td(p.name, 'parts-name'),
        td(k(p.triangles), 'perf-num'),
        td(k(verts.get(p.color) ?? 0), 'perf-num'),
        td(`${((100 * p.triangles) / cost.triangles).toFixed(0)}%`, 'perf-num'),
        td('', 'perf-bar'),
      ]);
      (row.children[0] as HTMLElement).style.background = p.color;
      // bar scaled to the BIGGEST part, not the body total: the whole
      // point is the long tail, and against a 84% hog everything else
      // rounds to an empty cell
      (row.children[5] as HTMLElement).textContent = '█'.repeat(
        Math.max(1, Math.round((12 * p.triangles) / top)),
      );

      row.title = `isolate ${p.name} and fly the camera to it`;
      row.addEventListener('click', () => this.select(p.color));
      row.dataset.color = p.color;
      this.list.append(row);
    }

    this.el.classList.add('on');
    this.place(anchor);
    this.sync();
  }

  // One row at a time: selecting a part isolates it in the scene (every
  // other part fades) AND flies the camera to it, because a row is the
  // only handle the user has on a part that may be buried in the arm.
  // Clicking the lit row again drops the selection and pulls back out.
  private select(color: string): void {
    const on = this.scene.highlight;
    if (on && on.body === this.body && on.color === color) {
      this.scene.setHighlight(null);
      this.scene.resetView();
    } else {
      this.scene.setHighlight({ body: this.body, color });
      this.scene.focusPart(this.body, color);
    }
    this.sync();
  }

  // mark whichever row is currently isolated
  private sync(): void {
    const on = this.scene.highlight;
    for (const row of this.list.querySelectorAll<HTMLElement>('.parts-row')) {
      const lit = !!on && on.body === this.body && on.color === row.dataset.color;
      row.classList.toggle('lit', lit);
    }
  }

  // Park the overlay directly above the stats window it was opened from:
  // right edges flush, sitting on top of it. Both panels then read as one
  // stack in the corner, and the arm keeps the rest of the viewport.
  private place(anchor: HTMLElement): void {
    if (this.moved) return;
    const r = anchor.getBoundingClientRect();
    this.el.style.left = 'auto';
    this.el.style.top = 'auto';
    this.el.style.right = `${Math.max(8, window.innerWidth - r.right)}px`;
    this.el.style.bottom = `${Math.max(8, window.innerHeight - r.top + 8)}px`;
  }

  close(): void {
    this.el.classList.remove('on');
    this.scene.setHighlight(null);
    this.scene.resetView();
  }
}

// Drag `panel` by its `handle`, calling `onMove` the first time a drag
// actually starts. The panel is laid out from an edge in CSS; the first
// drag pins it to left/top so the delta means one thing.
function dragBy(handle: HTMLElement, panel: HTMLElement, onMove: () => void): void {
  let x0 = 0;
  let y0 = 0;
  let left = 0;
  let top = 0;

  handle.addEventListener('pointerdown', (ev) => {
    // The close button lives IN the handle. Capturing the pointer here
    // would retarget the pointerup to the bar, so the browser would fire
    // the click on the bar as well — and the close button would never
    // see it. Let buttons keep their own pointer.
    if ((ev.target as HTMLElement).closest('button')) return;

    const r = panel.getBoundingClientRect();
    left = r.left;
    top = r.top;
    x0 = ev.clientX;
    y0 = ev.clientY;
    panel.style.left = `${left}px`;
    panel.style.top = `${top}px`;
    panel.style.right = 'auto';
    panel.style.bottom = 'auto';
    handle.setPointerCapture(ev.pointerId);
    handle.classList.add('dragging');
    onMove();
  });
  handle.addEventListener('pointermove', (ev) => {
    if (!handle.hasPointerCapture(ev.pointerId)) return;
    // keep the handle on screen whatever the pointer does
    const w = panel.offsetWidth;
    const x = clamp(left + ev.clientX - x0, 8 - w + 60, window.innerWidth - 60);
    const y = clamp(top + ev.clientY - y0, 8, window.innerHeight - 32);
    panel.style.left = `${x}px`;
    panel.style.top = `${y}px`;
  });
  const drop = (ev: PointerEvent): void => {
    if (handle.hasPointerCapture(ev.pointerId)) handle.releasePointerCapture(ev.pointerId);
    handle.classList.remove('dragging');
  };
  handle.addEventListener('pointerup', drop);
  handle.addEventListener('pointercancel', drop);
}

// ---- tiny DOM helpers ----

const clamp = (n: number, lo: number, hi: number): number =>
  Math.min(Math.max(n, lo), hi);

const k = (n: number): string => `${(n / 1000).toFixed(1)}k`;

function el<K extends keyof HTMLElementTagNameMap>(
  tag: K,
  id = '',
  cls = '',
): HTMLElementTagNameMap[K] {
  const node = document.createElement(tag);
  if (id) node.id = id;
  if (cls) node.className = cls;
  return node;
}

function td(text: string, cls = ''): HTMLTableCellElement {
  const cell = el('td', '', cls);
  cell.textContent = text;
  return cell;
}

function tr(cls: string, cells: HTMLTableCellElement[]): HTMLTableRowElement {
  const row = el('tr', '', cls);
  row.append(...cells);
  return row;
}

function bodyRow(
  body: string,
  cost: BodyCost,
  total: number,
  budget?: number,
): HTMLTableRowElement {
  return tr('perf-row', [
    td(body),
    td(k(cost.triangles), 'perf-num'),
    td('█'.repeat(Math.max(1, Math.round((14 * cost.triangles) / total))), 'perf-bar'),
    budgetPct(cost.triangles, budget),
  ]);
}

// Spend against the triangle budget, reusing the calculator's margin
// colors: green under, amber close, red over. In a print-fidelity render
// every row goes red — which is exactly the picture worth screenshotting.
function budgetPct(tris: number, budget?: number): HTMLTableCellElement {
  if (!budget) return td('');
  const pct = (100 * tris) / budget;
  const cls = pct > 100 ? 'margin-bad' : pct > 85 ? 'margin-thin' : 'margin-good';
  return td(`${pct.toFixed(0)}%`, `perf-num ${cls}`);
}
