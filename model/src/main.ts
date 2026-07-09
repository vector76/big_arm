import { summarize } from './core/summary';
import { buildPanel } from './view/panel';
import { renderReadout } from './view/readout';
import { ArmScene } from './view/scene';
import { loadState, saveState } from './view/urlState';

const state = loadState();
const scene = new ArmScene(document.getElementById('app')!);
const readout = document.getElementById('readout')!;

function update(): void {
  const summary = summarize(state.params, state.pose);
  scene.rebuild(state.params, state.pose, summary);
  renderReadout(readout, summary, state.pose);
  saveState(state);
}

buildPanel(state, update);
update();
