export timeseries

"""
    timeseries(notes::Notes, property, f [, grid]) -> tvec, ts
Produce a timeseries of the `property` of the given notes, by
first quantizing on the given `grid`, which defaults to `0:1//notes.tpq:1`
(i.e. no real quantization). Return the time vector `tvec` in ticks
and the produced timeseries `ts`.

After quantization, it is often the case that many notes are in the same bin of
the grid. The **function** `f` denotes which value of the vector of the
`property` of the notes to keep. Typical values are `minimum, maximum, mean`,
etc. Notice that bins without any note in them obtain the value `missing`.

If the `property` is `:velocity`, `:pitch`, or `:duration` the function
behaves exactly as described. The `property` can also be `:position`.
In this case, the timeseries `ts` contain the timing deviations of the notes
with respect to the `tvec` vector.

This function requires that `notes` is temporally sorted. Bins that have no
notes in them obtain the value `missing`, regardless of the requested property.
"""
function timeseries(notes, property, f, grid = 0:1//notes.tpq:1)
    isgrid(grid)
    if !issorted(notes, by = x -> x.position)
        error("notes must be sorted by position!")
    elseif property ∉ (:velocity, :pitch, :duration, :position, :channel)
        error("Unknown property!")
    end

    ts, tvec, qnotes, pos = _init_timeseries_vectors(notes, grid)
    i = previdx = 1; L = length(pos)
    while i ≤ L
        # find entries of same grid bin
        j = 0
        while j ≤ L - i && pos[i+j] == pos[i]
            j+=1
        end
        add_timeseries_value!(ts, qnotes, pos, tvec, i, j, property, f)
        i += j
    end
    return tvec, ts
end

function add_timeseries_value!(ts, qnotes, pos, tvec, i, j, property, f)
    idx = findfirst(x -> x == pos[i], tvec) # where to add the value
    isnothing(idx) && error("nothing")
    if j > 0
        val = Float64(f(getfield(qnotes[k], property) for k in i:i+j))
    else
        val = Float64(getfield(qnotes[i], property))
    end
    if property == :position #, then we want timing deviations
        val = val - tvec[idx]
    end
    ts[idx] = val
end

function _init_timeseries_vectors(notes, grid)
    tpq = notes.tpq
    qnotes = quantize(notes, grid)
    pos = positions(qnotes)
    realgrid = tpq .* grid
    bins = round.(Int, realgrid)[1:end-1]
    # tvec limits
    firstp = Int(qnotes[1].position)
    firstbin = findfirst(x -> x == mod(firstp, tpq), bins)

    # Create vectors
    tvec = (firstp÷tpq)*tpq .+ bins[firstbin:end]
    c = firstp÷tpq + 1
    while tvec[end] < notes[end].position
        append!(tvec, bins .+ c*tpq)
        c += 1
    end
    ts = fill!(Vector{Union{Float64, Missing}}(undef, length(tvec)), missing)
    return ts, tvec, qnotes, pos
end
