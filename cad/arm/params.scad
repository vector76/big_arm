// Full-arm CONCEPT model parameters. Deliberately coarse: correct major
// dimensions and architecture (v0 design point: 0.45 m links, ratios
// 60/150/90/40, counterweights), placeholder detail. Premises:
//   - plywood box-truss links, wide sections preferred
//   - shoulder + elbow are PAIRED PRELOADED BEARING STATIONS (see
//     bearing_station.scad / joints.scad): internal preload loop, wood
//     never in a precision fit; wrist still a 608 dead-axle proxy
//   - the shoulder is the phase-1a capstan INVERTED: the sector is
//     fixed (integral with the left base board) and the drum/wheel/
//     motor ride the arm on a boom bent shoulder_bend up from
//     straight-back. The YAW is a single-stage herringbone ring:
//     printed gear segments on a doubled two-ply slew disc, driven
//     directly by the m2 12T pinion (the shoulder primary pinion).
//     Elbow + wrist drives are BEING OVERHAULED with something
//     different (the worm lean is dropped — its motors outgrew the
//     truss hollows); the model carries bare stations/axles at those
//     joints until the redesign lands
//
// Y-LANE ZONING (why nothing collides), y in mm at the shoulder:
// truss chords 0..43, counterweight block 1..43 (bolted inboard of
// the boom plate's downward tail), link side plates 43..55 (the +y
// one grows the drive boom plate), then a 3 mm running gap — SAME as
// the elbow's, so ONE bearing-station design serves every joint.
// Static: base boards 58..70; the fixed sector band 58..106.5
// (wedge-backed printed segments on the left board's circular rim,
// r 213..240, FLUSH on the board's inner face and growing outboard —
// from the wrap math below: two ramped tracks, band + march + walls);
// green joint bushings + bolt heads |y| ~53..78 at
// the axis. Riding the arm: drum 60..105 (grooved band matching the
// sector tracks, r 249..277), wheel + pinion 108.5..135.5 (outboard
// of the band's end), motor 56.5..104.5 sleeved off the boom plate
// with its face 4 under the gear plane (the old plunge idiom died
// when the stack moved outboard), bridge 137.5..145.5. The
// joint-angle sensor is a camera
// on the arm (-56..-70 lane, r 92 about the axis) reading a printed
// scale strip on the sensor-board lobe rim (r 80).
// The radial rule that makes the lane crossings safe: every moving
// part that enters y > 55 lives at r > 249 from the shoulder axis —
// outside the fixed band's crest (r 240) and wedge (r >= 213) — and
// the base boards have no material beyond x = -80 up high, which is
// the only region the swept drive fan (base angles 115..235) reaches.

ply_t = 12;

// ---- herringbone primary (4.25:1) ----
// drawn REAL everywhere (pinion.scad / gear_drum.scad on
// lib/gears.scad), so mesh and lane collisions in the concept are true
gear_module = 2;
pinion_teeth = 12;        // was 17: bigger primary so the sector shrinks
gear_teeth = 51;
primary_ratio = gear_teeth / pinion_teeth;    // 4.25 (capstan joints)
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
cd = gear_module * (pinion_teeth + gear_teeth) / 2;   // center distance, 63
drum_eff_r = 6.75;        // cable CENTERLINE radius — sets the joint
                          // ratio, invariant to cable/groove changes
motor_w = 42.3;           // NEMA 17
motor_len = 48;
function sector_r(ratio) = ratio / primary_ratio * drum_eff_r;

yaw_travel = 180;     // +-90, single-stage herringbone ring drive
yaw_disc_r = 200;     // slew disc: DOUBLED, two ply layers (24 thick)
yaw_pitch_r = yaw_disc_r + 7;   // gear-segment pitch radius; with the
                                // m2 12T pinion (pitch r 12) the yaw
                                // ratio is ~17:1 — plenty for a
                                // gravity-neutral vertical axis
yaw_seg_arc = yaw_travel + 20;  // segment arc: travel + mesh margin
shoulder_ratio = 150; shoulder_min = -20; shoulder_max = 100;  // capstan
elbow_travel = 135;   // downward bend only; drive TBD (redesign underway)
wrist_travel = 180;   // +-90; drive TBD (redesign underway)

// ---- links ----
upper_len = 450;
upper_stub = 120;     // SHORT: just closes the box; the drive boom and
                      // counterweight take over behind the joint
