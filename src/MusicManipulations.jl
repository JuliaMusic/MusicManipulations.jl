module MusicManipulations

using StatsBase, Distributions
using Reexport
@reexport using MIDI

include("midifiles.jl")
include("quantize.jl")
include("statistics.jl")
include("jazz.jl")
export Jazz

end
