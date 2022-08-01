clearscreen.
runoncepath("m.lib").

global stg is get_stages().
global throt is 0.
global lock throttle to throt.

set processor("SCV"):bootfilename to "".
processor("SCV"):doaction("open terminal", true).
wait 1.

local ship_name is ship:name.
deploy_sat(core:part).

function deploy_sat {
    parameter part.

    if part:tag = "SCV_D" {
        part:getmodule("moduledecouple"):doevent("decouple").
        return.
    }

    else if part:hasparent deploy_sat(part:parent).

    else {
        print "No decoupler found!".
        return 1/0.
    }
}

wait 1. set kuniverse:activevessel to ship. wait 5.

for part in ship:parts {
    if part:tag = core:tag + "_S" part:getmodule("KopernicusSolarPanel"):doevent("extend solar panel").
    else if part:tag = core:tag + "_A" part:getmodule("ModuleDeployableAntenna"):doevent("extend antenna").
    else if part:tag = core:tag + "_C" part:getmodule("ModuleReactionWheel"):doevent("toggle torque").
    else if part:tag = core:tag + "_E" part:activate().
}

wait 1.
steer_to("pro").
maneuver(
    { return orbit:eccentricity. },
    { return ap_vec(). },
    { return sqrt(body:mu/(body:radius + apoapsis)) - velocity:orbit:mag. },
    0.00000025,
    25000
).
wait 1.

vessel(ship_name):connection:sendmessage("ping").
set kuniverse:activevessel to vessel(ship_name).