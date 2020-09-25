export translate, transpose, louden, randomnotes, subdivision
export velocities, positions, pitches, durations, relpos
export timesort, timesort!, combine

velocities(notes::Notes) = [Int(x.velocity) for x in notes]
positions(notes::Notes) = [Int(x.position) for x in notes]
pitches(notes::Notes) = [Int(x.pitch) for x in notes]
durations(notes::Notes) = [Int(x.duration) for x in notes]

using Random

"""
    randomnotes(n::Int, tpq = 960)
Generate some random notes that start sequentially.
"""
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
    translate(notes, ticks)
Translate the `notes` for the given amount of `ticks`.
Also works for a single note.
"""
translate(notes::Notes, ticks) = Notes(translate(notes.notes, ticks), notes.tpq)
translate(notes::Vector{N}, ticks) where {N<:AbstractNote} =
[N(n.pitch, n.velocity, n.position + ticks, n.duration, n.channel) for n in notes]
translate(n::N, ticks) where {N<:AbstractNote} =
N(n.pitch, n.velocity, n.position+ticks, n.duration, n.channel)

"""
    translate!(notes, ticks)
In-place version of [`translate`](@ref).
"""
function translate!(notes::Notes, ticks)
    for note in notes
        note.position += ticks
    end
end

"""
    transpose(notes, semitones)
Transpose the `notes` by the given amount of `semitones`.
Also works for a single note.
"""
Base.transpose(notes::Notes, semitones) =
Notes(transpose(notes.notes, semitones), notes.tpq)
Base.transpose(notes::Vector{N}, semitones) where {N<:AbstractNote} =
[Note(n.pitch + semitones, n.velocity, n.position, n.duration, n.channel) for n in notes]
Base.transpose(n::N, ticks) where {N<:AbstractNote} =
N(n.pitch+ticks, n.velocity, n.position, n.duration, n.channel)

"""
    louden(notes, v::Int)
Change the velocity of the notes by `v` (which could also be negative).
Also works for a single note.
"""
louden(notes::Notes, v) =
Notes(louden(notes.notes, v), notes.tpq)
louden(notes::Vector{N}, v) where {N<:AbstractNote} =
[Note(n.pitch, n.velocity + v, n.position, n.duration, n.channel) for n in notes]
louden(n::N, ticks) where {N<:AbstractNote} =
N(n.pitch, n.velocity+ticks, n.position, n.duration, n.channel)

"""
    timesort!(notes::Notes)
In-place sort the `notes` by their temporal position.
Use `timesort` for a non-mutating version.
"""
function timesort!(notes::Notes)
    sort!(notes.notes, by = x -> x.position)
    return notes
end
timesort(notes) = timesort!(copy(notes))

"""
    combine(note_container) -> notes
Combine the given container (either `Array{Notes}` or `Dict{Any, Notes}`) into
a single `Notes` instance. In the process, sort the notes by position in the
final container.
"""
function combine(notearray::AbstractArray{<:Notes}, tsort = true)
    notes = copy(notearray[1])
    for i in 2:length(notearray)
        append!(notes, notearray[i])
    end
    tsort && timesort!(notes)
    return notes
end

function combine(notearray::AbstractArray{<:AbstractArray{<:AbstractNote}}, tsort=true)
    notes = copy(notearray[1])
    for i in 2:length(notearray)
        append!(notes, notearray[i])
    end
    tsort && timesort!(notes)
    return notes
end

function combine(notedict::Dict{<:Any, Notes{N}}, tsort = true) where {N}
    n = Notes(N[], first(values(notedict)).tpq)
    for (k, v) in notedict
        append!(n, v)
    end
    tsort && timesort!(n)
    return n
end


"""
    relpos(notes::Notes, grid)
Return the *relative* positions of the notes with respect to the current
`grid`, i.e. all notes are brought within one quarter note.
"""
function relpos(notes::Notes, grid)
    tpq = notes.tpq
    c = (grid[end-1] + (1 - grid[end-1])/2) * tpq
    rpos = zeros(Int, length(notes))
    for (i, n) in enumerate(notes)
        m = mod1(Int(n.position), tpq)
        if m ≥ c
            rpos[i] = m - tpq
        else
            rpos[i] = m
        end
    end
    return rpos
end

"""
    repeat(notes, i = 1)
Repeat the `notes` `i` times, by successively adding duplicates of `notes`
shifted by the total duration of `notes`. Return a single `Notes` container
for convenience.

The function assumes that notes are `timesort`ed.
"""
Base.repeat(n::Notes, i::Int = 1) = Notes(repeat(n.notes, i), n.tpq)
function Base.repeat(n::Vector{<:AbstractNote}, i::Int = 1)
    maxdur = maximum(a.position + a.duration for a in n)
    r = [copy(n)]
    for j in 1:i
        push!(r, translate(r[end], maxdur))
    end
    return combine(r, false)
end
