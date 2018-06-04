module MusicManipulations

using Reexport
@reexport using MIDI

import MIDI: Notes, Note

include("midifiles.jl")
include("quantize.jl")
include("data_extraction.jl")
include("jazz.jl")
include("drums.jl")
include("timeseries.jl")
include("visualize.jl")

export Jazz, Drums

end
