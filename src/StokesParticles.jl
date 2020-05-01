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
include("DataReuse.jl")

export AbstractWall, NearestPoint, generateQuadNodes!,isInLine

# CellLists.jl
export femGenerateMap,
       generateCellList,
       updateCellList!

# TypeDefinitions.jl
export Point2D,
       Particle2D,
       LineWall,
       CircleWall,
       ArcWall

# UpdateParticles.jl
export update_particles_nofluid!

# DataReuse
export sh_data

end # module
