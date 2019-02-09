using MIDI
using StatsBase

# export scale_identification, SCALES
export note_to_fundamental, pitch_frequency

const SCALES = Dict{String, Vector{String}}()

SCALES["C Major/A minor"] = ["C", "D", "E", "F", "G", "A", "B"]
SCALES["C♯ Major/A♯ minor"] = ["C", "C♯", "D♯", "F", "F♯", "G♯", "A♯"]
SCALES["D Major/B minor"] = ["C♯", "D", "E", "F♯", "G", "A", "B"]
SCALES["D♯ Major/C minor"] = ["C", "D", "D♯", "F", "G", "G♯", "A♯"]
SCALES["E Major/C♯ minor"] = ["C♯", "D♯", "E", "F♯", "G♯", "A", "B"]
SCALES["F Major/D minor"] = ["C", "D", "E", "F", "G", "A", "A♯"]
SCALES["F♯ Major/D♯ minor"] = ["C♯", "D♯", "F", "F♯", "G♯", "A♯", "B"]
SCALES["G Major/E minor"] = ["C", "D", "E", "F♯", "G", "A", "B"]
SCALES["G♯ Major/F minor"] = ["C","C♯", "D♯", "F", "G", "G♯", "A♯"]
SCALES["A Major/F♯ minor"] = ["C♯", "D", "E", "F♯", "G♯", "A", "B"]
SCALES["A♯ Major/G minor"] = ["C", "D", "D♯", "F", "G", "A", "A♯"]
SCALES["B Major/G♯ minor"] = ["C♯", "D♯", "E", "F♯", "G♯", "A♯", "B"]
SCALES["C minor harmonic"] = ["C", "D", "D♯", "F", "G", "G♯", "B"]
SCALES["C♯ minor harmonic"] = ["C", "C♯","D♯", "E", "F♯", "G♯", "A"]
SCALES["D minor harmonic"] = ["C♯", "D", "E", "F", "G", "A", "A♯"]
SCALES["D♯ minor harmonic"] = ["B", "D", "D♯", "F", "F♯", "G♯", "A♯"]
SCALES["E minor harmonic"] = ["C", "D♯", "E", "F♯", "G", "A", "B"]
SCALES["F minor harmonic"] = ["C", "C♯", "E", "F", "G", "G♯", "A♯"]
SCALES["F♯ minor harmonic"] =  ["C♯", "D", "F", "F♯", "G♯", "A", "B"]
SCALES["G minor harmonic"] = ["C", "D", "D♯", "F♯", "G", "A", "A♯"]
SCALES["G♯ minor harmonic"] = ["C♯", "D♯", "E", "G", "G♯", "A♯", "B"]
SCALES["A minor harmonic"] = ["C", "D", "E", "F", "G♯", "A", "B"]
SCALES["A♯ minor harmonic"] = ["C", "C♯", "D♯", "F", "F♯", "A", "A♯"]
SCALES["B minor harmonic"] = ["C♯", "D", "E", "F♯", "G", "A♯", "B"]
SCALES["C minor melodic"] = ["C", "D", "D♯", "F", "G", "A", "B"]
SCALES["C♯ minor melodic"] = ["C", "C♯","D♯", "E", "F♯", "G♯", "A♯"]
SCALES["D minor melodic"] = ["C♯", "D", "E", "F", "G", "A", "B"]
SCALES["D♯ minor harmonic"] = ["C", "D", "D♯", "F", "F♯", "G♯", "A♯"]
SCALES["E minor melodic"] = ["C♯", "D♯", "E", "F♯", "G", "A", "B"]
SCALES["F minor melodic"] = ["C", "D", "E", "F", "G", "G♯", "A♯"]
SCALES["F♯ minor melodic"] =  ["C♯", "D♯", "F", "F♯", "G♯", "A", "B"]
SCALES["G minor melodic"] = ["C", "D", "E", "F♯", "G", "A", "A♯"]
SCALES["G♯ minor melodic"] = ["C♯", "D♯", "F", "G", "G♯", "A♯", "B"]
SCALES["A minor melodic"] = ["C", "D", "E", "F♯", "G♯", "A", "B"]
SCALES["A♯ minor melodic"] = ["C", "C♯", "D♯", "F", "G", "A", "A♯"]
SCALES["B minor melodic"] = ["C♯", "D", "E", "F♯", "G♯", "A♯", "B"]

"""
    note_to_fundamental(note(s))

Return a `String` or `Vector{String}` with the fundamental pitch of the notes
(i.e. without the octave information).
"""
note_to_fundamental(n::AbstractNote) = MIDI.PITCH_TO_NAME[mod(n.pitch, 12)]
note_to_fundamental(notes) = note_to_fundamental.(notes)

"""
    pitch_frequency(notes)

Return the pitches (without octaves) in the given `notes`,
sorted by most to least frequent.
"""
pitch_frequency(notes) = pitch_frequency(note_to_fundamental(notes))
function pitch_frequency(fundamentals::Vector{String})
    occurency = sort(Dict(value => key for (key, value) in countmap(fundamentals)), rev = true)
    most_frequent = collect(values(occurency))
    return most_frequent
end

"""
    scale_identification(notes)

Return the most probable scale that represents the given `notes`.
"""
function scale_identification(notes)
    fund = note_to_fundamental(notes)
    mostfreq = pitch_frequency(fund)[1:7] # only 7 most frequent
    for (k,v) in SCALES
        tester = true
        for n in mostfreq
            if n ∉ v
                tester = false
            end
        end
        if tester == true
            return k
        end
    end
    if tester == false
        error("Atonal/modulating musical key center or Unregistered exotic scale")
    end
end
