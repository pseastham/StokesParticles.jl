function update_particles_nofluid!(pList,wList,param,data)
    pUarr,pVarr = compute_particle_velocity_nofluids(pList,wList,param,data)
    for ti=1:data.n_particles
        pList[ti].pos.x += pUarr[ti]*param.Δt
        pList[ti].pos.y += pVarr[ti]*param.Δt
    end

    nothing
end

# does not use cell lists
function compute_particle_velocity_nofluids(pList,wList,param,data)
    # 1. compute gravitational force
    gfX = zeros(data.n_particles)
    gfY = -param.G*ones(data.n_particles)

    # 2. interpolate seepage velocity of fluid at position of particles
    # not done when there is no fluid

    # 3. compute cohesion forces
    #computeCohesion!(cfX,cfY,pList,rList,rc,ϵ)
    computeCohesion_backup!(data.cfX,data.cfY,pList,param.sC,param.ϵ)

    # 4. compute adhesion forces
    computeAdhesionForce!(data.afX,data.afY,pList,wList,data.pointOnWall,param.sA,param.ϵ)

    pUarr = gfX + data.cfX + data.afX
    pVarr = gfY + data.cfY + data.afY

    return pUarr,pVarr
end