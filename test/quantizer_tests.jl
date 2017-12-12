using MIDI
using Base.Test

midi = readMIDIfile("serenade_full.mid")
piano = midi.tracks[2]

notes = getnotes(piano)

triplets = [0, 1//3, 2//3, 1]
sixteenths = [0, 1//4, 2//4, 3//4, 1]

@testset "Classify triplets" begin

    @test isgrid(triplets)

    class = classify(notes, triplets)
    inbetw = [428, 432, 829, 833, 836, 837]

    @test length(class) == length(notes)
    @test findin(class .== 2, true) == inbetw

    @test sum( sum( class .== n ) for n in 1:3) == length(notes)
end
@testset "Classify 16ths" begin
    @test isgrid(sixteenths)

    class = classify(notes, sixteenths)
    inbetw = [837]

    @test length(class) == length(notes)
    @test findin(class .== 3, true) == inbetw

    @test sum( sum( class .== n ) for n in 1:4) == length(notes)
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
