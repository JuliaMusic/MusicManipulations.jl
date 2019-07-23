export translate, transpose, randomnotes, subdivision
export velocities, positions, pitches, durations
import Base: transpose, +, -

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

+(notes::Notes, x::Real) = translate(notes, round(Int, x))
-(notes::Notes, x::Real) = translate(notes, -round(Int, x))
+(x::Real, notes::Notes) = notes + x
-(x::Real, notes::Notes) = notes - x

"""
    transpose(notes, semitones)
Transpose the `notes` for the given amount of `semitones`.
"""
transpose(notes::Notes, semitones) = Notes(transpose(notes.notes, semitones), notes.tpq)
transpose(notes::Vector{N}, semitones) where {N<:AbstractNote} =
[Note(n.pitch + semitones, n.velocity, n.position, n.duration, n.channel) for n in notes]

"""
    subdivision(n::Int, tpq)
Return how many ticks is the duration of
the subdivision of a 4/4-bar into `n` equal parts, assuming the ticks per quarter
note are `tpq`.

For example, for sixteenth notes you would do `subdivision(16, tpq)`, for
eigth-note triplets `subdivision(12, tpq)` and so on.
"""
subdivision(n::Int, tpq)::Int = (4*tpq)/n

function timesort(notes::Notes)
    issorted(notes, by = x -> x.position) && return notes
    return Notes(sort(notes.notes, by = x -> x.position), notes.tpq)
end
