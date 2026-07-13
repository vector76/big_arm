// Renders the OpenSCAD assembly into the meshes the twin viewer
// (twin.html) loads: one 3MF per rigid body plus frames.json with the
// joint offsets / travel limits / default pose, all echoed straight out
// of cad/arm/params.scad so nothing is duplicated here. Outputs land in
// model/public/cad/ (git-ignored — regenerate from source):
//
//   npm run export:cad         twin fidelity — what the viewer ships
//   npm run export:cad:full    full manufacturing fidelity, for comparison
//
// The twin renders with $twin = true (params.scad): features that exist
// to make a part WORK rather than to make it READ — the drums' helical
// cable groove, the involute flanks — get coarse tessellation, because on
// screen they are worth a handful of pixels and cost six figures of
// triangles. --detail=print turns that off and renders exactly what the
// printers get, so the two can be measured and screenshotted side by side.
// It is a REFERENCE render: it overruns the budget on purpose, and the
// viewer labels it, so nobody mistakes it for what gets deployed.
//
// OpenSCAD is found via the OPENSCAD env var, then PATH, then the
// nightly's default install location.
//
// Every render also reports its TRIANGLE BUDGET (see TRI_BUDGET): the
// twin draws the whole arm every frame, so a CAD edit that quietly
// tessellates a print feature into six figures of triangles is a
// rendering regression, and the cheapest place to catch it is here,
// where OpenSCAD already knows the count. Over budget = non-zero exit,
// so CI fails on the commit that caused it rather than months later on
// someone's laptop.

import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const modelDir = dirname(dirname(fileURLToPath(import.meta.url)));
const scad = join(modelDir, '..', 'cad', 'arm', 'export.scad');
const outDir = join(modelDir, 'public', 'cad');
mkdirSync(outDir, { recursive: true });

// --detail=twin (default) | print. `print` overrides export.scad's
// $twin = true, so the SAME assembly renders at manufacturing fidelity.
const arg = process.argv.slice(2).find((a) => a.startsWith('--detail='));
const detail = arg ? arg.slice('--detail='.length) : 'twin';
if (detail !== 'twin' && detail !== 'print') {
  console.error(`unknown --detail=${detail} (expected "twin" or "print")`);
  process.exit(2);
}
// -D wins over a top-level assignment, which is how `group` already works
const detailArgs = detail === 'print' ? ['-D', '$twin=false'] : [];

const candidates = [
  process.env.OPENSCAD,
  'openscad',
  'C:\\Program Files\\OpenSCAD (Nightly)\\openscad.exe',
  'C:\\Program Files\\OpenSCAD\\openscad.exe',
].filter(Boolean);
const openscad = candidates.find((c) => {
  try {
    execFileSync(c, ['--version'], { stdio: 'ignore' });
    return true;
  } catch {
    return c !== 'openscad' && existsSync(c);
  }
});
if (!openscad) {
  console.error('OpenSCAD not found; set the OPENSCAD env var to the exe.');
  process.exit(1);
}

const run = (args) =>
  execFileSync(openscad, args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });

// Per-body triangle ceilings, at TWIN fidelity ($twin in params.scad —
// export.scad renders the viewer's meshes with the manufacturing detail
// turned down; the print exports still get every flank and every turn of
// the drums' cable groove).
//
// These are a HIGH-WATER MARK, not a target: they sit ~20% above what the
// CAD renders today so that new detail trips the build, and they should
// be RATCHETED DOWN whenever a part gets cheaper. If a body blows its
// budget, the first question is whether the offending feature exists for
// MANUFACTURE, in which case it belongs behind $twin rather than in the
// viewer's meshes — that switch is what took this scene from 447k
// triangles to 99k with no visible change.
const TRI_BUDGET = {
  static: 13_000,
  yaw: 20_000,
  upper: 44_000,
  fore: 25_000,
  ee: 16_000,
};

