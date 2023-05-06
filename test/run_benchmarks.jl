using BenchmarkTools
using SoilDynamics

println("Benchmark bucket.jl")
include("./benchmark/benchmark_bucket.jl")
println("")
