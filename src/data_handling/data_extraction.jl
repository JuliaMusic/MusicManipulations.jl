export getfirstnotes, filterpitches, separatepitches, firstnotes

"""
    firstnotes(notes, grid)

Return the notes that first appear in each grid point, *without quantizing them*.

This function *does not* consider the notes modulo the quarter note! Different
quarter notes have different grid points.
"""
function firstnotes(notes::Notes{N}, grid) where {N<:AbstractNote}
    isgrid(grid)

    clas = classify(notes, grid)

    # Notes with dif == 0 belong to the same grid bin
    dif = clas[2:end] - clas[1:end-1]

    posdif = [Int(notes[j].position - notes[j-1].position) for j in 2:length(notes)]
    # minpos is the minimum position difference notes can have while being in the
    # same quarter note
    tpq = notes.tpq
    minpos = tpq - tpq*(grid[end] - grid[end-1] + grid[2] - grid[1])/2

    # The first notes are notes that have dif == 0 OR posdif > minpos
    toadd = Vector{Note}()
    for j in 1:length(notes)-1
        if (dif[j] == 0 && posdif[j] > minpos) || dif[j] != 0
            push!(toadd, notes[j+1])
        end
    end

    # Take care of first note in notes:
    if clas[1] != clas[2] || notes[2].position - notes[1].position > minpos
        pushfirst!(toadd, notes[1])
    elseif notes[2].position < notes[1].position
        toadd[1] = notes[1]
    end
    return Notes(toadd, notes.tpq)
end


"""
    filterpitches(notes::Notes, filters) -> newnotes

Only keep the notes that have a pitch specified in `filters` (one or many pitches).
"""
function filterpitches(notes::Notes{N}, filters) where {N<:AbstractNote}
    n = N[]
    for i ∈ 1:length(notes)
        notes[i].pitch ∈ filters && push!(n, copy(notes[i]))
    end
    return Notes(n, notes.tpq)
end

@deprecate allowedpitches filterpitches


"""
    separatepitches(notes::Notes [, allowed])

Get a dictionary \"pitch\"=>\"notes of that pitch\".
Optionally only keep pitches that are contained in `allowed`.
"""
function separatepitches(notes::Notes{N}) where {N}
    separated = Dict{UInt8, Notes{N}}()
    for note in notes
        _add_note_to_dict!(separated, note, notes.tpq)
    end
    return separated
end

function separatepitches(notes::Notes{N}, pitches) where {N}
    separated = Dict{UInt8, Notes{N}}()
    for note in notes
        note.pitch ∈ pitches && _add_note_to_dict!(separated, note, notes.tpq)
    end
    return separated
end

function _add_note_to_dict!(separated, note::N, tpq) where {N<:AbstractNote}
    if haskey(separated, note.pitch)
        push!(separated[note.pitch], deepcopy(note))
    else
        separated[note.pitch] = Notes{N}(Vector{N}[], tpq)
        push!(separated[note.pitch], deepcopy(note))
    end
end

export estimate_delay, estimate_delay_recursive

estimate_delay(notes, sub::Int) = estimate_delay(notes,  0:(1/sub):1)

"""
    estimate_delay(notes, grid)
Estimate the average temporal deviation of the given `notes` from the
quarter note grid point. The notes are classified according to the `grid`
and only notes in the first and last grid bins are used. Their position
is subtracted from the nearby quarter note and the returned value
is the average of this operation.
"""
function estimate_delay(notes::Notes, grid::AbstractVector)
    # TODO: this can be optimized by looping over the notes directly
    # and classifying one by one, and adding to `d` one by one
    clas = classify(notes, grid)
    base = notes[findall(x -> x == 1 || x == length(grid), clas)]
    d = 0.0
    for n in base
        pos = Int(n.position % notes.tpq)
        res = pos ≤ grid[2]*notes.tpq ? pos : pos - notes.tpq
        d += res
    end
    return d / length(base)
end

"""
    estimate_delay_recursive(notes, grid, m)
Do the same as [`estimate_delay`](@ref) but for `m` times, while in each step
shifting the notes by the previously found delay. This improves the accuracy
of the algorithm, because the distribution of the quarter notes is estimated
better and better each time. The function should typically converge
after a couple of `m`.

The returned result is the estimated delay, in integer (ticks), as only integers
can be used to actually shift the notes around.
"""
function estimate_delay_recursive(notes, grid, m)
    totaldelay = 0
    xnotes = notes
    for i in 1:m
        delay = round(Int, estimate_delay(xnotes, grid))
        totaldelay += delay
        xnotes = xnotes - delay
    end
    return totaldelay
end
