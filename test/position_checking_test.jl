using StokesParticles, Test
import StokesParticles: do_intersect, get_orientation, is_point_in_wall, Particle2D, Point2D

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