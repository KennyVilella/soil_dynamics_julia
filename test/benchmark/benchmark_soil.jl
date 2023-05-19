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

# Benchmarking for _update_body_soil! function
pos_1 = [0.5, 0.0, 0.0]
ori_1 = angle_to_quat(0.0, 0.0, pi / 2, :ZYX)
_calc_bucket_pos!(out, pos_1, ori_1, grid, bucket)
out.body_soil[1][91:105, 71] .= out.body[2][91:105, 71]
out.body_soil[2][91:105, 71] .= out.body[2][91:105, 71] .+ 0.2
out.body_soil[1][91:104, 72] .= out.body[2][91:104, 72]
out.body_soil[2][91:104, 72] .= out.body[2][91:104, 72] .+ 0.2
out.body_soil[1][91:103, 73] .= out.body[2][91:103, 73]
out.body_soil[2][91:103, 73] .= out.body[2][91:103, 73] .+ 0.2
out.body_soil[1][91:101, 74] .= out.body[2][91:101, 74]
out.body_soil[2][91:101, 74] .= out.body[2][91:101, 74] .+ 0.2
out.body_soil[1][91:100, 75] .= out.body[2][91:100, 75]
out.body_soil[2][91:100, 75] .= out.body[2][91:100, 75] .+ 0.2
out.body_soil[1][91:99, 76] .= out.body[2][91:99, 76]
out.body_soil[2][91:99, 76] .= out.body[2][91:99, 76] .+ 0.2
out.body_soil[1][91:97, 77] .= out.body[2][91:97, 77]
out.body_soil[2][91:97, 77] .= out.body[2][91:97, 77] .+ 0.2
out.body_soil[1][91:96, 78] .= out.body[2][91:96, 78]
out.body_soil[2][91:96, 78] .= out.body[2][91:96, 78] .+ 0.2
out.body_soil[1][91:94, 79] .= out.body[2][91:94, 79]
out.body_soil[2][91:94, 79] .= out.body[2][91:94, 79] .+ 0.2
out.body_soil[1][91:93, 80] .= out.body[2][91:93, 80]
out.body_soil[2][91:93, 80] .= out.body[2][91:93, 80] .+ 0.2
out.body_soil[1][91:92, 81] .= out.body[2][91:92, 81]
out.body_soil[2][91:92, 81] .= out.body[2][91:92, 81] .+ 0.2
pos_2 = [0.5 + cell_size_xy, 0.0, 0.0]
_calc_bucket_pos!(out, pos_2, ori_1, grid, bucket)
println("_update_body_soil!")
display(
    @benchmark _update_body_soil!(out, pos_2, ori_1, grid, bucket)
)
println("")

# Benchmarking for _body_to_terrain! function
out.body_soil[1][10, 15] = 0.2
out.body_soil[2][10, 15] = 0.5
println("_body_to_terrain!")
display(
    @benchmark _body_to_terrain!(out, 10, 15, 1, 5, 7, grid)
)
println("")
