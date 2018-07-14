# module MusicSequences
# using MusicManipulations

using Combinatorics

export random_sequence

struct DeadEndMotifs <: Exception
  tries::Int
  recursion::Int
end
Base.show(io::IO, e::DeadEndMotifs) = print(io,
"Couldn't find a proper sequence with $(e.tries) random tries, "*
"each with a recursion level of $(e.recursion).")

function minimum_subdivision(motifs::Vector{Notes{N}}) where {N}
    Int(minimum(minimum(n.duration for n in notes) for notes in motifs))
end


function timesort(notes::Notes)
    issorted(notes, by = x -> x.position) && return notes
    return Notes(sort(notes.notes, by = x -> x.position), notes.tpq)
end

function motif_limits(notes::Notes)
    start = minimum(n.position for n in notes)
    fine  = maximum(n.position + n.duration for n in notes)
    return (start, fine)
end

"""
Bring all motifs to the origin (starting position of earliest note)
and compute the motif lengths.
"""
function _motifs_at_origin(motifs::Vector{<:Notes})
    motifs0 = similar(motifs)
    motiflens = zeros(Int, length(motifs))
    for i in 1:length(motifs)
        start, fine = motif_limits(motifs[i])
        motifs0[i] = start == 0 ? motifs[i] : translate(motifs[i], -start)
        motiflens[i] = fine - start
    end
    return motifs0, motiflens
end

"""
Return a random sequence of motifs (that have lengths `motiflens`)
so that the total sequence is *guaranteed* `q ≤ s ≤ q - maximum(motiflens)`.
"""
function _random_sequence_try(motiflens, q)
    seq = Int[]; seq_length = 0; idxs = 1:length(motifs)
    while seq_length < q
        i = rand(idxs)
        push!(seq, i)
        seq_length += motiflens[i]
    end
    return seq, seq_length
end

function random_sequence(motifs::Vector{<:Notes}, q; tries = 5, recursion = 3)

    q % minimum_subdivision(motifs) == 0 || throw(ArgumentError("
    Given window `q` is not divisible by the minimum subdivision present in `motifs`."))

    idxs = 1:length(motifs)
    motifs0, motiflens = _motifs_at_origin(motifs)

    worked = false; count = 0
    while worked == false
        count > tries && throw(DeadEndMotifs(tries, recursion))

        seq, seq_length = _random_sequence_try(motiflens, q)
        worked = complete_sequence!(seq, motifs0, motiflens, q, recursion)
        count += 1
    end

    return _instantiate_sequence(motifs0, motiflens, seq)
end

function complete_sequence!(seq, motifs0, motiflens, q, recursion)

    remainder = q - sum(motiflens[k] for k in seq)
    if remainder == 0
        # Case 0: The sequence is already exactly equal to q
        return true
    elseif remainder < 0 && -remainder ∈ motiflens
        # Case 1: There is an extra difference, which is an
        # exact length of some motif.
        # We find the possible motifs, pick a random one, and pick
        # a random position in the sequence that it exists.
        # Delete that entry of the sequence.
        mi = rand(findall((in)(remainder), motiflens))
        possible = findall((in)(mi), seq)
        if !isempty(possible)
            deleteat!(seq, rand(possible))
            return true
        end
    else
        # Case 2: Recursive deletion of last entry of the sequence, and trying to
        # see if it can be completed with some combination of existing motifs
        req = 0
        uniquelens = unique(motiflens)

        while req < recursion
            req += 1
            pop!(seq)
            if remainder ∈ motiflens
                mi = rand(findall((in)(remainder), motiflens))
                push!(seq, mi)
                return true
            else
                allsums = all_possible_sums(uniquelens, (req+1)÷2 + 1)
            end
        end
    end
    return false
end



function all_possible_sums(uniquelens, n)
end



function _instantiate_sequence(motifs0::Vector{Notes{N}}, motiflens, seq) where N<:AbstractNote
    notvec = N[]
    prev = 0
    for s in seq
        append!(notvec, translate(motifs[s].notes, prev))
        prev += motiflens[s]
    end
    return Notes(notvec, motifs0[1].tpq)
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
# end
