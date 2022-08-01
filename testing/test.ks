clearscreen.


function mean_anomaly {
    parameter t is time:seconds.
    local mean_motion is sqrt(body:mu / orbit:semimajoraxis^3).

    return constant:degtorad * orbit:meananomalyatepoch + mean_motion * (t - orbit:epoch).
}


function rad_cos {
    parameter x.
    return cos(constant:radtodeg*x).
}


function rad_sin {
    parameter x.
    return sin(constant:radtodeg*x).
}


function eccentric_anomaly {
    parameter t is time:seconds.

    local ecc is orbit:eccentricity.
    local M is { parameter t. return mean_anomaly(t). }.
    local E is M(t).
    local n is 0.

    until abs(E - ecc * rad_sin(E) - M(t)) < 1e-8 {

        set E to E - (E - ecc * rad_sin(E) - M(t)) / (1 - ecc * rad_cos(E)).
        set n to n + 1.
        wait 0.
    }

    print "n: " + n.

    return E.
}


local tf is time:seconds + 30.
local E0 is eccentric_anomaly(tf).
print "E0: " + E0.
wait until tf - time:seconds < 0.0001.
local EF is eccentric_anomaly().
print "EF: " + EF.
print "error: " + abs(E0 - EF)/EF.


// until false {
//     print(eccentric_anomaly()).
//     wait 0.
// }

// local orbital_elements is lex(
//     "r",    { return o:position - o:body:position.                          },
//     "v",    { return o:velocity:orbit.                                      },
//     "h",    { return vcrs(o:position - o:body:position, o:velocity:orbit).  },
//     "e",    { return o:eccentricity.                                        },
//     "nu",   { return o:trueanomaly.                                         },
//     "mu",   { return o:body:mu.                                             },
//     "soi",  { return o:body:soiradius.                                      },
//     "sma",  { return o:semimajoraxis.                                       },
//     "slr",  { return o:semimajoraxis*(1 - o:eccentricity^2).                },
//     "aop",  { return o:argumentofperiapsis.                                 }
// ).

// print orbital_elements:r().


// runoncepath("m.lib").

// global stg is get_stages().
// global throt is 0.
// global lock throttle to throt.

// // duna_comms_prep().
// // kuniverse:quicksaveto("CLV_008_DCP").
// comms_transfer_orbit().
// kuniverse:quicksaveto("CLV_009_CTO").
// // comms_sat_deploy().
// // deorbit().

// // Duna arrival comms transfer orbit
// function duna_comms_prep {
//     local t is time:seconds + eta:apoapsis - 80.
//     warpto(t). wait until time:seconds > t and kuniverse:timewarp:rate = 1.

//     steer_to("nml").

//     wait 5.
//     stage_jettison(stg["P0"]).
//     wait 1.
//     stage_jettison(stg["P1"]).
//     wait 5.
//     lights off.
// }

// // Establish transfer orbit.
// function comms_transfer_orbit {
//     // Change to 0° inclination.
//     print phase_angle("eq an").
//     print phase_angle("eq dn").

//     if phase_angle("eq an") < phase_angle("eq dn") local inc_type is "a_nml".
//     else local inc_type is "nml".

//     steer_to(inc_type).

//     if inc_type = "a_nml" coast_to_phz(phase_angle@:bind("eq an")).
//     else coast_to_phz(phase_angle@:bind("eq dn")).

//     obt_inc(inc_type).
    
//     steer_to("pro").
//     local n is ship:partstagged("SCV"):length().
//     local k is (n-1)/n.

//     local target_period is 2*k*constant:pi*sqrt((apoapsis + body:radius)^3/body:mu).
//     local target_pe is 2*((apoapsis + body:radius)*k^(2/3) - body:radius) - apoapsis.
//     local target_sma is (apoapsis + target_pe + 2*body:radius)/2.

//     ipu(2000).
//     until orbit:period >= target_period {
//         local dV is sqrt(body:mu * (2/(body:radius + apoapsis) - 1/target_sma)) - velocity:orbit:mag.
//         local r_0 is positionat(ship, time:seconds + burn_time(dv)/2) - body:position.
//         local x is half_vang(r_0, ap_vec(), specific_angular_momentum()).
//         print periapsis at (0,2).

