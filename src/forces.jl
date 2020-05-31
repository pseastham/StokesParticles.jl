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
function compute_cohesion_force_backup!(cfX::Vector{T},cfY::Vector{T},particleList::Vector{P},s::T,ϵ::T) where {T<:Real,P<:AbstractParticle}
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

function compute_adhesion_force!(afX::Vector{T},afY::Vector{T},particleList::Vector{P},wallList::Vector{W},pointOnWall::Point2D{T},s::T,ϵ::T) where {T<:Real,P<:AbstractParticle,W<:AbstractWall}
    if length(afX) != length(afY)
        throw(DimensionMismatch("length of afX and afY must match!"))
    end

    # zero-out adhesion array
    fill!(afX,zero(T))
    fill!(afY,zero(T))

    for tp=1:length(particleList), tw=1:length(wallList)
        get_nearest_point!(pointOnWall,particleList[tp],wallList[tw])
        if is_in_line(wallList[tw],pointOnWall)
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

function compute_gravity_force!(gfX,gfY,n_particles,G)
    for ti=1:n_particles
        gfX[ti] = 0.0
        gfY[ti] = -G
    end
    nothing
end

function compute_cohesion_force_cl!(cfX::Vector{T},cfY::Vector{T},cl::CellList,pList::Vector{P},s::T,ϵ::T) where {T<:Real,P<:AbstractParticle}
    # zero-out cohesion
    fill!(cfX,zero(T))
    fill!(cfY,zero(T))

    # go over cell lists
    for cellInd = 1:length(cl.cells)
        # compute cell-cell (same cell) forces
        numNodes = length(cl.cells[cellInd].particleIDList)
        for ti=1:numNodes, tj=(ti+1):numNodes
            nodeI = cl.cells[cellInd].particleIDList[ti]
            nodeJ = cl.cells[cellInd].particleIDList[tj]

            Δx = pList[nodeJ].pos.x - pList[nodeI].pos.x
            Δy = pList[nodeJ].pos.y - pList[nodeI].pos.y
    
            d = pList[nodeI].radius + pList[nodeJ].radius
    
            fx,fy = ForceCalculation(s,d,ϵ,Δx,Δy)
            cfX[nodeI] += fx; cfY[nodeI] += fy
            cfX[nodeJ] -= fx; cfY[nodeJ] -= fy
        end

        # compute cell-neighbor forces
        for ncInd in cl.cells[cellInd].neighborList
            numNeighborNodes = length(cl.cells[ncInd].particleIDList)
            for ti=1:numNodes, tj=1:numNeighborNodes
                nodeI = cl.cells[cellInd].particleIDList[ti]
                nodeJ = cl.cells[ncInd].particleIDList[tj]

                Δx = pList[nodeJ].pos.x - pList[nodeI].pos.x
                Δy = pList[nodeJ].pos.y - pList[nodeI].pos.y
        
                d = pList[nodeI].radius + pList[nodeJ].radius
        
                fx,fy = ForceCalculation(s,d,ϵ,Δx,Δy)
                cfX[nodeI] += fx
                cfY[nodeI] += fy
            end 
        end
    end

    nothing
end