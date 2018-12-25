using Test

let
cd(@__DIR__)
midi = readMIDIFile("serenade_full.mid")
piano = midi.tracks[4]
notes = getnotes(piano, midi.tpq)
tpq = 960

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
    @test findall(class .== 2) == inbetw

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

    for f in (velocities, pitches)
        @test f(notes) == f(qnotes)
    end
    @test durations(notes) != durations(qnotes)

    qqnotes = quantize(notes, triplets, false)
    @test durations(notes) == durations(qqnotes)

    pos = positions(notes)
    qpos = positions(qnotes)

    @test positions(notes) !== positions(qnotes)
    @test mod.(qpos, 320) == zeros(length(notes))
end

@testset "quantize duration" begin

    for (i, grid) in enumerate([triplets, sixteenths])

        qnotes = quantize(notes, grid)

        dnotes = quantize_duration!(deepcopy(qnotes), grid)

        for note in dnotes
            @test note.duration != 0
            @test mod(note.duration, tpq÷(2+i)) == 0
        end

    end

end

end
