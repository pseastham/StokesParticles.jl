using StokesParticles, Test

d = 1.3
ϵ = 0.1
s = 0.3

@test ( StokesParticles.LJForceMagnitude(1.5,s,d,ϵ) == 0)
@test ( StokesParticles.LJForceMagnitude(d,s,d,ϵ) == 0)
@test ( StokesParticles.LJForceMagnitude(0.5*d,s,d,ϵ) > 0 )
@test ( StokesParticles.LJForceMagnitude((1+ϵ/2)*d,s,d,ϵ) < 0 )

