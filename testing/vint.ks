clearscreen.
clearvecdraws().
runoncepath("m.lib").

local t is 0.
local tar is latlng(0, -17).
// flight_vectors().

on t {
    local vint is integrate_v(state(), 0.5, 0.5).
    set t to vint[1].
    preserve.
}

local t is -1.

local state is { return lex("r", -body:position, "v", velocity:orbit). }.
local m is { parameter t. return mass - t*availablethrust/get_vex(). }.
local ag is {
    local st is state().
    return -(body:mu/st:r:mag^3)*st:r.
}.
local net_acc is {
    return ag() - state():v:normalized*(availablethrust/m(t)).
}.
local a_c is { return (2/t^2)*(tar:position + t*velocity:surface) + ag(). }.

draw_vec(a_c@).
draw_vec(net_acc@).

until false {   
    print t at (0,2).
    wait 0.
}
