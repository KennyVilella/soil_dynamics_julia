using Test
using SoilDynamics
import ReferenceFrameRotations: angle_to_quat
import SparseArrays: SparseMatrixCSC, nonzeros

println("Unit testing")
@time @testset "types.jl" verbose = true begin
    include("./unit_test/test_types.jl")
end
println("")
@time @testset "bucket.jl" verbose = true begin
    include("./unit_test/test_bucket.jl")
end
println("")
@time @testset "utils.jl" verbose = true begin
    include("./unit_test/test_utils.jl")
end
