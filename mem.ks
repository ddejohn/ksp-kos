{
    set processor("MEM"):bootfilename to "".


    function extraction_stability_mode {
        if not (body = mun) {
            wait until ship:crewcapacity = 2.
            wait 3.
            toggle ag3.
            wait 3.
            lock steering to "kill".
            wait until ship:partstagged("port")[0]:state:split(" ")[0] = "acquire".
            unlock steering.
            wait until ship:partstagged("port")[0]:state:split(" ")[0] = "docked".
        }
    }


    function sleep_mode {
        wait until ship:crewcapacity = 2.
        utilities:initialize().
        processor("MEM"):doaction("open terminal", true).
    }


    function des_prep {
        wait 1.
        lock steering to "kill".
        separate().

        wait 1.
        set kuniverse:activevessel to ship.
        wait 1.
        vessel(ship:name:split(" lander")[0]):connection:sendmessage("ping").
        wait 1.

        global throt is 0.
        global lock throttle to throt.

        ship:partstagged("MX_E")[0]:activate().

        systems:warp_to(eta:apoapsis - 30).
        systems:steer_to("pro").
        guidance:circularize(1e-7).

        toggle gear.
    }


    function des_orbit_phasing {
        local tar is latlng(0, -17).

        set tarvec to vecdraw(v(0,0,0), v(0,0,0), red, "", 1, true, 15).
        set tarvec:startupdater to {
            return tar:altitudeposition(tar:terrainheight+tar:position:mag/2).
        }.
        set tarvec:vecupdater to {
            return tar:position - tar:altitudeposition(tar:terrainheight+tar:position:mag/2).
        }.

        steer_to("a_pro").
        local ang_disp is navigation:descent_orbit_phase(5500).
        navigation:coast:to_phz(navigation:phase_angle@:bind(latlng(0, -17 - ang_disp), 180)).
    }


    function des_orbit_insertion {
        until round(periapsis, 0) = 5500 {
            set throt to neg_exp(periapsis, -1, 5500, 4000).
            wait 0.
        }

        set throt to 0.
        systems:warp_to(eta:periapsis - 90).
    }


    function braking_phase {
        lock steering to srfretrograde.

        local mem_engine is ship:partstagged("MX_E")[0].
        if not(mem_engine:ignition) mem_engine:activate().

        when eta:periapsis < 0.25 then {
            set throttle to 1.
        }

        until velocity:surface:mag < 25 {
            print geoposition:lng at (0,10).
            wait 0.
        }

        set throt to 0.
        unlock throttle.
        unlock steering.
    }


    // WTF IS THIS NONSENSE.
    function terminal_descent {
        if not(hastarget) set target to vessel("LZ1").

        local acc is td_acceleration_vector().
        local throt is 1.

        lock steering to acc.
        lock throttle to throt.
       
        until ship:status = "landed" {
            set shift to -42 / constant:e^(target:distance/120) + 44.
            set throt to 1/(1 + constant:e^(verticalspeed + shift)).
            
            if ship:altitude - geoposition:terrainheight < 5 set acc to up + r(0,0,270).
            else set acc to td_acceleration_vector().
            
            wait 0.
        }

        ship:partstagged("MX_E")[0]:shutdown().
        wait 5.
    }


    function srf_eva {
        wait until ship:crew:length() = 0.
        wait until ship:crew:length() = 1.
        wait 1.
    }


    function rvz_orbit_phasing {
        set target to vessel(ship:name:split(" lander")[0]).
    }


    function rvz_transfer_orbit {
        set pitch to 0.
        set throt to 0.
        lock throttle to throt.

        ship:partstagged("MX_E")[0]:activate().
        set throt to 1.

        steer_to("ascent").
        ascent(round(target:apoapsis), 1000).
    }


    function rvz_final_approach {

    }


    function jettison_module {

    }


//—————————————————————————————————————————————————  MEM FUNCTIONS  ——————————————————————————————————————————————————//


    function separate {
        wait 1.
        rcs on.
        set ship:control:fore to -0.25. 
        wait 1.
        set ship:control:fore to 0.
        wait 2.
        set ship:control:fore to 0.25.
        wait 1.
        set ship:control:fore to 0.
        rcs off.
        wait 1.
    }

    function td_acceleration_vector {
        local trg is latlng(0, vessel("LZ1"):geoposition:lng):position:direction.
        local a_p is (trg - srfprograde):pitch.
        local a_y is (srfprograde - trg):yaw.
        return srfretrograde + r(a_p, a_y, 180).
    }


//—————————————————————————————————————————————————————  EXPORT  —————————————————————————————————————————————————————//


    export(lex(
        "ESM", extraction_stability_mode@,
        "SLP", sleep_mode@,
        "SEP", des_prep@,
        "DOP", des_orbit_phasing@,
        "DOI", des_orbit_insertion@,
        "LBK", braking_phase@
        // "LTD", terminal_descent@,
        // "SRF", srf_eva@,
        // "ROP", rvz_orbit_phasing@,
        // "RTO", rvz_transfer_orbit@,
        // "RVZ", rvz_final_approach@,
        // "JTM", jettison_module@ 
    )).
}
