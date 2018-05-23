export velocities, positions, pitches, durations
export replace_notes, getnotnotes, modpositions
export MoreVelNote, randomnotes

"""
    MoreVelNote

Enables velocities higher than 127 but other than that identical with [`Note`](@ref).

When [`Notes`](@ref) with `MoreVelNote` are written into a [`MIDITrack`](@ref),
any velocity higher than 127 is equaled to 127.
"""
mutable struct MoreVelNote <: AbstractNote
    pitch::UInt8
    velocity::UInt
    position::UInt
    duration::UInt8
    channel::UInt8


    MoreVelNote(pitch, velocity = 0x7f, position, duration, channel) =
        if channel > 0x7F
            error( "Channel must be less than 128" )
        else
            new(pitch, velocity, position, duration, channel)
        end
end
Notes(::Type{MoreVelNote}) = Notes{MoreVelNote}(Vector{MoreVelNote}[], 960)

velocities(notes::Notes) = [Int(x.velocity) for x in notes]
positions(notes::Notes) = [Int(x.position) for x in notes]
pitches(notes::Notes) = [Int(x.pitch) for x in notes]
durations(notes::Notes) = [Int(x.duration) for x in notes]

function randomnotes(n::Int, tpq = 960)
    notes = Note[]
    prevpos = 0
    durran = 1:tpq
    posran = 0:4*tpq
    for i in 1:n
        note = Note(rand(UInt8), rand(0:127), prevpos + rand(posran), rand(durran), 0)
        push!(notes, note)
        prevpos = note.position
    end
    return Notes(notes, tpq)
end


"""
    replace_notes(oldtrack::MIDITrack, notes::Notes) -> newtrack
Create a *new* midi track that copies all `MIDIEvent`s that
are not NOTEON or NOTEOFF from the
`oldtrack` while it also adds all notes from `notes`.
"""
function replace_notes(oldtrack::MIDI.MIDITrack, notes::Notes)

    newtrack = MIDI.MIDITrack()

    # Get pedal events with relative time and absolute time
    other_events_abspos, other_events = getnotnotes(oldtrack)

    # Second track will contain the new `notes`
    MIDI.addnotes!(newtrack, notes)

    for j in 1:length(other_events)
        MIDI.addevent!(newtrack, other_events_abspos[j], other_events[j])
    end

    return newtrack
end

"""
    getnotnotes(track::MIDI.MIDITrack) -> (abs_pos, events)
Find all events in `track` that are not NOTEON or NOTEOFF.
Return the found events and their positions in absolute time (in ticks).

Each event can be added to another `MIDITrack` using
```julia
for ev in zip(abs_pos, events)
    MIDI.addevent!(newtrack, ev...)
end
```

See also [`replace_notes`](@ref).
"""
function getnotnotes(oldtrack::MIDI.MIDITrack)
    old_events = oldtrack.events
    # Get pedal events with relative time and absolute time
    other_events = MIDI.MIDIEvent[]
    other_events_abspos = Int[]
    for i in 1:length(old_events)
        if typeof(old_events[i]) == MIDI.MIDIEvent
            # skip NOTEON and NOTEOFF events of first channel
            if old_events[i].status != 0x80 && old_events[i].status != 0x90
                # Get absolute time of event
                # This line can be made much more efficient!
                abstime = sum(old_events[k].dT for k in 1:i)

                push!(other_events, old_events[i])
                push!(other_events_abspos, abstime)
            end
        end
    end

    return other_events_abspos, other_events
end
