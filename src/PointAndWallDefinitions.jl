mutable struct Point2D{T} <: AbstractPoint
    x::T
    y::T
end

mutable struct Point3D{T} <: AbstractPoint
    x::T
    y::T
    z::T
end

struct Particle2D{T} <: AbstractParticle
    pos::Point2D{T}
    radius::T
    materialID::Int
end

struct Particle3D{T} <: AbstractParticle
    pos::Point3D{T}
    radius::T
    materialID::Int
end

struct LineWall{T} <: AbstractWall
    nodes::Vector{Point2D{T}}     # 2 points, defining start and end
    thickness::T                  # gives line "area"
    n::Vector{T}                  # normal unit vector of wall
    t::Vector{T}                  # tangent unit vector of wall
end

struct CircleWall{T} <: AbstractWall
    center::Point2D{T}        # point that defines center
    radius::T                 # radius of circle
    thickness::T              # gives circle curve "area"
end

struct ArcWall{T} <: AbstractWall
    nodes::Vector{Point2D{T}}   # 3 nodes, 1) start, 2) center, and 3) end going counterclockwise
    thickness::T                # gives curve "area"
end

# initializes new wall defined by 2 points (Start,End)
function LineWall(nodes::Vector{Point2D{T}},thickness::T) where T<:Real
    if length(nodes) != 2
        throw(DimensionMismatch("line is defined by 2 points"))
    end

    x0 = [nodes[1].x,nodes[2].x]
    x1 = [nodes[1].y,nodes[2].y]

    n = zeros(Float64,2)
    t = zeros(Float64,2)

    # compute wall length
    WL = sqrt((nodes[2].x - nodes[1].x)^2 + (nodes[2].y - nodes[1].y)^2)

    # comute tangent
    t[1] = (nodes[2].x - nodes[1].x)/WL
    t[2] = (nodes[2].y - nodes[1].y)/WL

    n[1] = -t[2]
    n[2] =  t[1]

    return LineWall(nodes,thickness,n,t)
end
LineWall(n1,n2,thickness) = LineWall([n1,n2],thickness)

function ArcWall(V::Vector{Vector{Float64}},thickness::Float64)
    p1 = Point(V[1][1],V[1][2])
    p2 = Point(V[2][1],V[2][2])
    p3 = Point(V[3][1],V[3][2])

    r1 = sqrt((p2.x-p1.x)^2 + (p2.y-p1.y)^2)
    r2 = sqrt((p2.x-p3.x)^2 + (p2.y-p3.y)^2)

    TOL = 1e-12
    if abs(r1-r2) > TOL
        error("points do not make a circle with constant radius, r1=$(round(r1,2)), r2=$(round(r2,2))")
    end

    return ArcWall([p1,p2,p3],thickness)
end
ArcWall(v1,v2,v3,thickness) = ArcWall([v1,v2,v3],thickness)
