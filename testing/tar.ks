clearscreen.
clearvecdraws().

// runoncepath("m.lib").

local tar is latlng(0, -17).

set tarvec to vecdraw(v(0,0,0), v(0,0,0), red, "", 1, true, 25).
set tarvec:startupdater to { return tar:altitudeposition(tar:terrainheight+tar:distance). }.
set tarvec:vecupdater to { return tar:position - tar:altitudeposition(tar:terrainheight+tar:distance). }.

vecdraw(v(0,0,0), { return tar:position. }, rgb(0,1,1), "tar", 1, true, 0.2).
vecdraw(v(0,0,0), { return velocity:orbit. }, rgb(1,0,1), "vel", 1, true, 0.2).
vecdraw(v(0,0,0), { return 10*vcrs(tar:position, velocity:orbit):normalized. }, rgb(1,1,0), "tar x vel", 1, true, 0.2).

// vecdraw(v(0,0,0), { return tar:position })







// until false {

// }
// global throt is 0.
// lock throttle to throt.

// function des_orbit_phasing {
//     steer_to("a_pro").
//     local ang_disp is descent_orbit_phase(5500).
//     coast_to_phz(phase_angle@:bind(latlng(0, -17 - ang_disp), 180)).
// }

// function des_orbit_insertion {
//     until round(periapsis, 0) = 5500 {
//         set throt to neg_exp(periapsis, -1, 5500, 4000).
//         wait 0.
//     }

//     set throt to 0.
//     systems:warp_to(eta:periapsis - 30).
//     steer_to("a_srf").
// }

// des_orbit_phasing().
// des_orbit_insertion().

// unlock steering.
// unlock throttle.

// local theta is { return constant:radtodeg*burn_disp(velocity:surface:mag, -1)/body:position:mag. }.
// local dist is { return abs(ship:geoposition:lng + 17). }.

// until false {
//     print "theta: " + theta() at (0,2).
//     print "dist: "  + dist() at (0,4).
//     wait 0.
// }