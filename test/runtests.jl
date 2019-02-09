using MusicManipulations
using MIDI
using Test

cd(@__DIR__)

include("midiio.jl")
include("quantizer_tests.jl")
include("timeseries.jl")
include("data_extraction.jl")
include("scale_tests.jl")
