clearscreen.

// Convert vang from [0, 180)° to (-180, 180]°. Requires vector normal to u and w BESIDES their cross product.
// NOTE: since only directions are needed, all vectors are normalized in order to avoid floating point errors.
function pi_vang {
    parameter u, w, norm.
    return dot_sign(norm:normalized, vcrs(u:normalized, w:normalized):normalized)*vang(u:normalized, w:normalized).
}


// Convert pi_vang from (-180, 180]° to [0, 360)°. Requires vector normal to u and w BESIDES their cross product.
function tau_vang {
    parameter u, w, norm.
    return mod(360 + pi_vang(u, w, norm), 360).
}


// Return 1 or -1 for vectors in the same or opposition directions, respectively.
function dot_sign {
    parameter u, w.
    local dot is vdot(u, w).
    return dot/abs(dot).
}


// Angular momentum vector of the given orbitable (defaults to ship).
function specific_angular_momentum {
    parameter obj is ship.
    local obj_position is obj:position - obj:body:position.
    local obj_velocity is obj:velocity:orbit - obj:body:velocity:orbit.
    return vcrs(obj_position, obj_velocity).
}


// Relative inclination with target orbit.
function relative_inclination {
    parameter tgt_obt.
    local ship_h is specific_angular_momentum().
    local tgt_h is specific_angular_momentum(tgt_obt).
    local hxh is vcrs(ship_h, tgt_h).
    return round(pi_vang(ship_h, tgt_h, hxh), 5).
}


print relative_inclination(vessel("SKS")).