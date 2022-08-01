{
    runoncepath("m.lib").
    initialize().

    global throt is 0.
    global pitch is 0.
    global lock throttle to throt.

    function launch_to_orbit {
        launch().
        ascent(150000, 70000).
        toggle ag1.
        wait until altitude > 71000.
        systems:warp_to(eta:apoapsis - 90).
        obt_crc().
    }


    function trans_munar_phasing {
        steer_to("pro").
        coast_to_phz(phase_angle@:bind(mun, 128)).
    }


    function trans_munar_injection {
        in_soi_inj(30000, 80000).
        stage_shutdown(1).
    }


    // Warp to 60 seconds before Munar periapsis.
    function coast_to_orbital_insertion {
        coast_to_flyby(mun, 60).
    }


    function munar_orbital_insertion {
        stage_ignition(1).
        wait 0.
        obt_ins(40000, 2000).
        wait 0.
    }


    function munar_orbital_adjustment {
        obt_inc().

        set throt to 0. wait 1.
        systems:warp_to(eta:apoapsis - 60).
        steer_to("pro").
        
        obt_crc().
        stage_shutdown(3).
    }


//—————————————————————————————————————————————————————  EXPORT  —————————————————————————————————————————————————————//

    export(lex(
        "LTO", launch_to_orbit@,
        "TMP", trans_munar_phasing@,
        "TMI", trans_munar_injection@,
        "CST", coast_to_orbital_insertion@,
        "MOI", munar_orbital_insertion@,
        "MOA", munar_orbital_adjustment@
    )).

}