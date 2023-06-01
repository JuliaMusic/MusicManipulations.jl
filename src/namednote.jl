using MIDI: name_to_pitch, pitch_to_name, Note
export NamedNote,NamedNotes

"""
    NamedNote(name, velocity, position, duration, channel = 0) <: AbstractNote
Mutable data structure describing a music note with certain pitch name. A bundle of many notes results
in the [`Notes`](@ref) struct, which is the output of the [`getnotes`](@ref)
function.

If the `channel` of the note is `0` (default), it is not shown.

You can also create a `NamedNote` with the following keyword constructor:
```julia
NamedNote(pitch_name::String; position = 0, velocity = 100, duration = 960, channel = 0)
NamedNote(n::Note; pitch_name::String = "")
```

Initialize `Notes{NamedNote}` from a pitch name string, use spaces to separate pitch name.

``` julia
NamedNotes(notes_string::String; tpq::Int = 960)
# NamedNotes("C#6 Db5 E4")
```

Converte `NamedNote` to `Note`:

``` julia
Note(n::NamedNote)
```

Warning: We use attribute `name_to_pitch(name)`,`duration`,`position`,`channel`,`velocity` to compare `NamedNote`. So:

``` julia
NamedNote("Db5") == NamedNote("C#5")
# true
```

## Fields:
* `name::String` : Pitch name, Uppercase.
* `velocity::UInt8` : Dynamic intensity. Cannot be higher than 127 (0x7F).
* `position::UInt` : Position in absolute time (since beginning of track), in ticks.
* `duration::UInt` : Duration in ticks.
* `channel::UInt8 = 0` : Channel of the track that the note is played on.
  Cannot be higher than 127 (0x7F).
"""
mutable struct NamedNote <: AbstractNote
    name::String
    velocity::UInt8
    position::UInt
    duration::UInt
    channel::UInt8

    NamedNote(name, velocity, position, duration, channel = 0) =
        if channel > 0x7F
            error( "Channel must be less than 128" )
        elseif velocity > 0x7F
            error( "Velocity must be less than 128")
            # check if match the regex
        elseif !occursin(r"^[A-G][#b♯♭]?\d?$",name)
            error("Invalid note pitch name")
        else
            if !isnumeric(name[end])
                name *= "5"
            end
            
            # store flat use "♭", store sharp use "♯"
            if name[prevind(name,end,1)] == 'b'
                name = replace(name,"b"=>"♭")
            elseif name[prevind(name,end,1)] == '#'
                name = replace(name,"#"=>"♯")
            end

            new(name, velocity, position, duration, channel)
        end
end

NamedNote(pitch_name::String; position = 0, velocity = 100, duration = 960, channel = 0) = 
    NamedNote(pitch_name, velocity, position, duration, channel)

NamedNote(n::Note; pitch_name::String = "") = 
    length(pitch_name) == 0 ? NamedNote(pitch_to_name(n.pitch), n.position, n.velocity, n.duration, n.channel) : NamedNote(name, n.position, n.velocity, n.duration, n.channel) 

NamedNotes(notes_string::String; tpq::Int = 960) = Notes([NamedNote(String(s)) for s in split(notes_string," ")], tpq)

Note(n::NamedNote) = Note(name_to_pitch(n.pitch), n.position, n.velocity, n.duration, n.channel)

function Base.show(io::IO, note::NamedNote) 
    nn = rpad(note.name, 3)
    chpr = note.channel == 0 ? "" : " | channel $(note.channel)"
    velprint = rpad("vel = $(Int(note.velocity))", 9)
    print(io, "NamedNote $nn | $velprint | "*
    "pos = $(Int(note.position)), "*
    "dur = $(Int(note.duration))"*chpr)
end

import Base.==
==(n1::NamedNote, n2::NamedNote) =
    name_to_pitch(n1.name) == name_to_pitch(n2.name) &&
    n1.duration == n2.duration &&
    n1.position == n2.position &&
    n1.channel == n2.channel &&
    n1.velocity == n2.velocity