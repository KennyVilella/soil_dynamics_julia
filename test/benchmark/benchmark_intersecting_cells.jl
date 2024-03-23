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

# Simulation properties
repose_angle = 0.85
max_iterations = 3
cell_buffer = 4
sim = SimParam(repose_angle, max_iterations, cell_buffer)

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
_calc_bucket_pos!(out, pos_1, ori_1, grid, bucket, sim)
println("_move_intersecting_cells!")
display(
    @benchmark _move_intersecting_cells!(out, grid, bucket)
)
println("")

# Benchmarking for _move_intersecting_body! function
out.terrain[:, :] .= 0.0
pos_1 = [0.0, 0.0, 0.0]
ori_1 = angle_to_quat(0.0, 0.0, pi / 2, :ZYX)
_calc_bucket_pos!(out, pos_1, ori_1, grid, bucket, sim)
println("_move_intersecting_body!")
display(
    @benchmark _move_intersecting_body!(out)
)
println("")

# Benchmarking for _move_intersecting_body_soil! function
out.terrain[:, :] .= 0.0
_init_sparse_array!(out.body, grid)
_init_sparse_array!(out.body_soil, grid)
out.body[1][20:30, 24:41] .= 0.1
out.body[2][20:30, 24:41] .= 0.3
out.body[3][20:30, 24:41] .= 0.6
out.body[4][20:30, 24:41] .= 0.8
out.body_soil[1][20:30, 24:41] .= 0.3
out.body_soil[2][20:30, 24:41] .= 0.4
out.body_soil[3][20:30, 24:41] .= 0.8
out.body_soil[4][20:30, 24:41] .= 0.9
out.body_soil[2][20, 24:41] .= 0.8
out.body_soil[2][25, 24:41] .= 0.9
out.body_soil[2][20:38, 40] .= 0.7
println("_move_intersecting_body_soil!")
display(
    @benchmark _move_intersecting_body_soil!(out, grid, bucket)
)
println("")

# Benchmarking for _locate_intersecting_cells function
out.terrain[:, :] .= 0.0
pos_1 = [0.0, 0.0, 0.0]
ori_1 = angle_to_quat(0.0, 0.0, pi / 2, :ZYX)
_calc_bucket_pos!(out, pos_1, ori_1, grid, bucket, sim)
println("_locate_intersecting_cells")
display(
    @benchmark intersecting_cells = _locate_intersecting_cells(out)
)
println("")

# Benchmarking for _move_body_soil! function
out.terrain[:, :] .= 0.0
_init_sparse_array!(out.body, grid)
_init_sparse_array!(out.body_soil, grid)
out.body[1][5, 7] = 0.1
out.body[2][5, 7] = 0.3
out.body[3][5, 7] = 0.6
out.body[4][5, 7] = 0.8
out.body_soil[1][5, 7] = 0.3
out.body_soil[2][5, 7] = 1.1
out.body_soil[3][5, 7] = 0.8
out.body_soil[4][5, 7] = 0.9
out.body[1][5, 11] = 0.0
out.body[2][5, 11] = 0.2
out.body[3][5, 11] = 0.4
out.body[4][5, 11] = 0.8
out.body_soil[1][5, 11] = 0.2
out.body_soil[2][5, 11] = 0.3
println("_move_body_soil!")
display(
    @benchmark ind_p, ii_p, jj_p, h_soil, wall_presence = _move_body_soil!(
                    out, 1, 5, 7, 0.4, 5, 11, 0.5, true, grid, bucket
               )
)
println("")
