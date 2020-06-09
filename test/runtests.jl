using SafeTestsets

@time begin
    @time @safetestset "FIGTree Tests" begin include("fgt_test.jl") end
    @time @safetestset "Forces Tests" begin include("forces_test.jl") end
    @time @safetestset "Cell List Tests" begin include("celllists_test.jl") end
    @time @safetestset "Check Position Tests" begin include("position_checking_test.jl") end
    @time @safetestset "Full Run Tests" begin include("full_run_test.jl") end
end