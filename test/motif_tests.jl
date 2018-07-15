@testset "Random Notes Sequence"

    # Dummy sequence
    sixt = subdivision(16, 960)
    snare = 0x26
    tom1 = 0x30
    tom3 = 0x2b

    m1 = Note(tom1, 100, 0, sixt)
    motif1 = [
    Note(tom1, 100, 0, sixt),
    Note(snare, 100, sixt, sixt),
    Note(snare, 100, 2sixt, sixt),
    Note(snare, 100, 3sixt, sixt),
    Note(snare, 100, 4sixt, sixt)
    ]
    motif2 = [
    Note(tom1, 100, 0, sixt),
    Note(snare, 100, sixt, sixt),
    Note(tom1, 100, 2sixt, sixt),
    Note(snare, 100, 3sixt, sixt),
    Note(snare, 100, 4sixt, sixt)
    ]
    motif3 = [
    Note(tom1, 100, 0, sixt),
    Note(snare, 100, sixt, sixt),
    Note(snare, 100, 2sixt, sixt),
    ]
    motif4 = [
    Note(tom1, 100, 0, sixt),
    Note(snare, 100, sixt, sixt),
    Note(snare, 100, 2sixt, sixt),
    Note(snare, 100, 3sixt, sixt),
    ]

    motifs = Notes.([motif1, motif2, motif3, motif4], 960)


    for q = [20, 30]
        notes = random_notes_sequence(motifs, q*960)

        @test length(notes) == 4*q
        @test Int(notes[end].position+notes[end].duration) == q*960
    end

    @test_throws ArgumentError random_notes_sequence(motifs, 50)
end
