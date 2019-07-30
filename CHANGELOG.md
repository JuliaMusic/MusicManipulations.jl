# Changelog of `MusicManipulations`

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
