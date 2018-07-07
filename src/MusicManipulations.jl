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

using Requires
@require PyPlot="d330b81b-6aea-500a-939a-2ce795aea3ee" begin
    include("visualize.jl")
end

export Jazz, Drums

end
