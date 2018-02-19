using MIDI, StatsBase
export isgrid, classify, quantize, quantize!
###############################################################################
# Grid
###############################################################################
function isgrid(Grid)
    issorted(Grid) || throw(ArgumentError("Grids must be sorted."))
    if Grid[1] != 0 || Grid[end] != 1
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


"""
```julia
average_swing_ratio(notes::Vector{Note}, tpq::Integer, asr_method::String)
```
Calculate the average swing ratio of given `notes` array. Return the average
swing ratio and the associated standard deviation.
## Methods
### `"AsrFromAll"`
Classify each note with the "13triplet" method. Calculate for each
swing note the swing ratio (with respect to a perfect quarter note)
and then average for all notes.
### `"Triplets"`
Classify each note with the "triplets" method. Use the notes with
id 3 to calculate the swing ratio, and the average for all.
"""
function average_swing_ratio(notes::Vector{Note},
  tpq::Integer, asr_method::String)

  sr::Vector{Float64} = Float64[]

  # Create array of Swing Notes
  if asr_method == "AsrFromAll"
    s = classify(notes, tpq, "13triplet")
    swingnotes = notes[s .== 2]
  elseif asr_method == "Triplets"
    s = classify(notes, tpq, "triplets")
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




function inbetween_portion(notes::Vector{Note}, tpq)
  clas = classify(notes, tpq, "triplets")
  length(clas[clas .== 2])/length(notes)
end
