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

# Benchmarking for _init_sparse_array! function
ori = angle_to_quat(0.0, -pi / 2, 0.0, :ZYX)
pos = Vector{Float64}([0.0, 0.0, -0.1])
_calc_bucket_pos!(out, pos, ori, grid, bucket)
println("_init_sparse_array!")
display(
    @benchmark _init_sparse_array!(out.body, grid)
)
println("")

# Benchmarking for _locate_all_non_zeros function
out.body_soil[1][20:50, 15:75] .= 0.2
out.body_soil[2][20:50, 15:75] .= 0.5
out.body_soil[3][40:50, 50:70] .= 0.3
out.body_soil[4][40:50, 50:70] .= 0.7
println("_locate_all_non_zeros")
display(
    @benchmark body_soil_pos = _locate_all_non_zeros(out.body)
)
println("")

# Benchmarking for _locate_non_zeros function
out.body_soil[1][20:50, 15:75] .= 0.2
println("_locate_non_zeros")
display(
    @benchmark non_zeros = _locate_non_zeros(out.body_soil[1])
)

# Benchmarking for calc_normal function
a = [1.0, 0.0, 0.0]
b = [0.0, 1.0, 0.0]
c = [0.0, 0.0, 1.0]
println("calc_normal")
display(
    @benchmark unit_normal = calc_normal(a, b, c)
)
println("")
