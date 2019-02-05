using MIDI


"""
    MIDI_to_notes

Returns the note names of an array of MIDI pitch value, inside of single octave.

Example :
julia> Midi_to_notes([0,13,26])
["C","C","C"]

"""
function MIDI_to_notes(MIDInotes)
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
    most_frenquent_notes(notes)

Takes an Array representing musical notes
and returns the 7 most frequent values from this array.

"""
function most_frenquent_notes(notes)
    occurency = sort(Dict(value => key for (key, value) in countmap(notes)), rev = true)
     most_frequent = values(occurency)
    return most_frequent[1:7]
end

"""
    scale_identification(scales, notes)

Takes an Array of MIDI pitches (ranging from 0 to 127) and returns the most probable scale it belongs to.
If the scale is unknown or the piece contains several tonality, will return : 
"Unregistered exotic scale or atonal/modulating musical piece"

"""
function scale_identification(scales, MIDInotes)
    notes = MIDI_to_notes(MIDInotes)
    for (k,v) in scales
        tester = true
        for n in most_frenquent_notes(notes)
            if n ∉ v
                tester = false
            end
        end
        if tester == true
            return k,v
            break
        end
    end
    if tester == false
        print("Unregistered exotic scale or atonal/modulating musical piece")
    end
end

const scales = Dict{String, Vector{String}}()

scales["C Major/A minor"] = ["C", "D", "E", "F", "G", "A", "B"]
scales["C# Major/A# minor"] = ["C", "C#", "D#", "F", "F#", "G#", "A#"]
scales["D Major/B minor"] = ["C#", "D", "E", "F#", "G", "A", "B"]
scales["D# Major/C minor"] = ["C", "D", "D#", "F", "G", "G#", "A#"]
scales["E Major/C# minor"] = ["C#", "D#", "E", "F#", "G#", "A", "B"]
scales["F Major/D minor"] = ["C", "D", "E", "F", "G", "A", "A#"]
scales["F# Major/D# minor"] = ["C#", "D#", "F", "F#", "G#", "A#", "B"]
scales["G Major/E minor"] = ["C", "D", "E", "F#", "G", "A", "B"]
scales["G# Major/F minor"] = ["C","C#", "D#", "F", "G", "G#", "A#"]
scales["A Major/F# minor"] = ["C#", "D", "E", "F#", "G#", "A", "B"]
scales["A# Major/G minor"] = ["C", "D", "D#", "F", "G", "A", "A#"]
scales["B Major/G# minor"] = ["C#", "D#", "E", "F#", "G#", "A#", "B"]
scales["C minor harmonic"] = ["C", "D", "D#", "F", "G", "G#", "B"]
scales["C# minor harmonic"] = ["C", "C#","D#", "E", "F#", "G#", "A"]
scales["D minor harmonic"] = ["C#", "D", "E", "F", "G", "A", "A#"]
scales["D# minor harmonic"] = ["B", "D", "D#", "F", "F#", "G#", "A#"]
scales["E minor harmonic"] = ["C", "D#", "E", "F#", "G", "A", "B"]
scales["F minor harmonic"] = ["C", "C#", "E", "F", "G", "G#", "A#"]
scales["F# minor harmonic"] =  ["C#", "D", "F", "F#", "G#", "A", "B"]
scales["G minor harmonic"] = ["C", "D", "D#", "F#", "G", "A", "A#"]
scales["G# minor harmonic"] = ["C#", "D#", "E", "G", "G#", "A#", "B"]
scales["A minor harmonic"] = ["C", "D", "E", "F", "G#", "A", "B"]
scales["A# minor harmonic"] = ["C", "C#", "D#", "F", "F#", "A", "A#"]
scales["B minor harmonic"] = ["C#", "D", "E", "F#", "G", "A#", "B"]
scales["C minor melodic"] = ["C", "D", "D#", "F", "G", "A", "B"]
scales["C# minor melodic"] = ["C", "C#","D#", "E", "F#", "G#", "A#"]
scales["D minor melodic"] = ["C#", "D", "E", "F", "G", "A", "B"]
scales["D# minor harmonic"] = ["C", "D", "D#", "F", "F#", "G#", "A#"]
scales["E minor melodic"] = ["C#", "D#", "E", "F#", "G", "A", "B"]
scales["F minor melodic"] = ["C", "D", "E", "F", "G", "G#", "A#"]
scales["F# minor melodic"] =  ["C#", "D#", "F", "F#", "G#", "A", "B"]
scales["G minor melodic"] = ["C", "D", "E", "F#", "G", "A", "A#"]
scales["G# minor melodic"] = ["C#", "D#", "F", "G", "G#", "A#", "B"]
scales["A minor melodic"] = ["C", "D", "E", "F#", "G#", "A", "B"]
scales["A# minor melodic"] = ["C", "C#", "D#", "F", "G", "A", "A#"]
scales["B minor melodic"] = ["C#", "D", "E", "F#", "G#", "A#", "B"]
