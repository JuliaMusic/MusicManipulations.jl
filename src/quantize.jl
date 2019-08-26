export isgrid, classify, quantize, quantize!, quantize_duration!
###############################################################################
# Grid
###############################################################################
function isgrid(grid)
    issorted(grid) || throw(ArgumentError("Grids must be sorted."))
    if grid[1] != 0 || grid[end] != 1
        throw(ArgumentError("Grids must start from 0 and end in 1."))
    end
    true
end

function closest_point(grid, x)
    best = 1
    dxbest = abs(x - grid[1])
    for i in 2:length(grid)
        dx = abs(x - grid[i])
        if dx < dxbest
            dxbest = dx
            best = i
        end
    end
    return best
end

function closest_realgrid(grid, x, tpq)
    best = 1
    dxbest = abs(x - grid[1]*tpq)
    for i in 2:length(grid)
        dx = abs(x - grid[i]*tpq)
        if dx < dxbest
            dxbest = dx
            best = i
        end
    end
    return best
end




###############################################################################
# Classifiers and quantizers
###############################################################################

"""
```julia
classify(notes::Notes, grid)
classify(note::AbstractNote, grid, tpq::Integer)
```
Classify given notes according to the given grid.

Returns an integer (or vector of integers) that corresponds to the index
of the closest grid point to the note position modulo the quarter note.
`1` means start of the grid and `length(grid)` means
end of the grid (i.e. *next* quarter note).
"""
function classify(note::AbstractNote, grid, tpq::Integer)
    posmod = mod(note.position, tpq)
    return closest_realgrid(grid, posmod, tpq)
end

function classify(notes::Notes, grid)
    isgrid(grid)
    r = zeros(Int, length(notes))
    for i in 1:length(notes)
        r[i] = classify(notes[i], grid, notes.tpq)
    end
    return r
end

function quantize!(note::AbstractNote, grid, tpq::Integer)

    number_of_quarters = div(note.position, tpq)
    b = classify(note, grid, tpq)
    note.position = round(Int, (number_of_quarters*tpq + grid[b]*tpq))
    return nothing
end

function quantize!(notes::Notes, grid)

    isgrid(grid)
    for note in notes
        quantize!(note, grid, notes.tpq)
    end
    return nothing
end

"""
```julia
quantize(notes::Notes, grid, duration = true)
quantize(note::AbstractNote, grid, tpq::Integer)
```
Return a quantized copy of the given notes on the given `grid`, which can be any
sorted iterable that starts on `0` and ends on `1`.

Each note is quantized (relocated) to its closest point of the `grid`, by first
identifying that point using [`classify`](@ref).
It is assumed that the grid is the same for all quarter notes of the track.

If `duration` is `true`, the function also quantizes the duration of the notes
on the same grid, while ensuring a duration spanning at least one grid point.

This function respects the notes' absolute position and quantizes in absolute position,
not relative.
"""
function quantize(notes::Notes, grid, duration = true)
    qnotes = deepcopy(notes)
    quantize!(qnotes, grid)
    duration && quantize_duration!(qnotes, grid)
    return qnotes
end

function quantize_duration!(note::AbstractNote, grid, tpq)
    durmod = mod(note.position + note.duration, tpq)
    best = closest_realgrid(grid, durmod, tpq)
    # Check if quantization removes duration
    final_dur = Int(grid[best]*tpq)
    dist = final_dur - durmod
    note.duration += final_dur - durmod
    if note.duration == 0
        if best != length(grid)
            note.duration += (grid[best+1] - grid[best])*tpq
        else
            note.duration += grid[2]*tpq # grid[1] is always 0 by definition
        end
    end
    return
end

"""
    quantize_duration!(notes::Notes, grid)
    quantize_duration!(note::Note, grid, tpq)
Quantize the duration of given notes on the `grid`.
"""
function quantize_duration!(notes::Notes, grid)
    for note in notes
        quantize_duration!(note, grid, notes.tpq)
    end
    return notes
end