upper_w = 110;        // side plates clear the drive wheel (y 14..41) by 2
fore_len = 450;
fore_w = 80;          // roots inside the upper arm's elbow fork
ee_len = 90;

// ---- link taper ----
// Both links TAPER at the same angle and share the same depth at the
// elbow, so at full extension the top and bottom edges read as one
// continuous taper from the shoulder stub to the wrist. link_d() gives
// the local depth anywhere on that shared line (`back` = distance
// behind the elbow: positive up the upper arm, negative down the
// forearm). ANCHORED AT THE SHOULDER: the depth at the shoulder axis
// stays at the original 165 box depth, and the taper thins everything
// distal of it — elbow ~132, wrist ~99 (2.1 deg is what connects 165
// to ~100 over the 900 mm arm). The tapered hollows are a hard
// constraint on the elbow/wrist drive overhaul: the old worm motors
// outgrew them (one reason the worms were dropped).
shoulder_d = 165;     // depth at the shoulder axis (the original)
arm_taper = 2.1;      // deg per edge
elbow_d = shoulder_d - 2 * upper_len * tan(arm_taper);   // ~132
function link_d(back) = elbow_d + 2 * back * tan(arm_taper);

// ---- counterweights ----
// Shoulder: NO separate boom — the drive-boom plate (left side) is a
// SOLID FAN from the boom down past straight-back (arm angles
// 135..200, outer arc r 338), and the CW block bolts to its inboard
// face (y 1..43: inside the base boards, under the drum/motor/bridge
// lanes). The block sits just BELOW the arm centerline (cw_bend is
// NEGATIVE): the drive stack's mass rides above the centerline, so
// the closing weight must hang under it for the combined CG to land
// on the shoulder axis. Fan + block are travel-capped: over the full
// pose range the lowest sweep passes z 54+ over the z 48 disc top,
// and at full-up everything stays x <= 124 off the x 130 front-board
// face (the fan's lower corner slides down parallel to it). The block
// (a stand-in shape) bottoms at z 67, 8 over the hub pillar's bolt
// tip. Sized
// ~1.06 kg.m: the ~1.2 needed less what the motor + wheel + drum
// already contribute at r 263..326.
// Elbow: the LEFT forearm plate grows a FIN back over the elbow (one
// CNC piece with the plate; bottom edge 2 above the shared taper
// line, so it clears the upper arm's top chord at full extension and
// the down-only bend sweeps it up and away everywhere else). The CW
// itself stays CENTERED for lateral symmetry: a dog-leg hanger
// crosses from the fin's inboard face to the center plane and drops
// to the block, whose CG lies on the forearm axis extended back
// through the elbow — so the combined forearm+CW CG sits AT the
// elbow axis and gravity torque is zero at every pose. At FULL
// EXTENSION the hanger parks inside the upper arm through the
// centered slot in its top board (it enters nearly vertically: arc
// r ~245, vertical tangent at 0 deg).
cw_bend = -2;                  // deg above straight-back: NEGATIVE =
                               // 2 deg below the centerline
cw_r = 265;                    // block center; worst corner sweeps 325
cw_mass = [110, 42, 110];      // ~4.0 kg steel, 42 across y
elbow_cw_x0 = -252;            // boom tail; hook and block hang there
elbow_cw_blk = [70, 40, 80];   // placeholder block, center near the axis line
elbow_cw_slot = [88, 48];      // in the upper arm's top board only...
elbow_cw_slot_x = 205;         // ...centered at upper_len - 245

