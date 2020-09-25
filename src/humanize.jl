using ARFIMA

"""
    humanize!((notes::Notes, d, φ)
Generate pink noise with varying exponents from -0.5 to -1.5.
"""
function humanize!(notes::Notes, property, σ=0.2, noisetype, d=0.25, φ=SVector(-0.5, -1.5))
    if noisetype == :power_law
        if method = :ARFIMA
            noise = arfima(length(notes), σ, d, φ)
        end
        for j in 1:length(noise)
            setproperty!(notes[j], property, getfield(notes[j], property) + floor(noise[j]))
        end
    end
    return notes
end
