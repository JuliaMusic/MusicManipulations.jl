export getfirstnotes, purgepitches!, purgepitches, twonote_distances, separatepitches

"""
    getfirstnotes(notes::Notes, septicks = 960)

Get only the first played note of each instrument in a series of notes.
If no note is played for `septicks` ticks, the next following notes are
considered a new series.
"""
function getfirstnotes(notes::Notes, trackno = 2, septicks = 960)
    pitch = UInt8[] #save which pitches allready occurred in current series
    firstnotes = Notes() #container for firstnotes

    #iterate through all notes
    for (i,note) in enumerate(notes)
        #if the current note is the first of a new series, empty the pitches
        if i>1 && note.position - notes.notes[i-1].position > septicks
            pitch = UInt8[]
        end
        # take every first note of each pitch
        if !(note.value in pitch)
            push!(firstnotes.notes, note)
            push!(pitch, note.value)
        end
    end
    return firstnotes
end


"""
    purgepitches!(notes::MIDI.Notes, allowedpitch::Array{UInt8})

Remove all notes that do not have a pitch specified in `allowedpitch`.
"""
function purgepitches!(notes::MIDI.Notes, allowedpitch::Array{UInt8})
    deletes = Int[]
    for i ∈ 1:length(notes)
        !(notes[i].value ∈ allowedpitch) && push!(deletes, i)
    end
    deleteat!(notes.notes, deletes)
    return notes
end

"""Same as `purgepitches!` but returns a copy instead."""
purgepitches(notes::MIDI.Notes, allowedpitch::Array{UInt8}) =
    purgepitches!(deepcopy(notes), allowedpitch)



"""
    separatepitches(notes::Notes)

Get a dictionary \"pitch\"=>\"notes of that pitch\".
"""
function separatepitches(notes::Notes{N}) where {N}
    separated = Dict{UInt8, Notes{N}}()
    for note in notes
        if haskey(separated, note.value)
            push!(separated[note.value], deepcopy(note))
        else
            push!(separated, note.value => Notes{N}(Vector{N}[], notes.tpq))
            push!(separated[note.value], deepcopy(note))
        end
    end
    return separated
end
