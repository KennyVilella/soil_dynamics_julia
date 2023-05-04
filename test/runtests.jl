using Test
using SoilDynamics

println("Unit testing")
@time @testset "types.jl" verbose = true begin
    include("./unit_test/test_types.jl")
end

