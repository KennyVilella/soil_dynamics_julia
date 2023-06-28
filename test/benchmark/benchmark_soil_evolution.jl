"""
Copyright, 2023,  Vilella Kenny.
"""

include("../example/soil_evolution.jl")
#==========================================================================================#
#                                                                                          #
#                                       Benchmarking                                       #
#                                                                                          #
#==========================================================================================#
# Setting benchmarking properties
BenchmarkTools.DEFAULT_PARAMETERS.gcsample = true
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 60
BenchmarkTools.DEFAULT_PARAMETERS.samples = 100

# Benchmarking for a simple digging scoop
disable_logging(Logging.Info)
println("soil_evolution")
display(
    @benchmark soil_evolution(false, false, false, false, true)
)
println("")
