// Shared parameters for the Phase 1a shoulder drivetrain prototype:
// herringbone primary + capstan cable sector.
// Total ratio = (z_gear/z_pinion) * (sector_eff_r/drum_eff_r)
//             = 4.25 * 35.3 = 150.
//
// The vertical-board PENDULUM TEST STAND these parts originally
// mounted to is SUPERSEDED — the drivetrain now gets tested on the
// real base + upper arm (see ../arm/testbench.scad), with the sector
// inverted onto the left base board. The stand's files (assembly,
// baseplate, arm, spacers, hub_tube) were removed; git history has
// them, and their rig/hub parameters below are retained because the
// surviving part files reference them.

// ---- herringbone primary (4.25:1) ----
gear_module = 2;
pinion_teeth = 12;        // was 17: bigger primary so the sector shrinks
gear_teeth = 51;
pressure_angle = 20;
// Stub the 51T wheel's tips: full-addendum tips would gouge a 12T
// pinion's base-circle root at pa 20 (interference limit: wheel tip
// radius <= 52.5 mm at C = 63). At 0.65 the transverse contact ratio is
// still ~1.3, and the herringbone face overlap adds a full tooth pitch
// on top, so coverage never gaps. The pinion keeps full addendum —
// interference is one-sided.
wheel_addendum = 0.65;
helix_angle = 25;
// One whole tooth of helix phase per herringbone half (center to edge):
// systematic tooth errors average out at every rotation angle, and the
// extra width adds strength. ~27 mm at m2 / 25 deg.
gear_width = 2 * PI * gear_module / tan(helix_angle);
gear_backlash = 0;        // cut none in; set the mesh snug by press-and-clamp
center_distance = gear_module * (pinion_teeth + gear_teeth) / 2; // 68 mm

// ---- motor (NEMA 17) ----
nema17_hole_spacing = 31;   // mm square
nema17_pilot_d = 22.3;      // boss diameter
nema17_body = 42.3;
motor_body_len = 47;
motor_shaft_d = 5;

// ---- arm travel (defined early: the capstan wrap math needs it) ----
// Arm angle theta measured from straight-down, + toward the open (+X)
// side. travel_max covers horizontal (sin = 1): tau = m*g*r, ~6.05 kg at
// the 450 mm hole = 26.7 N*m (worst-case shoulder). travel_min gives
// reverse-flank loading up to 42% torque.
travel_min = -25;
travel_max = 95;
travel_mid = (travel_min + travel_max) / 2;   // 35: rig tilt on the board

// ---- capstan stage (~35:1; total ratio fixed at 150) ----
total_ratio = 150;
primary_ratio = gear_teeth / pinion_teeth;       // 4.25
capstan_ratio = total_ratio / primary_ratio;     // 35.3
cable_d = 1.1;              // stiff aramid cord (nominal — measure the
                            // real spool and set groove_p from it)
// GROOVE PITCH MUST EXCEED THE GROOVE OPENING BY A PRINTABLE LAND —
// adjacent turns otherwise overlap and machine the lands away. Here
// p - w = 0.25: the land tip is ~a nozzle width and the rib widens
// toward its base, so it prints. (See drum_groove in gear_drum.scad
// for the OTHER groove pitfall: the twist-extrude cutter must be an
// arc-width crescent, not an offset circle.)
groove_p = 1.5;             // helical lay pitch: drum groove AND the
                            // sector track ramp share it (one helix)
// The DRUM groove is ROUND-BOTTOM: the cord seats on the floor, so
// the centerline radius — which sets the RATIO, and through it the
// registration between drum revs and the sector track stations — sees
// cord-diameter error only 1:1 (a V would amplify it ~1.4-2x). The
// SECTOR tracks are V's instead: their radius barely moves the ratio
// (238 vs 6.75 lever), and the segments print lying down, where a V
// is what keeps every overhang at 45 deg.
groove_w = cable_d + 0.15;  // drum groove width: snug, guides the lay
groove_g = 0.6;             // drum groove depth; land = p - w = 0.25
drum_eff_r = 6.75;          // cable CENTERLINE radius — this sets the
                            // ratio, invariant to cable/groove changes
