using BenchmarkTools
using SoilDynamics
import Logging: disable_logging
import ReferenceFrameRotations: angle_to_quat

println("Benchmark for a simple digging scoop")
include("./benchmark/benchmark_soil_evolution.jl")
println("")
println("Benchmark for soil_dynamics.jl")
include("./benchmark/benchmark_soil_dynamics.jl")
println("")
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
