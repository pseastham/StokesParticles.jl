using StokesParticles, Test
import StokesParticles: is_inside_rect, Particle2D, Point2D

# test isInsideRect
sampleRect    = [0.0, 0.6, -0.2, 0.4]
pointIn       = Point2D(0.1,0.3)
pointOut      = Point2D(1.1,0.3)
pointOnEdge   = Point2D(0.6,0.3)
pointOnCorner = Point2D(0.6,0.4)
@test is_inside_rect(sampleRect,pointIn) == true
@test is_inside_rect(sampleRect,pointOut) == false
@test is_inside_rect(sampleRect,pointOnEdge) == true
@test is_inside_rect(sampleRect,pointOnCorner) == true

# test generateCellList
n_particles = 3
particleList1 = [Particle2D(Point2D(rand(),rand()),rand(),1) for i=1:n_particles]
TotalBounds = [0.0,1.0,0.0,1.0]
L = 0.1
cl = StokesParticles.generateCellList(particleList1,TotalBounds,L)
sum = 0 
for i=1:length(cl.cells)
  global sum += length(cl.cells[i].particleIDList)
end
@test n_particles == sum

# test updateCellList!
n_particles = 1_000
particleList2 = [Particle2D(Point2D(rand(),rand()),rand(),1) for i=1:n_particles]
TotalBounds = [0.0,1.0,0.0,1.0]
L = 0.1
cl = generateCellList(particleList2,TotalBounds,L)
particleList3 = [Particle2D(Point2D(rand(),rand()),rand(),1) for i=1:n_particles]
updateCellList!(cl,particleList3)
sum = 0 
for i=1:length(cl.cells)
  global sum += length(cl.cells[i].particleIDList)
end
@test n_particles == sum