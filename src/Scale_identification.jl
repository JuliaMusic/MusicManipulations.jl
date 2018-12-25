using DelimitedFiles
using Statistics
using StatsBase
using MIDI
using MusicManipulations

"""
    MIDI_to_notes

Returns the pitch of an array of MIDI note value, inside of single octave.

Example :
julia> Midi_to_notes([0,13,26])
["C","C","C"]

"""
function MIDI_to_notes(MIDInotes::Array{})
    name = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    MIDIrange = []
    for i in range(-1,12)
        for note in name
            push!(MIDIrange,note)
        end
    end
    notes = []
    for n in MIDInotes
        push!(notes,MIDIrange[n+1])
    end
    return notes
end


"""
    MostfrequentNotes(notes)

Takes an Array representing musical notes
and returns the 7 most frequent values from this array.

"""
function MostFrenquentNotes(notes::Array{})
    occurency = sort(Dict(value => key for (key, value) in countmap(notes)), rev = true)
    most_frequent_notes = Any[n for n in values(occurency)]
    return most_frequent_notes[1:7]
end

"""
    ScaleIdentification(scales, notes::Array{})

Takes an Array representing musical notes and returns the most probable scale it belongs to.

"""
function ScaleIdentification(scales, notes::Array{})
    for s in scales
        tester = true
        for sn in s
            for n in MostFrenquentNotes(notes)
                if n != sn
                    test = false
                end
            end
        end
        if tester == true
            return s
            break
        end
    end
end

scales = Dict()
# Common western scales
scales["C Major/A minor"] = ["C", "D", "E", "F", "G", "A", "B"]
scales["C# Major/A# minor"] = ["C", "C#", "D#", "F", "F#", "G#", "A#"]
scales["D Major/B minor"]=["C#", "D", "E", "F#", "G", "A", "B"]
scales["D# Major/C minor"]=["C", "D", "D#", "F", "G", "G#", "A#"]
scales["E Major/C# minor"]=["C#", "D#", "E", "F#", "G#", "A", "B"]
scales["F Major/D minor"]=["C", "D", "E", "F", "G", "A", "A#"]
scales["F# Major/D# minor"]=["C#", "D#", "F", "F#", "G#", "A#", "B"]
scales["G Major/E minor"]=["C", "D", "E", "F#", "G", "A", "B"]
scales["G# Major/F minor"]=["C","C#", "D#", "F", "G", "G#", "A#", "B"]
scales["A Major/F# minor"]=["C#", "D", "E", "F#", "G#", "A", "B"]
scales["A# Major/G minor"]=["C", "D", "D#", "F", "G", "A", "A#"]
scales["B Major/G# minor"]=["C#", "D#", "E", "F#", "G#", "A#", "B"]
# Minor harmonic scales
#scales["C minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["C# minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["D minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["D# minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["E minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["F minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["F# minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["G minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["G# minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["A minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["A# minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
#scales["B minor"]=["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
# Minor melodic scales

export MIDI_to_cat, MIDI_to_notes, MIDI_to_spectral


