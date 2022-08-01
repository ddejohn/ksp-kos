function intra_soi_phasing {
    parameter target_body.

    local central_body is target_body:body.
    local origin_body is ship.

    local r1 is origin_body:position - central_body:position.
    local r2 is target_body:position - central_body:position.
    local norm is vcrs(r1, r2):normalized.

    local h_dat is hohmann(r1:mag, r2:mag, central_body:mu).

    // Delta-true_anomaly of target body over coast time, in degrees.
    local dNu is constant:radtodeg*h_dat:tof*(target_body:velocity:orbit:mag/r2:mag).
    
    // Injection position vector delegate.
    return {
        return r1:mag*(angleaxis(180-dNu, norm)*(r2:normalized)).
    }.
}


// Return a lexicon for hohmann transfer delta-V and time of flight.
function hohmann {
    parameter r1, r2, mu.

    local sma is 0.5*(r1 + r2).
    return lex(
        "dV", sqrt(mu/r1^2)*(sqrt(r2/sma) - 1),
        "tof", constant:pi*sqrt(sma^3/mu)
    ).
}



// function maneuver {
//     parameter kwargs is lex().

//     // 1. integrate over dV to get approximate angular displacement
//     // 2. offset burn start by displacement/2 around maneuver position vector
//     // 3. gaussian or fractional throttle
// }


// Draws a vector from tail to tip.
// vec_color is either an rgb() or cmy() object, but defaults to a random rgb().
// If tail and/or tip are delegates, they are used to update the vector.
function draw_vec {
    parameter tip, tail is v(0,0,0), vec_color is rgb(random(), random(), random()), label is "".

    local type is { parameter x. if x:istype("UserDelegate") return x(). else return x. }.
    local vec is vecdraw(type(tail), type(tip), vec_color, label, 1, true, 0.2).
    
    if tip:istype("UserDelegate") set vec:vecupdater to { return tip(). }.
    if tail:istype("UserDelegate") set vec:startupdater to { return tail(). }.
}


// Draws current foreward, normal, and radial FACING vectors.
function facing_vectors {
    draw_vec({ return ship:facing*r(0,0,270):vector*20. }, { return v(0,0,0). }, cmy(0,0,1), "facing fre").
    draw_vec({ return ship:facing*r(0,270,0):vector*20. }, { return v(0,0,0). }, cmy(0,1,0), "facing nrm").
    draw_vec({ return ship:facing*r(270,0,0):vector*20. }, { return v(0,0,0). }, cmy(1,0,0), "facing rad").
}


function cmy {
    parameter c, m, y, a is 1.
    return rgba(m + y, c + y, c + m, a).
}


facing_vectors().
draw_vec(intra_soi_phasing(mun), { return body:position. }, cmy(1,1,0)).

until false wait 0.
