let

rnotes = randomnotes(1000)
coun = Int[]
pit = pitches(rnotes)
pitchdict = Dict(pitch => count(x->x == pitch, pit) for pitch in pit)

@testset "allowed pitches" begin

    allowed = unique(pit)[1:2]
    anotes = allowedpitches(rnotes, allowed)
    @test length(anotes) > 0
    @test length(anotes) == pitchdict[allowed[1]] + pitchdict[allowed[2]]
    for note ∈ anotes
        @test note.pitch ∈ allowed
    end

end
@testset "separate pitches" begin
    sep = separatepitches(rnotes)
    sepa = Int[]
    for pitch in unique(pitches(rnotes))
        push!(sepa, length(sep[pitch]))
    end

    @test sort(collect(keys(sep))) == sort(unique(pitches(rnotes)))
    @test sepa == coun
end
end
