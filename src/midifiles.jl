using MIDI
export velocities, positions, pitches, durations
export replace_notes
###############################################################################
###############################################################################
# MIDI File exporting
###############################################################################
velocities(notes::Notes) = [Int8(x.velocity) for x in notes]
positions(notes::Notes) = [Int(x.position) for x in notes]
pitches(notes::Notes) = [Int8(x.value) for x in notes]
durations(notes::Notes) = [Int(x.duration) for x in notes]



"""
    replace_notes(oldtrack::MIDITrack, notes::Notes) -> newtrack
Create a *new* midi track that copies all `MIDIEvent`s that
are not NOTEON or NOTEOFF from the
`oldtrack` while it also adds all notes from `notes`.
"""
function replace_notes(oldtrack::MIDI.MIDITrack, notes::Notes)

    newtrack = MIDI.MIDITrack()
    old_events = oldtrack.events

    # Get pedal events with relative time and absolute time
    other_events = MIDI.MIDIEvent[]
    other_events_abspos = Int[]
    for i in 1:length(old_events)
        if typeof(old_events[i]) == MIDI.MIDIEvent
            # skip NOTEON and NOTEOFF events of first channel
            if old_events[i].status != 0x80 && old_events[i].status != 0x90
                # Get absolute time of event
                abstime = sum(old_events[k].dT for k in 1:i)

                push!(other_events, old_events[i])
                push!(other_events_abspos, abstime)
            end
        end
    end

    # Second track will contain the new `notes`
    MIDI.addnotes(newtrack, notes)

    for j in 1:length(other_events)
        MIDI.addevent(newtrack, other_events_abspos[j], other_events[j])
    end

    return newtrack
end
