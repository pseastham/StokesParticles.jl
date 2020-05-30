using StokesParticles, Test

d = 1.3
ϵ = 0.1
s = 0.3

@test ( StokesParticles.LJForceMagnitude((1+2*ϵ)*d,s,d,ϵ) == 0)
@test ( StokesParticles.LJForceMagnitude(d,s,d,ϵ) == 0)
@test ( StokesParticles.LJForceMagnitude((1-ϵ)*d,s,d,ϵ) < 0 )
@test ( StokesParticles.LJForceMagnitude((1+ϵ/2)*d,s,d,ϵ) > 0 )





