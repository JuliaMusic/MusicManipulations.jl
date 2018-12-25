let

midi = readMIDIFile("serenade_full.mid")
piano = midi.tracks[4]
notes = getnotes(piano, midi.tpq)

@testset "MIDI IO" begin
    @test midi.tpq == 960
    @test length(midi.tracks) == 4

    notes = getnotes(midi.tracks[2])

    @test length(notes.notes) > 1
    @test notes.tpq == 960

    @testset "extract numbers" begin
        for f in (velocities, positions, pitches, durations)
            @test length(f(notes)) == length(notes)
        end
    end
end

@testset "Replace Notes" begin

    midi = readMIDIFile("serenade_full.mid")
    notes2 = getnotes(midi.tracks[2])
    newtrack = deepcopy(midi.tracks[2])
    newnotes = getnotes(newtrack)

    for f in (velocities, positions, pitches, durations)
        @test f(notes2) == f(newnotes)
    end

    for note in newnotes
        note.velocity = rand(1:126)
    end

    newtrack = replace_notes(newtrack, newnotes)
    newnotes = getnotes(newtrack)

    for f in (positions, pitches, durations)
        @test f(notes2) == f(newnotes)
    end

    @test velocities(notes) !== velocities(newnotes)
end
end
