# computes cohesion forces

"""
    LJForceMagnitude(r,s,d,ϵ)

Returns magnitude of force resulting from Lennard-Jones-type potential.
r is the distance between particles, s is a scale parameter for the 
strength of interaction, d is the equilibrium distance between particles,
and ϵ is the interaction extension, typically a small positive number. 
"""
function LJForceMagnitude(r::T,s::T,d::T,ϵ::T) where T<:Real
    return ( r > (1+ϵ)*d ? zero(T) : 2*s*d/r^2*(1 - d/r) )
end

"""
    ForceCalculation(r,s,d,ϵ,Δx,Δy)

Returns 2D cohesion force between two particles. s is a scale parameter for 
the strength of interaction, d is the equilibrium distance between particles, 
and ϵ is the interaction extension, typically a small positive number. 
"""
function ForceCalculation(s::T,d::T,ϵ::T,Δx::T,Δy::T) where T<:Real
    r = sqrt(Δx^2 + Δy^2)
    tx = Δx/r
    ty = Δy/r

    LJmag = LJForceMagnitude(r,s,d,ϵ)

    Fx = tx*LJmag
    Fy = ty*LJmag

    return Fx,Fy
end 

"""
    computeCohesion_backup!(cfX,cfY,particleList,rc,ϵ)

Backup method to directly compute cohesion force on all particles. cfX and cfY are arrays storing
forces on each particle. particleList is an arrays of the particles. r is the distance between 
particles, s is a scale parameter for the strength of interaction, and ϵ is the interaction 
extension, typically a small positive number. 

Note that this method is *slow* for large number of particles. It is O(N^2) where N is the number
of particles (the length of nodeList). 
"""
function computeCohesion_backup!(cfX::Vector{T},cfY::Vector{T},particleList::Vector{P},s::T,ϵ::T) where {T<:Real,P<:AbstractParticle}
    Nparticles = length(particleList)

    fill!(cfX,zero(T))
    fill!(cfY,zero(T))

    for ti=1:Nparticles, tj=(ti+1):Nparticles       # takes advantage of force anti-symmetry
        Δx = particleList[tj].pos.x - particleList[ti].pos.x
        Δy = particleList[tj].pos.y - particleList[ti].pos.y

        d = particleList[ti].radius + particleList[tj].radius

        fx,fy = ForceCalculation(s,d,ϵ,Δx,Δy)
        cfX[ti] += fx; cfY[ti] += fy
        cfX[tj] -= fx; cfY[tj] -= fy
    end

    nothing
end

function computeAdhesionForce!(afX::Vector{T},afY::Vector{T},particleList::Vector{P},wallList::Vector{W},pointOnWall::Point2D{T},s::T,ϵ::T) where {T<:Real,P<:AbstractParticle,W<:AbstractWall}
    if length(afX) != length(afY)
        throw(DimensionMismatch("length of afX and afY must match!"))
    end

    # zero-out adhesion array
    fill!(afX,zero(T))
    fill!(afY,zero(T))

    for tp=1:length(particleList), tw=1:length(wallList)
        NearestPoint!(pointOnWall,particleList[tp],wallList[tw])
        if isInLine(wallList[tw],pointOnWall)
            Δx = pointOnWall.x - particleList[tp].pos.x
            Δy = pointOnWall.y - particleList[tp].pos.y

            d = particleList[tp].radius + wallList[tw].thickness/2

            fx,fy = ForceCalculation(s,d,ϵ,Δx,Δy)
            afX[tp] += fx
            afY[tp] += fy
        end
    end

    nothing
end

#    NearestPoint!(point,node,wall)
#
#Compute nearest point to particle on LineWall, CircleWall, and ArcWall 
function NearestPoint!(point::Point2D{T},node::Particle2D{T},wall::LineWall) where T<:Real
    px=node.pos.x; py=node.pos.y

    Ax=wall.nodes[1].x; Ay=wall.nodes[1].y
    Bx=wall.nodes[2].x; By=wall.nodes[2].y

    bx=px-Ax; by=py-Ay
    ax=Bx-Ax; ay=By-Ay

    ℓ2 = ax^2+ay^2

    dotprod = ax*bx + ay*by

    point.x = dotprod*ax/ℓ2 + Ax
    point.y = dotprod*ay/ℓ2 + Ay

    nothing
end
function NearestPoint!(point::Point2D{T},node::Particle2D{T},wall::CircleWall) where T<:Real
    px=node.pos.x; py=node.pos.y
    cx=wall.center.x; cy=wall.center.y
    r = wall.radius
    θ = atan(py-cy,px-cx)

    point.x = cx + r*cos(θ)
    point.y = cy + r*sin(θ)

    nothing
