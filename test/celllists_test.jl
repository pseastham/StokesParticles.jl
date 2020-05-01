using StokesParticles, Test
import StokesParticles: isInsideRect, Particle2D, Point2D

import eFEM: squareMesh

# test isInsideRect
sampleRect    = [0.0, 0.6, -0.2, 0.4]
pointIn       = Point2D(0.1,0.3)
pointOut      = Point2D(1.1,0.3)
pointOnEdge   = Point2D(0.6,0.3)
pointOnCorner = Point2D(0.6,0.4)
@test isInsideRect(sampleRect,pointIn) == true
@test isInsideRect(sampleRect,pointOut) == false
@test isInsideRect(sampleRect,pointOnEdge) == true
@test isInsideRect(sampleRect,pointOnCorner) == true

# test generateCellList
n_particles = 3
particleList1 = [Particle2D(Point2D(rand(),rand()),rand(),rand()) for i=1:n_particles]
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
particleList2 = [Particle2D(Point2D(rand(),rand()),rand(),rand()) for i=1:n_particles]
TotalBounds = [0.0,1.0,0.0,1.0]
L = 0.1
cl = generateCellList(particleList2,TotalBounds,L)
particleList3 = [Particle2D(Point2D(rand(),rand()),rand(),rand()) for i=1:n_particles]
updateCellList!(cl,particleList3)
sum = 0 
for i=1:length(cl.cells)
  global sum += length(cl.cells[i].particleIDList)
end
@test n_particles == sum

# test fem_generate_map
rect = [-1.0,1.0,-1.0,1.0]
N    = 64
mesh = squareMesh(rect,N,2)
L    = 0.1
totalBounds = [rect[1]-L,rect[2]+L,rect[3]-L,rect[4]+L]
femCLmap = StokesParticles.femGenerateMap(mesh,totalBounds,L)

# test getElementFromNode!
rect = [-1.0,1.0,-1.0,1.0]
N    = 5
mesh = squareMesh(rect,N,1)
elementArray = zeros(Int,4)
nodeInd = 12
@test StokesParticles.getElementFromNode!(elementArray,mesh,nodeInd) != π     # just to make sure function runs