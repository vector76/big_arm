import { defaultParams, defaultPose, DesignParams, Pose } from '../core/params';

export interface AppState {
  params: DesignParams;
  pose: Pose;
}

export function defaultState(): AppState {
  return {
    params: structuredClone(defaultParams),
    pose: { ...defaultPose },
  };
}

// Parameter sets serialize into the URL so a configuration is shareable as
// a link. Unknown/missing fields fall back to defaults.
export function loadState(): AppState {
  const state = defaultState();
  const raw = new URLSearchParams(window.location.search).get('s');
  if (!raw) return state;
  try {
    const parsed = JSON.parse(decodeURIComponent(raw));
    deepMerge(state.params as unknown as Record<string, unknown>, parsed.params);
    deepMerge(state.pose as unknown as Record<string, unknown>, parsed.pose);
  } catch {
    // malformed link: keep defaults
  }
  return state;
}

export function saveState(state: AppState): void {
  const s = encodeURIComponent(JSON.stringify(state));
  window.history.replaceState(null, '', `?s=${s}`);
}

function deepMerge(target: Record<string, unknown>, source: unknown): void {
  if (typeof source !== 'object' || source === null) return;
  for (const [key, value] of Object.entries(source)) {
    if (!(key in target)) continue;
    const current = target[key];
    if (typeof current === 'object' && current !== null) {
      deepMerge(current as Record<string, unknown>, value);
    } else if (typeof value === typeof current) {
      target[key] = value;
    }
  }
}
