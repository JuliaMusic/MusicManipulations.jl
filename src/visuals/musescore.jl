module MuseScore
using MIDI
using DefaultApplication

const MUSESCORE = @static Sys.iswindows() ? "MuseScore3" : "mscore"
# const MUSESCORE_EXISTS = [false]
#
# function test_musescore()
#     if !MUSESCORE_EXISTS[1]
#         r = try
#             r = run(`$(MUSESCORE) -v`)
#         catch
#             false
#         end
#         if r == false || ((typeof(r) == Base.Process) && r.exitcode != 0)
#             throw(SystemError(
#             """
#             The command `$(MUSESCORE) -v` did not run, which probably means that
#             MuseScore is not accessible from the command line.
# 			Please first install MuseScore
#             on your computer and then add it to your PATH."""
#             ))
#         end
#     end
#     global MUSESCORE_EXISTS[1] = true
# end

"""
    musescore(file, notes | midi; display = true, rmmidi = false)
Use the open source software "MuseScore" to create a score and save the
output to `file`. By default it will also display the created `file`,
which can be either a `.pdf` or a `.png`. The function must first create a MIDI file
(uses the same name as `file`). You can choose to delete it afterwards (`rmmidi`).

MuseScore must be accessible from the command line. In Windows try `MuseScore -v` to
ensure that, otherwise `mscore -v`.

If given a `.png` the actual file name will end with `-1`, `-2` etc.
for each page of the score. Notice that MuseScore must be accessible from the
command line for this function to work.
"""
function musescore(file, notes; display = true, rmmidi = false)

    file[end-3:end] ∈ (".png", ".pdf") || error("file must be .pdf or .png.")

    # MUSESCORE_EXISTS[1] || test_musescore()

    midiname = file[1:end-4]*".mid"
	midi = writeMIDIFile(midiname, notes)

    if file[end-3:end] == ".png"
        cmd = `$MUSESCORE -n -T 10 -o $(file) $(midiname)`
        muspng = file[1:end-4]*"-1.png"
    else
        cmd = `$MUSESCORE -n -o $(file) $(midiname)`
        muspng = file
    end
	run(cmd)
    rmmidi && rm(midiname)
    display && DefaultApplication.open(muspng)
end


"""
	MuseScore.drumkey

A dictionary that given the drum instrument as a string it returns the
MIDI pitch that MuseScore uses.

Notice that to import a MIDI file into MuseScore and the drumset to be the selected
instrument, you should write the MIDI notes to channel `9`.
"""
const drumkey = begin
	a =
	Dict(
	"Acoustic Bass Drum" => "B1",
	"Acoustic Snare" => "D2",
	"Side Stick" => "C#2",
	"Closed Hi-Hat" => "F#2",
	"Open Hi-Hat" => "A#2",
	"Pedal Hi-Hat" => "G#2",
	"Ride Cymbal" => "D#3",
	"Ride Bell" => "F3",
	"Low-Mid Tom" => "B2",
	"Cowbell" => "G#3",
	"Tambourine" => "F#3",
	"High Floor Tom" => "G2",
	"Low Floor Tom" => "F2",
	"Crash Cymbal 1" => "C#3",
	"Crash Cymbal 2" => "A3"
	)
	b = Dict((k, name_to_pitch(a[k])) for k in keys(a))
end

end#module
