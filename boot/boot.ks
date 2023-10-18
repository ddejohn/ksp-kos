runoncepath("0:boot/import.ks").
global guidance is import("0:libraries/guidance.lib").
global navigation is import("0:libraries/navigation.lib").
global control is import("0:libraries/control.lib").
global systems is import("0:libraries/systems.lib").
global utilities is import("0:libraries/utilities.lib").
global helpers is import("0:libraries/helpers.lib").
global math is import("0:libraries/math.lib").

utilities:openterminal().
local flight_plan is import(core:tag).
local mission_log is "1:/" + core:tag:tolower() + ".json".

local init is 0.
local meta is lexicon().

if exists(mission_log) {
    print "loading mission log...".
    set meta to readJson(mission_log).
    print "current stage: " + meta["current_stage"].
    set init to flight_plan:keys:indexof(meta["current_stage"]).
} else {
    meta:add("launch_date", time).
    meta:add("current_stage", flight_plan:keys[0]).
}

for i in range(init, flight_plan:length()) {
    local current_stage is flight_plan:keys[i].
    set meta["current_stage"] to current_stage.
    writeJson(meta, mission_log).
    utilities:save(core:tag + "_" + current_stage).

    clearscreen.
    for k in flight_plan:keys print k:padleft(17).
    print core:tag + "_RUNMODE > " at (0, i).

    flight_plan:values[i]().
}
