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

# Bucket properties
o_pos_init = Vector{Float64}([0.0, 0.0, 0.0])
j_pos_init = Vector{Float64}([0.0, 0.0, 0.0])
b_pos_init = Vector{Float64}([0.0, 0.0, -0.5])
t_pos_init = Vector{Float64}([0.7, 0.0, -0.5])
bucket_width = 0.5
bucket = BucketParam(o_pos_init, j_pos_init, b_pos_init, t_pos_init, bucket_width)

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

# Benchmarking for _move_intersecting_cells! function
out.terrain[:, :] .= 0.0
pos_1 = [0.0, 0.0, 0.0]
ori_1 = angle_to_quat(0.0, 0.0, pi / 2, :ZYX)
_calc_bucket_pos!(out, pos_1, ori_1, grid, bucket)
println("_move_intersecting_cells!")
display(
    @benchmark _move_intersecting_cells!(out, grid)
)
println("")

# Benchmarking for _move_intersecting_body! function
out.terrain[:, :] .= 0.0
pos_1 = [0.0, 0.0, 0.0]
ori_1 = angle_to_quat(0.0, 0.0, pi / 2, :ZYX)
_calc_bucket_pos!(out, pos_1, ori_1, grid, bucket)
println("_move_intersecting_body!")
display(
    @benchmark _move_intersecting_body!(out, grid)
)
println("")

# Benchmarking for _locate_intersecting_cells function
out.terrain[:, :] .= 0.0
pos_1 = [0.0, 0.0, 0.0]
ori_1 = angle_to_quat(0.0, 0.0, pi / 2, :ZYX)
_calc_bucket_pos!(out, pos_1, ori_1, grid, bucket)
println("_locate_intersecting_cells")
display(
    @benchmark intersecting_cells = _locate_intersecting_cells(out)
)
println("")