//         set throt to neg_exp(orbit:period, 1, target_period, 100) * gaussian(x, 600).
//         wait 0. 
//     }
//     ipu().

//     print "".
//     print "".
//     print "target pe":padright(18) + target_pe.
//     print "actual pe":padright(18) + periapsis.
//     print "".
//     print "target period":padright(18) + target_period.
//     print "actual period":padright(18) + orbit:period.

//     set throt to 0. wait 1.
// }

// // Warp to next sat deployment.
// function comms_sat_deploy {
//     for sat in ship:partstagged("SCV") {        
//         local cpu is sat:getmodule("kOSProcessor").
        
//         if eta:apoapsis < 60 local t is (time:seconds + eta:apoapsis + orbit:period - 60).
//         else local t is time:seconds + eta:apoapsis - 60.
        
//         warpto(t). wait until time:seconds > t and kuniverse:timewarp:rate = 1.
//         steer_to("pro").
//         wait 5.

//         // set orbiter bootfile
//         set cpu:bootfilename to cpu:tag.
//         cpu:activate. wait 1.

//         wait until not ship:messages:empty.
//         ship:messages:clear().
//         wait 5.
//     }
// }

// // Deorbit.
// function deorbit {
//     steer_to("a_pro").
//     set throt to 1.
//     wait until periapsis < 0.
//     set throt to 0.
// }

//————————————————————————————————————————————————————————————————————————————————————————————————————————————————————//
//****************************************************** HOHMANN *****************************************************//
//————————————————————————————————————————————————————————————————————————————————————————————————————————————————————//

// // // Hohmann stuff

// // // // Raise or lower orbit to hohmann transfer with given dimensions. Circularizes if pe not given.
// // // // Note: parameters are in km.
// // // function hohmann {
// // //     parameter ap.
// // //     parameter pe is ap.

// // //     local r_0 is body:position:mag.
// // //     local r_1 is r_0 + 1000*ap.
// // //     local mu is obt_elm("mu").

// // //     local dv_1 is sqrt(mu/r_0) * (sqrt(2*r_1/(r_0 + r_1)) - 1).     // Δv to hohmann
// // //     local dv_2 is sqrt(mu/r_1) * (1 - sqrt(2*r_0/(r_0 + r_1))).     // Δv to circularize

// // //     if ap > apoapsis {
// // //         // warpto periapsis, steerto("pro"). set throt to gaussian(dv_1)
// // //     }
// // //     else if {
// // //         // warptp apoapsis
// // //     }

// // // }

//————————————————————————————————————————————————————————————————————————————————————————————————————————————————————//
//*************************************************** ISP/VE TEST ****************************************************//
//————————————————————————————————————————————————————————————————————————————————————————————————————————————————————//

// // clearscreen.

// // set config:ipu to 2000.
// // local tm is availablethrust * 1000.
// // local ve is get_vex().
// // local md is tm / ve.

// // print "md":padright(15) + md at (0,0).
// // print "ve":padright(15) + ve at (0,2).

// // until false {
// //     local tested_md is rate_of_change({ return 1000*ship:mass. }).
// //     local tested_ve is tm/tested_md.

// //     print "tested md":padright(15) + tested_md at (0,6).
// //     print "tested ve":padright(15) + tested_ve at (0,8).

// //     wait 0.
// // }

// // // Rate of change of some variable averaged across one physics 'tick'.
// // function rate_of_change {
// //     parameter var.

// //     local t_0 is time:seconds.
// //     local var_0 is var().

// //     wait 0.
    
// //     local t_1 is time:seconds.
// //     local var_1 is var().

// //     local d_var is (var_1 - var_0)/(t_1 - t_0).

// //     return d_var.
// // }

// // // Return effective exhaust velocity of currently active engine.
// // function get_vex {
// //     for part in ship:parts if part:tag:endswith("_E") if part:ignition {
// //         return part:isp*9.80665.
// //         break.
// //     }
// // }