module MusicSequences
using MusicManipulations

export random_sequence, motif_duration

function timesort(notes::Notes)
    issorted(notes, by = x -> x.position) && return notes
    return Notes(sort(notes.notes, by = x -> x.position), notes.tpq)
end

"""
    motif_duration(notes)
Get the total duration of the `notes` in ticks (from start of first position
to end of final duration).
"""
function motif_duration(notes::Notes)
    start = minimum(n.position for n in notes)
    fine  = maximum(n.position + n.duration for n in notes)
    return (start, fine)
end

function random_sequence(motifs::Vector{<:Notes}, q)
end


end
