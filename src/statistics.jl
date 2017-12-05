using MIDI, Distributions, StatsBase

###############################################################################
###############################################################################
# Statistics Functions
###############################################################################
###############################################################################

function mtd_statistics(notes::Vector{Note}, qnotes::Vector{Note})
  mtd = [Int(a.position) - Int(b.position) for (a,b) in zip(notes, qnotes)]
  return mtd_statistics(mtd)
end
function mtd_statistics(mtd::Vector{<:Real})
  mtd_mean = mean(mtd)
  mtd_std = std(mtd)
  # Similarity to gaussian distribution
  f = fit(Histogram, mtd, nbins=100, closed=:left)
  mtd_bins, mtd_hist = f.edges[1], f.weights
  kld = similarity_to_G(mtd, mtd_bins, mtd_hist)

  return mtd_mean, mtd_std, kld
end

function similarity_to_G(mtd::AbstractVector)
  bins, h = (f = fit(Histogram, mtd, nbins=100); (f.edges[1], f.weights))
  vals = mtd
  similarity_to_G(vals, bins, h)
end
function similarity_to_G(vals, bins, h)
  h = copy(h)
  G = fit(Normal, vals)
  gval = rand(G, length(vals))
  g_hist = (f = fit(Histogram, gval, bins, closed=:left); f.weights)

  # Remove indeces where Gaussian is 0 but h is not
  indeces = find((g_hist .== 0) .& (h .!= 0))
  deleteat!(g_hist, indeces)
  deleteat!(h, indeces)

  kld = kldivergence(h, g_hist)
end


function velocity_statistics(notes::Vector{Note})
  vels = [Int(note.velocity) for note in notes]
  velocity_statistics(vels)
end
function velocity_statistics(vels::Vector{Int})
  vel_mean = mean(vels)
  vel_std = std(vels, mean = vel_mean)
  vel_skew = skewness(vels, vel_mean)
  return vel_mean, vel_std, vel_skew
end

function notesperquarter(notes, tpq)
  poss = [Int(note.position) for note in notes]
  npq = 0
  avrg = 0.0
  quarters = div(poss[1], tpq)
  quarterline = tpq*quarters
  for pos in poss
    if pos < quarterline
      npq += 1
    else
      avrg += npq
      quarters += 1
      quarterline += tpq
      npq = 0
    end
  end
  avrg/(quarters - div(poss[1], tpq))
end

function relpos(n::Note, tpq = 960)
  apos = 0
  m = mod1(Int(n.position), tpq)
  if m >= (5//6)*tpq
    apos = m - tpq
  else
    apos = m
  end
  return apos
end

relpos(notes::Notes, tpq = 960) = [relpos(n, tpq) for n in notes]
