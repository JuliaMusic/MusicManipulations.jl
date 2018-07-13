import Base.transpose

export translate, transpose, randomnotes, subdivision

function randomnotes(n::Int, tpq = 960, randchannel = false)
    notes = Note[]
    prevpos = 0
    durran = 1:tpq
    posran = 0:4*tpq
    for i in 1:n
        if randchannel
            note = Note(rand(UInt8), rand(0:0x7F), prevpos + rand(posran), rand(durran), rand(0:127))
        else
            note = Note(rand(UInt8), rand(0:127), prevpos + rand(posran), rand(durran))
        end
        push!(notes, note)
        prevpos = note.position
    end
    return Notes(notes, tpq)
end

"""
    translate(notes::Notes, ticks) -> tnotes
Translate the `notes` for the given amount of `ticks`.
"""
translate(notes::Notes, ticks) = [Note(n.pitch, n.velocity, n.position + ticks, n.duration, n.channel) for n in notes]

"""
    transpose(notes::Notes, semitones) -> tnotes
Transpose the `notes` for the given amount of `semitones`.
"""
transpose(notes::Notes, semitones) = [Note(n.pitch + semitones, n.velocity, n.position, n.duration, n.channel) for n in notes]

"""
    subdivision(n::Int, tpq)
Return how many ticks is the duration of
the subdivision of a 4/4-bar into `n` equal parts.

For example, for sixteenth notes you would do `subdivision(16, tpq)`, for
eigth-note triplets `subdivision(12, tpq)` and so on.
"""
subdivision(n::Int, tpq)::Int = (4*tpq)/n
