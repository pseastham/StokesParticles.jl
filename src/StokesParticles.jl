module StokesParticles

using figtree_jll

include("struct_defs.jl")
include("inside_checking_functions.jl")
include("cell_lists.jl")
include("fgt.jl")
include("forces.jl")
include("update_particles.jl")

export generateCellList,
       updateCellList!

export Point2D,
       Particle2D,
       LineWall,
       CircleWall,
       ArcWall

export update_particles_nofluid!

end # module
