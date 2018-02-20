using MIDI, StatsBase
export isgrid, classify, quantize, quantize!

# Have to move swing stuff in different folder. Create module Jazz
export average_swing_ratio, inbetween_portion
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

function closest_realgrid(grid, x, tpq::Integer)
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
classify(note::Note, grid, tpq::Integer)
```
Classify given notes according to the given grid.

Returns an integer (or vector of integers) that corresponds to the index
of the closest grid point to the note position modulo the quarter note.
`1` means start of the grid and `length(grid)` means
end of the grid (i.e. *next* quarter note).
"""
function classify(note::Note, grid, tpq::Integer)
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


"""
```julia
quantize!(notes::Notes, grid)
quantize!(note::Note, grid, tpq::Integer)
```
Quantize the given notes on the given `grid`.

Each note is quantized (relocated) to its closest point of the `grid`, by first
identifying that point using [`classify`](@ref).
It is assumed that the grid is the same for all quarter notes of the track.

This function respects the notes absolute position and quantizes in absolute position,
not relative.

See also [`quantize`](@ref).
"""
function quantize!(note::Note, grid, tpq::Integer)

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
    quantize(notes::Notes, grid) -> qnotes
Same as [`quantize!`](@ref) but returns new `qnotes` instead of operating in-place.
"""
function quantize(notes::Notes, grid)
    qnotes = deepcopy(notes)
    quantize!(qnotes, grid)
    return qnotes
end


#### JAzz

"""
```julia
average_swing_ratio(notes::Notes, asr_method::String)
```
Calculate the average swing ratio of given `notes` array. Return the average
swing ratio and the associated standard deviation.
## Methods
### `"swung8s"`
Classify each note with the grid `[0, 2//3, 1]`. Use the notes with
index 2 to calculate the swing ratio, and then average for all.
### `"triplets"`
Classify each note with the grud `[0, 1//3, 2//3, 1]`. Use the notes with
index 3 to calculate the swing ratio, and then average for all.
"""
function average_swing_ratio(notes::Notes, asr_method::String)

    tpq = notes.tpq
    sr = Float64[]

    # Create array of Swing Notes
    if asr_method == "swung8s"
        s = classify(notes, [0, 2//3, 1])
        swingnotes = notes[s .== 2]
    elseif asr_method == "triplets"
        s = classify(notes, [0, 1//3, 2//3, 1])
        swingnotes = notes[s .== 3]
    end

    # Create Swing ratios array
    for i in 1:length(swingnotes)
        pos = Int64(swingnotes[i].position)
        posmod = mod(pos, tpq)
        push!(sr, posmod/(tpq-posmod))
    end

    # asr /= length(swingnotes)
    # # Calculate std
    # for i in 1:length(swingnotes)
    #   pos = Int64(swingnotes[i].position)
    #   posmod = mod(pos, tpq)
    #   sr = posmod/(tpq-posmod)
    #   sr_std += (sr - asr)^2
    # end
    # sr_std = sqrt(sr_std/length(swingnotes)) # do not use length-1

    return mean_and_std(sr)
end




function inbetween_portion(notes::Notes)
  clas = classify(notes, [0, 1//3, 2//3, 1])
  count(i -> i == 2, clas)/length(notes)
end
