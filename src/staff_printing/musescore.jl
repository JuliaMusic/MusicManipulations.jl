module MuseScore
using MIDI
using DefaultApplication

const MUSESCORE = @static Sys.iswindows() ? "MuseScore" : "musescore"
const MUSESCORE_EXISTS = [false]

function test_musescore()
    if !MUSESCORE_EXISTS[1]
        r = try
            r = run(`$(MUSESCORE) -v`)
        catch
            false
        end
        if r == false || ((typeof(r) == Base.Process) && r.exitcode != 0)
            throw(SystemError(
            """
            The command `$(MUSESCORE) -v` did not run, which probably means that
            MuseScore is not accessible from the command line. Please first install MuseScore
            on your computer and then add it to your PATH."""
            ))
        end
    end
    global MUSESCORE_EXISTS[1] = true
end

"""
    musescore(file, notes | midi; display = true)
Use the open source software "MuseScore" to create a score and save the
output to `file`. By default it will also display the created `file`,
which can be either a `.pdf` or a `.png`.

Notice that MuseScore must be accessible from the command line for this function to
work.
"""
function musescore(file, notes; display = true)

    @assert file[end-3:end] ∈ (".png", ".pdf")
    MUSESCORE_EXISTS[1] || test_musescore()

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
    nothing
end

end#module
