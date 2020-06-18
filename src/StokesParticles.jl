module StokesParticles

using figtree_jll

include("struct_defs.jl")
include("inside_checking_functions.jl")
include("cell_lists.jl")
include("fgt.jl")
include("forces.jl")
include("update_particles.jl")
include("params.jl")
include("io.jl")

export generate_cell_list,
       update_cell_list!

export Point2D,
       Particle2D,
       LineWall,
       CircleWall,
       ArcWall

export update_particles_nofluid!,
       update_particles_nofluid_nocl!

export scratch_data,
       sp_params

export write_circ, read_circ2, 
       write_circ2, read_circ2,
       write_wall, read_wall,
       combine_circ

end # module
