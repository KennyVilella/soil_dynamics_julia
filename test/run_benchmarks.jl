using BenchmarkTools
using SoilDynamics
import ReferenceFrameRotations: angle_to_quat


println("Benchmark bucket.jl")
include("./benchmark/benchmark_bucket.jl")
println("")
println("Benchmark utils.jl")
include("./benchmark/benchmark_utils.jl")
