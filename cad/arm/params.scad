// Full-arm CONCEPT model parameters. Deliberately coarse: correct major
// dimensions and architecture (v0 design point: 0.45 m links, ratios
// 60/150/90/40, counterweights), placeholder detail. Premises:
//   - plywood box-truss links, wide sections preferred
//   - ALL THREE pitch joints are PAIRED PRELOADED BEARING STATIONS
//     (see bearing_station.scad / joints.scad): internal preload loop,
//     wood never in a precision fit. At the wrist the fork nesting
//     flips (the EE straddles OUTSIDE the forearm) and green rides
//     the outer link, keeping the tail stack inside the forearm box
//   - the shoulder is the phase-1a capstan INVERTED: the sector is
//     fixed (integral with the left base board) and the drum/wheel/
//     motor ride the arm on a boom bent shoulder_bend up from
//     straight-back. The YAW is a single-stage herringbone ring:
//     printed gear segments on a doubled two-ply slew disc, driven
//     directly by the m2 8T pinion (the shoulder primary pinion).
//     Elbow + wrist drives are BEING OVERHAULED (the worm lean is
//     dropped — its motors outgrew the truss hollows). The WRIST
//     redesign has landed: a second herringbone primary + cable loop,
//     remote-mounted on the elbow-CW fin (see the wrist capstan drive
//     section below). The elbow still carries a bare station
//
// Y-LANE ZONING (why nothing collides), y in mm at the shoulder:
// truss chords 0..43, counterweight block 1..43 (bolted inboard of
// the boom plate's downward tail), link side plates 43..55 (the +y
// one grows the drive boom plate), then a 3 mm running gap — SAME as
// the elbow's, so ONE bearing-station design serves every joint.
// Static: base boards 58..70; the fixed sector band 58..94.3
// (wedge-backed printed segments on the left board's circular rim,
// r 213..240, FLUSH on the board's inner face and growing outboard —
// from the wrap math below: two ramped tracks, band + march + walls);
// green joint bushings + bolt heads |y| ~53..78 at
// the axis. Riding the arm — the drive stack is FLIPPED (wheel
// INBOARD): wheel + pinion 27..54, straddling the boom plate through
// its kidney cutout and stopping 4 short of the band/board face at
// 58; motor -30..18, its face on the printed inboard support slab,
// body pointing back into the arm side; drum 60..101 (grooved band
// 62..92 matching the sector tracks, r 242..270, then the outboard
// bearing boss); inboard housing (slab + kidney-tracing wall +
// bosses) 18..43; outboard housing 55..109 — its shear walls cross
// the band lane holding shoulder r >= 261, bridge plate 101..109.
// The joint-angle sensor is a camera
// on the arm (-56..-70 lane, r 92 about the axis) reading a printed
// scale strip on the sensor-board lobe rim (r 80).
// The radial rule that makes the lane crossings safe: every moving
// part that enters y > 55 clears the fixed band's crest (r 240) —
// the drum flanges, the lowest of them, pass 2.8 over it (r 242.4:
// the axis sits CLOSE IN so the take-off pull is mostly tangential)
// — and the base boards have no material beyond x = -80 up high,
// which is the only region the swept drive fan (base angles 105..225)
// reaches. The wheel/pinion/motor never enter y > 55: they dip to
// r 204, but only in |y| < 55, and the swept back fan holds no
// static material there (the boards own |y| >= 58) — at full-up the
// wheel's low point passes z ~159 and the motor's z ~140, far over
// the z 48 disc top.

ply_t = 12;

// ---- herringbone primary (6.375:1) ----
// drawn REAL everywhere (pinion.scad / gear_drum.scad on
// lib/gears.scad), so mesh and lane collisions in the concept are true
gear_module = 2;
pinion_teeth = 8;         // was 17, then 12: smaller pinion = bigger
                          // primary. Changed 12->8 in step with
                          // drum_eff_r x1.5 (sector_r ~ drum_eff_r *
                          // pinion_teeth, so the sector/board are
                          // EXACTLY unchanged) to fatten the core
