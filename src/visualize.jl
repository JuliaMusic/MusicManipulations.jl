using Requires

identimap = Dict{UInt8, UInt8}()
for i = 0:255
    push!(identimap, i => i)
end

function notename(i)
    res = ""
    t = i % 12
    if t == 0
        res *= "C"
    elseif t == 1
        res *= "C#"
    elseif t == 2
        res *= "D"
    elseif t == 3
        res *= "D#"
    elseif t == 4
        res *= "E"
    elseif t == 5
        res *= "F"
    elseif t == 6
        res *= "F#"
    elseif t == 7
        res *= "G"
    elseif t == 8
        res *= "G#"
    elseif t == 9
        res *= "A"
    elseif t == 10
        res *= "A#"
    elseif t == 11
            res *= "B"
    end
    res *= string(floor(Int,i/12))
    return res
end

standardnames = Dict{UInt8, String}()
for i = 0:255
    push!(standardnames, i => notename(i))
end

function velcol(minvel, maxvel, vel)
    # map the velocities to the interval [0.1, 0.9]
    rvel = vel - minvel
    rvel /= (maxvel - minvel)
    rvel = 0.8 * rvel + 0.1
    return string(round(rvel,4))
end


@require PyPlot begin

function tobenamed(notes::MIDI.Notes, grid = 0:1//notes.tpq:1; ticknames::Dict{UInt8, String} = standardnames, reorder::Dict{UInt8, UInt8} = identimap)

# positions of the notes separated by velocities (for plotting in different colors)
x1 = Dict{UInt, Vector{UInt}}()
x2 = Dict{UInt, Vector{UInt}}()
y = Dict{UInt, Vector{UInt}}()

# collect note information
for note in notes
    if !haskey(x1, note.velocity)
        push!(x1, note.velocity => [note.position])
        push!(x2, note.velocity => [note.position + note.duration])
        push!(y, note.velocity => [haskey(reorder, note.pitch) ? reorder[note.pitch] : note.pitch])
    else
        push!(x1[note.velocity], note.position)
        push!(x2[note.velocity], note.position + note.duration)
        push!(y[note.velocity], haskey(reorder, note.pitch) ? reorder[note.pitch] : note.pitch)
    end
end

# reorder pitches with new names
spits = sort(collect(keys(ticknames)))
rpits = copy(spits)
for i in 1:length(rpits)
    if haskey(reorder, rpits[i])
        rpits[i] = reorder[rpits[i]]
    end
end

# find minimum and maximum of >played and reordered< pitches to adjust plot limits
pits = sort(unique(pitches(notes)))
for i in 1:length(pits)
    if haskey(reorder, pits[i])
        pits[i] = reorder[pits[i]]
    end
end
minpit = minimum(pits)
maxpit = maximum(pits)

# find the index of the minimum plotted pitch in the list of all reordered pitches
# permutation array instead of real sorting to be able to reconstruct names
# of reordered pitches
soperm = sortperm(rpits)
minrpit = 1
while minpit > rpits[soperm[minrpit]]
    minrpit += 1
end

# assemble the ticks labels for the graph first look for provided tickname, if
# not given unse standard name.
tickrange = minpit:maxpit
tickstrings = String[]
ind = minrpit
for i = 1:length(tickrange)
    # if pitch was reordered
    if rpits[soperm[ind]] == tickrange[i]
        # revert the reordering with the permutation to get real tick name
        if haskey(ticknames, spits[soperm[ind]])
            push!(tickstrings, ticknames[spits[soperm[ind]]])
        else
            push!(tickstrings, standardnames[spits[soperm[ind]]])
        end
        ind += 1
    # for non reordered pitches
    else
        if haskey(ticknames, i)
            push!(tickstrings, ticknames[i])
        else
            push!(tickstrings, standardnames[i])
        end
    end
end

# get min and max vel to get ready for plotting
vels = keys(y)
minvel = minimum(vels)
maxvel = maximum(vels)

#initialize figure
f = PyPlot.figure("Some well describing name")
ax = PyPlot.axes()

#plotting action
for vel in vels
    PyPlot.plot([x1[vel], x2[vel]], [y[vel], y[vel]], color = velcol(minvel, maxvel, vel), lw = 3)
end

# handle grid
if grid != 0:1//notes.tpq:1
    gpoints = notes.tpq*grid[2:end-1]
    g = UInt[]
    beat = UInt[]
    for i = 0:ceil(Int,(notes.notes[end].position+notes.notes[end].duration)/notes.tpq)
        append!(g,i*notes.tpq+gpoints)
        push!(beat, i*notes.tpq)
    end
    temp = ones(length(g))
    temp2 = ones(length(beat))
    PyPlot.plot([g,g] ,[temp .* (minpit - 0.5), temp .* (maxpit + 0.5)], lw=0.1, color="grey")
    PyPlot.plot([beat,beat] ,[temp .* (minpit - 0.5), temp .* (maxpit + 0.5)], lw=0.1, color="black")
end

# labels, ranges, ...
ax[:set_ylim](minpit-0.5, maxpit+0.5)
ax[:set_yticks](tickrange)
ax[:set_yticklabels](tickstrings)
ax[:set_title]("Some well describing name")
ax[:set_xlabel]("Time in ticks")
ax[:set_ylabel]("Pitch")
f[:tight_layout]()

end

end
