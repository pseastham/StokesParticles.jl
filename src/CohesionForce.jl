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

Returns 2D cohesion force between two particles. r is the distance between 
particles, s is a scale parameter for the strength of interaction, d is the 
equilibrium distance between particles, and ϵ is the interaction extension, 
typically a small positive number. 
"""
function ForceCalculation(r::T,s::T,d::T,ϵ::T,Δx::T,Δy::T) where T<:Real
    len = sqrt(Δx^2 + Δy^2)
    tx = Δx/len
    ty = Δy/len

    LJmag = LJForceMagnitude(r,s,d,ϵ)

    Fx = tx*LJmag
    Fy = ty*LJmag

    return Fx,Fy
end 

"""
    computeCohesion_backup!(cfX,cfY,nodeList,radiusList,rc,ϵ)

Backup method to directly compute cohesion force on all particles. cfX and cfY are arrays storing
forces on each particle. nodeList and radiuslist are arrays of the points and radii, respectively,
or the particles. r is the distance between particles, s is a scale parameter for the strength 
of interaction, and ϵ is the interaction extension, typically a small positive number. 

Note that this method is *slow* for large number of particles. It is O(N^2) where N is the number
of particles (the length of nodeList). 
"""
function computeCohesion_backup!(cfX::Vector{T},cfY::Vector{T},nodeList::Vector{Point2D{T}},radiusList::Vector{T},r::T,s::T,ϵ::T) where T<:Real
    Nparticles = length(nodeList)

    fill!(cfX,zero(T))
    fill!(cfY,zero(T))

    for ti=1:Nparticles, tj=(ti+1):Nparticles       # takes advantage of force anti-symmetry
        Δx = nodeList[tj].x - nodeList[ti].x
        Δy = nodeList[tj].y - nodeList[ti].y

        d = radiusList[ti] + radiusList[tj]

        fx,fy = ForceCalculation(r,s,d,ϵ,Δx,Δy)
        cfX[ti] += fx; cfY[ti] += fy
        cfX[tj] -= fx; cfY[tj] -= fy
    end

    nothing
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