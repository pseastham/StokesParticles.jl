module StokesParticles

using BenchmarkTools                # delete this once everything is cleaned up

abstract type AbstractWall end
abstract type AbstractParticle end
abstract type AbstractPoint end

include("PointAndWallDefinitions.jl")
include("CellLists.jl")

using figtree_jll

include("fgt.jl")
include("UpdateParticles.jl")
include("AdhesionForce.jl")
include("CohesionForce.jl")

export AbstractWall, NearestPoint, generateQuadNodes!,isInLine

# CellLists.jl
export femGenerateMap,
       generateCellList,
       updateCellList!

# TypeDefinitions.jl
export Point2D,
       LineWall,
       CircleWall,
       ArcWall

# UpdateParticles.jl
export updateParticle_all!,
       updateParticle_all_nofluid!

# for testing...
export BarycentricVelocityInterp_CL!,
       computeCohesion!,
       AdhesionForce!,
       computeCohesion_CL!,
       LennardJonesForceMagnitude

end # module
