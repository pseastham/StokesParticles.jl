using StokesParticles, Test

# no cl test
pList = [Particle2D(Point2D(-0.5,0.3),0.02,1),
         Particle2D(Point2D(-0.5,-0.3),0.01,1),
         Particle2D(Point2D(-0.5,-0.28),0.01,1)]
wList = [LineWall(Point2D(2.0,1.0),Point2D(2.0,0.0),0.1)]
param = sp_params()
data = scratch_data(length(pList)) 
update_particles_nofluid_nocl!(pList,wList,param,data)


L = 0.5
cl = generate_cell_list(pList,[-3.0,3.0,-3.0,3.0],L)
update_particles_nofluid!(pList,wList,param,data,cl)