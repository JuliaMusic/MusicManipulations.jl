export veltimeseries

"""
    veltimeseries(notes, grid = 0:1//notes.tpq:1; zeros = false, av = false)

Generate a time series of velocities out of given `notes`, by
also quantizing on given grid (see [`quantize`](@ref)).
### Keyword Arguments
- `zeros` : If `true`, put zeros on gridpoints where no note occurs. If `false` then
  simply stich the individual entries.
- `av`: If multiple notes appear at one gridpoint, the highest velocity is
  chosen by default (`false`).
  Set this to `true` to average over different velocities at that grid point.
"""
function veltimeseries(notes::MIDI.Notes, grid = 0:1//notes.tpq:1; zeros::Bool = false, av::Bool = false)

    #quantize
    qnotes = quantize(notes, grid)

    #select if to put zeros and do timeseries
    if zeros
        return veltimeseries_quant_zeros(qnotes, grid, av)
    else
        return veltimeseries_quant(qnotes, av)
    end

end


"""
    veltimeseries_quant_zeros(notes::MIDI.Notes, grid, average::Bool = false)

Get the velocity time series of the given notes which have been quantized to
`grid`. Add zeros at grid positions where no note is played.
If multiple notes appear at the same gridpoint, the higher velocity is
chosen for the time series. Set `average` to true, to use the mean value.
"""
function veltimeseries_quant_zeros(notes::MIDI.Notes, grid, average::Bool = false)

    #beat position
    pos = 0
    #end of last beat (or less than tpq more)
    maxpos = notes[end].position

    #number of intervals in the grid
    intervalcount = length(grid)-1

    #ticks from beginning of beat to gridpoint
    steps = round.(Int,notes.tpq.*grid)

    #index in notes
    notenumber = 1
    maxnotenumber = length(notes.notes)

    #container for multiple velocities at one point
    velatpoint = Float64[]

    #select how to deal with multiple notes at one point
    if average
        pointvalue = mean
    else
        pointvalue = maximum
    end

    #space for timeseries
    series = Float64[]
    sizehint!(series,round(Int,notes[end].position/intervalcount))
    posi = Float64[]
    sizehint!(posi,round(Int,notes[end].position/intervalcount))

    #for each beat
    while pos <= maxpos

        #for each gridpoint
        for i = 1:intervalcount

            currentpos = pos + steps[i]
            velatpoint = Float64[]

            #collect notes at current gridpoint
            while notenumber <= maxnotenumber && notes[notenumber].position == currentpos
                push!(velatpoint,notes[notenumber].velocity)
                notenumber +=1
            end

            # find value for this gridpoint
            if velatpoint == []
                push!(series,0.0)
                push!(posi,currentpos)
            else
                push!(series,pointvalue(velatpoint))
                push!(posi,currentpos)
            end
        end
        # go to next beat
        pos += notes.tpq
    end
    return hcat(posi,series)
end

"""
    veltimeseries_quant(notes::MIDI.Notes, average::Bool = false)

Get the velocity time series of the given notes which might have been quantized.
If multiple notes appear at the same position, the higher velocity is
chosen for the time series. Set `average` to true, to use the mean value.
"""
function veltimeseries_quant(notes::MIDI.Notes, average::Bool = false)

    #select how to deal with multiple notes at one point
    if average
        pointvalue = mean
    else
        pointvalue = maximum
    end

    #get velocities and positions
    vel = convert(Vector{Float64},velocities(notes))
    pos = positions(notes)

    # multiple notes at one position will be deleted
    deletes = Int[]
    # here we keep their velocities
    velatpoint = Float64[]

    # note index
    i = 1
    #maximum index
    len = length(pos)
    #for each note
    while i <= len
        velatpoint = [Float64(vel[i])]

        # compare the positions of the following notes to the position of the
        # current note. If they have the same position, save their velocities
        # for later and mark them for deletion.
        j = 1
        p = pos[i]
        while i + j <= len && pos[i+j] == p
            push!(velatpoint,vel[i+j])
            push!(deletes,i+j)
            j += 1
        end

        # calculate velocity from overlapping notes
        if velatpoint != []
            vel[i] = pointvalue(velatpoint)
            println(length(velatpoint), pointvalue(velatpoint))
        end

        #proceed with the next note, which has a different position
        i = i+j
    end
    deleteat!(vel,deletes)
    deleteat!(pos,deletes)
    return hcat(pos,vel)
end
