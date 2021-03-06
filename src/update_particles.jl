function update_particles_nofluid_nocl!(pList,wList,param,data)
    pUarr,pVarr = compute_particle_velocity_nofluids_nocl(pList,wList,param,data)
    for ti=1:data.n_particles
        pList[ti].pos.x += pUarr[ti]*param.Δt
        pList[ti].pos.y += pVarr[ti]*param.Δt
    end

    nothing
end

# does not use cell lists
function compute_particle_velocity_nofluids_nocl(pList,wList,param,data)
    compute_gravity_force!(data.gfX,data.gfY,data.n_particles,param.G)
    compute_cohesion_force_backup!(data.cfX,data.cfY,pList,param.sC,param.ϵ)
    compute_adhesion_force!(data.afX,data.afY,pList,wList,data.pointOnWall,param.sA,param.ϵ)

    pUarr = data.gfX + data.cfX + data.afX
    pVarr = data.gfY + data.cfY + data.afY

    return pUarr,pVarr
end

function update_particles_nofluid!(pList,wList,param,data,cl)
    pUarr,pVarr = compute_particle_velocity_nofluids(pList,wList,param,data,cl)
    for ti=1:data.n_particles
        pList[ti].pos.x += pUarr[ti]*param.Δt
        pList[ti].pos.y += pVarr[ti]*param.Δt
    end

    nothing
end

# does not use cell lists
function compute_particle_velocity_nofluids(pList,wList,param,data,cl)
    compute_gravity_force!(data.gfX,data.gfY,data.n_particles,param.G)
    compute_cohesion_force_cl!(data.cfX,data.cfY,cl,pList,param.sC,param.ϵ)
    compute_adhesion_force!(data.afX,data.afY,pList,wList,data.pointOnWall,param.sA,param.ϵ)

    pUarr = data.gfX + data.cfX + data.afX
    pVarr = data.gfY + data.cfY + data.afY

    return pUarr,pVarr
end