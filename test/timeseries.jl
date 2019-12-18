using Statistics, Test, MusicManipulations

@testset "Velocity timeseries" begin

    # test object: onbeat notes with velocity ascending from 0 to 159
    notes = Notes{MoreVelNote}(Vector{MoreVelNote}(), 960)
    for i = 0:159
        push!(notes.notes, MoreVelNote(1, i, 960*i, 2))
    end

    #simple time series
    tvec, tseries = timeseries(notes, :velocity, maximum, 0:1)
    @test tvec == collect(0:960:159*960)
    @test tseries == collect(0:159)

    # time series for eights with missing values
    grid = 0:1//2:1
    tvec, tseries = timeseries(notes, :velocity, maximum, grid)

    @test tvec == collect(0:480:159*960+480)
    @test [tseries[i] for i in 1:2:159*2+1] == collect(Float64, 0:159)
    @test count(ismissing, [tseries[i] for i in 2:2:159*2+2]) == 160
    @test count(x -> x isa Float64, [tseries[i] for i in 2:2:159*2+2]) == 0

    # add notes which have been quantized to same bin
    for i = 0:159
        push!(notes.notes, MoreVelNote(1, i+1, 960*i, 2))
    end
    sort!(notes.notes, lt=((x, y)->x.position<y.position))

    # simple time series choosing maximum in bin
    tvec, tseries = timeseries(notes, :velocity, maximum, 0:1)

    @test tvec == collect(Float64, 0:960:159*960)
    @test tseries == collect(Float64, 1:160)


    # simple time series choosing mean value in bin
    tvec, tseries = timeseries(notes, :velocity, mean, 0:1)

    @test tvec == collect(Float64, 0:960:159*960)
    @test tseries == collect(Float64, 1:160) .- 0.5

    # time series for eights with missing and average for bins
    grid = 0:1//2:1
    tvec, tseries = timeseries(notes, :velocity, mean, grid)

    @test tvec == collect(Float64, 0:480:159*960+480)
    @test [tseries[i] for i in 1:2:159*2+1] == collect(Float64, 0:159) .+ 0.5
    @test count(ismissing, [tseries[i] for i in 2:2:159*2+2]) == 160
    @test count(x -> x isa Float64, [tseries[i] for i in 2:2:159*2+2]) == 0

end

@testset "Pitch timeseries" begin
    # test object: onbeat (quarter) notes with pitch ascending
    notes = Notes{Note}(Vector{Note}(), 960)
    vals = 10:20
    L = length(vals)
    for (i, val) in enumerate(vals)
        push!(notes.notes, Note(val, 5, 960*(i-1), 2))
    end

    #simple time series
    tvec, tseries = timeseries(notes, :pitch, maximum, 0:1)
    @test tvec == collect(0:960:(L-1)*960)
    @test tseries == collect(vals)

    # add notes which have been quantized to same bin
    for  (i, val) in enumerate(vals)
        push!(notes.notes, Note(5, 5, 960*(i-1), 2))
    end
    sort!(notes.notes, lt=((x, y)->x.position<y.position))

    # time series for eights with missing and average for bins
    grid = 0:1//2:1
    tvec, tseries = timeseries(notes, :pitch, mean, grid)

    @test tvec == collect(0:480:(L)*960-480)
    @test [tseries[i] for i in 1:2:(L-1)*2+1] == (collect(Float64, vals) .+ 5)./2
    @test count(ismissing, [tseries[i] for i in 2:2:(L-1)*2+2]) == L
    @test count(x -> x isa Float64, [tseries[i] for i in 2:2:(L-1)*2+2]) == 0
end

midipath = dirname(dirname(pathof(MIDI)))*"/test/"
midis = [readMIDIFile(joinpath(@__DIR__, "serenade_full.mid")),
readMIDIFile(joinpath(midipath, "doxy.mid"))
]

@testset "MTD timeseries $i" for i in 1:2

    midi = midis[i]
    piano = getnotes(midi, 4)
    triplets = 0:1//3:1

    tvec, mtd = timeseries(piano, :position, mean, triplets)

    @test tvec[end] ≥ piano[end].position

    lastnote = findlast(x -> x isa Float64, mtd)
    @test tvec[lastnote] + mtd[lastnote] ≤ Int(piano[end].position)

    maxmtd = 1//6 * piano.tpq

    @test maximum(skipmissing(mtd)) ≤ maxmtd
    @test minimum(skipmissing(mtd)) ≥ -maxmtd
    @test any(x -> x > 0, skipmissing(mtd))
    @test any(x -> x < 0, skipmissing(mtd))
    @test count(!ismissing, mtd) + count(ismissing, mtd) == length(mtd)

    # maximum mtd:
    tvec, mtd = timeseries(piano, :position, maximum, triplets)
    lastnote = findlast(x -> x isa Float64, mtd)
    @test tvec[lastnote] + mtd[lastnote] == Int(piano[end].position)

end

@testset "max pitch velocity timeseries $i" for i in 1:2
    midi = midis[i]

    notes = getnotes(midi, 4)

    function f(notes)
        m, i = findmax(pitches(notes))
        notes[i].velocity
    end

    grid = 0:1//3:1
    tvec1, ts1 = timeseries(notes, :velocity, mean, grid)
    tvec2, ts2 = timeseries(notes, f, grid)

    @test findall(ismissing, ts1) == findall(ismissing, ts2)
    @test tvec1 == tvec2
    @test ts1 != ts2
end

#test of segmenting functionality
notes_to_segment = Notes()
push!(notes_to_segment,Note(67,70,15,540))
push!(notes_to_segment,Note(70,75,330,125))
push!(notes_to_segment,Note(60,73,610,829))
tvec, ts = timeseries(notes_to_segment, :pitch, maximum, 0:1//6:1; segmenting = true)
ts[findall(ismissing,ts)] .= 0
@test ts == [67.0, 67.0, 70.0, 0.0, 60.0, 60.0, 60.0, 60.0, 60.0, 0.0, 0.0, 0.0]
