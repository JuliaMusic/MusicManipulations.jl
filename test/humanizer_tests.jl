using MusicManipulations, Test, Statistics

@testset "humanize" begin

#test of humanize functionality
notes = randomnotes(100)
for n in notes; n.velocity = 100; end
hnotes = humanize(notes, :velocity, 10)
@test any(i -> notes[i].velocity ≠ hnotes[i].velocity, 1:length(notes))
σ = std(velocities(hnotes))
@test 9.5 ≤ σ ≤ 10.5

end
