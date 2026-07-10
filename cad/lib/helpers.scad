// Personal helper routines (house style for all OpenSCAD in this repo).
// Conventions:
//   tx/ty/tz(q)  translate along one axis; q may be a list -> replicate
//   txy/tyz/txz  translate in a plane by [a,b] or list of pairs -> replicate
//   rx/ry/rz(q)  rotate about one axis; list -> replicate
//   mx/my/mz(q)  mirror about one axis; list like [0,1] -> original + mirrored
//   cub(d, c)    cube with per-axis centering: 0 from origin, 1 centered,
//                -1 extending negative
//   sq(d, c, r)  2D analog of cub, optional corner radius r
//   hull_seq()   hull each adjacent pair of children (chained hulls)
// Prefer these over raw translate/rotate/mirror throughout.

module hull_seq()
  for (i=[0:$children-2]) hull() { children(i); children(i+1); }

module cub(d, c=[0, 0, 0])
  tx(c[0] == -1 ? -d[0] : c[0] ? -d[0]/2 : 0)
  ty(c[1] == -1 ? -d[1] : c[1] ? -d[1]/2 : 0)
  tz(c[2] == -1 ? -d[2] : c[2] ? -d[2]/2 : 0)
  cube(d);

module sq(d, c=[0, 0], r=0)
  tx(c[0] == -1 ? -d[0] : c[0] ? -d[0]/2 : 0)
  ty(c[1] == -1 ? -d[1] : c[1] ? -d[1]/2 : 0)
  if (r <= 0) { square(d); }
  else { hull() ty([r, d[1]-r]) tx([r, d[0]-r]) circle(r=r); }

module txy(q)
  if (is_list(q) && is_list(q[0])) for (qq=q) txy(qq) children();
  else translate([q[0], q[1], 0]) children();

module tyz(q)
  if (is_list(q) && is_list(q[0])) for (qq=q) tyz(qq) children();
  else translate([0, q[0], q[1]]) children();

module txz(q)
  if (is_list(q) && is_list(q[0])) for (qq=q) txz(qq) children();
  else translate([q[0], 0, q[1]]) children();

module tq(q, v)
  if (is_list(q)) for (qq=q) tq(qq, v) children();
  else translate(q*v) children();

module tx(q) tq(q, [1, 0, 0]) children();
module ty(q) tq(q, [0, 1, 0]) children();
module tz(q) tq(q, [0, 0, 1]) children();

module mq(q, v)
  if (is_list(q)) for (qq=q) mq(qq, v) children();
  else mirror(q*v) children();

module mx(q=1) mq(q, [1, 0, 0]) children();
module my(q=1) mq(q, [0, 1, 0]) children();
module mz(q=1) mq(q, [0, 0, 1]) children();

// generic rotation recursively expands q and rotates about v
module rq(q, v)
  if (is_list(q)) for (qq=q) rq(qq, v) children();
  else rotate(q*v) children();

// specific rotation about x, y, z for everyday convenience
module rx(q) rq(q, [1, 0, 0]) children();
module ry(q) rq(q, [0, 1, 0]) children();
module rz(q) rq(q, [0, 0, 1]) children();
