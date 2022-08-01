// Extra-SOI Hohmann transfer injection. Assumes correct planetary phase angle, and angle to prograde.
// For transfers to bodies in your current SOI, see in_soi_inj().
function ex_soi_inj {
    parameter target_alt.

    set throt to 1.
    wait until orbit:eccentricity > 1. wait 1.

    until tens_round(orbit:nextpatch:apoapsis, 10) = tens_round(target_alt, 10) {
        set throt to neg_exp(orbit:nextpatch:apoapsis, 1, target_alt, 4E7).
        wait 0.
    }

    set throt to 0. wait 1.

    local ang_err is {
        return pi_vang(ap_vec(orbit:nextpatch),
            sun:position - body:position,
                obt_elm("h", orbit:nextpatch)).
    }.
    
    local ang_diff is ang_err().
    
    if ang_diff < 0 steer_to("rad").
    else steer_to("a_rad").

    until round(ang_diff) = 0 {
        set ang_diff to ang_err().
        set throt to 1 - gaussian(ang_diff, 1000).
        wait 0.
    }

    set throt to 0. wait 1.
}


// Intra-SOI Hohmann transfer injection.
// NOTE: ASSUMES CORRECT PHASE ANGLE.
// For interplanetary injections, see extra_soi_injection.
function intra_soi_injection {
    parameter target_param.

    steer_to("pro").
    local proceed_cond is { return orbit:hasnextpatch. }.
    local variable is { return orbit:nextpatch:periapsis. }.

    fractional_throttle(proceed_cond, variable, target_param).
}


// Orbital insertion. Decelerate until desired apoapsis reached.
function orbital_insertion {
    parameter target_param.

    steer_to("a_pro").
    local proceed_cond is { return orbit:eccentricity < 1. }.
    local variable is { return apoapsis. }.

    fractional_throttle(proceed_cond, variable, target_param).
}


function fractional_throttle {
    parameter proceed_cond, variable, target_param.

    set throt to 1.

    wait until proceed_cond().
    local xi is variable().
    local interval is abs(xi - target_param).

    until round(variable()) = target_param {
        local x is abs(xi - variable())/interval.
        set throt to 1 - x^10.
        wait 0.
    }

    set throt to 0.
}