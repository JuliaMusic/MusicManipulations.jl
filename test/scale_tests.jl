using Test
using MusicManipulations: scale_identification

tester = getnotes(readMIDIFile(joinpath(@__DIR__, "recording_uwe_2.mid")),1)
@test scale_identification(tester) == "A♯ Major/G minor"
