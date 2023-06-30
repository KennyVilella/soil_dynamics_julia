"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#
# Grid properties
grid_size_x = 1.0
grid_size_y = 1.0
grid_size_z = 1.0
cell_size_xy = 0.1
cell_size_z = 0.1
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
#                                         Testing                                          #
#                                                                                          #
#==========================================================================================#
@testset "_body_to_terrain!" begin
    # Setting dummy values in body_soil
    out.body_soil[1][5, 5] = 0.1
    out.body_soil[2][5, 5] = 0.2
    out.body_soil[3][5, 5] = 0.5
    out.body_soil[4][5, 5] = 0.9
    out.body_soil[3][7, 9] = -0.2
    out.body_soil[4][7, 9] = 0.0
    out.body_soil[1][4, 9] = 0.1
    out.body_soil[2][4, 9] = 0.1
    out.body_soil[1][11, 7] = -0.5
    out.body_soil[2][11, 7] = -0.3
    out.body_soil[3][11, 7] = -0.2
    out.body_soil[4][11, 7] = -0.0
    out.body_soil[1][2, 7] = 0.0
    out.body_soil[2][2, 7] = 0.3

    # Testing for partial avalanche (1)
    _body_to_terrain!(out, 5, 5, 1, 1, 2, grid, 0.05)
    @test (out.body_soil[1][5, 5] ≈ 0.1) && (out.body_soil[2][5, 5] ≈ 0.15)
    @test out.terrain[1, 2] ≈ 0.05
    # Resetting terrain
    out.terrain[1, 2] = 0.0

    # Testing for partial avalanche (2)
    _body_to_terrain!(out, 5, 5, 3, 1, 3, grid, 0.2)
    @test (out.body_soil[3][5, 5] ≈ 0.5) && (out.body_soil[4][5, 5] ≈ 0.7)
    @test out.terrain[1, 3] ≈ 0.2
    # Resetting terrain
    out.terrain[1, 3] = 0.0

    # Testing for partial avalanche (3)
    _body_to_terrain!(out, 7, 9, 3, 1, 4, grid, 0.1)
    @test (out.body_soil[3][7, 9] ≈ -0.2) && (out.body_soil[4][7, 9] ≈ -0.1)
    @test out.terrain[1, 4] ≈ 0.1
    # Resetting terrain
    out.terrain[1, 4] = 0.0

    # Testing for full avalanche with default value (1)
    _body_to_terrain!(out, 5, 5, 1, 2, 3, grid)
    @test (out.body_soil[1][5, 5] == 0.0) && (out.body_soil[2][5, 5] == 0.0)
    @test out.terrain[2, 3] ≈ 0.05
    # Resetting terrain
    out.terrain[2, 3] = 0.0

    # Testing for full avalanche with default value (2)
    _body_to_terrain!(out, 5, 5, 3, 2, 4, grid)
    @test (out.body_soil[3][5, 5] == 0.0) && (out.body_soil[4][5, 5] == 0.0)
    @test out.terrain[2, 4] ≈ 0.2
    # Resetting terrain
    out.terrain[2, 4] = 0.0

    # Testing for full avalanche with inputted -1.0 (1)
    _body_to_terrain!(out, 11, 7, 1, 3, 4, grid, 1e8)
    @test (out.body_soil[1][11, 7] == 0.0) && (out.body_soil[2][11, 7] == 0.0)
    @test out.terrain[3, 4] ≈ 0.2
    # Resetting terrain
    out.terrain[3, 4] = 0.0

    # Testing for full avalanche with inputted -1.0 (2)
    _body_to_terrain!(out, 11, 7, 3, 3, 5, grid, 1e8)
    @test (out.body_soil[3][11, 7] == 0.0) && (out.body_soil[4][11, 7] == 0.0)
    @test out.terrain[3, 5] ≈ 0.2
    # Resetting terrain
    out.terrain[3, 5] = 0.0

    # Testing for full avalanche
    _body_to_terrain!(out, 7, 9, 3, 4, 5, grid, 0.1)
    @test (out.body_soil[3][7, 9] == 0.0) && (out.body_soil[4][7, 9] == 0.0)
    @test out.terrain[4, 5] ≈ 0.1
    # Resetting terrain
    out.terrain[4, 5] = 0.0

    # Testing for the edge case where no soil is present
    _body_to_terrain!(out, 4, 9, 1, 5, 6, grid, 0.0)
    @test (out.body_soil[1][4, 9] == 0.0) && (out.body_soil[2][4, 9] == 0.0)
    @test out.terrain[5, 6] == 0.0

    # Testing that incorrect request throws an error
    @test_throws ErrorException _body_to_terrain!(out, 4, 9, 1, 6, 7, grid, 0.2)
    @test_throws ErrorException _body_to_terrain!(out, 1, 1, 3, 6, 8, grid, 0.1)
    @test_throws ErrorException _body_to_terrain!(out, 2, 7, 1, 6, 9, grid, 0.8)
    @test_throws ErrorException _body_to_terrain!(out, 2, 7, 3, 6, 9, grid, 0.2)

    # Resetting unused body_soil
    out.body_soil[1][2, 7] = 0.0
    out.body_soil[2][2, 7] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])

    # Testing that body_soil has not been unexpectedly modified
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    @test isempty(nonzeros(out.body_soil[3]))
    @test isempty(nonzeros(out.body_soil[4]))

    # Testing that terrain has not been unexpectedly modified
    @test all(out.terrain[:, :] .== 0.0)
