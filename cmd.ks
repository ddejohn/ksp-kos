{
    global throt is 0.
    lock throttle to throt.
    utilities:initialize().


    function wake_mem {
        set processor("MEM"):bootfilename to "m.ks".
        processor("MEM"):activate.
    }


    function launch_to_orbit {
        guidance:launch().
        guidance:ascent(150000, 70000).
        wait until altitude > 71000.
        wait 5.
        systems:warp_to(eta:apoapsis - 90).
        guidance:circularize().
    }


    function trans_munar_phasing {
        systems:steer_to("pro").
        navigation:intra_soi_phasing(mun).
        // navigation:coast:to_phz(navigation:phase_angle@:bind(mun, 122.23)).
    }


    function trans_munar_injection {
        guidance:intra_soi_injection(30000).
        systems:stage_shutdown(1).
    }


    function munar_module_extraction {
        wait 5.
        systems:warp_to(3600).
        systems:steer_to("nml").
        wake_mem().

        wait 1.
        toggle ag2. // docking lights
        wait 1.
        ship:partstagged("C0_D")[0]:getmodule("moduledecouple"):doevent("decouple").

        wait 1.
        mem_extract().
        wait 1.

        systems:stage_jettison(1, "S").
        wait 1.
        toggle ag2.
        wait 5.
    }


    // Warp to 60 seconds before Munar periapsis.
    function coast_to_orbital_insertion {
        navigation:coast:to_flyby(mun, 60).
    }


    function munar_orbital_insertion {
        systems:stage_ignition(3).
        wait 0.
        guidance:insertion(40000).
        wait 0.
    }


    function munar_orbital_adjustment {
        guidance:change_inclination().

        set throt to 0. wait 1.
        systems:warp_to(eta:apoapsis - 60).
        systems:steer_to("pro").
        
        guidance:circularize().
        systems:stage_shutdown(3).
    }


    function munar_module_separation {
        wait 5.
        wake_mem().
        mem_sep().
        wait 1.
    }


    function rendezvous_hibernation_mode {
        mem_rvz().
        // REINITIALIZE ME
        processor("CMD"):doaction("open terminal", true).
    }


    function trans_kerbin_phasing {
        // roughly 60° 
    }


    function trans_kerbin_injection {
        // ez-pz
    }


    function aerocapture_reentry {
        // Kerbin intercept and reentry
    }


    function mem_sep {
        ship:partstagged("port")[0]:undock().
        wait until not ship:messages:empty.
        ship:messages:clear().
    }


    function mem_rvz {
        wait until ship:partstagged("port")[0]:state:split(" ")[0] = "acquire".
        unlock steering.
        lock steering to "kill".
        wait until ship:crewcapacity = 5.
    }


    // Separates from transfer stage, zeroes relative velocity, points to target, then runs docking procedure.
    function mem_extract { 
        set target to vessel(ship:name:split(" ")[0] + " lander").
        local t_port is target:partstagged("port")[0].
        local c_port is ship:partstagged("port")[0].
        rcs on.

        local rel_vel is {
            return -vdot(ship:facing:forevector, target:velocity:orbit - ship:velocity:orbit).
        }.

        if abs(rel_vel()) < 0.25 {
            set ship:control:fore to 0.5.
            wait 1.
            set ship:control:fore to 0.
        }
        
        wait until abs(target:distance) > 10.

        until abs(rel_vel()) < 0.01 {
            set ship:control:fore to control:corrective_sigmoid(rel_vel(), 1, 0, 50).
            wait 0.
        }

        set ship:control:neutralize to true.
        rcs off.
        wait 1.
        guidance:dock().
    }


//—————————————————————————————————————————————————————  EXPORT  —————————————————————————————————————————————————————//


    export(lex(
        "LTO", launch_to_orbit@,
        "TMP", trans_munar_phasing@,
        "TMI", trans_munar_injection@,
        "MME", munar_module_extraction@,
        "CST", coast_to_orbital_insertion@,
        "MOI", munar_orbital_insertion@,
        "MOA", munar_orbital_adjustment@,
        "SEP", munar_module_separation@,
        "RHM", rendezvous_hibernation_mode@,
        "TKP", trans_kerbin_phasing@,
        "TKI", trans_kerbin_injection@,
        "ACR", aerocapture_reentry@
    )).
}
