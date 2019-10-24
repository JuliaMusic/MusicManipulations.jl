export translate, transpose, louden, randomnotes, subdivision
export velocities, positions, pitches, durations, relpos
export ▷, □, ◇

velocities(notes::Notes) = [Int(x.velocity) for x in notes]
positions(notes::Notes) = [Int(x.position) for x in notes]
pitches(notes::Notes) = [Int(x.pitch) for x in notes]
durations(notes::Notes) = [Int(x.duration) for x in notes]

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

The unicode symbol `▷` (`\\triangleright<tab>`) is equivalent to `translate`.
"""
translate(notes::Notes, ticks) = Notes(translate(notes.notes, ticks), notes.tpq)
translate(notes::Vector{N}, ticks) where {N<:AbstractNote} =
[N(n.pitch, n.velocity, n.position + ticks, n.duration, n.channel) for n in notes]

"""
    translate!(notes, ticks)
In-place version of [`translate`](@ref).
"""
function translate!(notes::Notes, ticks)
    for note in notes
        note.position += ticks
    end
end

▷ = translate

"""
    transpose(notes, semitones)
Transpose the `notes` for the given amount of `semitones`.

The unicode symbol `□` (`\\square`) is equivalent with `transpose`.
"""
Base.transpose(notes::Notes, semitones) =
Notes(transpose(notes.notes, semitones), notes.tpq)
Base.transpose(notes::Vector{N}, semitones) where {N<:AbstractNote} =
[Note(n.pitch + semitones, n.velocity, n.position, n.duration, n.channel) for n in notes]

□(notes::Notes, semitones) = transpose(notes, semitones)
□(notes::Vector, semitones) = transpose(notes, semitones)

"""
    louden(notes, v::Int)
Increase the velocity of the notes by `v`.

The unicode symbol `◇` (`\\mdlgwhtdiamond`) is equivalent with `louden`.
"""
louden(notes::Notes, semitones) =
Notes(louden(notes.notes, semitones), notes.tpq)
louden(notes::Vector{N}, semitones) where {N<:AbstractNote} =
[Note(n.pitch, n.velocity + semitones, n.position, n.duration, n.channel) for n in notes]

◇ = louden

subdivision(n::Int, tpq)::Int = (4*tpq)/n

function timesort(notes::Notes)
    issorted(notes, by = x -> x.position) && return notes
    return Notes(sort(notes.notes, by = x -> x.position), notes.tpq)
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