end

@testset "_update_body_soil!" begin
    # Setting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]

    # Testing for a simple lateral translation from (11, 11) to (12, 11)
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = Quaternion([1.0, 0.0, 0.0, 0.0])
    out.body[1][12, 11] = 0.0
    out.body[2][12, 11] = 0.1
    out.body_soil[1][11, 11] = 0.1
    out.body_soil[2][11, 11] = 0.2
    push!(out.body_soil_pos, [1; 11; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[1][12, 11] ≈ 0.1) && (out.body_soil[2][12, 11] ≈ 0.2)
    out.body_soil[1][12, 11] = 0.0
    out.body_soil[2][12, 11] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[1][12, 11] = 0.0
    out.body[2][12, 11] = 0.0
    empty!(out.body_soil_pos)

    # Testing for a simple lateral translation (2)
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = Quaternion([1.0, 0.0, 0.0, 0.0])
    out.body[1][12, 11] = 0.0
    out.body[2][12, 11] = 0.1
    out.body_soil[3][11, 11] = 0.1
    out.body_soil[4][11, 11] = 0.2
    push!(out.body_soil_pos, [3; 11; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[1][12, 11] ≈ 0.1) && (out.body_soil[2][12, 11] ≈ 0.2)
    out.body_soil[1][12, 11] = 0.0
    out.body_soil[2][12, 11] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[1][12, 11] = 0.0
    out.body[2][12, 11] = 0.0
    empty!(out.body_soil_pos)

    # Testing for a simple lateral translation (3)
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = Quaternion([1.0, 0.0, 0.0, 0.0])
    out.body[3][12, 11] = 0.0
    out.body[4][12, 11] = 0.1
    out.body_soil[1][11, 11] = 0.1
    out.body_soil[2][11, 11] = 0.2
    push!(out.body_soil_pos, [1; 11; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[3][12, 11] ≈ 0.1) && (out.body_soil[4][12, 11] ≈ 0.2)
    out.body_soil[3][12, 11] = 0.0
    out.body_soil[4][12, 11] = 0.0
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])
    @test isempty(nonzeros(out.body_soil[3]))
    @test isempty(nonzeros(out.body_soil[4]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[3][12, 11] = 0.0
    out.body[4][12, 11] = 0.0
    empty!(out.body_soil_pos)

    # Testing for a simple lateral translation (4)
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = Quaternion([1.0, 0.0, 0.0, 0.0])
    out.body[3][12, 11] = 0.0
    out.body[4][12, 11] = 0.1
    out.body_soil[3][11, 11] = 0.1
    out.body_soil[4][11, 11] = 0.2
    push!(out.body_soil_pos, [3; 11; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[3][12, 11] ≈ 0.1) && (out.body_soil[4][12, 11] ≈ 0.2)
    out.body_soil[3][12, 11] = 0.0
    out.body_soil[4][12, 11] = 0.0
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])
    @test isempty(nonzeros(out.body_soil[3]))
    @test isempty(nonzeros(out.body_soil[4]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[3][12, 11] = 0.0
    out.body[4][12, 11] = 0.0
    empty!(out.body_soil_pos)

    # Testing for a simple rotation from (12, 11) to (11, 12)
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(-pi / 2, 0.0, 0.0, :ZYX)
    out.body[1][11, 12] = 0.0
    out.body[2][11, 12] = 0.1
    out.body_soil[1][12, 11] = 0.1
    out.body_soil[2][12, 11] = 0.2
    push!(out.body_soil_pos, [1; 12; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[1][11, 12] ≈ 0.1) && (out.body_soil[2][11, 12] ≈ 0.2)
    out.body_soil[1][11, 12] = 0.0
    out.body_soil[2][11, 12] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[1][11, 12] = 0.0
    out.body[2][11, 12] = 0.0
    empty!(out.body_soil_pos)

    # Testing for a simple rotation from (12, 11) to (12, 12)
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(-pi / 4, 0.0, 0.0, :ZYX)
    out.body[1][12, 12] = 0.0
    out.body[2][12, 12] = 0.1
    out.body_soil[1][12, 11] = 0.1
    out.body_soil[2][12, 11] = 0.2
    push!(out.body_soil_pos, [1; 12; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[1][12, 12] ≈ 0.1) && (out.body_soil[2][12, 12] ≈ 0.2)
    out.body_soil[1][12, 12] = 0.0
    out.body_soil[2][12, 12] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[1][12, 12] = 0.0
    out.body[2][12, 12] = 0.0
    empty!(out.body_soil_pos)

    # Testing for a simple rotation + translation from (12, 11) to (13, 12)
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = angle_to_quat(-pi / 4, 0.0, 0.0, :ZYX)
    out.body[1][13, 12] = 0.0
    out.body[2][13, 12] = 0.1
    out.body_soil[1][12, 11] = 0.1
    out.body_soil[2][12, 11] = 0.2
    push!(out.body_soil_pos, [1; 12; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[1][13, 12] ≈ 0.1) && (out.body_soil[2][13, 12] ≈ 0.2)
    out.body_soil[1][13, 12] = 0.0
    out.body_soil[2][13, 12] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[1][13, 12] = 0.0
    out.body[2][13, 12] = 0.0
    empty!(out.body_soil_pos)

    # Testing for a large transformation
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(0.0, pi, 0.0, :ZYX)
    out.body_soil[1][12, 11] = 0.1
    out.body_soil[2][12, 11] = 0.2
    push!(out.body_soil_pos, [1; 12; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    # Checking terrain
    @test out.terrain[10, 11] ≈ 0.1
    out.terrain[10, 11] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[1][13, 12] = 0.0
    out.body[2][13, 12] = 0.0
    empty!(out.body_soil_pos)

    # Testing when two body_soil move to the same position (1)
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(0.0, pi / 2, 0.0, :ZYX)
    out.body[1][10, 11] = 0.0
    out.body[2][10, 11] = 0.1
    out.body_soil[1][12, 11] = 0.1
    out.body_soil[2][12, 11] = 0.2
    out.body_soil[1][13, 11] = 0.1
    out.body_soil[2][13, 11] = 0.3
    push!(out.body_soil_pos, [1; 12; 11])
    push!(out.body_soil_pos, [1; 13; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[1][10, 11] ≈ 0.1) && (out.body_soil[2][10, 11] ≈ 0.4)
    out.body_soil[1][10, 11] = 0.0
    out.body_soil[2][10, 11] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[1][10, 11] = 0.0
    out.body[2][10, 11] = 0.0
    empty!(out.body_soil_pos)

    # Testing when two body_soil move to the same position (2)
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(0.0, pi / 2, 0.0, :ZYX)
    out.body[1][10, 11] = 0.0
    out.body[2][10, 11] = 0.1
    out.body_soil[1][12, 11] = 0.1
    out.body_soil[2][12, 11] = 0.2
    out.body_soil[3][13, 11] = 0.1
    out.body_soil[4][13, 11] = 0.3
    push!(out.body_soil_pos, [1; 12; 11])
    push!(out.body_soil_pos, [3; 13; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[1][10, 11] ≈ 0.1) && (out.body_soil[2][10, 11] ≈ 0.4)
    out.body_soil[1][10, 11] = 0.0
    out.body_soil[2][10, 11] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[1][10, 11] = 0.0
    out.body[2][10, 11] = 0.0
    empty!(out.body_soil_pos)

    # Testing when two body_soil move to the same position (3)
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(0.0, pi / 2, 0.0, :ZYX)
    out.body[3][10, 11] = 0.0
    out.body[4][10, 11] = 0.1
    out.body_soil[1][12, 11] = 0.1
    out.body_soil[2][12, 11] = 0.2
    out.body_soil[3][13, 11] = 0.1
    out.body_soil[4][13, 11] = 0.3
    push!(out.body_soil_pos, [1; 12; 11])
    push!(out.body_soil_pos, [3; 13; 11])
    _update_body_soil!(out, pos, ori, grid, bucket)
    # Checking body_soil
    @test (out.body_soil[3][10, 11] ≈ 0.1) && (out.body_soil[4][10, 11] ≈ 0.4)
    out.body_soil[3][10, 11] = 0.0
    out.body_soil[4][10, 11] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting bucket position and orientation
    bucket.pos[:] .= [0.0, 0.0, 0.0]
    bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    out.body[3][10, 11] = 0.0
    out.body[4][10, 11] = 0.0
    empty!(out.body_soil_pos)
end
