// Renders the OpenSCAD assembly into the meshes the twin viewer
// (twin.html) loads: one 3MF per rigid body plus frames.json with the
// joint offsets / travel limits / default pose, all echoed straight out
// of cad/arm/params.scad so nothing is duplicated here. Outputs land in
// model/public/cad/ (git-ignored — regenerate from source):
//
//   npm run export:cad
//
// OpenSCAD is found via the OPENSCAD env var, then PATH, then the
// nightly's default install location.

import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const modelDir = dirname(dirname(fileURLToPath(import.meta.url)));
const scad = join(modelDir, '..', 'cad', 'arm', 'export.scad');
const outDir = join(modelDir, 'public', 'cad');
mkdirSync(outDir, { recursive: true });

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

const GROUPS = ['static', 'yaw', 'upper', 'fore', 'ee'];
for (const g of GROUPS) {
  const out = join(outDir, `${g}.3mf`);
  process.stdout.write(`rendering ${g}.3mf ... `);
  run(['-o', out, '--backend', 'Manifold', '-D', `group="${g}"`, scad]);
  console.log('done');
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
