using StokesParticles, Test

@test_throws DimensionMismatch LineWall([Point2D(0.0,0.0)],0.1)

ArcWall(Point2D(1.0,0.0),Point2D(0.0,0.0),Point2D(0.0,1.0),0.1)

@test_throws MethodError ArcWall(Point2D(1.0,0.0),Point2D(0.0,0.0),Point2D(0.0,2.0),0.1)