gear_teeth = 51;
primary_ratio = gear_teeth / pinion_teeth;    // 6.375 (capstan joints)
pressure_angle = 20;
// Stub the 51T wheel's tips: full-addendum tips would gouge an 8T
// pinion's base-circle root at pa 20 (interference limit: wheel tip
// radius <= 52.0 mm at C = 59). At 0.45 the tips stop at 51.9 and the
// transverse contact ratio is ~1.07 — thin, but each herringbone half
// adds a full tooth pitch of face overlap, so coverage never gaps.
// The pinion keeps full addendum (its tip lands ~1.1 wide — printable);
// interference is one-sided.
wheel_addendum = 0.45;
helix_angle = 25;
// One whole tooth of helix phase per herringbone half (center to edge):
// systematic tooth errors average out at every rotation angle, and the
// extra width adds strength. ~27 mm at m2 / 25 deg.
gear_width = 2 * PI * gear_module / tan(helix_angle);
gear_backlash = 0;        // cut none in; set the mesh snug by press-and-clamp
cd = gear_module * (pinion_teeth + gear_teeth) / 2;   // center distance, 59
drum_eff_r = 10.125;      // cable CENTERLINE radius — sets the joint
                          // ratio, invariant to cable/groove changes.
                          // x1.5 with the 12T->8T pinion: the sector
                          // stays put while the core's groove-floor
                          // wall grows 0.95 -> 4.3 over the bore
                          // (~10x the torsional section for 1.5x the
                          // drum torque)
motor_w = 42.3;           // NEMA 17
motor_len = 48;
function sector_r(ratio) = ratio / primary_ratio * drum_eff_r;

// The slew RIM is a full-circle budget shared exactly between the gear
// band and the yaw angle strip (the pitch-axis sensing idiom brought
// down to the base: white band on the bare arc, base-fixed camera).
// The camera reads the strip over the WHOLE travel, so the bare arc
// must span travel + overshoot while the gear spans travel + mesh
// margin: travel = 180 - margin/end - overshoot/end. 180 -> 170 paid
// for the strip; trimming the old 10-deg/end mesh margin to 6 kept the
// cut that small (the herringbone contact patch spreads only ~1.7 deg
// each way at the 207 pitch radius — transverse action + half-chevron
// helix advance — so 6 still leaves ~2.5 backed teeth in reserve)
yaw_travel = 170;     // +-85, single-stage herringbone ring drive
yaw_disc_r = 200;     // slew disc: DOUBLED, two ply layers (24 thick)
yaw_pitch_r = yaw_disc_r + 7;   // gear-segment pitch radius; with the
                                // m2 8T pinion (pitch r 8) the yaw
                                // ratio is ~26:1 — plenty for a
                                // gravity-neutral vertical axis
yaw_seg_arc = yaw_travel + 12;  // segment arc: travel + 6/end mesh margin
yaw_strip_arc = 360 - yaw_seg_arc;  // 178 = travel + 4/end read
                                // overshoot — 15 mm at the r 214 crest,
                                // more than the shoulder's 10 deg buys
                                // at its r 81 lobe (the overshoot
                                // guards camera field of view, a
                                // length, not an angle)
yaw_lobe_r = yaw_pitch_r + 7 - 0.8;  // 213.2: the disc is NOT a plain
                                // circle — the bare arc bulges into a
                                // READOUT LOBE sized so the strip
                                // crest lands EXACTLY at the gear
                                // band's outer radius (214). The
                                // rotating rim presents ONE cylinder
                                // to the world, so a band/camera
                                // collision is geometrically
                                // impossible at any overtravel — the
                                // reading goes bad (camera sees gear)
                                // before anything can touch. Real
                                // tooth tips (yaw_pitch_r + m = 209)
                                // sit 5 inside; the 13-deep steps
                                // where lobe meets band double as
                                // azimuth registers for the end
                                // segments
