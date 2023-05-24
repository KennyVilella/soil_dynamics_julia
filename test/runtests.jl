using Test
using SoilDynamics
import Random: seed!
import ReferenceFrameRotations: angle_to_quat, Quaternion
import SparseArrays: SparseMatrixCSC, nonzeros, dropzeros!

println("Unit testing")
@time @testset "types.jl" verbose = true begin
    include("./unit_test/test_types.jl")
end
println("")
@time @testset "utils.jl" verbose = true begin
    include("./unit_test/test_utils.jl")
end
println("")
@time @testset "bucket.jl" verbose = true begin
    include("./unit_test/test_bucket.jl")
end
println("")
@time @testset "body_soil.jl" verbose = true begin
    include("./unit_test/test_body_soil.jl")
end
println("")
@time @testset "intersecting_cells.jl" verbose = true begin
    include("./unit_test/test_intersecting_cells.jl")
end
