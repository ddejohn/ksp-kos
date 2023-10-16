clearscreen.

local test_string is "abcdef".

print test_string:padright(15).
print r_pad(test_string, 15, "#").
print test_string:padleft(15).
print el_pad(test_string, 15, "#").

for i in range(12) print el_pad(i, 3, "0").

par_test(5).

// Right-pad data with a given char. Defaults to whitespace padding.
function r_pad {
    parameter data, pad_size, char is " ".

    local data is data:tostring().
    until data:length() = pad_size {
        set data to data + char.
    }

    return data.
}

// Left-pad data with a given char. Defaults to whitespace padding.
function el_pad {
    parameter data, pad_size, char is " ".

    local data is data:tostring().
    until data:length() = pad_size {
        set data to char + data.
    }

    return data.
}