// ---- base: slew disc + THREE boards ----
// (0) the slew disc: a plain TWO-LAYER ply disc (24 thick) riding
//     bare-608 support rollers under its rim (stub axles at z 13 off
//     small blocks: crowns at 24 = the disc bottom, 2 mm of ground
//     clearance) and hold-downs over it — the roller ring reacts the
//     overturning moment. The hub is the joint bearing-station idiom
//     FLIPPED onto the baseplate (hub_station in joints.scad; the
//     annotated diagram is hub_station.scad): a preloaded 608 pair
//     locates the axis — and with it the yaw gear mesh — from a
//     broad flat-bottomed green cone held by 8 perimeter screws
//     (they carry the shear; nothing is pocketed into the plate),
//     its M3 head captive in a hex pocket backed by a diagonal lock
//     screw, NO through-hole, so the baseplate bottom stays flat for
//     clamping. The bearing rides high in the cone, so pink's
//     cantilever is short. The lower sheet takes pink's
//     flange; the upper sheet's 48 cutout swallows the mechanism,
//     leaving only a 16-dia pillar (washer + jam nuts + bolt tip)
//     11 proud of the disc top. Printed herringbone gear segments
//     wrap yaw_seg_arc of the rim; the motor hangs INVERTED from a
//     printed pylon at azimuth 315, pinion down over the full gear
//     band — out of every swept corridor (the arm's drive boom owns
//     azimuths 90..270 at full-up; the front board corners sweep
//     r 161 vs the pinion's 219)
// (1) LEFT (+y) board: grows the FIXED shoulder sector — one CNC ply
//     piece (or face-bolted stack), so joint torque grounds straight
//     into the base with no bracket or pylon
// (2) RIGHT (-y) board: near-twin of the left minus the sector; its
//     r 80 lobe rim carries a printed adhesive scale strip, read by a
//     high-res closeup camera riding the arm — optical, unloaded, no
//     drivetrain compliance in the measurement
// (3) FRONT board tying the two into a stiff U. With the sector static,
//     only the ARM truss sweeps the front: at shoulder_min its bottom
//     edge passes z~263 at the board plane (the taper is anchored at
//     the shoulder), top rises to 247.
//     The arm swings between the side boards (110 wide in a 116 gap).
// ALL THREE boards tab straight into the disc — mortises through both
// ply layers, panel shoulders landing on the disc top (no angle
// blocks); the front board runs disc-top-to-front_z1, closing the U
// into a torsion box with the disc as its floor.
base_plate = 520;
col_w = 140;          // side board spacing (inner faces at +-58: a
                      // 3 mm running gap to the arm plates, matching
                      // the elbow — one bearing-station design serves
                      // every joint)
shoulder_h = 392;     // the whole machine rode down 28 with the disc
front_x = 130;        // side boards' front edge; the front board spans it
front_z1 = 247;       // 16 mm under the truss bottom at shoulder_min
disc_z0 = 24;         // disc bottom = the support-608 crowns (stub
                      // axles at z 13, 2 mm ground clearance under
                      // each bearing); inverting the yaw motor freed
                      // the under-rim space that set the old height
roller_r = 185;       // support/hold-down roller stations

// ---- inverted shoulder capstan ----
// The sector is FIXED and coplanar/integral with the LEFT base board.
// The drive rides the ARM: a boom plate grown from the +y truss plate
// at arm angle 180 - shoulder_bend carries the drum dead axle and the
// sleeved motor; a printed bridge picks up
// both axle ends outboard so they are simply supported. The bend is
// the packaging knob: at full-up the drive bottoms out at base angle
// 280 - shoulder_bend (235: clear of the well between the boards), at
// full-down it parks up-back at 160 - shoulder_bend where nothing
// lives. With the sector out of every arm plane, the bend is
// otherwise free.
shoulder_bend = 45;

// ---- capstan stage (~35:1; total joint ratio 150) ----
capstan_ratio = shoulder_ratio / primary_ratio;  // 35.3
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
drum_core_d = 2 * (drum_eff_r - cable_d / 2 + groove_g);  // 13.6: the
                            // groove floor puts the centerline at eff_r
                            // (bend D at the centerline 13.5, D/d ~12)
drum_flange_d = drum_core_d + 14;
sector_eff_r = capstan_ratio * drum_eff_r;      // 238.2 = sector_r(150)
sector_angle = shoulder_max - shoulder_min + 10;  // 130: travel + margin

// Sector construction: the web IS the left base board (one CNC piece);
// printed WEDGE-BACKED segments hang on its circular rim. The track
// band sits flush ON the rim, so cable tension presses printed part
// onto wood; outboard of the board face — where there is no wood —
// the section fills SOLID from the band down past the rim to the leg:
// ample radial backing for the track loads. The leg lands on the
// OUTBOARD ply face and takes wood screws (through-bolts would poke
// into the 3 mm arm-side gap), each at the bottom of a DEEP
// COUNTERBORE reaching in from the wide outboard end face. Segments
// print INVERTED — that wide outboard face is the bed — with the arc
// in the bed plane: the 45-deg V tracks, the >= 45-deg wedge
// diagonal, and the up-facing leg land all print support-free.
sector_core_t = ply_t;      // the web = the board
seg_n = 3;                  // ~177 mm chord per print at 43.3 deg
seg_ang = sector_angle / seg_n;
seg_wall = 4;               // band wall beyond the outermost track's
                            // V MOUTH (~2.7 half-width at the crest)
