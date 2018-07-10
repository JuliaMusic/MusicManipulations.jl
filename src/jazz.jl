module Jazz
using MIDI, MusicManipulations

"""
```julia
average_swing_ratio(notes::Notes, asr_method::String)
```
Calculate the average swing ratio of given `notes` array. Return the average
swing ratio and the associated standard deviation.
## Methods
### `"swung8s"`
Classify each note with the grid `[0, 2//3, 1]`. Use the notes with
index 2 to calculate the swing ratio, and then average for all.
### `"triplets"`
Classify each note with the grid `[0, 1//3, 2//3, 1]`. Use the notes with
index 3 to calculate the swing ratio, and then average for all.
"""
function average_swing_ratio(notes::Notes, asr_method::String)

    tpq = notes.tpq
    sr = Float64[]

    # Create array of Swing Notes
    if asr_method == "swung8s"
        s = classify(notes, [0, 2//3, 1])
        swingnotes = notes.notes[s .== 2]
    elseif asr_method == "triplets"
        s = classify(notes, [0, 1//3, 2//3, 1])
        swingnotes = notes.notes[s .== 3]
    end

    # Create Swing ratios array
    for i in 1:length(swingnotes)
        pos = Int64(swingnotes[i].position)
        posmod = mod(pos, tpq)
        push!(sr, posmod/(tpq-posmod))
    end

    return mean(sr), std(sr)
end



function inbetween_portion(notes::Notes)
  clas = classify(notes, [0, 1//3, 2//3, 1])
  count(i -> i == 2, clas)/length(notes)
end

end
