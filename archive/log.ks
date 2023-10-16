global pitch_vals is list().
global gndalt_vals is list().
global eta_vals is list().
global apo_vals is list().
global vert_vals is list().
global acc_vals is list().

wait until not (ship:status = "prelaunch").

until throttle = 0 {
    pitch_vals:add(vang(ship:facing:vector, up*r(0,270,0):vector)).
    gndalt_vals:add(altitude - geoposition:terrainheight).
    eta_vals:add(eta:apoapsis).
    apo_vals:add(apoapsis).
    vert_vals:add(verticalspeed).

    local v1 is verticalspeed.
    local t1 is time:seconds.
    wait 0.
    local v2 is verticalspeed.
    local t2 is time:seconds.

    local vert_acc is (v2 - v1)/(t2 - t1).

    acc_vals:add(vert_acc).
    
    wait 1.
}

for val in pitch_vals log val to pitch.txt.
for val in gndalt_vals log val to gndalt.txt.
for val in eta_vals log val to eta.txt.
for val in apo_vals log val to apo.txt.
for val in vert_vals log val to vert.txt.
for val in acc_vals log val to acc.txt.