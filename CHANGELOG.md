# Changelog of `MusicManipulations`

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

# 1.7.0

* New type `NamedNote`.

# 1.5.0
* Option `missingval` for `timeseries`.

# 1.4.0
* New function `repeat`.
* `combine` now works with `Vector{Vector{<:Note}}` as well.

# 1.3.0
* `translate, transpose, louden` now also work on single notes.

# 1.2.0
* New function `segment(notes)`.
* New option `segmented` in `timeseries`.

# 1.1.0
* New functions `timesort!` and `combine`.
# 1.0.0
Identical to 0.12.0.
# 0.12.0
* Removed the unicode symbols `▷, □, ◇`; it was a bad idea.
* Removed plotting functionality (`musescore / noteplotter`), and moved it to MusicVisualizations.jl

# 0.11.0
* new function `removepitches`
# 0.10.0
* The extention of `+` and `-` for `Notes` that was introduced in version 0.8 has now been reverted. Instead, dedicated unicode symbols are now used, `▷, □, ◇`, se the docstrings of `translate, transpose, louden`.
* `timeseries` now has more options regarding how to record the data: it is now also possible to provide a function `f` that operates on the array of notes directly.
* performance improvements for `timeseries`.
* New function `relpos` that gives relative positions of notes.

# 0.9.0
* Add a heuristic so that the default behavior of `noteplotter` does not add all pitches into the y-axis ticks and labels.

# 0.8.2
* Bugfix of `noteplotter`.

# 0.8
* new functions `estimate_delay` and `estimate_delay_recursive`.
* Implemented `+` and `-` for `Notes` and `Int`. The operations are identical to `translate`.
* new function `noteplotter`, that comes into scope after `using PyPlot`. this is a full-featured plotting function to plot notes on a time grid. See its docstring for details, as well as the official documentation.
* Renamed `allowedpitches` to `filterpiches`.
* Added in-place methods for `translate` and `transpose`.

# v0.7
Rework and big improvement of the function `timeseries`. Firstly, now bins with missing entries get the Julia value `missing` instead of 0. In addition, now one can also get the timeserises of the positions of the data, using the property `:position`. This returns the timing deviations with respect to the corresponding entry in `tvec`. These numbers are also known as *microtiming deviations* in the literature. Finally, the `grid` argument is now mandatory.
See the updated documentation string for more.

# v0.6.2
* Improve fake note removal functionality for notes loaded from the TD-50 (function `rm_hihatfake` in `drums.jl`)

# v0.6.0
* Move to musescore 3

# v0.5.0
* Preliminary scale identification method (not exported)

# v0.4.0
* added drumkey for Musescore (its actually the GM)

# v0.3.0
* Printing/saving a `midi` or `notes` struct into a score is now possible through MuseScore.

# v0.2.0
* It is now possible to quantize the duration of notes as well!

# v0.1.0 - Initial Release
Changelog is kept with respect to this release.
