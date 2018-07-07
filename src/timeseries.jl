export timeseries

"""
    timeseries(notes::Notes, property, f [, grid]) -> tvec, ts
Produce a timeseries of the `property` of the given notes, optionally
first quantizing on the given `grid`.

After quantization, it is often
the case that many notes are in the same bin of the grid. The **function** `f`
denotes which value of the vector of the `property` of the notes to keep.
Typical values are `minimum, maximum, mean`, etc (*for type stability the returned
timeseries are always `Float64`*).

The `property` can be `:velocity`, `:pitch`, or `:duration`. Grid bins without any
notes are given the value `0`. This **can be problematic** if you request for
`:pitch` and your `notes` also include notes which actually have pitch `0`,
i.e. `C0`.
"""
function timeseries(notes, property, f, grid = 0:1//notes.tpq:1)
    isgrid(grid)
    tpq = notes.tpq
    qnotes = quantize(notes, grid)
    pos = positions(qnotes)
    # Real grid and grid bins
    rgrid = tpq .* grid
    bins = round.(Int, rgrid)[1:end-1]
    # tvec limits
    firstp = Int(qnotes[1].position)
    firstbin = findfirst(x -> x == mod(firstp, tpq), bins)

    # Create tvec
    tvec = (firstp÷tpq)*tpq .+ bins[firstbin:end]
    c = firstp÷tpq + 1
    while tvec[end] < notes[end].position
        append!(tvec, bins .+ c*tpq)
        c += 1
    end

    ts = zeros(Float64, size(tvec))

    i = previdx = 1; L = length(pos)
    while i ≤ L
        # find entries of same grid bin
        j = 1
        while j ≤ L - i && pos[i+j] == pos[i]
            j+=1
        end
        # get timeseries value for this note
        if j > 1
            d = [getfield(qnotes[k], property) for k in i:i+j-1]
            val = Float64(f(d))
        else
            val = Float64(getfield(qnotes[i], property))
        end

        # find pos[i] in tvec
        idx = findfirst(x -> x == pos[i], tvec)
        ts[idx] = val

        # TODO: For pitch, change zeros of intermediate entries
        # to pitch of previous notes

        i += j
    end
    return tvec, ts
end
