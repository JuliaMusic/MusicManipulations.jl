if current_module() == Main
    using MusicManipulations
end
using MIDI
using Base.Test

cd(@__DIR__)

include("midiio.jl")
include("quantizer_tests.jl")
include("timeseries.jl")
include("data_extraction.jl")
