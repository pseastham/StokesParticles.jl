mutable struct sh_data  # sinkhole data
    polygon::Vector      = [Point2D(0.0,0.0),Point2D(0.0,0.0),Point2D(0.0,0.0),Point2D(0.0,0.0)]
    extremePoint = Point2D(100_000.0,0.0)
    pointOnWall = Point2D(0.0,0.0)
    xquad = zeros(Float64,Nint); yquad = zeros(Float64,Nint)
    cfX = zeros(Float64,Nparticles); cfY = zeros(Float64,Nparticles)
    afX = zeros(Float64,Nparticles); afY = zeros(Float64,Nparticles)

    function sh_data(n_quad::Int,n_particles::Int)
        polygon      = [Point2D(0.0,0.0),Point2D(0.0,0.0),Point2D(0.0,0.0),Point2D(0.0,0.0)]
        extremePoint = Point2D(100_000.0,0.0)
        pointOnWall  = Point2D(0.0,0.0)
        xquad        = zeros(Nint)
        yquad        = zeros(Nint)
        cfX          = zeros(Nparticles)
        cfY          = zeros(Nparticles)
        afX          = zeros(Nparticles)
        afY          = zeros(Nparticles)
        return new(polygon,extremePoint,pointOnWall,xquad,yquad,cfX,cfY,afX,afY)
    end
end 