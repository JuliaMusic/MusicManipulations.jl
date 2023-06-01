using Test, MusicManipulations
@testset "Random Notes Sequence" begin
    nn1 = NamedNote("C")
    @test nn1.name == "C5"
    nn2 = NamedNote("C#6")
    @test nn2.name == "C#6"
    nn2 = NamedNote("C#6")
    @test NamedNote("Db5") == NamedNote("C#5")
    @show nn2
end