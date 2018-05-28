rnotes = randomnotes(1000)

@testset "purge/separate pitches" begin

    pit = pitches(rnotes)
    purg = Int[]
    coun = Int[]
    for pitch in unique(pitches(rnotes))
        push!(purg, length(purgepitches(rnotes, UInt8(pitch))))
        push!(coun, count(x->x == pitch, pit))
    end
    @test purg == coun

    sep = separatepitches(rnotes)
    sepa = Int[]
    for pitch in unique(pitches(rnotes))
        push!(sepa, length(sep[pitch]))
    end

    @test sort(collect(keys(sep))) == sort(unique(pitches(rnotes)))
    @test sepa == coun
end