shoulder_ratio = 150; shoulder_min = -20; shoulder_max = 100;  // capstan
elbow_travel = 135;   // downward bend only; drive TBD (redesign underway)
wrist_travel = 180;   // +-90; capstan drive, remote motor (below)

// ---- links ----
upper_len = 450;
upper_stub = 120;     // SHORT: just closes the box; the drive boom and
                      // counterweight take over behind the joint
upper_w = 110;        // arm box width: plates at 43..55 with the
                      // elbow-matching 3 mm gap to the boards; the
                      // flipped drive wheel (27..54) crosses the +y
                      // plate only inside the boom kidney cutout
fore_len = 450;
fore_w = 80;          // roots inside the upper arm's elbow fork

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

// ---- wrist / end effector ----
// The forearm's front end is a FULL CIRCULAR CAP about the wrist axis
// (the upper arm's elbow-fork idiom one joint down), and the END
// EFFECTOR is a U-fork OUTSIDE it: side plates in the upper arm's
// 43..55 lane (ee_w = upper_w), so the elbow's 3 mm running gap — and
// with it the one bearing-station design — repeats at the wrist.
// Station roles mirror the joint's nesting: pink + the tail stack
// (tee washer, jam nuts, bolt tail) ride the INNER forearm plates and
// hide inside the forearm box; green + bolt head go on the outer EE
// sides, where only the low flange stands proud. Bores follow: 15.5
// (pink's sleeve) in the forearm, 28.5 (green's snout) in the EE.
wrist_d = link_d(-fore_len);  // forearm depth at the wrist, ~99
ee_w = upper_w;               // EE fork width = upper arm width
ee_clear = 5;                 // forearm end to end-plate inner face: a
                              // SWEPT running clearance, so more than
                              // the 3 mm lateral gaps. The circular
                              // forearm end makes it pose-invariant —
                              // constant radius about the wrist axis
ee_len = wrist_d / 2 + ee_clear + ply_t;  // end plate FRONT face (~67);
                              // the tool flange centers here (the twin
                              // viewer's IK drag tip reads this)
ee_strap = 72;                // side strap depth forward of the cap
                              // disc: the strap edges leave the circle
                              // at azimuth +-46.7, keeping the rim
                              // circular through the wrist scale
                              // strip's 200-deg arc (+-90 travel + 10
                              // overshoot each end, camera dead-aft)

// ---- counterweights ----
// Shoulder: NO separate boom — the drive-boom plate (left side) is a
// SOLID FAN from the boom down past straight-back (arm angles
// 135..200, outer arc r 338), and the CW block bolts to its inboard
// face (y 1..43: inside the base boards; the flipped motor shares
// this lane at pin_a, ~240 in-plane mm away — no cohabitation).
// The block sits just BELOW the arm centerline (cw_bend is
// NEGATIVE): the drive stack's mass rides above the centerline, so
// the closing weight must hang under it for the combined CG to land
// on the shoulder axis. Fan + block are travel-capped: over the full
// pose range the lowest sweep passes z 54+ over the z 48 disc top,
// and at full-up everything stays x <= 124 off the x 130 front-board
// face (the fan's lower corner slides down parallel to it). The block
// (a stand-in shape) bottoms at z 67, 8 over the hub pillar's bolt
// tip. Sized
// ~1.06 kg.m: the ~1.2 needed less what the motor + wheel + drum
// already contribute at r 256..315.
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
// ---- elbow fold clearance (the upper arm's bottom, behind the joint) ----
// At FULL BEND (135) the folded forearm's bottom face lies on the
// 45-deg plane tangent to the r = elbow_d/2 circle about the elbow
// (its bottom edge runs elbow_d/2 below the folded axis; the taper
// only ever adds clearance, so elbow_d/2 is the conservative radius).
// The upper arm's bottom chord used to cross that plane ~150 behind
// the joint: it is now cut STRAIGHT (square plank end, box_truss
// bot_short) where its lowest corner reaches the fold_gap offset
// plane, and a diagonal CROSS BOARD between the side plates lies ON
// that offset plane — parallel to the folded forearm, fold_gap clear
// — restoring the box closure the chord cut opened (the plates are
// solid through that whole zone, so the board lands on solid wood).
// Sweep check: the forearm root's chamfer corner passes r 67.1 vs the
// plane's 74, so nothing folding gets closer than ~7.
fold_gap = 8;
fold_off = elbow_d / 2 + fold_gap;              // offset plane, 74
fold_cut = (elbow_d / 2 + sqrt(2) * fold_off)   // chord setback behind
           / (1 - tan(arm_taper));              // the elbow, 177

