export getnotes2, Note2, Notes2

# provide support for extra velocities
# ----------------------------------------------


# all pitches that support extra velocities
digital = [0x26,0x28,0x33,0x35,0x3b]

"""
    getnotes2(track::MIDITrack, tpq = 960)

Get notes from midi track. Take care of Roland TD-50's ability to have velocities up to 159 for snare and ride.
"""
function getnotes2(track::MIDI.MIDITrack, tpq = 960)
    notes = Note2[]
    tracktime = UInt(0)
    extravel = 0
    for (i, event) in enumerate(track.events)
        tracktime += event.dT
        # Read through events until a noteon with velocity higher tha 0 is found
        if isa(event, MIDIEvent) && event.status & 0xF0 == NOTEON && event.data[2] > 0
            duration = UInt(0)
            #Test if the next event is an extra velocity event and modify velocity if needed.
            if event.data[2]==0x7f && track.events[i+1].status==0xb0 && track.events[i+1].data[1]==0x58
                extravel = floor(UInt8,track.events[i+1].data[2]/2)
                if extravel > 32
                    extravel = 32
                end
            end
            #Test if the previous event is an extra velocity event and modify velocity if needed.
            if i>2 #first event is alwas METAEvent
                if event.data[2]==0x7f && track.events[i-1].status==0xb0 && track.events[i-1].data[1]==0x58
                    extravel = floor(UInt8,track.events[i-1].data[2]/2)
                    if extravel > 32
                        extravel = 32
                    end
                end
            end
            for event2 in track.events[i+1:length(track.events)]
                duration += event2.dT
                # If we have a MIDI event & it's a noteoff (or a note on with 0 velocity), and it's for the same note as the first event we found, make a note
                # Many MIDI files will encode note offs as note ons with velocity zero
                if isa(event2, MIDI.MIDIEvent) && (event2.status & 0xF0 == MIDI.NOTEOFF || (event2.status & 0xF0 == MIDI.NOTEON && event2.data[2] == 0)) && event.data[1] == event2.data[1]
                    push!(notes, Note2(event.data[1], duration, tracktime, event.status & 0x0F, event.data[2]+extravel))
                    break
                end
            end
            extravel = 0
        end
    end
    sort!(notes, lt=((x, y)->x.position<y.position))
    return Notes(notes, tpq)
end

"""
    Note2

Enables velocities higher than 127. Rest stays the same, see documentation of `MIDI.Note`.
"""
mutable struct Note2 <: AbstractNote
    value::UInt8
    duration::UInt
    position::UInt
    channel::UInt8
    velocity::UInt8

    Note2(value, duration, position, channel, velocity=0x7F) =
        if channel > 0x7F
            error( "Channel must be less than 128" )
        elseif velocity > 0x9F
            error( "Velocity must be less than 160" )
        else
            new(value, duration, position, channel, velocity)
        end
end


import Base.+, Base.-, Base.==

+(n::Note2, i::Integer) = Note2(n.value + i, n.duration, n.position, n.channel, n.velocity)
+(i::Integer, n::Note2) = n + i

-(n::Note2, i::Integer) = Note2(n.value - i, n.duration, n.position, n.channel, n.velocity)
-(i::Integer, n::Note2) = n - i

==(n1::Note2, n2::Note2) =
    n1.value == n2.value &&
    n1.duration == n2.duration &&
    n1.position == n2.position &&
    n1.channel == n2.channel &&
    n1.velocity == n2.velocity
