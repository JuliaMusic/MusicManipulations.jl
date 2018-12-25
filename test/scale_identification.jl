include("scale_identification.jl")
using Test
readdlm(s3)

@test ScaleIdentification(scales, s3) == Pair("B Major/G# minor", ["C#", "D#", "E", "F#", "G#", "A#", "B"])
@test MostFrenquentNotes(s3) == Any["G", "C", "F", "D#", "A#", "D", "A"]
@test MIDI_to_notes([50,2,60,4,5,6,7,8,9,10,20,30]) == Any["D", "D", "C", "E", "F", "F#", "G", "G#", "A", "A#", "G#", "F#"]
