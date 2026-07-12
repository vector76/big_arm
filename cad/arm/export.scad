// Mesh export for the three.js TWIN VIEWER (model/twin.html): emit ONE
// rigid body of the assembly per invocation, drawn in its OWN joint
// frame at zero pose — the viewer re-creates the kinematic tree from
// assembly.scad's top level and poses the meshes with the four joint
// angles alone. Driven by model/scripts/export-cad.mjs:
//
//   openscad -o build/upper.3mf -D group="upper" export.scad
//   openscad -o build/frames.echo -D group="frames" export.scad
//
// (3MF, not STL: the nightly's 3MF export carries the color() calls
// through as materials, and the color key IS part semantics here.)
//
// Groups = the rigid bodies between the pose transforms:
//   static — bench_env(): baseplate, hub, rollers, yaw pylon + motor
//   yaw    — slew_base(): disc + boards + fixed sector    [rz(pose_yaw)]
//   upper  — upper_arm() + elbow stations   [tz(shoulder_h) ry(-pose_shoulder)]
//   fore   — forearm()                      [tx(upper_len) ry(pose_elbow)]
//   ee     — end_effector()                 [tx(fore_len) ry(-pose_wrist)]
//   frames — no geometry: echoes the joint offsets, travel limits and
//            default pose as JSON (params.scad stays the source of
//            record; the viewer never duplicates these numbers)
//
// The ghosted (%) tool volume on the end effector is a reference
// envelope, not a part — background modifiers don't export.

group = "frames";

include <params.scad>
use <../lib/helpers.scad>
use <assembly.scad>

if (group == "static") bench_env();
else if (group == "yaw") slew_base();
// housings = false: the twin is an illustration — the printed drive
// covers would hide the gear mesh and capstan, so the viewer's mesh
// leaves the motor/wheel/drum floating on their stations
else if (group == "upper")
  { upper_arm(housings = false); tx(upper_len) elbow_stations(); }
else if (group == "fore") forearm();
else if (group == "ee") end_effector();
else if (group == "frames")
  echo(str("FRAMES=", "{",
    "\"shoulder_h\":", shoulder_h,
    ",\"upper_len\":", upper_len,
    ",\"fore_len\":", fore_len,
    ",\"ee_len\":", ee_len,
    ",\"plate_t\":", ply_t,
    ",\"yaw_travel\":", yaw_travel,
    ",\"shoulder_min\":", shoulder_min,
    ",\"shoulder_max\":", shoulder_max,
    ",\"elbow_travel\":", elbow_travel,
    ",\"wrist_travel\":", wrist_travel,
    ",\"pose\":{",
      "\"yaw\":", pose_yaw,
      ",\"shoulder\":", pose_shoulder,
      ",\"elbow\":", pose_elbow,
      ",\"wrist\":", pose_wrist,
    "}",
  "}"));
else assert(false, str("unknown export group: ", group));
