module MusicManipulations

using StatsBase, Distributions
using Reexport
@reexport using MIDI

include("drummap.jl")
include("clipping_recovery.jl")
include("drum_statistics.jl")
include("note_processing.jl")
include("midifiles.jl")
include("quantize.jl")
include("statistics.jl")
include("jazz.jl")
export Jazz

end
