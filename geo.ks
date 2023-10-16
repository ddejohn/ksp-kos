{
    global throt is 0.
    lock throttle to throt.

    function launch_to_orbit {
        guidance:launch().
        guidance:ascent(navigation:geostationary_altitude(), 70000).
        wait until altitude > 71000.
        wait 5.
        print "ascent: done".
        systems:warp_to(eta:apoapsis - 90).
        // guidance:circularize().
    }

    export(lex("LTO", launch_to_orbit@)).
}