v_half = 45;                // track V half-angle (>= 45: lying print)
track_seat = cable_d / 2 / sin(v_half);  // cord center above the apex
apex_r = sector_eff_r - track_seat;      // V apex radius (~237.4)
rim_r = apex_r - 2.2;                    // ply rim: 2.2 under the apex
crest_r = sector_eff_r + 1.4;            // cord captive by ~0.85
leg_t = 5;                  // leg plate on the outboard board face
leg_d = 22;                 // leg reach down that face
seg_back = 14;              // wedge depth below the rim at the
                            // outboard face — the inverted print bed
leg_screw_d = 3.6;          // wood screws, 3 per segment
leg_screw_r = rim_r - 10;   // screw circle: keeps the counterbore
                            // fully inside the wedge (seg_back 14)
cb_d = 7.5;                 // screw-head counterbore (heads ~7)

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
travel_turns = (shoulder_max - shoulder_min) / 360 * capstan_ratio; // 11.8
dead_turns = 2.5;           // strain-relief margin, ~1.25 per run
band_w = (travel_turns + dead_turns) * groove_p; // 21.4: frozen band =
                                                 // track separation
ramp = travel_turns * groove_p;                  // 17.7: the march
drum_len = ceil(band_w + ramp + 2);              // 41: grooved core
// sector track stations: z in the web frame (board mid-plane = 0), a
// in deg from the arc bisector. The band is ONE-SIDED: it starts FLUSH
// at the board's arm-side face (band_z0) and grows outboard. The
// tangent point sweeps 1 deg of arc per deg of joint, so the ramp
// completes over the TRAVEL span and the 5-deg end margins extend at
// the same slope to the anchors. Run A (run = -1) anchors at the -half
// end, run B (+1) at +half — the diagonal extremes; between them the
// tracks run parallel, band_w apart.
band_z0 = -sector_core_t / 2;             // the FLUSH (arm-side) face
band_wt = band_w + ramp * sector_angle / (shoulder_max - shoulder_min)
          + 2 * seg_wall;                 // 48.5: full band width
function track_z(a, run) = band_z0 + band_wt / 2
  + run * band_w / 2 + ramp * a / (shoulder_max - shoulder_min);

// ---- axle & bearings ----
// the gear+drum spins on 608s pocketed into its ends, riding a fixed
// M8 dead axle off the boom plate, simply supported by the bridge
shaft_d = 8;                // M8 rod / bolt
bearing_w = 7;              // 608
bearing_pocket_d = 22.1;    // press fit; tune to printer

// ---- the capstan lane on the arm ----
// The sector band is flush on the left board's inner face, growing
// outboard; the drum's grooved band spans the same y so the shared
// two-track helix lines up, and the wheel + pinion + bridge stack
// outboard of the band's end.
cab_y0 = col_w / 2 - ply_t;   // 58: band start = board inner face
cab_w = band_wt;              // 48.5
drum_l = drum_len + 4;        // 45: grooved core + flanges
whl_y0 = cab_y0 + cab_w + 2;  // 108.5: wheel/pinion plane, outboard
                              // of the fixed band's end

// ---- testbench (the assembly modules recomposed; testbench.scad) ----
// The REAL base + upper arm double as the shoulder test rig: the slew
// disc lies flat on the desk (desk top = disc_z0, so every part keeps
// its final-assembly coordinates), clamped dead; no forearm — weight
// plates ride BARBELL-STYLE on the ends of an M8 rod through the
// empty elbow pilot bores. Their CG sits exactly ON the elbow axis,
// which is a statically EXACT forearm stand-in (the elbow CW puts the
// forearm+CW CG there too), and they sweep only r ~67 about the axis
// in the empty |y| > 55 lane — clear of everything at every pose.
tb_desk = [900, 700, 25];
tb_clamp_az = [45, 135, 225, 315]; // hold-down bars; keep hardware off
                                   // the rim near azimuth 180, where
                                   // the CW sweep dips to z 54
tb_stack = 30;                     // plate stack per rod end: ~2 std
tb_plate_d = 134;                  // 2.5 kg plates each side, ~6 kg
                                   // total ~ the forearm assembly

// ---- pose ----
pose_yaw = 0;
pose_shoulder = 40;
pose_elbow = 70;      // 0..135 downward
pose_wrist = -10;     // +-90

$fn = 48;