cw_bend = -2;                  // deg above straight-back: NEGATIVE =
                               // 2 deg below the centerline
cw_r = 265;                    // block center; worst corner sweeps 325
cw_mass = [110, 42, 110];      // ~4.0 kg steel, 42 across y
elbow_cw_x0 = -252;            // boom tail; hook and block hang there
elbow_cw_blk = [70, 40, 80];   // placeholder block, center near the axis
                               // line. TEMPORARILY NOT DRAWN: the wrist
                               // drive stack (~0.6 kg) now rides the
                               // enlarged fin above the axis line, so
                               // block, dog-leg and fin outline all get
                               // resized together at the next mass
                               // audit (re-add + trim)
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
//     r 161 vs the pinion's 215). The REST of the rim bulges into
//     the READOUT LOBE (yaw_lobe_r): white strip on its face, crest
//     flush with the gear band's outer radius, read by a base-fixed
//     camera at azimuth 135 — diametrically opposite the pinion, the
//     only heading that stays on the strip at both extremes. With
//     the rim envelope one cylinder the camera can never be struck;
//     the lobe's own worst passes are the hold-down risers (6 off —
//     the same clearance the gear band always had) and the pinion
//     teeth at full travel (step corner 3.3 deg / ~12 mm off)
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
// into a torsion box with the disc as its floor. Rear HEELS on both
// side boards (third disc tab each; the left one notched around the
// drive-blade corridor) plus a perpendicular disc-tabbed GUSSET
// outboard of each board face (assembly.scad) brace the box against
// torsion and lateral racking above the front board's top edge.
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
// at arm angle 180 - shoulder_bend carries the whole stack — the
// wheel + pinion straddle it through its kidney cutout, the motor
// and the drum axle's wheel end hang on the printed inboard support,
// and a short printed bridge picks up the axle's boss end outboard,
// so the dead axle is simply supported. The bend is
// the packaging knob: at full-up the drive bottoms out at base angle
// 280 - shoulder_bend (225: the wheel's low point passes z ~159 over
// the z 48 disc top, the motor's z ~140), at full-down it parks
// up-back at 160 - shoulder_bend (105) where nothing lives. With the
// sector out of every arm plane, the bend is otherwise free.
// 45 -> 55: lifted the whole swept drive corridor 10 deg off the base
// woodwork — the blade corner that passed 5.6 off the boards' rear
// edge at full-up now stops at base angle ~241 (was ~251), well clear
// of the heels and rear gussets, and the sector arc rides up with it
// (base 100..230). The drive stack's CG rises with the bend, so
// re-check cw_bend/cw_mass at the next mass audit.
shoulder_bend = 55;

// ---- capstan stage (~23.5:1; total joint ratio 150) ----
capstan_ratio = shoulder_ratio / primary_ratio;  // 23.5
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
drum_core_d = 2 * (drum_eff_r - cable_d / 2 + groove_g);  // 20.35: the
                            // groove floor puts the centerline at eff_r
                            // (bend D at the centerline 20.25, D/d ~18)
