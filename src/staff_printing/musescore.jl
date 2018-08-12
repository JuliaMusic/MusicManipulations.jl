using DefaultApplications

const MUSESCORE = @static Sys.iswindows() ? "MuseScore" : "musescore"

function musescore(file, notes::Notes;
    tozero = true, display = true)

    @assert file[end-3:end] == ".png"
    if tozero
        shift = minimum(n.position for n in notes)
        notes = translate(notes, -shift)
    end

    dir =  dirname(file)
    tdir = tempdir()
    midi = writeMIDIfile(tdir*"/tempmid.mid", notes)

    cmd = `$MUSESCORE -o $(file) $(tdir*"/tempmid.mid")`

    rm(tdir*"/tempmid.mid")
    pngname = basename(file)

    muspng = file[1:end-4]*"-1.png"

    display && DefaultApplications.open(muspng)
end