drum_core_d = 2 * (drum_eff_r - cable_d / 2 + groove_g);  // 13.6: the
                            // groove floor puts the centerline at eff_r
                            // (bend D at the centerline 13.5, D/d ~12)
sector_eff_r = capstan_ratio * drum_eff_r;       // 238.2 mm
sector_angle = 130;         // deg of arc (120 travel + margin)
// Sector construction: the web is a plain CIRCULAR ply arc (in the arm
// it IS the left base board); printed L-SEGMENTS hang on it. The L's
// top arm — the track band — sits flush ON the rim, so cable tension
// presses printed part onto wood (the screws only locate); the leg
// drops down the OUTBOARD face and takes wood screws into the ply
// (through-bolts would poke into the 3 mm arm-side gap). Segments
// print lying on the flush face — the arc is then in the bed plane —
// so the track slots are 45-deg V's (self-centering, and every
// overhang is 45 deg except the one flat support plane under the leg,
// which can also be sliced away by swapping the leg for ribs + screw
// bosses at print time).
sector_core_t = 12;
seg_n = 3;                  // ~177 mm chord per print at 43.3 deg
seg_ang = sector_angle / seg_n;
seg_wall = 4;               // band wall beyond the outermost track's
                            // V MOUTH (~2.7 half-width at the crest)
v_half = 45;                // track V half-angle (>= 45: lying print)
track_seat = cable_d / 2 / sin(v_half);  // cord center above the apex
apex_r = sector_eff_r - track_seat;      // V apex radius (~237.4)
rim_r = apex_r - 2.2;                    // ply rim: 2.2 under the apex
crest_r = sector_eff_r + 1.4;            // cord captive by ~0.85
leg_t = 5;                  // leg plate on the outboard core face
leg_d = 22;                 // leg reach down that face
leg_screw_d = 3.6;          // wood screws, 3 per segment
leg_screw_r = rim_r - 13;   // screw circle radius
// WRAP MATH — the band MARCHES. The resident wraps between the two
// take-offs are frozen to the drum (no slip; the mid-anchor pins them),
// so every wrap the joint motion adds lands one pitch beyond the band
// edge: BOTH take-offs walk axially, one groove pitch per drum rev,
// while the anchor stays put mid-band. Deterministic and repeatable —
// the groove makes it exact — but the drum must be as long as the band
// PLUS its march, and the sector needs TWO tracks (one per run) at
// constant separation band_w, each ramping by `ramp` across the arc.
// Drum groove and sector tracks are one continuous helix at the shared
// lead angle atan(groove_p / (2*PI*drum_eff_r)) ~ 1.8 deg, so the free
// spans leave both surfaces square: zero fleet angle at every pose.
// (Assembly check: the drum groove HAND must match the track ramp
// direction — a left-hand groove with a right-hand ramp puts the two
// helices in opposition and doubles the fleet instead of killing it.)
travel_turns = (travel_max - travel_min) / 360 * capstan_ratio; // 11.8
dead_turns = 2.5;           // strain-relief margin, ~1.25 per run
band_w = (travel_turns + dead_turns) * groove_p; // 21.4: frozen band =
                                                 // track separation
ramp = travel_turns * groove_p;                  // 17.7: the march
drum_len = ceil(band_w + ramp + 2);              // 41 (the old formula,
                            // resident band only, missed the march)
