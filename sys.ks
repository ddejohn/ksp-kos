global aux is "".
global hib is "".
global lts is "".
global ec is 0.

for res in ship:resources {
    if res:name = "ElectricCharge" {
        set ec to res.
        break.
    }
}

on ec:capacity { reboot. }
on ship:partstagged("AUX"):length() { reboot. }
on ship:partstaggedpattern("_[C]\z"):length() { reboot. }
on aux { print "AUX":padleft(6) + aux:padleft(11) at (0,3). preserve. }
on hib { print "HIB":padleft(6) + hib:padleft(11) at (0,4). preserve. }
on lts { print "LTS":padleft(6) + lts:padleft(11) at (0,5). preserve. }


sys_initialize().


// telemetry, maybe?
wait until false.


// Initialize terminal.
function sys_initialize {
    clearscreen.
    set processor(core:tag):bootfilename to "sys.ks".
    processor(core:tag):doaction("open terminal", true).

    wait 0.
    set terminal:width to 21.
    wait 0.
    set terminal:height to 7.

    print "---------------------".
    print "   SYS       STATE   ".
    print "---------------------".

    set aux to "OFF".
    set hib to "OFF".

    if ship:sensors:light = 0 {
        set lts to "ON".
        lights on.
    }
    else {
        set lts to "OFF".
        lights off.
    }

    sys_aux().
    sys_hib().
    sys_lts().
}


// Switches on fuel cells if power drops below 10%, and switches them back off above 90%.
function sys_aux {
    on ceiling(ec:amount / ec:capacity - 0.10) {
        set aux to "ON".
        for part in ship:partstagged("AUX") {
            part:getmodule("ModuleResourceConverter"):doaction("start fuel cell", true).
        }
        
        on floor(ec:amount / ec:capacity + 0.10) {
            set aux to "OFF".
            for part in ship:partstagged("AUX") {
                part:getmodule("ModuleResourceConverter"):doaction("stop fuel cell", true).
            }
            sys_aux().
        }
    }
}


// Hibernate all probe cores.
function sys_hib {
    on kuniverse:timewarp:warp {
        wait 1.
        if not kuniverse:timewarp:warp = 0 {
            set hib to "ON".
            for part in ship:partstaggedpattern("_[C]\z") {
                part:getmodule("modulecommand"):setfield("hibernation", true).
            }
        }
        else {
            set hib to "OFF".
            for part in ship:partstaggedpattern("_[C]\z") {
                part:getmodule("modulecommand"):setfield("hibernation", false).
            }
        }
        preserve.
    }
}


// Cabin lights on at night.
function sys_lts {
    on ceiling(min(ship:sensors:light, 1) - 0.10) {
        toggle lights.
        if lights set lts to "ON".
        else set lts to "OFF".
        preserve.
    }
}
