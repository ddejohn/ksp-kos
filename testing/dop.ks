runoncepath("m.lib").

clearscreen.
clearvecdraws().

global throt is 0.
global lock throttle to throt.


// Calculates how far from the target to place the descent transfer orbit periapsis
function descent_orbit_phase {
    parameter pe, state is 0.

    // Establish the target periapsis altitude.
    local pe is body:radius + pe.
    local ap is body:radius + apoapsis.

    // Determine the semi-major axis of the planned descent orbit.
    local sma is (ap + pe)/2.

    // Find the angle the body will rotate through
    // in the time it will take to reach periapsis. 
    local ttp is constant:pi*sqrt(sma^3 / body:mu).
    local phi is constant:radtodeg*body:angularvel:mag*ttp.
    
    // Get the velocity at the planned periapsis, and
    // the required delta-v from the current velocity.
    local vel_pe is sqrt(body:mu*(2/pe - 1/sma)).
    local srf_spd is body:angularvel:mag*pe.
    local dV is velocity:orbit:mag - vel_pe.
    local vex is get_vex().

    // Determine the mass of the lander after the deorbit burn.
    local mf is mass*(1000 - constant:e^(-dV/vex)).

    // Mass as a function of time.
    local mass_func is {
        parameter t.
        return mf/1000 - t*availablethrust/vex.
    }.

    // Establish hypothetical periapsis position and velocity vectors,
    // if initial state was not given.
    if state:istype("lexicon") {
        set r0 to (pe)*state:r:normalized.
        set v0 to (vel_pe-srf_spd)*state:v:normalized.
    }
    else {
        set r0 to (pe)*body:position:normalized.
        set v0 to (vel_pe-srf_spd)*(body:position:normalized*r(0,270,0)).
    }

    set state to lex("r", r0, "v", v0).

    // Integrate over the landing burn from the hypothetical state.
    // draw_vec({ return 1.25*r0. }, { return body:position. }).
    local deorbit_displacement is integrate_v(state, 5, 0.1, midpoint@, mass_func@)[0].
    // draw_vec({ return deorbit_displacement:r. }, { return body:position. }).


    // Angular displacement of landing burn.
    return list(vang(r0, deorbit_displacement:r), phi).
}

local tar is { return latlng(0, -17):position - body:position. }.
local sph is { return vcrs(body:position, velocity:orbit). }.
local opp is { return angleaxis(180, sph())*tar(). }.
local vecmag is body:position:mag.

set tarvec to vecdraw(
    { return body:position. },
    { return vecmag*tar():normalized. },
    red, "tar", 1, true, 0.2
).

set sphvec to vecdraw(
    { return body:position. },
    { return vecmag*sph():normalized. },
    green, "h", 1, true, 0.2
).

set oppvec to vecdraw(
    { return body:position. },
    { return vecmag*opp():normalized. },
    white, "opp", 1, true, 0.2
).

local disp is descent_orbit_phase(5500).
local phi is disp[1].
local theta is disp[0].

set apivec to vecdraw(
    { return body:position. },
    { return vecmag*(angleaxis(theta-phi, sph())*opp()):normalized. },
    rgb(1,0,1), "initial apoapsis", 1, true, 0.2
).

set apcvec to vecdraw(
    { return body:position. },
    { return vecmag*(angleaxis(theta, sph())*opp()):normalized. },
    rgb(0,1,1), "corrected apoapsis", 1, true, 0.2
).

set ppivec to vecdraw(
    { return body:position. },
    { return vecmag*(angleaxis(theta-phi, sph())*tar()):normalized. },
    rgb(1,0.5,0.5), "initial periapsis", 1, true, 0.2
).

set ppcvec to vecdraw(
    { return body:position. },
    { return vecmag*(angleaxis(theta, sph())*tar()):normalized. },
    rgb(1,1,0), "corrected periapsis", 1, true, 0.2
).

local deorbit_pos is {
    return body:position:mag*(angleaxis(theta-phi, sph())*opp():normalized).
}.

local deorbit_phz is { return tau_vang(deorbit_pos(), -body:position, sph()). }.

steer_to("a_pro").
coast_to_phz(deorbit_phz@, 0.1).

until round(periapsis, 0) = 5500 {
    set throt to neg_exp(periapsis, -1, 5500, 4000).
    wait 0.
}

set throt to 0.
systems:warp_to(eta:periapsis - 30).

unlock steering.
unlock throttle.

wait until eta:periapsis < 0.1.

// local state is lex(
//     "r", positionat(ship, time:seconds + eta:periapsis) - body:position,
//     "v", velocityat(ship, time:seconds + eta:periapsis):surface
// ).

// local disp is integrate_v(state:r, state:v, 5).

// set v1 to vecdraw(
//     { return body:position. },
//     { return 1.125*state:r. },
//     rgb(0,1,1), "", 1, true, 0.2
// ).

// set v2 to vecdraw(
//     { return body:position. },
//     { return 1.125*disp:r. },
//     rgb(1,1,0), "", 1, true, 0.2
// ).

runoncepath("tar.ks").

