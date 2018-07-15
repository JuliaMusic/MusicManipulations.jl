using MotifSequenceGenerator

export random_notes_sequence

function notes_limits(notes::Notes)
    start = minimum(n.position for n in notes)
    fine  = maximum(n.position + n.duration for n in notes)
    return (start, fine)
end

"""
    random_notes_sequence(motifs::Vector{Notes{N}}, q)
Create a random sequence from a pool of notes (`motifs`) such that
it has total length exactly `q`. Notice that `q` is measured in **ticks**.

Return the result as a single `Notes` container.

This function uses [`random_sequence`](@ref) from the module
[`MotifSequenceGenerator`](@ref), adapted to the `Notes` struct.
"""
function random_notes_sequence(motifs::Vector{Notes{N}}, q) where N

    tpq = motifs[1].tpq
    any(x -> x != tpq, notes.tpq for notes in motifs) && throw(ArgumentError("
    The pool of motifs does no share the same `tpq`."))

    res = random_sequence(motifs, q, notes_limits, translate)
    ret = N[]
    for notes in res
        append!(N, notes.notes)
    end
    return Notes(ret, motifs[1].tpq)
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
Note(snare, 100, 2sixt, sixt),
]
motif4 = [
Note(tom1, 100, 0, sixt),
Note(snare, 100, sixt, sixt),
Note(snare, 100, 2sixt, sixt),
Note(snare, 100, 3sixt, sixt),
]

motifs = Notes.([motif1, motif2, motif3, motif4], 960)
export motifs

# function minimum_subdivision(motifs::Vector{M}) where {M<:Notes}
#     Int(minimum(minimum(n.duration for n in notes) for notes in motifs))
# end
# q % minimum_subdivision(motifs) == 0 || throw(ArgumentError("
# Given window `q` is not divisible by the minimum subdivision present in `motifs`."))
