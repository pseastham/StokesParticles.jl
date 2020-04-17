module StokesParticles

const deps_path = abspath(joinpath(dirname(@__FILE__), "..", "deps"))

if !isfile(joinpath(deps_path, "deps.jl"))
    error("StokesParticles not installed properly, run Pkg.build(\"StokesParticles\"), restart Julia and try again")
end
include(joinpath(deps_path, "deps.jl"))
include(joinpath(deps_path, "usr", "lib", "StokesParticles.jl"))

function __init__()
    # Always check your dependencies that live in `deps.jl`
    check_deps()
end

using BenchmarkTools 

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
