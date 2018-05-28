using MIDI, MusicManipulations
using Base.Test

@testset "Velocity timeseries" begin

    # test object: onbeat notes with velocity ascending from 0 to 159
    notes = Notes{MoreVelNote}(Vector{MoreVelNote}(), 960)
    for i = 0:159
        push!(notes.notes, MoreVelNote(1, i, 960*i, 2, 3))
    end

    #simple time series
    tseries = veltimeseries(notes)

    @test tseries[:,1] == collect(0:960:159*960)
    @test tseries[:,2] == collect(0:159)


    # time series for eights with zeros
    grid = 0:1//2:1
    tseries = veltimeseries(notes, grid, zeros = true)

    @test tseries[:,1] == collect(Float64, 0:480:159*960+480)
    @test [tseries[i,2] for i in 1:2:159*2+1] == collect(Float64, 0:159)
    @test [tseries[i,2] for i in 2:2:159*2+2] == zeros(Int, 160)

    # add notes which have been quantized to same bin
    for i = 0:159
        push!(notes.notes, MoreVelNote(1, i+1, 960*i, 2, 3))
    end
    sort!(notes.notes, lt=((x, y)->x.position<y.position))

    # simple time series choosing maximum in bin
    tseries = veltimeseries(notes)

    @test tseries[:,1] == collect(Float64, 0:960:159*960)
    @test tseries[:,2] == collect(Float64, 1:160)


    # simple time series choosing mean value in bin
    tseries = veltimeseries(notes, av = true)

    @test tseries[:,1] == collect(Float64, 0:960:159*960)
    @test tseries[:,2] == collect(Float64, 1:160) .- 0.5

    # time series for eights with zeros and average for bins
    grid = 0:1//2:1
    tseries = veltimeseries(notes, grid, zeros = true, av = true)

    @test tseries[:,1] == collect(Float64, 0:480:159*960+480)
    @test [tseries[i,2] for i in 1:2:159*2+1] == collect(Float64, 0:159) .+ 0.5
    @test [tseries[i,2] for i in 2:2:159*2+2] == zeros(Int,160)

end