drum_flange_d = 27.6;       // = the 22.1 bearing pocket + 2.75 walls;
                            // stands ~3 proud of the cable crest (21.4)
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
// lead angle atan(groove_p / (2*PI*drum_eff_r)) ~ 1.35 deg, so the free
// spans leave both surfaces square: zero fleet angle at every pose.
// (Assembly check — now DRAWN REAL and verified at the tangency: the
// groove is LEFT-hand. With the segments placed so run A's knot lands
// at the lower/gusset end, the winding sense forces the LH lay; the
// wrong hand puts the two helices in opposition, crossing the tracks
// at 2x the lead angle and doubling the fleet instead of killing it.)
travel_turns = (shoulder_max - shoulder_min) / 360 * capstan_ratio; // 7.8
dead_turns = 2.5;           // strain-relief margin, ~1.25 per run
band_w = (travel_turns + dead_turns) * groove_p; // 15.5: frozen band =
                                                 // track separation
ramp = travel_turns * groove_p;                  // 11.8: the march
drum_len = ceil(band_w + ramp + 2);              // 30: grooved core
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
          + 2 * seg_wall;                 // 36.3: full band width
function track_z(a, run) = band_z0 + band_wt / 2
  + run * band_w / 2 + ramp * a / (shoulder_max - shoulder_min);

// ---- axle & bearings ----
// the gear+drum spins on 608s pocketed into its ends (one into the
// wheel's inboard face, one into the outboard boss — both with a
// full-shoulder floor and an inner-race relief), riding a fixed M8
// dead axle simply supported between the printed inboard support
// slab and the printed outboard bridge, both hung off the boom plate
shaft_d = 8;                // M8 rod / bolt
bearing_w = 7;              // 608
bearing_pocket_d = 22.1;    // press fit; tune to printer

// ---- wrist capstan drive (~20:1; herringbone primary + cable loop) ----
// (Lives BELOW the capstan-stage and bearing sections: it reuses
// groove_p and bearing_w, and top-level variables don't forward-
// reference.) The shoulder's architecture relocated: a second 8T/51T
// herringbone primary (the shared pinion again) drives a FAT grooved
// capstan riding the enlarged elbow-CW fin behind the elbow, and two
// straight cable runs go forward along the +y side to a full-circle
// printed DRUM on the EE fork's left plate. Remote motor: its mass
// lands where counterweight was going anyway, the forearm nose stays
// bare, and nothing along the span moves relative to anything (drum,
// runs, capstan and motor all live on the forearm/EE pair — no
// idlers, no joint crossing). Margin: 0.41 x 19.9 x ~0.85 / 2.9 = ~2.4.
wr_drum_r = 50;       // cable CENTERLINE radius at the EE drum — the
                      // nose-cap radius (49.4), so the drum's crest
                      // pokes only ~2 proud of the link outline
wr_cap_r = 16;        // capstan centerline radius: core wall over the
                      // bore ~10 mm — nothing thin anywhere
wrist_ratio = primary_ratio * wr_drum_r / wr_cap_r;   // ~19.9
wr_axle = [-190, 150];       // capstan dead axle (forearm frame x,z):
                             // high on the fin — the wheel's low point
                             // (z 97.6) passes 22 over the upper arm's
                             // top chord at full extension (75.5)
wr_mesh_a = 215;     // pinion direction from the capstan axle, deg
                     // (180 = straight back). ROTATED DOWN past 180 to
                     // drop the motor — the heaviest piece — toward
                     // the forearm axis line: every mm of drive CG
                     // height is a mm the closing CW block must hang
                     // lower. Bound: the motor body's bottom must
                     // clear the fin's bottom-edge rule (taper line
                     // + 2) at full extension — at 215 the bottom
                     // passes z ~95 vs the line's ~77 at that x
                     // (~18 in hand; ~230 would spend it all)
wr_pin = wr_axle + cd * [cos(wr_mesh_a), sin(wr_mesh_a)];
// wrap bookkeeping — the shoulder's wrap math at wrist scale. The
// march is so short here (~2.3 mm over a ~650 mm span, ~0.2 deg of
// fleet) that the DRUM grooves stay PLAIN CIRCLES; only the capstan
// keeps the helical groove
wr_turns = wrist_travel / 360 * wr_drum_r / wr_cap_r;   // 1.56
wr_band = (wr_turns + 2.5) * groove_p;    // 6.1: frozen band = the
                                          // drum's groove separation
