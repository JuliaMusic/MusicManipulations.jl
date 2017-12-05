using MIDI, StatsBase

###############################################################################
###############################################################################
# Research Functions that concern musical aspects
###############################################################################
###############################################################################
function isgrid(Grid)
  if Grid[1] != 0 || Grid[end] != 1
    throw(ArgumentError("Grids must start from 0 and end in 1."))
  end
  true
end



# TODO: RERWITE THIS TO CLASSIFY ACCORDING TO GRID, NOT TO NONSENSE METHOD
"""
```julia
classify_notes(note/s, grid, tpq::Integer = 960; kw...)
```
Classify a given `Note` (or array of `Note`) according to the given grid.


a swing note or a quarter note.

The `kwargs...` are dependent on the type of classification method.
# Classification Methods
* "triplets" : Classifies notes as part of a triplet.
* "swung8s" : Classifies notes only as swing (last part of the triplet)
  or quarter notes. Has keyword `sr` (for the swing ratio).
* "13triplet" : Classifies notes as only the first or last part of a triplet. This
  method is not equivalent with "swung8s" with `sr = 2`, due to the different handling
  of the in-between notes.
# Returns
* "triplets" : 1, 2 or 3.
* "swung8s" : 1 or 2.
* "13triplet" : 1 or 2.

For input of `Vector{Note}`, returns a `Vector{Int}`.
"""
function classify_notes(note::Note, tpq::Integer, classify_method::String; kw...)

  r::Int = 0
  if classify_method == "13triplet"
    tpt = div(tpq,3)
    pos = Int64(note.position)
    posmod = mod(pos, tpq)

    if posmod <= div(tpt,2) || posmod >= tpq - div(tpt,2) #quarter
      r =  1
    elseif posmod >= 3*div(tpt,2) && posmod <= 5*div(tpt,2) #swing
      r =  2
    else #in the middle
      r =  posmod <= tpt ? 1 : 2
    end

  elseif classify_method == "triplets"
    tpt = div(tpq,3)
    pos = Int64(note.position)
    posmod = mod(pos, tpq)

    if posmod <= div(tpt,2) || posmod >= tpq - div(tpt,2) #quarter
      r =  1
    elseif posmod >= 3*div(tpt,2) && posmod <= 5*div(tpt,2) #3rd 8th
      r =  3
    else #in the middle
      r =  2
    end

  elseif classify_method == "swung8s"
    pos = Int64(note.position)
    posmod = mod(pos, tpq)
    sr = (kw = Dict(kw); kw[:sr])
    x = div(tpq*sr, sr+1)
    r = ((posmod < x/2) | (posmod > (x + (tpq-x)/2) ) ) ? 1 : 2

  else
    error("No correct method for classify_notes.")
  end
  return r
end

function classify_notes(notes::Vector{Note}, tpq::Integer,
  classify_method::String; kw...)

  r = zeros(Int, length(notes))
  if classify_method == "swung8s"
    kw = Dict(kw)
    for i in 1:length(notes)
      r[i]  = classify_notes(notes[i], tpq, classify_method; sr = kw[:sr])
    end
  else
    for i in 1:length(notes)
      r[i]  = classify_notes(notes[i], tpq, classify_method)
    end
  end
  return r
end

"""
```julia
average_swing_ratio(notes::Vector{Note}, tpq::Integer, asr_method::String)
```
Calculate the average swing ratio of given `notes` array. Return the average
swing ratio and the associated standard deviation.
# Methods:
## `"AsrFromAll"`
Classify each note with the "13triplet" method. Calculate for each
swing note the swing ratio (with respect to a perfect quarter note)
and then average for all notes.
## `"Triplets"`
Classify each note with the "triplets" method. Use the notes with
id 3 to calculate the swing ratio, and the average for all.
"""
function average_swing_ratio(notes::Vector{Note},
  tpq::Integer, asr_method::String)

  sr::Vector{Float64} = Float64[]

  # Create array of Swing Notes
  if asr_method == "AsrFromAll"
    s = classify_notes(notes, tpq, "13triplet")
    swingnotes = notes[s .== 2]
  elseif asr_method == "Triplets"
    s = classify_notes(notes, tpq, "triplets")
    swingnotes = notes[s .== 3]
  end

  # Create Swing ratios array
  for i in 1:length(swingnotes)
    pos = Int64(swingnotes[i].position)
    posmod = mod(pos, tpq)
    push!(sr, posmod/(tpq-posmod))
  end

  # asr /= length(swingnotes)
  # # Calculate std
  # for i in 1:length(swingnotes)
  #   pos = Int64(swingnotes[i].position)
  #   posmod = mod(pos, tpq)
  #   sr = posmod/(tpq-posmod)
  #   sr_std += (sr - asr)^2
  # end
  # sr_std = sqrt(sr_std/length(swingnotes)) # do not use length-1

  return mean_and_std(sr)
end


"""
```julia
quantize!(notes::Vector{Note}, tpq::Int, grid, which=trues(length(notes)))
```
Quantize the given `notes` on the given `grid`.

Each note is quantized (relocated) to its closest point of the `grid`.
The grid values must be **ordered** and in the range [0, 1]
(both must be **included**),
where 0 means the start of a quarter note and 1 means the end
(and the start of the next quarter note).

It is assumed that the grid is the same for all quarter notes of the track.
Internally the grid is multiplied with `tpq` to give the correct positions in ticks.

Optionally specify which notes you want to be quantized.
"""
function quantize!(notes::Vector{Note}, tpq::Int, Grid, which=trues(length(notes)))

  if Grid[1] != 0 || Grid[end] != 1
    error("Grid given to `quantize!` must start from 0 and end in 1.")
  end
  if !issorted(Grid)
    error("Grid given to `quantize!` must be sorted!")
  end

  grid = round.(Int, collect(Grid*tpq)) #grid in ticks

  for i in eachindex(notes)
    note = notes[i]
    which[i] || continue #if which == false do not quantize this note

    number_of_quarters = div(note.position, tpq)
    posmod = mod(note.position, tpq)
    closest = closest_point(grid, posmod)

    note.position = number_of_quarters*tpq + closest
  end
end

function closest_point(grid, x)
  best = grid[1]
  dxbest = abs(x - grid[1])
  for i in 2:length(grid)
    dx = abs(x - grid[i])
    if dx < dxbest
      dxbest = dx
      best = grid[i]
    end
  end
  return best
end

function inbetween_portion(notes::Vector{Note}, tpq)
  clas = classify_notes(notes, tpq, "triplets")
  length(clas[clas .== 2])/length(notes)
end

# old quantize
#
#   if quantization_method == :Swing
#     a = classify_notes(notes, tpq, quantization_method; show_info = show_info)
#     kw = Dict(kwargs); sr = kw[:sr]
#
#     for i in 1:length(notes)
#       number_of_quarters = div(cn[i].position, tpq)
#
#       if a[i] == 3 # its a "swing" note
#         cn[i].position = number_of_quarters*tpq + round(Int, (sr/(sr+1))*tpq)
#
#       else #its a quarter note
#         r = mod(cn[i].position, tpq)
#         if r > div(tpq,2)
#           cn[i].position = (number_of_quarters+1)*tpq
#         else
#           cn[i].position = number_of_quarters*tpq
#         end
#       end
#     end
#     return cn
#   else
#     error("Not correct method specified for function `quantize`.")
#   end
# end
