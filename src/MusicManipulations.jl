module MusicManipulations

using Reexport
@reexport using MIDI
import MIDI: Notes, Note

include("general.jl")
include("midifiles.jl")
include("quantize.jl")
include("scale.jl")
include("humanize.jl")
include("namednote.jl")

include("data_handling/data_extraction.jl")
include("data_handling/timeseries.jl")

include("specific_modules/jazz.jl")
include("specific_modules/drums.jl")

include("motifs/notes_with_motifs.jl")

export Jazz, Drums

end
