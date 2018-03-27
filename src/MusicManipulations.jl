module MusicManipulations

using StatsBase, Distributions
using Reexport
using PyPlot
@reexport using MIDI

include("drummap.jl")
include("clipping_recovery.jl")
include("drum_statistics.jl")
include("midifiles.jl")
include("quantize.jl")
include("statistics.jl")
include("jazz.jl")
export Jazz

# I made a change

end
