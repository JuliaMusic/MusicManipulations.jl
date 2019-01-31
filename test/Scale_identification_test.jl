using Test

tester = pitches(getnotes(readMIDIfile(recording_uwe_2.mid),1))
@test ScaleIdentification(scales, tester) == ("A# Major/G minor", ["C", "D", "D#", "F", "G", "A", "A#"])
@test MostFrenquentNotes(tester) == Any[55, 60, 65, 67, 72, 63, 77]
@test MIDI_to_notes([50,2,60,4,5,6,7,8,9,10,20,30]) == Any["D", "D", "C", "E", "F", "F#", "G", "G#", "A", "A#", "G#", "F#"]
