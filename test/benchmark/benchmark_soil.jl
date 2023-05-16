"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#
# Grid properties
grid_size_x = 4.0
grid_size_y = 4.0
grid_size_z = 3.0
cell_size_xy = 0.05
cell_size_z = 0.01
grid = GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)

# Terrain properties
terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
out = SimOut(terrain, grid)


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

# Benchmarking for _body_to_terrain! function
out.body_soil[1][10, 15] = 0.2
out.body_soil[2][10, 15] = 0.5
println("_body_to_terrain!")
display(
    @benchmark _body_to_terrain!(out, 10, 15, 1, 5, 7, grid)
)
println("")
