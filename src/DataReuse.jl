mutable struct sh_data  # sinkhole data
    polygon::Vector{Point2D{Float64}}
    extremePoint::Point2D{Float64}
    pointOnWall::Point2D{Float64}
    xquad::Vector{Float64}
    yquad::Vector{Float64}
    cfX::Vector{Float64}
    cfY::Vector{Float64}
    afX::Vector{Float64}
    afY::Vector{Float64}

    function sh_data(n_quad::Int,n_particles::Int)
        polygon      = [Point2D(0.0,0.0),Point2D(0.0,0.0),Point2D(0.0,0.0),Point2D(0.0,0.0)]
        extremePoint = Point2D(100_000.0,0.0)
        pointOnWall  = Point2D(0.0,0.0)
        xquad        = zeros(n_quad)
        yquad        = zeros(n_quad)
        cfX          = zeros(n_particles)
        cfY          = zeros(n_particles)
        afX          = zeros(n_particles)
        afY          = zeros(n_particles)
        return new(polygon,extremePoint,pointOnWall,xquad,yquad,cfX,cfY,afX,afY)
    end
    function sh_data(n_particles::Int)
        return sh_data(1,n_particles)
    end
end 