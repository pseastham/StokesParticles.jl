module StokesParticles

using BenchmarkTools 

include("ParticleTypes.jl")
include("CellLists.jl")

using figtree_jll

include("fgt.jl")
include("UpdateParticles.jl")
include("AdhesionForce.jl")

export AbstractWall, NearestPoint, generateQuadNodes!,isInLine

# CellLists.jl
export femGenerateMap,
       generateCellList,
       updateCellList!

# fgt.jl
export interpFGT!,
fgt!,
dgt!,
mydgt!

# ParticleTypes.jl
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
