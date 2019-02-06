using Test

tester = getnotes(readMIDIFile(recording_uwe_2.mid),1)
@test ScaleIdentification(scales, tester) == ("A# Major/G minor", ["C", "D", "D#", "F", "G", "A", "A#"])
