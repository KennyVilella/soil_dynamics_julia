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

# Simulation properties
repose_angle = 0.85
max_iterations = 3
sim = SimParam(repose_angle, max_iterations)

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

# Benchmarking for _relax_terrain! function
out.terrain[50:65, 50:65] .= 0.4
out.body[1][49, 50:65] .= 0.0
out.body[2][49, 50:60] .= 0.1
out.body[2][49, 61:65] .= 0.4
println("_relax_terrain!")
display(
    @benchmark _relax_terrain!(out, grid, sim)
)
println("")

# Benchmarking for _locate_unstable_terrain_cell function
out.terrain[:, :] .= 0.0
out.terrain[50:65, 50:65] .= 0.4
println("_locate_unstable_terrain_cell")
display(
    @benchmark unstable_cells = _locate_unstable_terrain_cell(out, 0.1)
)
println("")
