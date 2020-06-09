using Parameters

@with_kw struct sp_params
    # force parameters
    ϵ::Float64  = 10            # interaction distance (percentage)
    sC::Float64 = 1.0           # cohesion strength coefficient
    sA::Float64 = 1.0           # adhesion strength coefficient
    G::Float64  = 1.0           # force of gravity

    # time stepping
    Tf::Float64 = 10              # final time
    Δt::Float64 = 0.1            # maximum time step 

    # geometry
    circfile::String = "initial_figures.circ"    # file name for particle geometry
    wallfile::String = "step.wall"               # file name for wall geometry
    matID = Dict(1 => :clay)                     # IDs for particles

    # don't touch these (used internally)
    Nt::Int = Int(ceil(Tf/Δt))   # number of steps to take
    # need term for 'largest step size'
end