wr_ramp = wr_turns * groove_p;            // 2.3: the march
wr_cap_len = ceil(wr_band + wr_ramp + 2); // 11: grooved core
// LANES (+y side): the fin (28..40) hosts the stack exactly as the
// boom plate hosts the shoulder's — wheel + pinion straddle it
// through a kidney (27..54), grooved core out at the cable plane,
// bearing boss + bridge outboard. The cable plane hugs the WOOD:
// the only material in its way is the 55 outer face shared by the
// upper-arm fork plates (at the elbow) and the EE fork plates (at
// the wrist) — every piece of joint HARDWARE off those faces (green
// flanges r 24, screw heads r 23, bolt heads) is cleared RADIALLY,
// the runs' closest pass to either joint axis being ~75. So the
// first groove sits at 59: cord edge ~3.5 off the wood, and the
// groove mouth (+-2.2 at the crest) leaves a printable ~1.8 lip to
// the drum ring's inboard face. (The capstan's y is otherwise FREE:
// the axle is carried on both sides, so the band goes wherever the
// cable plane asks and the neck length absorbs the difference —
// wr_cab_y below ~59 would drive the neck negative into the wheel.)
wr_cab_y = 59;               // first groove centerline
wr_whl_y0 = 27;              // wheel inboard face (fin kidney idiom)
wr_core_y0 = wr_cab_y + wr_band / 2 - wr_cap_len / 2;   // 56.5
wr_y1 = wr_core_y0 + wr_cap_len + 2 + bearing_w;        // 76.5: part end
// the two runs are EXTERNAL COMMON TANGENTS of the drum and capstan
// circles (converging ~3 deg — belt-like); the common normal n makes
// angle acos((r2-r1)/d) with the center line, two signs = two runs
wr_span_phi = atan2(wr_axle[1], wr_axle[0] - fore_len);
wr_span_d = norm([wr_axle[0] - fore_len, wr_axle[1]]);
wr_span_gam = acos((wr_cap_r - wr_drum_r) / wr_span_d);
function wr_tan_n(s) = let (a = wr_span_phi + s * wr_span_gam)
  [cos(a), sin(a)];         // s = -1 upper run, +1 lower run
function wr_tan_p1(s) = [fore_len, 0] + wr_drum_r * wr_tan_n(s);
function wr_tan_p2(s) = wr_axle + wr_cap_r * wr_tan_n(s);
// the EE drum ring (wrist_drum.scad): one solid annulus seated on
// the EE plate's outer face (55), open center around the station's
// green flange (Ø48, r 24) and its screw heads (r 23) — the ring
// goes on after the joint is assembled
wr_hub_id = 58;
wr_screw_r = 41;             // 6 wood screws into the EE plate

// ---- the capstan lane on the arm ----
// FLIPPED STACK: the sector band is flush on the left board's inner
// face, growing outboard (58..94.3), and the drum's grooved core
// spans the same y so the shared two-track helix lines up (62..92).
// The WHEEL sits INBOARD of the band, straddling the boom plate
// through its kidney cutout; outboard, past the core's flange, the
// part ends in a bearing BOSS — free air where the wheel used to be,
// so BOTH ends take full 608 pockets (a gear-outboard stack jammed
// the free end against the boom plate, where a 608 pocket severed
// the core: pocket 22.1 vs core 20.4).
cab_y0 = col_w / 2 - ply_t;   // 58: band start = board inner face
cab_w = band_wt;              // 36.3
core_y0 = cab_y0 + 4;         // 62: grooved core start = the first
                              // track's V mouth (seg_wall inboard)
whl_y0 = core_y0 - 8 - gear_width;  // 27: wheel's inboard face; the 8
                              // = neck (6) + inboard flange (2)
drum_boss_l = bearing_w;      // 7: outboard bearing boss past the flange
drum_y1 = core_y0 + drum_len + 2 + drum_boss_l;  // 101: part's
                              // outboard end; bridge just past it

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
