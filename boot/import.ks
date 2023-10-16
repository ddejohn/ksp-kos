// library loader
{
    local current_file is 0.
    local lookup is lex().

    global import is {
        parameter name.
        set current_file to name.
        runoncepath(name).
        return lookup[name].
    }.

    global export is {
        parameter value.
        set lookup[current_file] to value.
    }.
}