end
function NearestPoint!(point::Point2D{T},node::Particle2D{T},wall::ArcWall) where T<:Real
    px= node.pos.x; py=node.pos.y
    cx= wall.nodes[2].x; cy=wall.nodes[2].y
    r = sqrt((cx-wall.nodes[1].x)^2 + (cy-wall.nodes[1].y)^2)
    θ = atan(py-cy,px-cx)

    point.x = cx + r*cos(θ)
    point.y = cy + r*sin(θ)

    nothing
end
function NearestPoint(node::Particle2D{T},wall::W) where {T<:Real,W<:AbstractWall}
    point = Point2D(0.0,0.0)
    NearestPoint!(point,node,wall)
    return point
end

# function to determine whether quadrature node (sx,sy) is within line
function isInLine(wall::LineWall{T},point::Point2D{T}) where T<:Real
    return onSegmentWithBuffer(wall.nodes[1],point,wall.nodes[2],wall.thickness/2)     # onSegment is located in isInside.jl
end
# note: s is input only to make all arguments for isInLine the same
function isInLine(wall::CircleWall{T},point::Point2D{T}) where T<:Real
    cx = wall.center.x; cy=wall.center.y
    val = abs(wall.radius - sqrt((cx-point.x)^2 + (cy-point.y)^2))
    TOL = 1e-12
    return (val < TOL ? true : false)
end
# note: s is input only to make all arguments for isInLine the same
function isInLine(wall::ArcWall{T},point::Point2D{T}) where T<:Real
    cx = wall.nodes[2].x; cy=wall.nodes[2].y
    radius = sqrt((cx-wall.nodes[1].x)^2 + (cy-wall.nodes[1].y)^2)
    val = abs(radius - sqrt((cx-point.x)^2 + (cy-point.y)^2))

    θ1 = atan(wall.nodes[1].y-cy,wall.nodes[1].x-cx)
    θ2 = atan(wall.nodes[3].y-cy,wall.nodes[3].x-cx)
    θs = atan(point.y-cy,point.x-cx)

    TOL = 1e-12
    isOn = false
    if val < TOL
        if θ1 > θ2
            if θs > θ1 || θs < θ2
                isOn = true
            end
        else
            if θs > θ1 && θs < θ2
                return true
            end
        end
    end

    return isOn
end


"""
# nodelist: list of points to compute force between
# radiuslist: list of particle radii            (currently unused)
# cfX: cohesion force in x-direction
# cfY: cohesion force in y-direction
function computeCohesion_CL!(cfX::Vector{T},cfY::Vector{T},nodeList::Vector{Point2D{T}},radiusList::Vector{T},
                                rc::T,ϵ::T,cl::CellList) where T<:Real
    # zero-out cohesion
    fill!(cfX,zero(T))
    fill!(cfY,zero(T))

    # go over cell lists
    for cellInd = 1:length(cl.cells)
        # compute cell-cell (same cell) forces
        numNodes = length(cl.cells[cellInd].nodeList)
        for ti=1:numNodes, tj=(ti+1):numNodes
            nodeI = cl.cells[cellInd].nodeList[ti]
            nodeJ = cl.cells[cellInd].nodeList[tj]

            Δx = nodeList[nodeJ].x - nodeList[nodeI].x
            Δy = nodeList[nodeJ].y - nodeList[nodeI].y
    
            d = radiusList[nodeI] + radiusList[nodeJ]
    
            fx,fy = ForceCalculation(ϵ,d,rc,Δx,Δy)
            cfX[nodeI] += fx; cfY[nodeI] += fy
            cfX[nodeJ] -= fx; cfY[nodeJ] -= fy
        end

        # compute cell-neighbor forces
        for ncInd in cl.cells[cellInd].neighborList
            numNeighborNodes = length(cl.cells[ncInd].nodeList)
            for ti=1:numNodes, tj=1:numNeighborNodes
                nodeI = cl.cells[cellInd].nodeList[ti]
                nodeJ = cl.cells[ncInd].nodeList[tj]

                Δx = nodeList[nodeJ].x - nodeList[nodeI].x
                Δy = nodeList[nodeJ].y - nodeList[nodeI].y
        
                d = radiusList[nodeI] + radiusList[nodeJ]
        
                fx,fy = ForceCalculation(ϵ,d,rc,Δx,Δy)
                cfX[nodeI] += fx
                cfY[nodeI] += fy
            end 
        end
    end

    nothing
end
"""