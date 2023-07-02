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
    @test (out.body_soil_pos == [[1; 12; 11]])
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
    @test (out.body_soil_pos == [[1; 12; 11]])
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
    @test (out.body_soil_pos == [[3; 12; 11]])
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
    @test (out.body_soil_pos == [[3; 12; 11]])
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
    @test (out.body_soil_pos == [[1; 11; 12]])
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
    @test (out.body_soil_pos == [[1; 12; 12]])
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
    @test (out.body_soil_pos == [[1; 13; 12]])
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
    @test (out.body_soil_pos == [[1; 10; 11]])
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
    @test (out.body_soil_pos == [[1; 10; 11]])
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
    @test (out.body_soil_pos == [[3; 10; 11]])
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