// sector track stations: z in the core frame (web mid-plane = 0), a in
// deg from the arc bisector. The band is ONE-SIDED: it starts FLUSH at
// the core's arm-side face (band_z0) and grows outboard — in the arm,
// the left board's inner face stays clean and everything wide lives
// outboard. The tangent point sweeps 1 deg of arc per deg of joint, so
// the ramp completes over the TRAVEL span and the 5-deg end margins
// extend at the same slope to the anchors. Run A (run = -1) anchors at
// the -half end, run B (+1) at +half — the diagonal extremes; between
// them the tracks run parallel, band_w apart.
band_z0 = -sector_core_t / 2;             // the FLUSH (arm-side) face
band_wt = band_w + ramp * sector_angle / (travel_max - travel_min)
          + 2 * seg_wall;                 // ~43: full band width
function track_z(a, run) = band_z0 + band_wt / 2
  + run * band_w / 2 + ramp * a / (travel_max - travel_min);
drum_flange_d = drum_core_d + 14;

// ---- axle & bearings ----
// The gear+drum spins on 608s pressed into it, riding a fixed M8 bolt
// (dead axle) through the rig board. No pillow blocks.
shaft_d = 8;                // M8 rod / bolt
bearing_od = 22;            // 608
bearing_w = 7;
bearing_pocket_d = bearing_od + 0.1; // press fit; tune to printer
top_hub_d = 30;             // boss above the drum carrying the upper bearing
top_hub_h = bearing_w + 2;
drum_z_top = gear_width + 2 + drum_len + 2 + top_hub_h; // full gear+drum height

// ---- motor mount (rigid slotted plate) ----
// No flexure: the mesh is set by sliding the plate along its slots,
// pressing the gears together, and tightening. The motor plunges through
// a cutout in the board and hangs from the plate by its face screws, so
// the gear plane stays ~10 mm off the board and the dead axles see small
// cantilever moments. Plate is thin: every mm costs pinion engagement on
// the 24 mm motor shaft.
motor_plate = [88, 56];    // local x = mesh/slide direction (radial)
motor_wing = [30, 100];    // tangential wings centered at x = motor_wing_x
motor_wing_x = -7;
motor_plate_t = 6;
motor_slide = 3;           // mesh-adjust slide each way
// Foot slot centers: all four sit outside the big gear's plan shadow
// (gear axis is 68 toward -x, tip radius 53.5), so every bolt stays
// tool-accessible with the pinion pressed into mesh.
motor_feet = [[36, 20], [36, -20], [-8, 42], [-8, -42]];

// ---- drum bridge ----
// The gear+drum's dead axle is simply supported: a printed bridge spans
// it tangent to the sector arc and picks up the axle top; the axle nut
// on the bridge preloads the whole stack into one rigid column. Legs sit
// outboard of the tangent line through the drum axis because the cable
// runs leave the drum ~7 mm inboard of it.
bridge_half_span = 65;     // leg centers along the tangent (clears the gear)
bridge_leg = [16, 14];     // leg section: tangent x outboard
bridge_offset = 15;        // leg centerline, outboard of the drum axis
bridge_beam_t = 8;         // beam plate thickness
bridge_beam_d = 32;        // beam depth, outboard face to past the axle
bridge_foot_bolts = [13, 23];  // hole offsets along tangent past leg center

// ---- sector hub & pivot ----
// The sector pivots on two 608s in a printed tube through its bore (a plain
// ply-on-bolt pivot would add friction right where efficiency is measured).
// The arm bolts across the stack on the same 6-bolt circle.
sector_hub_r = 38;          // sector hub disc radius
spoke_w = 40;               // radial web connecting hub to arc
hub_bolt_r = 28;            // arm + layer-stacking bolt circle on the hub
hub_bolt_n = 6;
hub_bolt_d = 4.5;           // M4 clearance
hub_tube_od = 30;           // printed bearing tube through the sector stack
hub_tube_inboard = 8;       // tube extension past the inboard flange face
hub_tube_outboard = 6;      // past the outboard face; arm rides around it
hub_tube_bore = 13;         // between pockets; clears the inner-race spacer

