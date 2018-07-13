# module MusicSequences
using MusicManipulations

export random_sequence

function timesort(notes::Notes)
    issorted(notes, by = x -> x.position) && return notes
    return Notes(sort(notes.notes, by = x -> x.position), notes.tpq)
end

function motif_limits(notes::Notes)
    start = minimum(n.position for n in notes)
    fine  = maximum(n.position + n.duration for n in notes)
    return (start, fine)
end

function motifs_at_origin(motifs::Vector{<:Notes})
    motifs0 = similar(motifs)
    motiflens = zeros(Int, length(motifs))
    for i in 1:length(motifs)
        start, fine = motif_limits(motifs[i])
        motifs0[i] = translate(motifs[i], -start)
        motiflens[i] = fine - start
    end
    return motifs0, motiflens
end

function random_sequence(motifs::Vector{<:Notes}, q)
    idxs = 1:length(motifs)
    ifs0, motiflens = motifs_at_origin(motifs)

end

# Dummy sequence
sixt = subdivision(16, 960)
snare = 0x26
tom1 = 0x30
tom3 = 0x2b

m1 = Note(tom1, 100, 0, sixt)
motif1 = [
Note(tom1, 100, 0, sixt),
Note(snare, 100, sixt, sixt),
Note(snare, 100, 2sixt, sixt),
Note(snare, 100, 3sixt, sixt),
Note(snare, 100, 4sixt, sixt)
]
motif2 = [
Note(tom1, 100, 0, sixt),
Note(snare, 100, sixt, sixt),
Note(tom1, 100, 2sixt, sixt),
Note(snare, 100, 3sixt, sixt),
Note(snare, 100, 4sixt, sixt)
]
motif3 = [
Note(tom1, 100, 0, sixt),
Note(snare, 100, sixt, sixt),
Note(snare, 100, 3sixt, sixt),
]
motif4 = [
Note(tom1, 100, 0, sixt),
Note(snare, 100, sixt, sixt),
Note(snare, 100, 2sixt, sixt),
Note(snare, 100, 3sixt, sixt),
]

motifs = Notes.([motif1, motif2, motif3, motif4], 960)

# end
