using BenchmarkTools
using SoilDynamics
import ReferenceFrameRotations: angle_to_quat

println("Benchmark bucket.jl")
include("./benchmark/benchmark_bucket.jl")
println("")
println("Benchmark body_soil.jl")
include("./benchmark/benchmark_body_soil.jl")
println("")
println("Benchmark intersecting_cells.jl")
include("./benchmark/benchmark_intersecting_cells.jl")
println("")
println("Benchmark relax.jl")
include("./benchmark/benchmark_relax.jl")
println("")
println("Benchmark utils.jl")
include("./benchmark/benchmark_utils.jl")
