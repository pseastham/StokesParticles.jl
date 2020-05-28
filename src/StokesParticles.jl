module StokesParticles

abstract type AbstractWall end
abstract type AbstractParticle end
abstract type AbstractPoint end

include("PointAndWallDefinitions.jl")
include("isInside.jl")
include("CellLists.jl")

using figtree_jll

include("fgt.jl")
include("Forces.jl")
include("DataReuse.jl")
include("UpdateParticles.jl")

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
