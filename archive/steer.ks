parameter steer is "nml".

clearscreen.
global steer_lex is lex(
    "pro",      { lock steering to prograde*r(0, 0, 0).         },
    "a_pro",    { lock steering to prograde*r(180, 0, 0).       },
    "nml",      { lock steering to prograde*r(0, 270, 0).       },
    "a_nml",    { lock steering to prograde*r(0, 90, 0).        },
    "rad",      { lock steering to prograde*r(270, 0, 0).       },
    "a_rad",    { lock steering to prograde*r(90, 0, 0).        },
    "srf",      { lock steering to srfprograde.                 },
    "a_srf",    { lock steering to srfretrograde.               },
    "tar",      { lock steering to target:direction.            },
    "a_tar",    { lock steering to -target:direction.           },
    "dock",     { lock steering to target:facing*r(0,180,180).  }
).

function steer_to {
    parameter dir is "".

    // Steer to given direction if present in steering lexicon.
    if steer_lex:haskey(dir) {
        steer_lex[dir]().
        until false {
            // "Dot product" of the facing and steering coordinate frames.
            local dot_dirs is
                vdot(ship:facing*r(90, 0, 0):vector, steering*r(90, 0, 0):vector)
                    + vdot(ship:facing*r(0, 90, 0):vector, steering*r(0, 90, 0):vector)
                        + vdot(ship:facing*r(0, 0, 90):vector, steering*r(0, 0, 90):vector).
            
            // Wait until we're pointed correctly.
            if round(dot_dirs, 4) = 3 break.
            else wait 0.
        }
    }

    // If dir not found, unlock steering.
    else unlock steering.
}

steer_to(steer).