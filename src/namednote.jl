using MIDI: AbstractNote,name_to_pitch
export NamedNote

"""
    NamedNote(name, pitch, velocity, position, duration, channel = 0) <: AbstractNote
Mutable data structure describing a music note with certain pitch name. A bundle of many notes results
in the [`Notes`](@ref) struct, which is the output of the [`getnotes`](@ref)
function.

If the `channel` of the note is `0` (default), it is not shown.

You can also create a `NamedNote` with the following keyword constructor:
```julia
NamedNote(pitch_name::String; position = 0, velocity = 100, duration = 960, channel = 0)
```

Warning: We use attribute `pitch`,`duration`,`position`,`channel`,`velocity` to compare `AbstractNote` value equality. So:

``` julia
NamedNote("Db5") == NamedNote("C#5")
```

## Fields:
* `name::String` : Pitch name.
* `pitch::UInt8` : Pitch, starting from C-1 = 0, adding one per semitone.
  Use the functions [`name_to_pitch`](@ref) and
  [`pitch_to_name`](@ref) for integer and string representations.
* `velocity::UInt8` : Dynamic intensity. Cannot be higher than 127 (0x7F).
* `position::UInt` : Position in absolute time (since beginning of track), in ticks.
* `duration::UInt` : Duration in ticks.
* `channel::UInt8 = 0` : Channel of the track that the note is played on.
  Cannot be higher than 127 (0x7F).
"""
mutable struct NamedNote <: AbstractNote
    name::String
    pitch::UInt8
    velocity::UInt8
    position::UInt
    duration::UInt
    channel::UInt8

    NamedNote(name, pitch, velocity, position, duration, channel = 0) =
        if channel > 0x7F
            error( "Channel must be less than 128" )
        elseif velocity > 0x7F
            error( "Velocity must be less than 128")
            # check if match the regex
        elseif !occursin(r"^[A-G][#b]?\d?$",name)
            error("Invalid note pitch name")
        elseif name_to_pitch(name) != pitch
            error("The note name does not match the pitch")
        else
            if !isnumeric(name[end])
                name *= "5"
            end
            
            # store flat use "♭", store sharp use "♯"
            if name[end-1] == "b"
                name = replace(name,"b"=>"♭")
            elseif name[end-1] == "#"
                name = replace(name,"#"=>"♯")
            end

            new(name, pitch, velocity, position, duration, channel)
        end
end

NamedNote(pitch_name::String; position = 0, velocity = 100, duration = 960, channel = 0) = 
    NamedNote(pitch_name, name_to_pitch(pitch_name), velocity, position, duration, channel)

function Base.show(io::IO, note::NamedNote) 
    nn = rpad(note.name, 3)
    chpr = note.channel == 0 ? "" : " | channel $(note.channel)"
    velprint = rpad("vel = $(Int(note.velocity))", 9)
    print(io, "NamedNote $nn | $velprint | "*
    "pos = $(Int(note.position)), "*
    "dur = $(Int(note.duration))"*chpr)
end