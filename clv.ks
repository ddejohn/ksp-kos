{
    runoncepath("m.lib").
    initialize().

    global throt is 0.
    global pitch is 0.
    global lock throttle to throt.

    function launch_to_orbit {
        launch().
        ascent(150000, 70000).
        wait until altitude > 71000.

        local t is time:seconds + eta:apoapsis - 60.
        warpto(t). wait until time:seconds > t.
        
        obt_crc().
    }

    function trans_duna_phasing {
        steer_to("pro").
        local phz is ex_soi_phz(duna)["atp"].
        coast_to_phz(angle:to_prograde@:bind(phz)).
    }

    function trans_duna_injection {
        ex_soi_inj(ex_soi_phz(duna)["t_alt"]).
    }

    function coast_to_mid_course {
        coast_to_node(duna).
    }

    // Normal burn to match Duna's orbital inclination.
    function mid_course_normal {
        steer_to("nml").

        local val is 0.00000125.
        local mult is 3E10.

        maneuver(
            { return relative_inclination(duna). },
            { return vcrs(specific_angular_momentum(duna), specific_angular_momentum()). },
            { return 2*velocity:orbit:mag*sin(relative_inclination(duna)). },
            val,
            mult
        ).
    }

    // Radial burn to establish dayside flyby.
    function mid_course_radial {
        local target_altitude is 500000.
        local flyby_side is dot_sign(sun:position - duna:position, pe_vec(orbit:nextpatch)).
        
        local a is -1.
        local b is 1.
        local c is 1.

        // If nightside flyby, burn anti-radial until flyby switches to dayside.
        if flyby_side = -1 {
            steer_to("a_rad").
            when orbit:nextpatch:periapsis < 0 then {
                set a to 1.
                return false.
            }
        }

        else {
            steer_to("rad").
            set b to -1.
            if orbit:nextpatch:periapsis < 0 set c to -1.
        }

        until round(orbit:nextpatch:periapsis) = target_altitude {
            set throt to neg_exp(a*orbit:nextpatch:periapsis, c, b*target_altitude, 2E6).
            wait 0.
        }

        local t1 is orbit:nextpatcheta + time_of_flight(360, orbit:nextpatch, soi_entry(orbit:nextpatch)).
        local t2 is orbit:nextpatcheta + orbit:nextpatch:nextpatcheta.

        if t1 > t2 {
            local o is seek_patch(orbit:nextpatch:nextpatch, duna).
            
            function seek_patch {
                parameter o, desired_body.
                if o:body = desired_body return o.
                else if o:hasnextpatch seek_patch(o:nextpatch, desired_body).
                else return 1/0.
            }

            until round(o:periapsis) = target_altitude {
                set throt to neg_exp(a*o:periapsis, c, b*target_altitude, 2E6).
                wait 0.
            }
        }

        set throt to 0. wait 5.
    }

    function coast_to_flyby {
        coast_to_flyby(duna).
    }

    function duna_orbital_insertion {
        steer_to("a_pro").
        lights on.
        ship:partstagged("P0_F")[0]:getmodule("ModuleProceduralFairing"):doaction("deploy", true).
        wait 5.

        obt_ins(1E6, 1E4).
        wait 0.
    }
        
    function duna_comms_prep {
        if angle:to_eq_an() < angle:to_eq_dn() steer_to("a_nml").
        else steer_to("nml").

        wait 1.
        stage_jettison(0, "P").
        wait 1.
        stage_jettison(1, "P").
        wait 5.
    }

    function comms_transfer_orbit {
        obt_inc(0.00000125, 10000).
        
        steer_to("pro").
        local t is time:seconds + eta:apoapsis - 60.
        warpto(t). wait until time:seconds > t and kuniverse:timewarp:rate = 1.
        
        local n is ship:partstagged("SCV"):length().
        local k is (n-1)/n.

        local target_period is 2*k*constant:pi*sqrt((apoapsis + body:radius)^3/body:mu).
        local target_pe is 2*((apoapsis + body:radius)*k^(2/3) - body:radius) - apoapsis.
        local target_sma is (apoapsis + target_pe + 2*body:radius)/2.

        ipu(2000).
        until orbit:period >= target_period {
            local dV is sqrt(body:mu * (2/(body:radius + apoapsis) - 1/target_sma)) - velocity:orbit:mag.
            local r_0 is positionat(ship, time:seconds + burn_time(dv)/2) - body:position.
            local x is pi_vang(r_0, ap_vec(), specific_angular_momentum()).

            set throt to neg_exp(orbit:period, 1, target_period, 100) * gaussian(x, 600).
            wait 0. 
        }
        ipu().

        set throt to 0. wait 1.
    }

    function comms_sat_deploy {
        for sat in ship:partstagged("SCV") {        
            local cpu is sat:getmodule("kOSProcessor").
            
            if eta:apoapsis < 60 local t is (time:seconds + eta:apoapsis + orbit:period - 60).
            else local t is time:seconds + eta:apoapsis - 60.
            
            warpto(t). wait until time:seconds > t and kuniverse:timewarp:rate = 1.
            steer_to("pro").
            wait 5.

            // set orbiter bootfile
            set cpu:bootfilename to cpu:tag.
            cpu:activate. wait 1.

            wait until not ship:messages:empty.
            ship:messages:clear().
            wait 5.
        }
    }

    function deorbit {
        steer_to("a_pro").
        lights off.
        set throt to 1.
        wait until periapsis < 0.
        set throt to 0.
    }

//—————————————————————————————————————————————————————  EXPORT  —————————————————————————————————————————————————————//

    export(lex(
        "LTO", launch_to_orbit@,
        "TDP", trans_duna_phasing@,
        "TDI", trans_duna_injection@,
        "CST", coast_to_mid_course@,
        "MCN", mid_course_normal@,
        "MCR", mid_course_radial@,
        "CTI", coast_to_flyby@,
        "DOI", duna_orbital_insertion@,
        "DCP", duna_comms_prep@,
        "CTO", comms_transfer_orbit@,
        "CSD", comms_sat_deploy@,
        "END", deorbit@ 
    )).

}