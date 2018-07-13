module MusicManipulations

using Reexport
@reexport using MIDI
import MIDI: Notes, Note

include("general.jl")
include("midifiles.jl")
include("quantize.jl")
include("data_handling/data_extraction.jl")
include("data_handling/timeseries.jl")
include("specific_modules/jazz.jl")
include("specific_modules/drums.jl")

# include("patterns/MusicSequences.jl")
# @reexport using .MusicSequences

using Requires
@require PyPlot="d330b81b-6aea-500a-939a-2ce795aea3ee" begin
    include("visualize.jl")
end

export Jazz, Drums

end
