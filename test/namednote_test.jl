using Test, MusicManipulations
@testset "NamedNote" begin
    nn1 = NamedNote("C")
    @test nn1.name == "C5"
    nn2 = NamedNote("C#6")
    @test nn2.name == "C♯6"

    @test NamedNote("C♯4").name == "C♯4"

    @test NamedNote("Db5") == NamedNote("C#5")

    nns = NamedNotes("C#6 Db5 E4")
    @test nns[1].name == "C♯6"
    @test nns[2].name == "D♭5"
    @test nns[3].name == "E4"
    
    @test NamedNote(Note("C#4")) == NamedNote(Note("Db4"))

    @test Note(NamedNote("C#4")) == Note(NamedNote("Db4"))
end