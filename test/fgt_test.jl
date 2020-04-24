using StokesParticles, Test
import LinearAlgebra: norm

d = 1                                   # dimension of data
M = 10_000                              # number of targets 
N = 10_000                              # number of sources
h = 0.2                                 # bandwidth
ε = 1e-2                                # max tolerance
x = rand(N*d)                           # source vectors, reshape'd to 1D array
y = collect(range(-2,stop=2,length=M))  # target vectors, reshape'd to 1D array
W = 1                                   # number of sources being evaluated 
q = rand(N*W)                           # weights for sources
v1 = rand(M)                            # output values array
v2 = rand(M)                            # output 2
v3 = rand(M)                            # output 3

t1 = @elapsed fgt!(v1,d,M,N,h,ε,x,y,q,W)
t2 = @elapsed dgt!(v2,d,M,N,h,ε,x,y,q,W)
t3 = @elapsed mydgt!(v3,d,M,N,h,ε,x,y,q,W)

@test t1 < t2 < t3
@test norm(v1 - v3)/norm(v3) < 1e-3     # approx alg, some error allowed
@test norm(v2 - v3)/norm(v3) < eps()    # same alg, so no error allowed