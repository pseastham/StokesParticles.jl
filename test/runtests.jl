using SafeTestsets

@time begin
    @time @safetestset "FIGTree Tests" begin include("fgt_test.jl") end
end