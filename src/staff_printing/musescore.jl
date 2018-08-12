export musescore

using DefaultApplication

const MUSESCORE = @static Sys.iswindows() ? "MuseScore" : "musescore"

function test_musescore()
    r = run(`$(MUSESCORE) -v`)
    @assert r.exitcode == 0
end

"""
    musescore(file, notes | midi; display = true)
Use the open source software "MuseScore" to create a score and save the
output to `file`. By default it will also display the created `file`,
which can be either a `.pdf` or a `.png`.

Notice that MuseScore must be accessible from the command line for this function to
work.
"""
function musescore(file, notes; display = true, grid = nothing)

    test_musescore()
    @assert file[end-3:end] ∈ (".png", ".pdf")

    tdir = tempdir()
    midi = writeMIDIfile(tdir*"/tempmid.mid", notes)
	midipath = joinpath(tdir, "tempmid.mid")

    if file[end-3:end] == ".png"
        cmd = `$MUSESCORE -n -T 10 -o $(file) $(midipath)`
        muspng = file[1:end-4]*"-1.png"
    else
        cmd = `$MUSESCORE -n -o $(file) $(midipath)`
        muspng = file
    end
	run(cmd)
    rm(tdir*"/tempmid.mid")
    display && DefaultApplication.open(muspng)
end