// ---- rig geometry (pendulum test stand) ----
// Board coordinates: sector pivot at the origin, +Y up (gravity is -Y),
// +Z out of the board toward the mechanism. Arm travel is defined above
// the capstan section.
sector_stack_t = sector_core_t;   // single-ply core (12)

// z stack, sector core mid-plane = 0: the gear sweeps under the sector
// band (2 mm below its flush face) and over the motor plate (4 mm),
// pinion z-aligned with the gear; the motor body hangs through the
// board cutout (~35 mm proud of the back face).
gear_top = band_z0 - 2;
gear_z = gear_top - gear_width;
board_face_z = gear_z - 4 - motor_plate_t;
face_z = board_face_z;      // motor face = board face plane
board_t = 12;               // plywood

// Drum axis just beyond the sector rim, along the mid-travel arc bisector;
// pinion radially outboard of the drum (opposite the arc — the tangent
// sides belong to the bridge legs) at mesh center distance.
drum_dist = sector_eff_r + 25;
drum_pos = drum_dist * [-sin(travel_mid), cos(travel_mid)];
pinion_pos = (drum_dist + center_distance) * [-sin(travel_mid), cos(travel_mid)];

// ---- arm (CNC ply, bolts to the sector hub, weights hang in its holes) ----
arm_len = 480;
arm_root_r = 45;            // clamp disc over the sector hub
arm_tip_r = 18;
arm_center_hole_d = hub_tube_od + 4;  // clears the hub tube + axle nut washer
arm_hole_d = 8.5;           // S-hook / shackle holes
arm_holes = [for (r = [150 : 50 : 450]) r];

// ---- standoffs (printed spacer stacks, preloaded by the M8 axles) ----
standoff_flange_t = 5;
sector_standoff_od = 34;
sector_standoff_flange_d = 70;   // 4x M4 to the board at r=27
sector_standoff_bolt_r = 27;
drum_standoff_od = 26;
drum_standoff_flange_d = 56;     // 3x M4 at r=21, flat toward the pinion
drum_standoff_bolt_r = 21;
race_tip_d = 11;            // step that bears only on the 608 inner race
race_tip_h = 1.5;
axle_hole_d = 8.4;          // free fit on M8

// ---- travel stops / pivot bridge posts ----
// Two M8 posts with printed sleeves catch the sector spoke just past
// nominal travel — and, sitting at angles the arm and spoke can never
// sweep, they double as the legs of the pivot bridge: a CNC ply beam
// across their tops picks up the sector axle so it is simply supported
// (the arm hangs high loads on this joint, and lateral force would
// otherwise tilt a cantilevered axle). A printed pilot bushing drops
// from the beam to the outboard 608's inner race for light axial preload.
stop_sleeve_od = 18;
stop_r = 150;               // post radius from the pivot
stop_margin = 1;            // deg past nominal travel before contact
stop_beta = (travel_max - travel_min) / 2 + stop_margin
          + asin((spoke_w / 2 + stop_sleeve_od / 2) / stop_r);
pivot_beam_z = 30;          // beam underside: arm bolt heads top out at +28
pivot_beam_end_r = 30;      // beam blob radii: at the posts / over the pivot
pivot_beam_hub_r = 40;

// ---- board & base (CNC 12 mm ply) ----
board_x0 = -270;  board_x1 = 120;
board_y0 = -75;   board_y1 = 340;
board_corner_r = 10;
board_tab_w = 40;
board_tabs_x = [-160, -20, 60];
rig_base_w = 440;           // clamps flat to the bench, board at its front
rig_base_d = 250;
rig_base_x0 = -280;
rig_base_front_z = board_face_z + board_t;  // base front edge, 12 mm proud
                            // of the board face; extends back over the bench
gusset_x = [-230, 105];     // gusset center planes
gusset_h = 150;             // height above the base
gusset_d = 160;             // depth along the base

// ---- general ----
fit = 0.25;                 // printed hole/shaft clearance
$fn = 48;
