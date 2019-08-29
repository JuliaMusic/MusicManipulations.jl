export noteplotter
maxnotevel(::Note) = 127
maxnotevel(::MoreVelNote) = 157

Rectangle = PyPlot.matplotlib.patches.Rectangle
function plotpianonote!(ax, note, cmap)
    r = Rectangle((note.position, note.pitch - 0.5), note.duration, 1,
    color = cmap(note.velocity/maxnotevel(note)))
    ax.add_artist(r)
    return note.pitch
end

"""
    noteplotter(notes::Notes; kwargs...)
Plot the given `notes` on a "piano roll" like setting with
- x axis being the position of the notes
- y axis being the "pitch" or "value" of the notes (see below)
- color being the velocity of the notes

Then return the values of the y axis.

## Keywords
* `st = (notes[1].position ÷ notes.tpq) * notes.tpq`  time to start plotting from
* `fi = st + 16notes.tpq` time to stop plotting at, by default 16 quarter notes, i.e. four bars.
  Give `Inf` if you want to plot until the end of the notes.
* `ax = (PyPlot.figure(); PyPlot.gca())` the axis to plot on.
* `cmap = "viridis"` the colormap to use for the velocity.
* `grid = 0:0.25:1` a grid to plot along with the notes (by default the 16th notes).
  Give nothing if you don't want grid lines to be plotted.
* `names = Dict(p => pitch_to_name(p) for p in unique(pitches(notes)))`
  a dictionary that given the y-axis value returns how this value should be named.
* `plotnote!` A function with call arguments
  `plotnote!(ax, note, cmap)` (with `cmap` a colormap instance, not a string),
  that actually plots the notes. By default plots a "piano-roll".

The `plotnote!` argument allows for customization. The function is supposed
to plot a note on the given axis **and return** the "value" of the note.
See the official documentation for an example of how this is taken
advantage of, to plot drum notes.
"""
function noteplotter(notes::Notes;
    st = (notes[1].position ÷ notes.tpq) * notes.tpq,
    fi = st + 16notes.tpq,
    ax = (PyPlot.figure(); PyPlot.gca()),
    names = Dict(p => pitch_to_name(p) for p in unique(pitches(notes))),
    plotnote! = plotpianonote!,
    grid = 0:0.25:1,
    cmap = "viridis"
    )

    cm = PyPlot.cm.get_cmap(cmap)
    fi == Inf && (fi = notes[end].position + notes[end].duration)

    # plot all notes:
    plottedpitches = Int[]
    for note in notes
        st > note.position && continue
        fi < note.position && break
        p = plotnote!(ax, note, cm)
        p ∉ plottedpitches && push!(plottedpitches, p)
    end

    # add gridpoints
    if !isnothing(grid) && isgrid(grid)
        gpoints = notes.tpq*grid[2:end-1]
        grid = UInt[]
        beat = UInt[]
        for i = (st÷notes.tpq):(fi÷notes.tpq + 1)
            append!(grid, i*notes.tpq .+ gpoints)
            push!(beat, i*notes.tpq)
        end
        for γ in grid
            ax.axvline(γ, color=fill(0.7, 3), lw = 1, ls="dashed", zorder = -5)
        end
        for b in beat
            ax.axvline(b, lw=1.5, color=fill(0.5, 3), zorder = -4)
        end
    end

    # limits and labels
    ax.set_xlim(st, fi)
    ax.set_yticks(plottedpitches)
    ax.set_ylim(minimum(plottedpitches)-1, maximum(plottedpitches)+1)
    ax.set_yticklabels([names[p] for p in plottedpitches])
    ax.set_xlabel("time (ticks)")
    return plottedpitches
end
