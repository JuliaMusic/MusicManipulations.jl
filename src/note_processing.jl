export getfirstnotes, purgepitches!, purgepitches, separatepitches, firstnotes

"""
    firstnotes(notes, grid)

Return the notes that first appear in each grid point, *without quantizing them*.

This function *does not* consider the notes modulo the quarter note! Different
quarter notes have different grid points.
"""
function firstnotes(notes::Notes{N}, grid) where {N<:AbstractNote}
    isgrid(grid)

    clas = classify(notes, grid)

    dif = clas[2:end] - clas[1:end-1]

    toadd = notes.notes[2:end][dif .!= 0]
    clas[1] != clas[2] && unshift!(toadd, notes[1])

    return Notes(toadd, notes.tpq)
end



"""
    purgepitches!(notes::Notes, allowedpitch::Array{UInt8})

Remove all notes that do not have a pitch specified in `allowedpitch`.
"""
function purgepitches!(notes::Notes, allowedpitch::Array{UInt8})
    deletes = Int[]
    for i ∈ 1:length(notes)
        !(notes[i].pitch ∈ allowedpitch) && push!(deletes, i)
    end
    deleteat!(notes.notes, deletes)
    return notes
end

purgepitches(notes::Notes, allowedpitch::UInt8) =
    purgepitches(notes,[allowedpitch])

purgepitches!(notes::Notes, allowedpitch::UInt8) =
    purgepitches!(notes,[allowedpitch])

"""Same as `purgepitches!` but returns a copy instead."""
purgepitches(notes::Notes, allowedpitch::Array{UInt8}) =
    purgepitches!(deepcopy(notes), allowedpitch)



"""
    separatepitches(notes::Notes)

Get a dictionary \"pitch\"=>\"notes of that pitch\".
"""
function separatepitches(notes::Notes{N}) where {N}
    separated = Dict{UInt8, Notes{N}}()
    for note in notes
        if haskey(separated, note.pitch)
            push!(separated[note.pitch], deepcopy(note))
        else
            push!(separated, note.pitch => Notes{N}(Vector{N}[], notes.tpq))
            push!(separated[note.pitch], deepcopy(note))
        end
    end
    return separated
end
