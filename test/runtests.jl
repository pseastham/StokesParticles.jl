using SafeTestsets

@time begin
    @time @safetestset "FIGTree Tests" begin include("fgt_test.jl") end
    @time @safetestset "Cohesion Tests" begin include("cohesion_test.jl") end
end