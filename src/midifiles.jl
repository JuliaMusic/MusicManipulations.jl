using MIDI
###############################################################################
###############################################################################
# MIDI File manipulation
###############################################################################
###############################################################################

"""
    BPM(midi)
Given a `MIDIFile`, find and return the BPM where it was originally exported.
"""
function BPM(t::MIDI.MIDIFile)
  # META-event list:
  tlist = [x for x in t.tracks[1].events]
  tttttt = Vector{UInt32}
  # Find the one that corresponds to Set-Time:
  for i in 1:length(tlist)
    if typeof(tlist[i]) == MIDI.MetaEvent
      y = tlist[i]
      if y.metatype == 0x51
        tttttt = y.data
      end
    end
  end
  # Get the microsecond number from this tt-tt-tt
  unshift!(tttttt , 0x00)
  u = ntoh(reinterpret(UInt32, tttttt)[1])
  μs = Int64(u)
  # BPM:
  BPM = round(Int64, 60000000/μs)
end

"""
    tick_in_ms(midi) -> ms::Float64
Given a `MIDIFile`, return how many miliseconds is one tick.
"""
function tick_in_ms(midi::MIDI.MIDIFile)
  tpq = midi.timedivision
  BPM = BPM(midi)
  tick_ms = (1000*60)/(BPM*tpq)
end

velocities(notes::Notes) = [Int8(x.velocity) for x in notes]
positions(notes::Notes) = [Int(x.position) for x in notes]
pitches(notes::Notes) = [Int8(x.value) for x in notes]
durations(notes::Notes) = [Int(x.duration) for x in notes]



# TODO: Change this to happen on MIDITRACK and not MIDIFILE!!!
"""
    replace_notes(oldtrack::MIDITrack, notes::Notes) -> newtrack
Create a *new* midi track that copies all `MIDIEvent`s that
are not NOTEON or NOTEOFF from the
`oldtrack` while it also adds all notes from `notes`.
"""
function replace_notes(oldmidi::MIDI.MIDIFile, notes::Notes)
  newmidi = MIDIFile()
  newmidi.format = oldmidi.format
  newmidi.timedivision = oldmidi.timedivision
  push!(newmidi.tracks, oldmidi.tracks[1])

  old_events = oldmidi.tracks[2].events

  # Get pedal events with relative time and absolute time
  pedal_events = MIDI.MIDIEvent[]
  pedal_events_abspos = Int[]
  for i in 1:length(old_events)
    if typeof(old_events[i]) == MIDI.MIDIEvent
      # skip NOTEON and NOTEOFF events of first channel
      if old_events[i].status != 0x80 && old_events[i].status != 0x90
        # Get absolute time of event
        abstime = sum(old_events[k].dT for k in 1:i)

        push!(pedal_events, old_events[i])
        push!(pedal_events_abspos, abstime)
      end
    end
  end

  # Second track will contain the new `notes`
  track2 = MIDI.MIDITrack()
  MIDI.addnotes(track2, notes)

  for j in 1:length(pedal_events)
    MIDI.addevent(track2, pedal_events_abspos[j], pedal_events[j])
  end

  push!(newmidi.tracks, track2)
  return newmidi
end
