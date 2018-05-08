export getfirstnotes, purgepitches!, purgepitches, twonote_distances, rm_hihatfake!

"""
    getfirstnotes(midi::MIDIFile, trackno = 2, septicks = 960)

Get only the first played note of each instrument in a series of notes.
If no note is played for `septicks` ticks, the next following notes are
considered a new series.
"""
function getfirstnotes(midi::MIDIFile, trackno = 2, septicks = 960)
    pitch = UInt8[] #save which pitches allready occurred in current series
    firstnotes = Notes() #container for firstnotes
    notes = getnotes(midi, trackno) #get all notes

    #iterate through all notes
    for (i,note) in enumerate(notes)
        #if the current note is the first of a new series, empty the pitches
        if i>1 && note.position - notes.notes[i-1].position > septicks
            pitch = UInt8[]
        end
        # take every first note of each pitch
        if !(note.value in pitch)
            push!(firstnotes.notes,note)
            push!(pitch,note.value)
        end
    end
    return firstnotes
end


"""
    purgepitches!(notes::MIDI.Notes, allowedpitch::Array{UInt8})

Remove all notes thatdo not have a pitch specified in `allowedpitch`.
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
    twonote_distances(notes::MIDI.Notes, firstpitch::UInt8)

REQIRES: `notes` must contain notes of only two pitches already arranged in pairs.

Get the distances in ticks between the two notes of a pair. Specify which note
is to be considered the \"first\" note with `firstpitch`. If they occur in
different order, the distance is negative.
"""
function twonote_distances(notes::MIDI.Notes, firstpitch::UInt8)
    dist = Int[] #Array for distances

    i = 1  # index of first note of pair
    while i < length(notes) # =length(notes) covered by +1
        # decide how to take the difference between two notes
        if notes[i].value == firstpitch
            push!(dist,notes[i+1].position-notes[i].position)
        else
            # casting to prevent InexactError
            push!(dist,Int(notes[i].position)-Int(notes[i+1].position))
        end
        i += 2
    end

    return dist
end
