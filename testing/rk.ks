parameter tf is 180.


clearscreen.
clearvecdraws().
runoncepath("./libraries/libs.ks").


local t0 is time:seconds.
local r0 is -body:position.
local v0 is velocity:orbit.
local dt is t0 + tf.
local posat is positionat(ship, dt) - body:position.
local velat is velocityat(ship, dt):orbit.


set t0 to time:seconds.
local rka_test is math:integrate(r0, v0, tf, math:rka@, tf/4).
print "TIME: " + round(time:seconds - t0, 2) + " s" at (0,6).
print "POS ERROR: " + round((posat - rka_test:r):mag, 2) + " m" at (0,7).
print "VEL ERROR: " + round((velat - rka_test:v):mag, 2) + " m/s" at (0,8).


// set t0 to time:seconds.
// local rk4_test is math:integrate(r0, v0, tf, math:rk4@).
// print "TIME: " + round(time:seconds - t0, 2) + " s" at (0,6).
// print "POS ERROR: " + round((posat - rk4_test:r):mag, 2) + " m" at (0,7).
// print "VEL ERROR: " + round((velat - rk4_test:v):mag, 2) + " m/s" at (0,8).


// utilities:draw_vec({ return -body:position. }, { return body:position. }, rgb(1,1,1), "current").
// utilities:draw_vec({ return posat. }, { return body:position. }, helpers:cmy(0,1,0), "posat").
// utilities:draw_vec({ return rka_test:r. }, { return body:position. }, helpers:cmy(1,0,0), "rka").
// utilities:draw_vec({ return rk4_test:r. }, { return body:position. }, helpers:cmy(0,0,1), "rk4").


// until round(dt - time:seconds, 2) = 0 wait 0.
