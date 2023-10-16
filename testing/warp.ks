// Time warp speed helper function. Uses the sum of offset sigmoids
// to create a continous "stair-step" function.  
function warp_help {
    // parameter x.

    local warp_steps is list(30, 90, 120, 180, 3600, 36000, 300000).
    local sig2 is {
        parameter x, a.
        local arg is min(100, -(x-a)).
        return round(1/(1 + constant:e^(arg))).
    }.

    return {
        parameter x.
        return sum(warp_steps, sig2@:bind(x)).
    }.
}


// Sum over an iterable. Can apply optional function f by passing in a delegate.
function sum {
    parameter itr, f is { parameter x. return x. }.
    local result is 0.
    for x in itr set result to result + f(x).
    return result.
}


function warp2 {
    parameter x.
    local rate is 7.
    local sig2 is {
        parameter a.
        local arg is min(100, x-a).
        return 1/(1 + constant:e^(arg)).
    }.

    for step in list(30, 90, 120, 180, 3600, 36000, 300000) {
        set rate to rate - round(sig2(step)).
    }

    return rate.
}


function sig {
    parameter x, a.
    local arg is min(100, -(x-a)).
    return 1/(1 + constant:e^(arg)).
}


function exp {
    parameter x.
    return constant:e^x.
}


function warp3 {
    parameter x.
    return round(1/(1+constant:e^(min(100, -(x-30)))) +
        1/(1+constant:e^(min(100, -(x-90)))) +
        1/(1+constant:e^(min(100, -(x-120)))) +
        1/(1+constant:e^(min(100, -(x-180)))) +
        1/(1+constant:e^(min(100, -(x-3600)))) +
        1/(1+constant:e^(min(100, -(x-36000)))) +
        1/(1+constant:e^(min(100, -(x-300000))))).
}



local x_steps is list(15, 45, 100, 150, 3000, 30000, 100000).
local new_warp is warp_help().
// local new_warp3 is warp3().

local t0 is time:seconds.
for x in x_steps {
    print new_warp(x).
}
print "new: " + (time:seconds - t0).


set t0 to time:seconds.
for x in x_steps {
    print warp2(x).
}
print "old: " + (time:seconds - t0).


set t0 to time:seconds.
for x in x_steps {
    print warp3(x).
}
print "explicit: " + (time:seconds - t0).






// Coast to desired phase angle.
function to_phz {
    parameter phz, thresh is 0.25.

    local warp_speed is 0.
    local tof is {
        local t is mod(orbit:trueanomaly + phz(), 360).
        return time_of_flight(t).
    }.

    on warp_speed {
        set kuniverse:timewarp:warp to warp_speed.
        if warp_speed > 0 preserve.
    }

    warp_to(tof() - 120).
    set kuniverse:timewarp:mode to "physics".

    until phz() < thresh and warp_speed = 0 {
        print kuniverse:timewarp:mode at (0,14).
        set warp_speed to helpers:phys_warp(tof()).
        wait 0.
    }
}


// Blocking warp. Program will not continue until warp is complete.
function warp_to {
    parameter t.
    local t is time:seconds + t.
    warpto(t).
    wait until time:seconds > t
        and kuniverse:timewarp:rate = 1
            and kuniverse:timewarp:issettled
                and ship:unpacked.
    wait 0.
}