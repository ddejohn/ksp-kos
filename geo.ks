{
    global throt is 0.
    lock throttle to throt.
    lock steer_ang to -15 / (1 + constant:e^(-(ship:verticalspeed - 100) / 20)).
    lock EAST to UP + r(0, 270, 90).
    lock SRFP to srfprograde + r(0, 0, 180).

    function launch_to_orbit {
        guidance:launch().
        guidance:ascent(navigation:geostationary_altitude(), 70000).
        wait until altitude > 71000.
        wait 5.
        systems:warp_to(eta:apoapsis - 90).
        // guidance:circularize().
    }

    export(lex("LTO", launch_to_orbit@)).
}
