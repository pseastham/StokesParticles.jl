# interface to C++ library "figtree" from
#   Vlad I. Morariu, Balaji Vasan Srinivasan, Vikas C. Raykar, 
#   Ramani Duraiswami, and Larry S. Davis. Automatic online tuning for 
#   fast Gaussian summation. Advances in Neural Information Processing 
#   Systems (NIPS), 2008. 
# and website that hosts code is 
#   http://www.umiacs.umd.edu/~morariu/figtree/ 

"""
    fgt!(v,d,M,N,h,ε,x,y,q,W)

Calls Fast Gauss Transform code compiled into shared library. Automatically chooses
   'speedup' parameters

Notes:

INPUTS:
v: [Vector{Float64}, M] interpolated values
d: [Int] dimension of data
M: [Int] number of targets
N: [Int] number of sources 
h: [Float64] bandwidth, h=sqrt(2)*stddev if standard deviation is known
ε: [Float64] maximum absolute error   
x: [Vector{Float64}, N×d] list of sources
y: [Vector{Float64}, M×d] list of targets
q: [Vector{Float64}, N] weights on sources
W: [Int] number of weight functions (e.g. if W=2, then length(q) = 2N)
"""
function fgt!(v::Array{Float64},d::Int,M::Int,N::Int,h::Float64,ε::Float64,
              x::Array{Float64},y::Array{Float64},q::Array{Float64},W::Int)
    # zero-out v output array
    fill!(v,zero(Float64))

    # call c function
    ccall((:figtree,"libfigtree.so"), 
            Int, 
            (Int, Int, Int, Int, Ptr{Float64}, Float64, Ptr{Float64}, Ptr{Float64}, Float64, Ptr{Float64}, Int, Int, Int, Int), 
            d, N, M, W, x, h, q, y, ε, v, 4, 1, 0, 0)       # 0 indicates direct evaluation, 4 is auto
                                                   # see figtree.h to learn last 4 integer codes -- DO NOT TOUCH
                                                   # -1 just used to avoid selecting any value

    # v is modified by reference
    nothing
end
# same as fgt but uses slow algorithm (classic matrix-vector multiply)
function dgt!(v::Array{Float64},d::Int,M::Int,N::Int,h::Float64,ε::Float64,
              x::Array{Float64},y::Array{Float64},q::Array{Float64},W::Int)
    # zero-out v output array
    fill!(v,zero(Float64))

    # call c function
    ccall((:figtree,"libfigtree.so"), 
            Int, 
            (Int, Int, Int, Int, Ptr{Float64}, Float64, Ptr{Float64}, Ptr{Float64}, Float64, Ptr{Float64},Int, Int, Int, Int), 
            d, N, M, W, x, h, q, y, ε, v, 0, 0, 0, 0)    # 0 indicates direct evaluation, 4 is auto
                                                   # see figtree.h to learn last 4 integer codes -- DO NOT TOUCH
                                                   # -1 just used to avoid selecting any value

    # v is modified by reference
    nothing
end

function mydgt!(v::Array{Float64},d::Int,M::Int,N::Int,h::Float64,ε::Float64,
                x::Array{Float64},y::Array{Float64},q::Array{Float64},W::Int)
    # zero-out v output array
    fill!(v,zero(Float64))

    # generate nodes
    for ti=1:M              # targets
        for tj=1:N          # sources
            dist = sqrt((x[tj] - y[ti])^2)
            v[ti] += q[tj]*GaussKernel(dist,h)
        end
    end

    nothing
end

function GaussKernel(x,h)
    return exp(-x^2/h^2)
end