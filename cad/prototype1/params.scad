// Shared parameters for the Phase 1a shoulder drivetrain prototype:
// herringbone primary + capstan cable sector, mounted on a vertical-board
// pendulum test stand (arm travel -25..+95 deg from straight-down, so
// horizontal — max gravity torque — is covered).
// Total ratio = (z_gear/z_pinion) * (sector_eff_r/drum_eff_r)
//             = 4.25 * 35.3 = 150.

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
cable_d = 1.5;              // Dyneema
drum_core_d = 12;           // cable bend D/d = 8, fine for synthetic line
drum_eff_r = drum_core_d / 2 + cable_d / 2;      // 6.75 mm
sector_eff_r = capstan_ratio * drum_eff_r;       // 238.2 mm
sector_core_r = sector_eff_r - cable_d / 2;      // middle plywood layer radius
sector_angle = 130;         // deg of arc (120 travel + margin)
sector_core_t = 12;         // plywood, middle layer (cable rides its edge)
sector_flange_t = 6;        // plywood, outer flange layers
sector_flange_extra = 4;    // flange radius beyond cable surface
// Resident cable on the drum is nearly constant (one side pays off as the
// other winds on): full-travel turns = travel/360 * capstan_ratio (~11.8),
// plus dead wraps at the anchor and end margin.
drum_len = ceil(((travel_max - travel_min) / 360 * capstan_ratio + 2.5)
                * cable_d + 2);                  // 24 mm
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
sector_stack_t = sector_core_t + 2 * sector_flange_t;  // 24

// z stack, sector core mid-plane = 0: the gear sweeps under the sector
// (2 mm below the lower flange) and over the motor plate (4 mm), pinion
// z-aligned with the gear; the motor body hangs through the board cutout
// (~35 mm proud of the back face).
gear_top = -sector_stack_t / 2 - 2;
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
