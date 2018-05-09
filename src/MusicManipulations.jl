module MusicManipulations

using Reexport
@reexport using MIDI

import MIDI: Notes, Note

include("midifiles.jl")
include("quantize.jl")
include("note_processing.jl")
include("jazz.jl")
include("drums.jl")

export Jazz, Drums

end
