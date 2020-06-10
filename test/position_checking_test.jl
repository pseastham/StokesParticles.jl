using StokesParticles, Test
import StokesParticles: do_intersect, get_orientation, get_nearest_point!, get_nearest_point, is_in_line

p1 = Point2D(0.0,0.0); q1 = Point2D(0.0,1.0)
p2 = Point2D(-0.5,0.5); q2 = Point2D(0.5,0.5)
@testset "do_intersect tests" begin 
    @test do_intersect(p1,q1,p2,q2) == true
    @test do_intersect(p1,p2,q1,q2) == false
end

z = Point2D(0.5+Float64(pi),1.5+Float64(pi))
@testset "get_orientation tests" begin
    @test get_orientation(p2,q1,z) == 0
    @test get_orientation(p2,z,q1) == 0
    @test get_orientation(z,p2,q1) == 0
    @test get_orientation(p1,q1,Point2D(1.0,0.0)) == 1
    @test get_orientation(p1,q1,Point2D(-1.0,0.0)) == 2
end

wall1 = LineWall(Point2D(0.0,0.0),Point2D(2.0,0.0),0.2)
pointOnWall1 = Point2D(0.0,0.0)
pointOnWall2 = Point2D(0.0,0.0)
pointOnWallA = Point2D(0.1,0.1)
pointOnWallC = Point2D(0.0,0.0)
particle = Particle2D(Point2D(0.6,0.1),0.5,1)
wall2 = LineWall(Point2D(0.0,0.0),Point2D(0.0,2.0),0.2)
wallC = CircleWall(Point2D(0.0,0.0),1.0,0.2)
wallA = ArcWall(Point2D(0.0,-1.0),Point2D(0.0,0.0),Point2D(0.0,1.0),0.2)
@testset "get_nearest_point! tests" begin
    get_nearest_point!(pointOnWall1,particle,wall1)
    @test pointOnWall1.x == 0.6
    @test pointOnWall1.y == 0.0

    get_nearest_point!(pointOnWall2,particle,wall2)
    @test pointOnWall2.x == 0.0
    @test pointOnWall2.y == 0.1

    pointOnWall3 = get_nearest_point(particle,wall2)
    @test pointOnWall3.x == 0.0
    @test pointOnWall3.y == 0.1

    get_nearest_point!(pointOnWallA,particle,wallA)
    get_nearest_point!(pointOnWallC,particle,wallC)
end

@testset "is_in_line tests" begin
    @test is_in_line(wall1,pointOnWall1) == true
    @test is_in_line(wall2,pointOnWall2) == true
    @test is_in_line(wall2,particle.pos) == false
    @test is_in_line(wall2,Point2D(0.0,2.1)) == false
    @test is_in_line(wall2,Point2D(0.0,-0.1)) == false
    @test is_in_line(wallA,pointOnWallA) == true
    @test is_in_line(wallC,pointOnWallC) == true
    @test is_in_line(wallA,Point2D(sqrt(2)/2,sqrt(2)/2)) == true
    @test is_in_line(wallA,Point2D(-sqrt(2)/2,sqrt(2)/2)) == false
    @test is_in_line(wallA,Point2D(sqrt(2)/2,-sqrt(2)/2)) == true
    @test is_in_line(wallA,Point2D(-sqrt(2)/2,-sqrt(2)/2)) == false
    @test is_in_line(wallA,Point2D(0.0,-0.1)) == false
    @test is_in_line(wallC,Point2D(sqrt(2)/2,sqrt(2)/2)) == true
    @test is_in_line(wallC,Point2D(0.0,-0.1)) == false
end