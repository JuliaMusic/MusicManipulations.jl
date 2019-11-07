export timeseries

"""
    timeseries(notes::Notes, property::Symbol, f, grid) -> tvec, ts
Produce a timeseries of the `property` of the given notes, by
first quantizing on the given `grid` (to avoid actual quantization
use the grid `0:1//notes.tpq:1`). Return the time vector `tvec` in ticks
and the produced timeseries `ts`.

After quantization, it is often the case that many notes are in the same bin of
the grid. The **function** `f` denotes which value of the vector of the
`property` of the notes to keep. Typical values are `minimum, maximum, mean`,
etc. Notice that bins without any note in them obtain the value `missing`,
regardless of the function `f` or the `property`.

If the `property` is `:velocity`, `:pitch`, or `:duration` the function
behaves exactly as described. The `property` can also be `:position`.
In this case, the timeseries `ts` contain the timing deviations of the notes
with respect to the `tvec` vector
(these numbers are known as *microtiming deviations* in the literature).
"""
function timeseries(notes, property, f, grid)
    isgrid(grid)
    if !issorted(notes, by = x -> x.position)
        error("notes must be sorted by position!")
    elseif !isnothing(property) &&
        property ∉ (:velocity, :pitch, :duration, :position, :channel)
        error("Unknown property!")
    end

    ts, tvec, quantizedpos = _init_timeseries_vectors(notes, grid)
    i = previdx = 1; L = length(quantizedpos); M = length(tvec)
    while i ≤ L
        # find entries of same grid bin
        j = 1
        while j ≤ L - i && quantizedpos[i+j] == quantizedpos[i]
            j+=1
        end
        # where to add the value in the timeseries:
        idx = findfirst(x -> tvec[x] == quantizedpos[i], previdx:M) + previdx-1
        previdx = idx
        ts[idx] = produce_note_value(notes, property, f, i, j)
        if property == :position # here we want timing *deviations*
            ts[idx] -= tvec[idx]
        end
        i += j
    end
    return tvec, ts
end

"""
    timeseries(notes::Notes, f, grid) -> tvec, ts
If `property` is not given, then `f` should take as input a `Notes` instance
and output a numeric value. This is useful for example in cases where one
would want the timeseries of the velocities of the notes of the
highest pitch.
"""
timeseries(notes, f, grid) = timeseries(notes, nothing, f, grid)

function produce_note_value(notes, property::Symbol, f, i, j)
    if j > 1
        val = Float64(f(getfield(notes[k], property) for k in i:i+j-1))
    else
        val = Float64(getfield(notes[i], property))
    end
    return val
end

function produce_note_value(notes, property::Nothing, f, i, j)
    v = notes[i:i+j-1]
    val = Float64(f(v))
end

function _init_timeseries_vectors(notes, grid)
    tpq = notes.tpq
    qnotes = quantize(notes, grid)
    quantizedpos = positions(qnotes)
    bins = round.(Int, tpq .* grid)[1:end-1]
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
    ts = Vector{Union{Float64, Missing}}(undef, length(tvec))
    return ts, tvec, quantizedpos
end