const GROUPS = Object.keys(TRI_BUDGET);
const stats = {};
console.log(`rendering at ${detail.toUpperCase()} fidelity\n`);
for (const g of GROUPS) {
  const out = join(outDir, `${g}.3mf`);
  process.stdout.write(`rendering ${g}.3mf ... `);
  // --summary geometry costs nothing: OpenSCAD already has the counts
  const summary = run([
    '-o', out,
    '--backend', 'Manifold',
    '--summary', 'geometry',
    '--summary-file', '-',
    '-D', `group="${g}"`,
    ...detailArgs,
    scad,
  ]);
  const { facets, vertices } = JSON.parse(summary).geometry;
  stats[g] = { triangles: facets, vertices, bytes: statSync(out).size };
  console.log(`${facets.toLocaleString()} tris`);
}

// the stats land next to the meshes so the viewer's perf HUD can show what
// it is spending, and against which budget (see src/view/perfHud.ts). It
// carries `detail` so a screenshot of the HUD says which render it came
// from — the whole point of being able to render both.
const total = (k) => GROUPS.reduce((n, g) => n + stats[g][k], 0);
writeFileSync(
  join(outDir, 'stats.json'),
  JSON.stringify({ detail, bodies: stats, budget: TRI_BUDGET }, null, 2) + '\n',
);

const pct = (n, d) => `${((100 * n) / d).toFixed(0)}%`;
const tris = total('triangles');
console.log('\n  body      triangles   vertices        3MF   of budget');
for (const g of GROUPS) {
  const s = stats[g];
  console.log(
    `  ${g.padEnd(8)} ${s.triangles.toLocaleString().padStart(9)} ` +
      `${s.vertices.toLocaleString().padStart(10)} ` +
      `${(s.bytes / 1e6).toFixed(2).padStart(7)} MB ` +
      `${pct(s.triangles, TRI_BUDGET[g]).padStart(8)}`,
  );
}
console.log(
  `  ${'TOTAL'.padEnd(8)} ${tris.toLocaleString().padStart(9)} ` +
    `${total('vertices').toLocaleString().padStart(10)} ` +
    `${(total('bytes') / 1e6).toFixed(2).padStart(7)} MB\n`,
);

const over = GROUPS.filter((g) => stats[g].triangles > TRI_BUDGET[g]);
if (over.length && detail === 'print') {
  // the reference render is EXPECTED to blow the budget — that overrun is
  // the measurement, not a failure. Say so and carry on.
  console.log(
    `(print fidelity is ${(tris / total0(TRI_BUDGET)).toFixed(1)}x the twin's ` +
      `budget — that gap is what $twin buys. Not a failure: this render ` +
      `is for comparison, not for deploy.)\n`,
  );
} else if (over.length) {
  for (const g of over) {
    console.error(
      `OVER BUDGET: ${g} is ${stats[g].triangles.toLocaleString()} triangles, ` +
        `budget ${TRI_BUDGET[g].toLocaleString()}.`,
    );
  }
  console.error(
    '\nSimplify the offending part, or raise TRI_BUDGET in this script ' +
      'deliberately (and say why in the commit). If the feature exists for ' +
      'MANUFACTURE rather than to be seen, put it behind $twin instead.',
  );
  process.exit(1);
}

function total0(o) {
  return Object.values(o).reduce((a, b) => a + b, 0);
}

// frames.json: openscad evaluates export.scad's "frames" group, whose
// echo carries the JSON; .echo output goes to the file we then parse
const echoFile = join(outDir, 'frames.echo');
run(['-o', echoFile, '-D', 'group="frames"', scad]);
const { readFileSync, rmSync } = await import('node:fs');
const echo = readFileSync(echoFile, 'utf8');
rmSync(echoFile);
const m = echo.match(/^ECHO: "FRAMES=(.*)"\s*$/m);
if (!m) {
  console.error('FRAMES echo not found in OpenSCAD output:\n' + echo);
  process.exit(1);
}
const frames = JSON.parse(m[1]);
writeFileSync(join(outDir, 'frames.json'), JSON.stringify(frames, null, 2) + '\n');
console.log('frames.json:', JSON.stringify(frames));
