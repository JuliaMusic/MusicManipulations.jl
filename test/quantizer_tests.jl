using MIDI, MusicManipulations
using Base.Test

triplets = [0, 1//3, 2//3, 1]
sixteenths = [0, 1//4, 2//4, 3//4, 1]

@testset "Classify triplets" begin

    @test isgrid(triplets)

    class = classify(notes, triplets)
    inbetw = [246
    450
    618
    619
    620
    627
    628
    629
    637
    638
    639
    640]

    @test length(class) == length(notes)
    @test findin(class .== 2, true) == inbetw

    @test sum( sum( class .== n ) for n in 1:4) == length(notes)
end
@testset "Classify 16ths" begin
    @test isgrid(sixteenths)
    class = classify(notes, sixteenths)
    @test length(class) == length(notes)
    @test sum( sum( class .== n ) for n in 1:5) == length(notes)
end

@testset "Quantize" begin

    tripletstpq = triplets.*960
    qnotes = quantize(notes, triplets)

    @test qnotes.tpq == notes.tpq
    @test length(notes) == length(qnotes)

    for f in (velocities, pitches, durations)
        @test f(notes) == f(qnotes)
    end

    pos = positions(notes)
    qpos = positions(qnotes)

    @test positions(notes) !== positions(qnotes)
    @test mod.(qpos, 320) == zeros(length(notes))
end
