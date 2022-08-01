parameter init is 0.
parameter breakpoint is 1000.

runoncepath("0:boot/import.ks").
global guidance is import("0:libraries/guidance.lib").
global navigation is import("0:libraries/navigation.lib").
global control is import("0:libraries/control.lib").
global systems is import("0:libraries/systems.lib").
global utilities is import("0:libraries/utilities.lib").
global helpers is import("0:libraries/helpers.lib").
global math is import("0:libraries/math.lib").

utilities:openterminal().
local runmode is import(core:tag).

for i in range(init, min(breakpoint, runmode:length())) {
    clearscreen.
    for k in runmode:keys print k:padleft(17).
    print core:tag + "_RUNMODE > " at (0, i).
    runmode:values[i]().
    utilities:save(core:tag + "_" + utilities:el_pad(i, 3, "0") + "_" + runmode:keys[i]).
}
