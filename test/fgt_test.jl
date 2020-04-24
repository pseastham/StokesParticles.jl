using StokesParticles, Test
import LinearAlgebra: norm

d = 2                           # dimension of data
M = 1_000                       # number of targets 
N = 2                           # number of sources
h = 0.8                         # bandwidth
ε = 1e-2                        # max tolerance
x = rand(N*d)                   # source vectors, reshape'd to 1D array
y = rand(M*d)                   # target vectors, reshape'd to 1D array
W = 1                           # number of sources being evaluated 
q = rand(N*W)                   # weights for sources
v1 = zeros(M)                   # output values array
v2 = zeros(M)                   # output 2
v3 = zeros(M)                   # output 3

# compile
fgt!(v1,d,M,N,h,ε,x,y,q,W)
dgt!(v1,d,M,N,h,ε,x,y,q,W)

t1 = @elapsed fgt!(v1,d,M,N,h,ε,x,y,q,W)        # fast c++
t2 = @elapsed dgt!(v2,d,M,N,h,ε,x,y,q,W)        # slow c++

@test t1 < t2
@test norm(v1-v2) < eps()