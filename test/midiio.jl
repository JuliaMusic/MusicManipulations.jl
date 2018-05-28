using MIDI, MusicManipulations
using Base.Test

@testset "MIDI IO" begin
    midi = readMIDIfile("serenade_full.mid")
    @test midi.tpq == 960
    @test length(midi.tracks) == 4

    notes = getnotes(midi.tracks[2])

    @test length(notes.notes) > 1
    @test start(notes) == 1
    @test notes.tpq == 960

    @testset "extract numbers" begin
        for f in (velocities, positions, pitches, durations)
            @test length(f(notes)) == length(notes)
        end
    end
end

@testset "Replace Notes" begin

    midi = readMIDIfile("serenade_full.mid")
    notes = getnotes(midi.tracks[2])
    newtrack = deepcopy(midi.tracks[2])
    newnotes = getnotes(newtrack)

    for f in (velocities, positions, pitches, durations)
        @test f(notes) == f(newnotes)
    end

    for note in newnotes
        note.velocity = rand(1:126)
    end

    newtrack = replace_notes(newtrack, newnotes)
    newnotes = getnotes(newtrack)

    for f in (positions, pitches, durations)
        @test f(notes) == f(newnotes)
    end

    @test velocities(notes) !== velocities(newnotes)
end

@testset "Note handling" begin

    notes = randomnotes(1000)
    pit = pitches(notes)
    purg = Int[]
    coun = Int[]
    for pitch in unique(pitches(notes))
        push!(purg, length(purgepitches(notes, UInt8(pitch))))
        push!(coun, count(x->x == pitch, pit))
    end
    @test purg == coun

    sep = separatepitches(notes)
    sepa = Int[]
    for pitch in unique(pitches(notes))
        push!(sepa, length(sep[pitch]))
    end

    @test sort(collect(keys(sep))) == sort(unique(pitches(notes)))
    @test sepa == coun
    
end
