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
        steer_to("nml").
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
        local target_altitude is 6000.
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
            set throt to neg_exp(a*orbit:nextpatch:periapsis, c, b*target_altitude, 5E6).
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

    function coast_to_aerocapture {
        stage_shutdown(1).
        coast_to_flyby(duna).
    }

    function aerocapture_prep {
        steer_to("a_pro").
        stage_jettison(1, "S").
        wait 0.
    }

    function unpowered_descent {
        steer_to("a_srf").
        wait until velocity:surface:mag < 250.
        ship:partstagged("fairing")[0]:getmodule("moduleproceduralfairing"):doevent("deploy").
        wait until not chutessafe.
        chutessafe on.
        wait until altitude - geoposition:terrainheight < 2500.
        ship:partstagged("heatshield")[0]:getmodule("moduledecouple"):doevent("jettison heat shield").
    }

    function powered_descent_initiation {
        steer_to("a_srf").

        wait until altitude - geoposition:terrainheight < 1000.
        for part in ship:partstagged("chutes") part:getmodule("moduleparachute"):doaction("cut chute", true).

        stage_ignition("DS").
        wait 1.

        until ship:status = "landed" {
            local alt_h is altitude - geoposition:terrainheight.
            local speed_limit is -(122 - constant:e^(ln(120) - alt_h/500)).
            local vert is verticalspeed.
            set throt to binary_sigmoid(vert, 1, speed_limit, 5).
        }

        steer_to().        
    }

    function surface_operations {
        wait 5. stage_shutdown("DS"). wait 5.
        ship:partstagged("payload")[0]:getmodule("moduledecouple"):doevent("decouple").
        wait 1.
        
        set ship:control:neutralize to true.
        set ship:control:wheelthrottle to 1. wait 3.
        set ship:control:wheelthrottle to 0.
        
        brakes on.
        ag1 on. wait 1. ag2 on. wait 1. ag3 on.
        
        set ship:control:neutralize to true.
    }

//—————————————————————————————————————————————————————  EXPORT  —————————————————————————————————————————————————————//

    export(lex(
        "LTO", launch_to_orbit@,
        "TDP", trans_duna_phasing@,
        "TDI", trans_duna_injection@,
        "CST", coast_to_mid_course@,
        "MCN", mid_course_normal@,
        "MCR", mid_course_radial@,
        "CTA", coast_to_aerocapture@,
        "ACP", aerocapture_prep@,
        "UPD", unpowered_descent@,
        "PDI", powered_descent_initiation@,
        "SRF", surface_operations@
    )).

}