module StokesParticles

include("ParticleTypes.jl")
include("CellLists.jl")
include("fgt.jl")
include("UpdateParticles.jl")
include("AdhesionForce.jl")

export AbstractWall, NearestPoint, generateQuadNodes!,isInLine

# CellLists.jl
export femGenerateMap,
       generateCellList,
       updateCellList!

# fgt.jl
export interpFGT!

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
