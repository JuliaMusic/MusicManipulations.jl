export humanize!, humanize

using ARFIMA, Statistics
const φ0 = ARFIMA.SVector(-0.5, -1.5)

"""
    humanize!(notes, property, σ, noise = :ARFIMA; kwargs...)
Humanize given `notes` by adding noise of standard deviation `σ` to their `property`,
typically either `:position` or `:velocity`. Research[^Datseris2019] suggests that `σ`
should be around 40 (for `:position`) but that depends on the BPM, and around 10 for `:velocity`.

The `noise` argument decides the type of noise:
* `:ARFIMA` uses ARFIMA.jl and attempts to generate a power-law correlated (pink) noise.
  Keywords `d = 0.25, φ = SVector(-0.5, -1.5)` are propagated to function `arfima`.
* `:white` plain ol' white noise.

Use `humanize` for a non-modifying version.

[^Datseris2019]: Datseris, G., et al. [Microtiming Deviations and Swing Feel in Jazz. Sci Rep 9, 19824 (2019)](https://doi.org/10.1038/s41598-019-55981-3)
"""
function humanize!(n::Notes, property, σ, noise = :ARFIMA; d=0.25, φ=φ0)
    N = length(n)
    if noise == :ARFIMA
        ξ = arfima(N, 1.0, d, φ)
    elseif noise == :white
        ξ = randn(N)
    else
        error("Unrecognized noise type")
    end
    ξ .*= σ/std(ξ)
    for j in 1:N
        setproperty!(n[j], property, getproperty(n[j], property) + round(Int, ξ[j]))
    end
    return n
end

humanize(notes, args...; kwargs...) = humanize!(copy(notes), args...; kwargs...)
