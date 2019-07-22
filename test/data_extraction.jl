let

rnotes = randomnotes(1000)
coun = Int[]
pit = pitches(rnotes)
pitchdict = Dict(pitch => count(x->x == pitch, pit) for pitch in pit)

@testset "allowed pitches" begin

    allowed = unique(pit)[1:2]
    anotes = filterpitches(rnotes, allowed)
    @test length(anotes) > 0
    @test length(anotes) == pitchdict[allowed[1]] + pitchdict[allowed[2]]
    for note ∈ anotes
        @test note.pitch ∈ allowed
    end

end
@testset "separate pitches" begin
    sep = separatepitches(rnotes)
    @test sort(collect(keys(sep))) == sort(unique(pitches(rnotes)))

    @test sum(length(n) for n in values(sep)) == length(rnotes)

end
end

@testset "estimate delay" begin
    for midi in (readMIDIFile("serenade_full.mid"), readMIDIFile(testmidi()))
        piano = getnotes(midi, 4)

        d = estimate_delay(piano, 0:1//3:1)
        @test abs(d) < 30

        d2 = estimate_delay_recursive(piano, 0:1//3:1, 5)

        @test d2 ≥ round(Int, d)
        @test abs(d2) < 30
    end
end
