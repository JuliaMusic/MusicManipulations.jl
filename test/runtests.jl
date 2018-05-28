if current_module() == Main
    using MusicManipulations
end
using MIDI
using Base.Test

cd(@__DIR__)

midi = readMIDIfile("serenade_full.mid")
piano = midi.tracks[4]
notes = getnotes(piano, midi.tpq)

include("midiio.jl")
include("quantizer_tests.jl")
include("timeseries.jl")
