export getfirstnotes, purgepitches, separatepitches, firstnotes

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
    purgepitches(notes::Notes, allowedpitch) -> newnotes

Remove all notes that do *not* have a pitch specified in `allowedpitch`.
"""
function purgepitches(notes::Notes{N}, allowedpitch) where {N<:AbstractNote}
    n = N[]
    for i ∈ 1:length(notes)
        notes[i].pitch ∈ allowedpitch && push!(n, deepcopy(notes[i]))
    end
    return Notes(n, notes.tpq)
end



"""
    separatepitches(notes::Notes [, pitches])

Get a dictionary \"pitch\"=>\"notes of that pitch\".
Optionally only keep pitches that are contained in `pitches`.
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
