using MotifSequenceGenerator

export random_notes_sequence

function notes_limits(notes::Notes)
    start = minimum(n.position for n in notes)
    fine  = maximum(n.position + n.duration for n in notes)
    return (start, fine)
end

"""
    random_notes_sequence(motifs::Vector{Notes{N}}, q, δq = 0; weights)
Create a random sequence from a pool of notes (`motifs`) such that
it has total length `ℓ` exactly `q - δq ≤ ℓ ≤ q + δq`.
Notice that `q` is measured in **ticks**. Optionally pass keyword `weights`
to sample different motifs with different weights (either as frequencies or as
probabilities).

Return the result as a single `Notes` container, and also return the sequence
of motifs used.

This function uses [`random_sequence`](@ref) from the module
[`MotifSequenceGenerator`](@ref), adapted to the [`Notes`](@ref) struct.
"""
function random_notes_sequence(motifs::Vector{Notes{N}}, q, δq = 0;
                               weights = ones(length(motifs))) where N

    tpq = motifs[1].tpq
    any(x -> x != tpq, notes.tpq for notes in motifs) && throw(ArgumentError(
    "The pool of motifs does no share the same `tpq`."))

    res, seq = random_sequence(motifs, q, notes_limits, translate, δq; weights=weights)
    ret = N[]
    for notes in res
        append!(ret, notes.notes)
    end
    return Notes(ret, motifs[1].tpq), seq
end

# function minimum_subdivision(motifs::Vector{M}) where {M<:Notes}
#     Int(minimum(minimum(n.duration for n in notes) for notes in motifs))
# end
# q % minimum_subdivision(motifs) == 0 || throw(ArgumentError("
# Given window `q` is not divisible by the minimum subdivision present in `motifs`."))
