using MIDI, StatsBase
export isgrid, classify, quantize, quantize!,
       td50_velquant_interval, td50_velquant_peaks

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


"""
```julia
quantize!(notes::Notes, grid)
quantize!(note::AbstractNote, grid, tpq::Integer)
```
Quantize the given notes on the given `grid`.

Each note is quantized (relocated) to its closest point of the `grid`, by first
identifying that point using [`classify`](@ref).
It is assumed that the grid is the same for all quarter notes of the track.

This function respects the notes absolute position and quantizes in absolute position,
not relative.

See also [`quantize`](@ref).
"""
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
    quantize(notes::Notes, grid) -> qnotes
Same as [`quantize!`](@ref) but returns new `qnotes` instead of operating in-place.
"""
function quantize(notes::Notes, grid)
    qnotes = deepcopy(notes)
    quantize!(qnotes, grid)
    return qnotes
end

###############################################################################
#drum things
###############################################################################

"""
    td50_velquant_interval(notes::MIDI.Notes, numintervals::Int)

Divide the velocity range in `numintervals` intervals and quantize the
velocities of each `Note` to the mean value of all notes of the corresponding
instrument in this interval.
"""
function td50_velquant_interval(notes::MIDI.Notes, numintervals::Int)
    #get notes separated by pitches
    sep = separatepitches(notes)
    newnotes = Notes_morevel()

    for pitch in keys(sep)
        #short acces to needed notes
        pitchnotes = sep[pitch].notes

        #take care of different maximum velocities
        maxvel = 0
        pitch in DIGITAL ? maxvel = 160 : maxvel = 128

        #do a histogram and weight it with the velocities
        hist = zeros(maxvel)
        for note in pitchnotes
            hist[note.velocity] += 1
        end
        whist = copy(hist)
        for i = 1:length(hist)
            whist[i] *= i
        end

        #create the partitioning and compute corresponding means
        intlength = ceil(Int, maxvel/numintervals)
        meanvals = zeros(Int, numintervals)
        for i = 0:numintervals-1
            start = i*intlength+1
            ende = i*intlength+intlength
            if ende > maxvel
                ende = maxvel
            end
            piece = whist[start:ende]
            hits = sum(hist[start:ende])
            if hits != 0
                piece ./= hits
            end
            meanvals[i+1] = round(Int,mean(piece)*intlength)
        end

        #quantize notes
        for note in pitchnotes
            quant = ceil(Int, note.velocity/intlength)
            note.velocity = meanvals[quant]
        end

        # append to field of quantized notes
        append!(newnotes.notes, pitchnotes)
    end

    #restore temporal order
    sort!(newnotes.notes, lt=((x, y)->x.position<y.position))
    return newnotes
end

"""
    td50_velquant_peaks(notes::MIDI.Notes, class::Dict{UInt8,VPinfo})

Quantize the velocities of each instruments to the velocities of the Histograms
peaks. Histogram classification must be provided in `class`, if not, nothing changes.
"""
function td50_velquant_peaks(notes::MIDI.Notes, class)#::Dict{UInt8,VPinfo})
    newnotes = Notes_morevel()
    sep = separatepitches(notes)

    for (pitch,notes) in sep

        #if quantize information supplied
        if haskey(class,pitch)
            vp = class[pitch]

            if length(vp.peaks) == 1    #trivial case (only one peak)
                for note in sep[pitch]
                    note.velocity = vp.peaks[1]
                    push!(newnotes.notes,note)
                end

            else                        #find corresponding peak
                for note in sep[pitch]
                    vall = 1
                    while vp.valleys[vall] < note.velocity
                        vall += 1
                    end
                    peak = 1
                    #still to do
                    while peak < length(vp.peaks) && vp.peaks[peak+1] < vp.valleys[vall]
                        peak += 1
                    end
                    note.velocity = vp.peaks[peak]
                    push!(newnotes.notes,note)

                end
            end

        #no quantization information -> do nothing with velocity
        else
            append!(newnotes.notes,notes)
        end
    end

    #restore temporal order
    sort!(newnotes.notes, lt=((x, y)->x.position<y.position))
    return newnotes
end
