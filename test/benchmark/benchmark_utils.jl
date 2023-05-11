"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#

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

# Benchmarking for calc_normal function
a = [1.0, 0.0, 0.0]
b = [0.0, 1.0, 0.0]
c = [0.0, 0.0, 1.0]
println("calc_normal")
display(
    @benchmark unit_normal = calc_normal(a, b, c)
)
println("")
