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

# Simulation properties
repose_angle = 0.785
max_iterations = 3
cell_buffer = 4
sim = SimParam(repose_angle, max_iterations, cell_buffer)

# Terrain properties
terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
out = SimOut(terrain, grid)


#==========================================================================================#
#                                                                                          #
#                                         Testing                                          #
#                                                                                          #
#==========================================================================================#
@testset "_locate_unstable_terrain_cell" begin
    # Setting up the environment
    out.impact_area[:, :] .= Int64[[2, 2] [17, 17]]

    # Test: RE-LUT-1
    unstable_cells = _locate_unstable_terrain_cell(out, 0.1, 1e-5)
    @test (length(unstable_cells) == 0)

    # Test: RE-LUT-2
    out.terrain[7, 13] = 0.1
    unstable_cells = _locate_unstable_terrain_cell(out, 0.1, 1e-5)
    @test (length(unstable_cells) == 0)
    unstable_cells = _locate_unstable_terrain_cell(out, 0.0, 1e-5)
    @test (unstable_cells == [[7, 13]])
    out.terrain[7, 13] = 0.0

    # Test: RE-LUT-3
    out.terrain[5, 13] = 0.2
    unstable_cells = _locate_unstable_terrain_cell(out, 0.1, 1e-5)
    @test (unstable_cells == [[5, 13]])
    unstable_cells = _locate_unstable_terrain_cell(out, 0.2, 1e-5)
    @test (length(unstable_cells) == 0)
    out.terrain[5, 13] = 0.0

    # Test: RE-LUT-4
    out.terrain[9, 9] = -0.1
    unstable_cells = _locate_unstable_terrain_cell(out, 0.1, 1e-5)
    @test (length(unstable_cells) == 0)
    unstable_cells = _locate_unstable_terrain_cell(out, 0.0, 1e-5)
    @test (unstable_cells == [[8, 9], [9, 8], [9, 10], [10, 9]])
    out.terrain[9, 9] = 0.0

    # Test: RE-LUT-5
    out.terrain[11, 13] = -0.2
    unstable_cells = _locate_unstable_terrain_cell(out, 0.1, 1e-5)
    @test (unstable_cells == [[10, 13], [11, 12], [11, 14], [12, 13]])
    unstable_cells = _locate_unstable_terrain_cell(out, 0.2, 1e-5)
    @test (length(unstable_cells) == 0)
    out.terrain[11, 13] = 0.0

    # Test: RE-LUT-6
    out.terrain[15, 5] = -0.4
    out.terrain[15, 6] = -0.2
    unstable_cells = _locate_unstable_terrain_cell(out, 0.1, 1e-5)
    @test (unstable_cells == [[14, 5], [14, 6], [15, 4], [15, 6], [15, 7], [16, 5], [16, 6]])
    out.terrain[15, 5] = 0.0
    out.terrain[15, 6] = 0.0

    # Test: RE-LUT-7
    out.terrain[5, 2] = -0.2
    unstable_cells = _locate_unstable_terrain_cell(out, 0.1, 1e-5)
    @test (unstable_cells == [[4, 2], [5, 3], [6, 2]])
    out.terrain[5, 2] = 0.0

    # Resetting terrain
    out.impact_area[:, :] .= Int64[[0, 0] [0, 0]]
end

@testset "_check_unstable_terrain_cell" begin
    # Test: RE-CUT-1
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)

    # Test: RE-CUT-2
    out.terrain[10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 40)
    reset_value_and_test(out, [[10, 15]], Vector{Vector{Int64}}(), Vector{Vector{Int64}}())

    # Test: RE-CUT-3
    set_height(out, 10, 15, -0.2, -0.1, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 10)
    reset_value_and_test(out, [[10, 15]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-4
    set_height(out, 10, 15, -0.4, -0.4, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(out, [[10, 15]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-5
    set_height(out, 10, 15, -0.4, -0.4, -0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 14)
    reset_value_and_test(out, [[10, 15]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-6
    set_height(out, 9, 15, -0.8, -0.7, -0.5, -0.5, -0.3, NaN, NaN, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 9, 15, -0.1, 1e-5)
    @test (status == 10)
    reset_value_and_test(out, [[9, 15]], [[1, 9, 15]], [[1, 9, 15]])

    # Test: RE-CUT-7
    set_height(out, 10, 15, -0.8, -0.8, -0.5, -0.5, 0.0, NaN, NaN, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(out, [[10, 15]], [[1, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-8
    set_height(out, 9, 15, -0.8, -0.8, -0.5, -0.5, -0.3, NaN, NaN, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 9, 15, -0.1, 1e-5)
    @test (status == 13)
    reset_value_and_test(out, [[9, 15]], [[1, 9, 15]], [[1, 9, 15]])

    # Test: RE-CUT-9
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.1, 0.0, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 20)
    reset_value_and_test(out, [[10, 15]], [[3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-10
    set_height(out, 10, 15, -0.4, NaN, NaN, NaN, NaN, -0.4, 0.0, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(out, [[10, 15]], [[3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-11
    set_height(out, 10, 15, -0.4, NaN, NaN, NaN, NaN, -0.4, -0.2, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 22)
    reset_value_and_test(out, [[10, 15]], [[3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-12
    set_height(out, 9, 15, -0.8, NaN, NaN, NaN, NaN, -0.7, -0.5, -0.5, -0.3)
    status = _check_unstable_terrain_cell(out, 9, 15, -0.1, 1e-5)
    @test (status == 20)
    reset_value_and_test(out, [[9, 15]], [[3, 9, 15]], [[3, 9, 15]])

    # Test: RE-CUT-13
    set_height(out, 10, 15, -0.8, NaN, NaN, NaN, NaN, -0.8, -0.5, -0.5, 0.0)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(out, [[10, 15]], [[3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-14
    set_height(out, 9, 15, -0.8, NaN, NaN, NaN, NaN, -0.8, -0.5, -0.5, -0.3)
    status = _check_unstable_terrain_cell(out, 9, 15, -0.1, 1e-5)
    @test (status == 21)
    reset_value_and_test(out, [[9, 15]], [[3, 9, 15]], [[3, 9, 15]])

    # Test: RE-CUT-15
    set_height(out, 9, 15, -0.8, -0.7, -0.6, NaN, NaN, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 9, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(out, [[9, 15]], [[1, 9, 15], [3, 9, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-16
    set_height(out, 10, 15, -0.8, -0.8, -0.6, NaN, NaN, 0.2, 0.4, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 34)
    reset_value_and_test(out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-17
    set_height(out, 9, 15, -0.8, -0.8, -0.6, NaN, NaN, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 9, 15, -0.1, 1e-5)
    @test (status == 34)
    reset_value_and_test(out, [[9, 15]], [[1, 9, 15], [3, 9, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-18
    set_height(
        out, 10, 15, -0.8, -0.7, -0.6, NaN, NaN, -0.4, -0.3, -0.3, -0.2)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-19
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, NaN, NaN, -0.4, -0.3, -0.3, 0.2)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-20
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, NaN, NaN, -0.4, -0.3, -0.3, -0.2)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-21
    set_height(
        out, 10, 15, -0.8, -0.7, -0.6, -0.6, -0.5, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-22
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.5, -0.4, 0.0, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-23
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.5, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-24
    set_height(
        out, 10, 15, -0.8, -0.7, -0.6, -0.6, -0.5, -0.4, -0.3, -0.3, -0.2)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-25
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.5, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-26
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.5, -0.4, -0.3, -0.3, -0.2)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-27
    set_height(
        out, 10, 15, -0.8, -0.7, -0.6, -0.6, -0.4, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-28
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.4, -0.4, 0.0, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-29
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.4, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-30
    set_height(
        out, 10, 15, -0.8, -0.7, -0.6, -0.6, -0.4, -0.4, -0.3, -0.3, -0.2)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-31
    set_height(
        out, 10, 15, -0.7, -0.7, -0.6, -0.6, -0.4, -0.4, -0.3, -0.3, 0.2)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-32
    set_height(
        out, 10, 15, -0.7, -0.7, -0.6, -0.6, -0.4, -0.4, -0.3, -0.3, -0.2)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-33
    set_height(out, 9, 15, -0.8, -0.4, -0.3, NaN, NaN, -0.7, -0.6, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 9, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[9, 15]], [[1, 9, 15], [3, 9, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-34
    set_height(out, 10, 15, -0.8, -0.4, 0.0, NaN, NaN, -0.8, -0.6, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-35
    set_height(out, 9, 15, -0.8, -0.4, -0.3, NaN, NaN, -0.8, -0.6, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 9, 15, -0.1, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[9, 15]], [[1, 9, 15], [3, 9, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-36
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.7, -0.6, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-37
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, 0.0, -0.8, -0.6, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-38
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.8, -0.6, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15]])

    # Test: RE-CUT-39
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, NaN, NaN, -0.7, -0.6, -0.6, -0.5)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-40
    set_height(
        out, 10, 15, -0.8, -0.4, 0.0, NaN, NaN, -0.8, -0.6, -0.6, -0.5)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-41
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, NaN, NaN, -0.8, -0.6, -0.6, -0.5)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-42
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.7, -0.6, -0.6, -0.5)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-43
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, 0.0, -0.8, -0.6, -0.6, -0.5)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-44
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.8, -0.6, -0.6, -0.5)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-45
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, NaN, NaN, -0.7, -0.6, -0.6, -0.4)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-46
    set_height(
        out, 10, 15, -0.8, -0.4, 0.0, NaN, NaN, -0.8, -0.6, -0.6, -0.4)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-47
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, NaN, NaN, -0.8, -0.6, -0.6, -0.4)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-CUT-48
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.7, -0.6, -0.6, -0.4)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 30)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-49
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, 0.0, -0.8, -0.6, -0.6, -0.4)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-50
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.8, -0.6, -0.6, -0.4)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-CUT-51
    set_height(out, 10, 15, -1.0, -0.4, -0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.6, 1e-5)
    @test (status == 10)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-52
    set_height(out, 10, 15, -0.4, -0.4, -0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-CUT-53
    out.terrain[10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.4, 1e-5)
    @test (status == 0)
    reset_value_and_test(out, [[10, 15]], Vector{Vector{Int64}}(), Vector{Vector{Int64}}())
end

@testset "_relax_unstable_terrain_cell!" begin
    # Test: RE-RUT-1
    out.terrain[10, 14] = 0.4
    out.terrain[10, 15] = 0.1
    _relax_unstable_terrain_cell!(
        out, 40, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ 0.3)
    @test (out.terrain[10, 15] ≈ 0.2)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 14], [10, 15]], Vector{Vector{Int64}}(), Vector{Vector{Int64}}())

    # Test: RE-RUT-2
    set_height(out, 10, 15, -0.8, -0.3, -0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    _relax_unstable_terrain_cell!(
        out, 10, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.4)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 14], [10, 15]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RUT-3
    set_height(out, 10, 15, -0.8, -0.5, -0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    _relax_unstable_terrain_cell!(
        out, 10, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.3)
    @test (out.terrain[10, 15] ≈ -0.5)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 14], [10, 15]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RUT-4
    set_height(out, 10, 15, -0.4, -0.4, -0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_unstable_terrain_cell!(
        out, 14, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.4, -0.2, -0.1, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15]], [[1, 10, 15]])

    # Test: RE-RUT-5
    set_height(out, 10, 15, -0.7, -0.2, -0.1, -0.1, 0.3, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.4)
    _relax_unstable_terrain_cell!(
        out, 10, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.3)
    check_height(out, 10, 15, -0.4, -0.1, 0.3, NaN, NaN)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15]], [[1, 10, 15]])

    # Test: RE-RUT-6
    set_height(
        out, 10, 15, -0.8, -0.7, -0.5, -0.5, -0.3, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    _relax_unstable_terrain_cell!(
        out, 10, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.7, -0.5, -0.3, NaN, NaN)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15]], [[1, 10, 15]])

    # Test: RE-RUT-7
    set_height(
        out, 10, 15, -0.8, -0.8, -0.5, -0.5, -0.3, NaN, NaN, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.2)
    _relax_unstable_terrain_cell!(
        out, 13, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.5, -0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15]], [[1, 10, 15]])

    # Test: RE-RUT-8
    set_height(out, 10, 15, -0.6, NaN, NaN, NaN, NaN, 0.0, 0.3, NaN, NaN)
    _relax_unstable_terrain_cell!(
        out, 20, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.3)
    @test (out.terrain[10, 15] ≈ -0.3)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 14], [10, 15]], [[3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RUT-9
    set_height(out, 10, 15, -0.6, NaN, NaN, NaN, NaN, -0.4, 0.3, NaN, NaN)
    _relax_unstable_terrain_cell!(
        out, 20, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.2)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 14], [10, 15]], [[3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RUT-10
    set_height(out, 10, 15, -0.4, NaN, NaN, NaN, NaN, -0.4, -0.3, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_unstable_terrain_cell!(
        out, 22, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.4, NaN, NaN, -0.3, -0.2)
    check_body_soil_pos(out.body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[3, 10, 15]], [[3, 10, 15]])

    # Test: RE-RUT-11
    set_height(out, 10, 15, -0.3, NaN, NaN, NaN, NaN, 0.0, 0.3, 0.3, 0.5)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_unstable_terrain_cell!(
        out, 20, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.3, 0.5)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[3, 10, 15]], [[3, 10, 15]])

    # Test: RE-RUT-12
    set_height(
        out, 10, 15, -0.8, NaN, NaN, NaN, NaN, -0.7, -0.5, -0.5, -0.3)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_unstable_terrain_cell!(
        out, 20, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.7, NaN, NaN, -0.5, -0.3)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[3, 10, 15]], [[3, 10, 15]])

    # Test: RE-RUT-13
    set_height(
        out, 10, 15, -0.8, NaN, NaN, NaN, NaN, -0.8, -0.5, -0.5, -0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.2)
    _relax_unstable_terrain_cell!(
        out, 21, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.5, -0.2)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[3, 10, 15]], [[3, 10, 15]])

    # Test: RE-RUT-14
    set_height(out, 10, 15, -0.5, -0.1, 0.0, NaN, NaN, 0.2, 0.4, NaN, NaN)
    _relax_unstable_terrain_cell!(
        out, 30, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.2)
    @test (out.terrain[10, 15] ≈ -0.3)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RUT-15
    set_height(
        out, 10, 15, -0.8, -0.7, -0.6, NaN, NaN, -0.4, -0.3, NaN, NaN)
    _relax_unstable_terrain_cell!(
        out, 30, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    @test (out.terrain[10, 15] ≈ -0.7)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RUT-16
    set_height(out, 10, 15, -0.8, -0.8, -0.6, NaN, NaN, 0.1, 0.3, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    _relax_unstable_terrain_cell!(
        out, 34, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.3)
    check_height(out, 10, 15, -0.8, -0.6, -0.3, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 10, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15]])

    # Test: RE-RUT-17
    set_height(out, 10, 15, -0.8, -0.8, -0.6, NaN, NaN, -0.4, 0.3, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    _relax_unstable_terrain_cell!(
        out, 34, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.2)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15]])

    # Test: RE-RUT-18
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.4, -0.4, -0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_unstable_terrain_cell!(
        out, 32, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, -0.3, -0.2)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RUT-19
    set_height(
        out, 10, 15, -0.8, -0.8, -0.4, -0.4, -0.3, 0.4, 0.7, 0.7, 0.9)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_unstable_terrain_cell!(
        out, 33, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.4, -0.2, 0.7, 0.9)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RUT-20
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.5, -0.4, -0.3, -0.3, -0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_unstable_terrain_cell!(
        out, 33, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, -0.3, -0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RUT-21
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.4, -0.4, -0.3, -0.3, -0.2)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_terrain_cell!(
        out, 31, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, -0.3, -0.1)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RUT-22
    set_height(out, 10, 15, -0.8, -0.1, 0.0, NaN, NaN, -0.3, -0.2, NaN, NaN)
    _relax_unstable_terrain_cell!(
        out, 30, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.4)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RUT-23
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, NaN, NaN, -0.7, -0.6, NaN, NaN)
    _relax_unstable_terrain_cell!(
        out, 30, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    @test (out.terrain[10, 15] ≈ -0.7)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RUT-24
    set_height(out, 10, 15, -0.8, -0.2, 0.3, NaN, NaN, -0.8, -0.6, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    _relax_unstable_terrain_cell!(
        out, 32, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.3)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.6, -0.3)
    check_body_soil_pos(out.body_soil_pos[1], 3, 10, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[3, 10, 15]])

    # Test: RE-RUT-25
    set_height(out, 10, 15, -0.8, -0.3, 0.3, NaN, NaN, -0.8, -0.4, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_unstable_terrain_cell!(
        out, 32, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.4, -0.3)
    check_body_soil_pos(out.body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[3, 10, 15]])

    # Test: RE-RUT-26
    set_height(
        out, 10, 15, -0.8, -0.6, -0.4, NaN, NaN, -0.8, -0.7, -0.7, -0.6)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_unstable_terrain_cell!(
        out, 34, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.2)
    check_height(out, 10, 15, -0.8, -0.4, -0.2, -0.7, -0.6)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RUT-27
    set_height(
        out, 10, 15, -0.8, -0.2, -0.1, -0.1, 0.5, -0.8, -0.7, -0.7, -0.6)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.6)
    posA = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_terrain_cell!(
        out, 31, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.3)
    check_height(out, 10, 15, -0.8, -0.1, 0.5, -0.7, -0.3)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RUT-28
    set_height(
        out, 10, 15, -0.8, -0.5, -0.4, -0.4, 0.5, -0.8, -0.7, -0.7, -0.6)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.9)
    posA = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_terrain_cell!(
        out, 31, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.4, 0.5, -0.7, -0.5)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RUT-29
    set_height(
        out, 10, 15, -0.8, -0.5, -0.4, -0.4, -0.3, -0.8, -0.7, -0.7, -0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_unstable_terrain_cell!(
        out, 33, 0.1, 10, 14, 10, 15, grid, bucket, 1e-5)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.4, -0.2, -0.7, -0.5)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])
end

@testset "_relax_terrain!" begin
    # Setting impact_area
    out.impact_area[:, :] .= Int64[[4, 9] [16, 20]]

    # Creating a lambda function to check relax_area
    function check_relax_area(a_11, a_12, a_21, a_22)
        @test (out.relax_area[1, 1] == a_11)
        @test (out.relax_area[1, 2] == a_12)
        @test (out.relax_area[2, 1] == a_21)
        @test (out.relax_area[2, 2] == a_22)
    end

    # Test: RE-RT-1
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    out.terrain[10, 15] = -0.1
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(10, 15, 10, 15)
    @test (out.terrain[10, 15] ≈ -0.1)
    @test (out.terrain[10, 16] ≈ 0.0)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 15], [10, 16]], Vector{Vector{Int64}}(), Vector{Vector{Int64}}())

    # Test: RE-RT-2
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    out.terrain[10, 15] = -0.2
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 15] ≈ -0.1)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 15], [10, 16]], Vector{Vector{Int64}}(), Vector{Vector{Int64}}())

    # Test: RE-RT-3
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.2, -0.1, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 15] ≈ -0.1)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 15], [10, 16]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RT-4
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.4, -0.4, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 15], [10, 16]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RT-5
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.4, -0.4, -0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.4, -0.2, -0.1, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15]], [[1, 10, 15]])

    # Test: RE-RT-6
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.8, -0.7, -0.5, -0.5, 0.0, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.5)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.7, -0.5, 0.0, NaN, NaN)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15]], [[1, 10, 15]])

    # Test: RE-RT-7
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.8, -0.8, -0.5, -0.5, 0.0, NaN, NaN, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.5)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    check_height(out, 10, 15, -0.8, -0.5, 0.0, NaN, NaN)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(out, [[10, 15]], [[1, 10, 15]], [[1, 10, 15]])

    # Test: RE-RT-8
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.8, -0.5, -0.5, -0.3, NaN, NaN, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.2)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.5, -0.1, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15]], [[1, 10, 15]])

    # Test: RE-RT-9
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.1, 0.0, NaN, NaN)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 15] ≈ -0.1)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 15], [10, 16]], [[3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RT-10
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.4, NaN, NaN, NaN, NaN, -0.4, 0.0, NaN, NaN)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 15]], [[3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RT-11
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.4, NaN, NaN, NaN, NaN, -0.4, -0.2, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.4, NaN, NaN, -0.2, -0.1)
    check_body_soil_pos(out.body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[3, 10, 15]], [[3, 10, 15]])

    # Test: RE-RT-12
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, NaN, NaN, NaN, NaN, -0.7, -0.5, -0.5, -0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.4)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.7, NaN, NaN, -0.5, -0.1)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[3, 10, 15]], [[3, 10, 15]])

    # Test: RE-RT-13
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.8, NaN, NaN, NaN, NaN, -0.8, -0.5, -0.5, 0.0)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.5)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.5, 0.0)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(out, [[10, 15]], [[3, 10, 15]], [[3, 10, 15]])

    # Test: RE-RT-14
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, NaN, NaN, NaN, NaN, -0.8, -0.5, -0.5, -0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.3)
    _relax_terrain!(out, grid, bucket, sim)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.5, -0.1)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[3, 10, 15]], [[3, 10, 15]])

    # Test: RE-RT-15
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.4, -0.2, 0.0, NaN, NaN, 0.2, 0.4, NaN, NaN)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 15] ≈ -0.2)
    @test (out.terrain[10, 16] ≈ -0.2)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RT-16
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.8, -0.8, -0.6, NaN, NaN, -0.4, 0.0, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.2)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15]])

    # Test: RE-RT-17
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, NaN, NaN, -0.4, -0.2, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    posB = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.2)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, -0.2, -0.1)
    check_body_soil_pos(out.body_soil_pos[1], 1, 10, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-18
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.4, -0.2, -0.1, NaN, NaN, 0.4, 0.5, 0.5, 0.7)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.2)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.5, 0.7)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[3, 10, 15]])

    # Test: RE-RT-19
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.2)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, -0.3, 0.0)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-20
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, NaN, NaN, -0.4, -0.3, -0.3, -0.2)
    posB = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posB, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.2)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, -0.3, -0.1)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-21
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.3, -0.1, 0.0, 0.0, 0.1, 0.2, 0.3, NaN, NaN)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.1, 0.0, 0.1, NaN, NaN)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15]])

    # Test: RE-RT-22
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.5, -0.4, 0.0, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15]])

    # Test: RE-RT-23
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.5, -0.4, -0.2, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, -0.2, -0.1)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-24
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.6, -0.5, -0.4, -0.4, 0.0, 0.0, 0.3, 0.3, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.4)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.5, -0.4, 0.0, 0.3, 0.4)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-25
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.5, -0.4, -0.3, -0.3, 0.0)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.3)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, -0.3, 0.0)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-26
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.8, -0.6, -0.6, -0.5, -0.4, -0.3, -0.3, -0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posB, 0.3)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.6, -0.4, -0.3, -0.1)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-27
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.8, 0.4, 0.7, NaN, NaN, -0.7, -0.1, NaN, NaN)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 15] ≈ -0.7)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RT-28
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.8, -0.4, 0.0, NaN, NaN, -0.8, -0.6, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.2)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.6, -0.4)
    check_body_soil_pos(out.body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[3, 10, 15]])

    # Test: RE-RT-29
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.4, -0.2, NaN, NaN, -0.8, -0.6, NaN, NaN)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    posB = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.2)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.2, -0.1, -0.6, -0.4)
    check_body_soil_pos(out.body_soil_pos[1], 3, 10, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-30
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.2, 0.4, 0.5, 0.5, 0.6, 0.0, 0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.1, 0.5, 0.6, NaN, NaN)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15]])

    # Test: RE-RT-31
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.8, 0.4, 0.5, 0.5, 0.6, -0.8, -0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.8, 0.5, 0.6, -0.2, -0.1)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-32
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.8, -0.6, NaN, NaN)
    posB = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posB, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.2)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.3, -0.1, -0.6, -0.4)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-33
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.4, -0.1, NaN, NaN, -0.7, -0.6, -0.6, -0.4)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.7, NaN, NaN, -0.6, -0.4)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[3, 10, 15]])

    # Test: RE-RT-34
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.1, 0.1, NaN, NaN, -0.8, -0.6, -0.6, -0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.2)
    @test (out.terrain[9, 15] ≈ -0.1)
    @test (out.terrain[10, 14] ≈ -0.1)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.6, -0.1)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[9, 15], [10, 14], [10, 15], [10, 16]],
        [[1, 10, 15], [3, 10, 15]], [[3, 10, 15]])

    # Test: RE-RT-35
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.4, -0.2, NaN, NaN, -0.8, -0.6, -0.6, -0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.2)
    posB = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.2, -0.1, -0.6, -0.4)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-36
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.1, -0.7, -0.6, -0.6, -0.4)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.7, -0.3, -0.1, -0.6, -0.4)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-37
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, 0.0, -0.8, -0.6, -0.6, -0.5)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.3, 0.0, -0.6, -0.4)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-38
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.8, -0.6, -0.6, -0.5)
    posB = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posB, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (out.terrain[9, 15] ≈ -0.1)
    check_height(out, 10, 15, -0.8, -0.3, -0.1, -0.6, -0.4)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[9, 15], [10, 15], [10, 16]], [[1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]])

    # Test: RE-RT-39
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    set_height(out, 10, 15, -0.6, 0.0, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 15] ≈ -0.1)
    @test (out.terrain[10, 16] ≈ -0.3)
    @test (out.terrain[9, 15] ≈ -0.1)
    @test (out.terrain[10, 14] ≈ -0.1)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(
        out, [[9, 15], [10, 14], [10, 15], [10, 16]], [[1, 10, 15]], Vector{Vector{Int64}}())

    # Test: RE-RT-40
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    out.terrain[10, 15] = -0.4
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    check_relax_area(5, 15, 10, 20)
    @test (out.terrain[10, 15] ≈ -0.1)
    @test (out.terrain[10, 16] ≈ -0.2)
    @test (out.terrain[9, 15] ≈ -0.1)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[9, 15], [10, 15], [10, 16]], Vector{Vector{Int64}}(), Vector{Vector{Int64}}())

    # Test: RE-RT-41
    set_RNG_seed!(18)
    out.relax_area[:, :] .= Int64[[10, 10] [15, 15]]
    out.terrain[10, 15] = -0.2
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    @test (out.terrain[10, 15] ≈ -0.1)
    @test (out.terrain[10, 16] ≈ -0.1)
    @test (length(out.body_soil_pos) == 0)
    set_RNG_seed!(3000)
    out.terrain[10, 15] = -0.2
    out.terrain[10, 16] = 0.0
    _relax_terrain!(out, grid, bucket, sim, 1e-5)
    @test (out.terrain[10, 15] ≈ -0.1)
    @test (out.terrain[11, 15] ≈ -0.1)
    @test (length(out.body_soil_pos) == 0)
    reset_value_and_test(out, [[10, 15], [11, 15]], Vector{Vector{Int64}}(), Vector{Vector{Int64}}())

    # Resetting impact_area
    out.impact_area[:, :] .= Int64[[0, 0] [0, 0]]
end

@testset "_check_unstable_body_cell" begin
    # Test: RE-CUB-1
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    out.terrain[10, 15] = 0.1
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])

    # Test: RE-CUB-2
    out.terrain[10, 15] = -0.2
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 40)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])

    # Test: RE-CUB-3
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-4
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 10)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-5
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 14)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-6
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, 0.0, 0.0, 0.1, NaN, NaN, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-7
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.3, 0.5, 0.5, 0.7, NaN, NaN, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 10)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-8
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, -0.1, 0.0, NaN, NaN, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 13)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-9
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.2, 0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-10
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, 0.4, 0.5, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 20)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-11
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.2, 0.0, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 22)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-12
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.2, 0.0, 0.0, 0.1)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-13
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 20)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-14
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.2, -0.1, -0.1, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 21)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-15
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-16
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-17
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.1, NaN, NaN, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-18
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-19
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-20
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-21
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-22
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.0, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-23
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, NaN, NaN, 0.0, 0.3, 0.3, 0.4)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-24
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, NaN, NaN, 0.0, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.3, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-25
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, NaN, NaN, 0.0, 0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.2, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-26
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, NaN, NaN, 0.0, 0.5, 0.5, 0.6)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-27
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, NaN, NaN, 0.0, 0.1, 0.1, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-28
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, NaN, NaN, 0.0, 0.1, 0.1, 0.2)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.3, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-29
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, -0.1, 0.0, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-30
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, -0.1, 0.0, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-31
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, -0.1, 0.0, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-32
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, -0.1, 0.0, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-33
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, -0.1, 0.0, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-34
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, -0.1, 0.0, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-35
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, -0.1, 0.0, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-36
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, -0.1, 0.0, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-37
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.0, 0.1, 0.3, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-38
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.0, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-39
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.0, 0.1, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.3, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-40
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.0, 0.1, 0.3, 0.3, 0.5)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-41
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-42
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.1, 0.2, 0.2, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.4, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-43
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.5, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-44
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.2, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-45
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.2, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-46
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.1, 0.1, 0.5)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-47
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.1, 0.1, 0.2)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-48
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.1, 0.1, 0.2)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.3, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-49
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.5, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-50
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-51
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.2, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-52
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.1, 0.1, 0.3)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-53
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.1, 0.1, 0.2)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-54
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, -0.3, 0.0, 0.0, 0.1, 0.1, 0.2)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.3, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-55
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, -0.2, -0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-56
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, -0.2, -0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-57
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, -0.2, -0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-58
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, -0.2, -0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.0, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-59
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, 0.2, 0.3, -0.2, -0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-60
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, 0.2, 0.3, -0.2, -0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-61
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, 0.2, 0.3, -0.2, -0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-62
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, 0.2, 0.3, -0.2, -0.1, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 32)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-63
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.4, NaN, NaN, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-64
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, NaN, NaN, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-65
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, NaN, NaN, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.2, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-CUB-66
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, 0.1, 0.3, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-67
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, 0.1, 0.3, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-68
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, 0.1, 0.2, -0.4, -0.3, NaN, NaN)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.3, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-CUB-69
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, -0.2, -0.1, -0.1, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.0, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-70
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, -0.2, -0.1, -0.1, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-71
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, -0.2, -0.1, -0.1, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.0, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-72
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, -0.2, -0.1, -0.1, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-73
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, 0.2, 0.3, -0.2, -0.1, -0.1, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-74
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, 0.2, 0.3, -0.2, -0.1, -0.1, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-75
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, 0.2, 0.3, -0.2, -0.1, -0.1, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-76
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, 0.2, 0.3, -0.2, -0.1, -0.1, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 31)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-77
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.3, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-78
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.1, 0.2, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.2, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-79
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.1, 0.2, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.4, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-80
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.1, 0.3, 0.3, 0.4, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-81
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.6, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.1, 0.3, 0.3, 0.4, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-82
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.6, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.1, 0.3, 0.3, 0.4, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.6, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-83
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.3, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-84
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-85
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.2, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-86
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, 0.1, 0.5, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-87
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, 0.1, 0.2, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-88
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, 0.1, 0.2, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.3, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-89
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.3, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-90
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-91
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, NaN, NaN, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.2, 1e-5)
    @test (status == 34)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-CUB-92
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, 0.1, 0.5, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-93
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, 0.1, 0.2, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.0, 1e-5)
    @test (status == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-CUB-94
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, 0.1, 0.2, -0.4, -0.3, -0.3, 0.0)
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.3, 1e-5)
    @test (status == 33)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])
end

@testset "_relax_unstable_body_cell!" begin
    # Test: RE-RUB-1
    body_soil_pos = Vector{BodySoil{Int64, Float64}}()
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    out.terrain[10, 15] = 0.0
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_unstable_body_cell!(
        out, 40, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.1)
    @test (length(body_soil_pos) == 0)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])

    # Test: RE-RUB-2
    body_soil_pos = Vector{BodySoil{Int64, Float64}}()
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    out.terrain[10, 15] = -0.2
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_unstable_body_cell!(
        out, 40, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.0)
    @test (length(body_soil_pos) == 0)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])

    # Test: RE-RUB-3
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    out.terrain[10, 15] = 0.0
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    _relax_unstable_body_cell!(
        out, 40, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.3, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.1)
    @test (length(body_soil_pos) == 0)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])

    # Test: RE-RUB-4
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, 0.0, 0.3, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_unstable_body_cell!(
        out, 10, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.1)
    @test (length(body_soil_pos) == 0)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RUB-5
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.1, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_unstable_body_cell!(
        out, 10, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN)
    @test (length(body_soil_pos) == 0)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-6
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, 0.0, 0.1, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.4)
    _relax_unstable_body_cell!(
        out, 10, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.3, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.1)
    @test (length(body_soil_pos) == 0)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RUB-7
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, 0.0, 0.3, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    _relax_unstable_body_cell!(
        out, 10, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.3, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.1)
    @test (length(body_soil_pos) == 0)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RUB-8
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.6, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, 0.0, 0.1, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    _relax_unstable_body_cell!(
        out, 10, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.5, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.1)
    @test (length(body_soil_pos) == 0)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RUB-9
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    _relax_unstable_body_cell!(
        out, 14, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.2, 0.0, 0.1, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-10
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 14, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.0, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-11
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 14, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, -0.1, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-12
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.2)
    _relax_unstable_body_cell!(
        out, 13, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.1, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-13
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.2, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 13, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.0, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-14
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.2, 0.2, 0.4, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 13, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.2, 0.3, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.0, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[3].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-15
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, 0.0, NaN, NaN, NaN, NaN, 0.5, 0.6, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_unstable_body_cell!(
        out, 20, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-16
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, NaN, NaN, NaN, NaN, 0.5, 0.6, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_unstable_body_cell!(
        out, 20, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RUB-17
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, 0.0, NaN, NaN, NaN, NaN, 0.1, 0.6, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.4)
    _relax_unstable_body_cell!(
        out, 20, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.3, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.3)
    @test (length(body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-18
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, NaN, NaN, NaN, NaN, 0.5, 0.6, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    _relax_unstable_body_cell!(
        out, 20, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RUB-19
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.6, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, 0.0, NaN, NaN, NaN, NaN, 0.1, 0.6, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.4)
    _relax_unstable_body_cell!(
        out, 20, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.5, NaN, NaN)
    @test (out.terrain[10, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.4)
    @test (length(body_soil_pos) == 0)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RUB-20
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.2, 0.0, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    _relax_unstable_body_cell!(
        out, 22, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.0, 0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-21
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.2, -0.1, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    _relax_unstable_body_cell!(
        out, 22, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, -0.1, 0.0)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-22
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, NaN, NaN, NaN, NaN, -0.3, -0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 22, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.2, NaN, NaN)
    check_height(out, 10, 15, -0.3, NaN, NaN, -0.2, -0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-23
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.2, -0.1, -0.1, 0.0)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 21, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, -0.1, 0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-24
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, NaN, NaN, NaN, NaN, -0.2, -0.1, -0.1, 0.0)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 21, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, -0.1, 0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-25
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.3, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, NaN, NaN, NaN, NaN, -0.3, -0.2, -0.2, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 21, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.2, NaN, NaN)
    check_height(out, 10, 15, -0.3, NaN, NaN, -0.2, 0.0)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[3].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-26
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.2, -0.1, 0.1, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-27
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.2, -0.1, 0.0, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-28
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, NaN, NaN, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, -0.1, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-29
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.3, NaN, NaN)
    check_height(out, 10, 15, -0.2, -0.1, 0.1, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.3)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-30
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.9, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    posA = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.8, NaN, NaN)
    check_height(out, 10, 15, -0.2, -0.1, 0.0, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.7)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-31
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.5, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.5)
    posA = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.4, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.3, 0.4)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.4)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-32
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.5, 0.5, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, 0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.2, 0.5)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-33
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.5, 0.5, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, -0.2, -0.1, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, 0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.5, 0.7, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.2, 0.3)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-34
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.3, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, 0.1, 0.3, 0.3, 0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.1, 0.3, 0.5)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-35
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.3, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, 0.2, 0.3, 0.3, 0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.1, 0.3, 0.5)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-36
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.3, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, 0.2, 0.3, 0.3, 0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.2, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.0, 0.3, 0.5)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-37
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.9, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, 0.2, 0.3, 0.3, 0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.6, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.2, 0.3, 0.5)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.5)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-38
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.9, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, 0.0, 0.3, 0.3, 0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.6)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.8, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.0, 0.3, 0.5)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.6)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-39
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.9, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, 0.1, 0.3, 0.3, 0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.2)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.7, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, -0.1, 0.3, 0.7)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.6)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-40
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.7, 0.7, 0.9, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, 0.1, 0.3, 0.3, 0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.2)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, -0.1, 0.3, 0.7)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-41
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.9, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, -0.3, -0.2, -0.2, -0.1, 0.1, 0.3, 0.3, 0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.2)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.8, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, -0.1, 0.3, 0.6)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.8)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-42
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.1, 0.1, 0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, 0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.5, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.1, 0.2, 0.5)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.5)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-43
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.6, 0.6, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.1, 0.1, 0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, 0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.1, 0.2, 0.4)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-44
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.1, 0.1, 0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, 0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.7, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.1, 0.2, 0.3)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.7)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-45
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.1, 0.1, 0.2, 0.2, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.2)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.6, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.1, 0.2, 0.6)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.6)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-46
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.7, 0.7, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.1, 0.1, 0.2, 0.2, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.2)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.1, 0.2, 0.5)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-47
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.3, -0.2, -0.2, 0.1, 0.1, 0.2, 0.2, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.2)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.7, NaN, NaN)
    check_height(out, 10, 15, -0.3, -0.2, 0.1, 0.2, 0.5)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.7)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-48
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.3, NaN, NaN, -0.2, -0.1, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, -0.1, 0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-49
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.2, 0.4, NaN, NaN, -0.2, 0.0, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.0, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.0, 0.2)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-50
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.2, 0.4, NaN, NaN, -0.2, 0.0, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.0, 2, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.2, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.0, 0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-51
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.2, 0.4, NaN, NaN, -0.2, 0.0, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    posA = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.6, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.0, 0.2)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.5)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-52
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 1.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.4, NaN, NaN, -0.2, 0.0, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    posA = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    _relax_unstable_body_cell!(
        out, 32, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.9, NaN, NaN)
    check_height(out, 10, 15, -0.2, NaN, NaN, 0.0, 0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.7)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RUB-53
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.4, NaN, NaN, -0.2, 0.0, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    posA = _calc_bucket_frame_pos(10, 15, 0.4, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.6, NaN, NaN)
    check_height(out, 10, 15, -0.2, 0.4, 0.6, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.5)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-54
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.6, 0.6, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.2, NaN, NaN, -0.2, 0.0, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, 0.2, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.2, 0.2, 0.4, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-55
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.2, 0.1, 0.4, NaN, NaN, -0.2, 0.0, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.6)
    posA = _calc_bucket_frame_pos(10, 15, 0.4, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.7, NaN, NaN)
    check_height(out, 10, 15, -0.2, 0.4, 0.5, NaN, NaN)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.6)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RUB-56
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.3, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, 0.1, 0.3, 0.3, 0.8, -0.3, -0.2, -0.2, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.3, 0.8, -0.2, 0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-57
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, 0.1, 0.3, 0.3, 0.8, -0.3, -0.2, -0.2, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.3, 0.8, -0.2, 0.0)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-58
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.4, 0.1, 0.3, 0.3, 0.8, -0.4, -0.3, -0.3, -0.2)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.4, 0.3, 0.8, -0.3, -0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-59
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.8, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, 0.1, 0.3, 0.3, 0.8, -0.3, -0.2, -0.2, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.6, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.3, 0.8, -0.2, 0.1)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.6)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-60
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 1.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, 0.0, 0.3, 0.3, 0.8, -0.3, -0.2, -0.2, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_unstable_body_cell!(
        out, 31, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.9, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.3, 0.8, -0.2, 0.0)
    check_body_soil_pos(body_soil_pos[1], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.8)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-61
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.8, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, 0.1, 0.3, 0.3, 0.5, -0.3, -0.2, -0.2, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    posA = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.2)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.7, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.3, 0.6, -0.2, -0.1)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.6)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-62
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.6, 0.6, 0.8, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, 0.1, 0.3, 0.3, 0.4, -0.3, -0.2, -0.2, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.3, 0.6, -0.2, -0.1)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-63
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.1, 0.1, 0.8, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.3, 0.1, 0.3, 0.3, 0.4, -0.3, -0.2, -0.2, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.6)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 2, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.1, 0.7, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.3, 0.5, -0.2, -0.1)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.6)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-64
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, 0.4, 0.5, NaN, NaN, -0.3, -0.2, -0.2, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.6)
    posA = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.7, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.5, 0.6, -0.2, 0.4)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-65
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.7, 0.7, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, 0.4, 0.5, NaN, NaN, -0.3, -0.2, -0.2, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.6)
    posA = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.5, 0.6, -0.2, 0.4)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-66
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.9, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, 0.4, 0.5, NaN, NaN, -0.3, -0.2, -0.2, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.6)
    posA = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
    _relax_unstable_body_cell!(
        out, 34, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.8, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.5, 0.6, -0.2, 0.4)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.8)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-67
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, 0.4, 0.5, 0.5, 0.6, -0.3, -0.2, -0.2, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.8)
    posA = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.6)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.7, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.5, 0.7, -0.2, 0.4)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-68
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.7, 0.7, 0.8, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, 0.4, 0.5, 0.5, 0.6, -0.3, -0.2, -0.2, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.6)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.5, 0.7, -0.2, 0.4)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RUB-69
    body_soil_pos = Vector{BodySoil{Int64, Float64}}() 
    set_height(out, 10, 14, -0.2, -0.2, 0.0, 0.0, 1.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, 0.4, 0.5, 0.5, 0.6, -0.3, -0.2, -0.2, 0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.9)
    posA = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.6)
    _relax_unstable_body_cell!(
        out, 33, body_soil_pos, 0.1, 1, 10, 14, 1, 10, 15, grid, bucket,
        1e-5)
    check_height(out, 10, 14, -0.2, 0.0, 0.9, NaN, NaN)
    check_height(out, 10, 15, -0.3, 0.5, 0.7, -0.2, 0.4)
    check_body_soil_pos(body_soil_pos[1], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.9)
    @test (length(body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])
end

@testset "_relax_body_soil!" begin
    # Setting up the environment
    out.impact_area[:, :] .= Int64[[2, 20] [2, 20]]

    # Test: RE-RBS-1
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])

    # Test: RE-RBS-2
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.3, -0.3, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    out.terrain[10, 15] = -0.2
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.3, -0.2, -0.1, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])

    # Test: RE-RBS-3
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.3, -0.3, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    out.terrain[10, 15] = -0.4
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.3, 0.0, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])

    # Test: RE-RBS-4
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.3, -0.3, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    out.terrain[10, 15] = -0.4
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.3, 0.0, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])

    # Test: RE-RBS-5
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-6
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.1, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.2, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-7
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, 0.0, 0.2, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.1, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-8
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, -0.2, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.4)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.3)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-9
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, 0.0, 0.2, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.1, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-10
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.4, -0.3, -0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-11
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.6, -0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.3, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-12
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.6, -0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.3, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-13
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.4, -0.2, 0.0, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-14
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.4, -0.4, -0.3, -0.3, -0.2, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.4, -0.3, -0.1, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-15
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.7, -0.6, -0.6, -0.5, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, -0.6, -0.3, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-16
    set_RNG_seed!(2)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.7, -0.6, -0.6, -0.5, NaN, NaN, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, -0.6, -0.3, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-17
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, NaN, NaN, NaN, NaN, -0.4, 0.1, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-18
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, NaN, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.2, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-19
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, NaN, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-20
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.3, NaN, NaN, NaN, NaN, -0.2, 0.1, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.4)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.3)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-21
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, NaN, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-22
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, NaN, NaN, NaN, NaN, -0.4, -0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.4, NaN, NaN, -0.3, -0.2)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-23
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, NaN, NaN, NaN, NaN, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.4)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, NaN, NaN, -0.5, -0.3)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-24
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, NaN, NaN, NaN, NaN, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, NaN, NaN, -0.5, -0.3)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-25
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.4, NaN, NaN, NaN, NaN, -0.4, -0.3, -0.3, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.4, NaN, NaN, -0.3, -0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-26
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.4, NaN, NaN, NaN, NaN, -0.4, -0.3, -0.3, -0.2)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.4, NaN, NaN, -0.3, -0.1)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-27
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, NaN, NaN, NaN, NaN, -0.7, -0.6, -0.6, -0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, NaN, NaN, -0.6, -0.3)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-28
    set_RNG_seed!(2)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, NaN, NaN, NaN, NaN, -0.7, -0.6, -0.6, -0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, NaN, NaN, -0.6, -0.3)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-29
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.1, NaN, NaN, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-30
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.3, NaN, NaN, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.4, -0.3, -0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-31
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.6, -0.5, NaN, NaN, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.3, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-32
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.3, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.6, -0.4, NaN, NaN, -0.2, 0.0, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.6)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.4, -0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.4)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-33
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.6, -0.5, NaN, NaN, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.3, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-34
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, NaN, NaN, -0.4, -0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.2, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.6, NaN, NaN, -0.2, -0.1)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-35
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, NaN, NaN, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.5, -0.3)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-36
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, NaN, NaN, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.5, -0.3)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-37
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.4, -0.2, NaN, NaN, -0.1, 0.0, 0.0, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.4, -0.2, -0.1, 0.0, 0.1)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-38
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.5, -0.5, -0.4, NaN, NaN, -0.1, 0.0, 0.0, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.5, -0.4, -0.2, 0.0, 0.1)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-39
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.5, -0.5, -0.3, NaN, NaN, -0.2, 0.0, 0.0, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.4)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.5, -0.3, -0.2, 0.0, 0.1)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-40
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.5, -0.5, -0.4, NaN, NaN, -0.1, 0.0, 0.0, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.5, -0.4, -0.2, 0.0, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[3].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-41
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.3, -0.3, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, NaN, NaN, -0.4, -0.3, -0.3, -0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.3, -0.2, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.6, NaN, NaN, -0.3, -0.1)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-42
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.3, -0.3, -0.1, -0.1, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, NaN, NaN, -0.4, -0.3, -0.3, -0.2)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.3, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, NaN, NaN, -0.3, -0.1)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-43
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.3, -0.3, 0.0, 0.0, 0.2, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.7, -0.6, NaN, NaN, -0.5, -0.4, -0.4, -0.3)
    pos0 = _calc_bucket_frame_pos(10, 14, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.3, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, NaN, NaN, -0.4, -0.1)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-44
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, -0.5, -0.3, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-45
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.2, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, -0.5, -0.4, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.3, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-46
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.4, -0.4, -0.3, -0.2, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.4)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.4, -0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-47
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.1, -0.1, 0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, -0.5, -0.4, 0.1, 0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-48
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, -0.7, -0.6, -0.4, -0.2, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.2, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.7, -0.6, -0.2, -0.1)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-49
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, -0.7, -0.6, -0.5, -0.4, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.7, -0.6, -0.4, -0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-50
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, -0.7, -0.6, -0.5, -0.4, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.7, -0.6, -0.4, -0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-51
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, -0.5, -0.4, -0.2, -0.1, -0.1, 0.0)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.2, -0.1, 0.0)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[3].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-52
    set_RNG_seed!(2)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.7, -0.6, -0.6, -0.5, -0.2, -0.1, -0.1, 0.0)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, -0.6, -0.3, -0.1, 0.0)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-53
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.2, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, -0.5, -0.3, -0.2, 0.0, 0.0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.2)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, 0.1, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.2, 0.0, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.4)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-54
    set_RNG_seed!(2)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.7, -0.6, -0.6, -0.5, -0.2, -0.1, -0.1, 0.0)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.1, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, -0.6, -0.3, -0.1, 0.0)
    check_body_soil_pos(out.body_soil_pos[5], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[3].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-55
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, -0.5, -0.4, -0.3, -0.2, -0.2, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.2, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.4, -0.2, 0.0)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-56
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.1, -0.1, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, -0.7, -0.6, -0.5, -0.4, -0.4, -0.3)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.7, -0.6, -0.4, -0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-57
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.9, -0.9, -0.8, -0.8, -0.7, -0.6, -0.5, -0.5, -0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.8, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.9, -0.8, -0.7, -0.5, -0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-58
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.6, -0.5, -0.5, -0.4, -0.4, -0.1, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.5, -0.4, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-59
    set_RNG_seed!(2)
    for ii in 9:11
        for jj in 13:15
            out.terrain[ii, jj] = 0.2
        end
    end
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.4, -0.4, -0.3, -0.3, -0.1, -0.1, 0.0, 0.0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    pos2 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.4, -0.3, -0.1, 0.0, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 3)
    terrain_pos = [
        [9, 13], [9, 14], [9, 15], [10, 13], [10, 14], [10, 15], [11, 13],
        [11, 14], [11, 15]]
    reset_value_and_test(
        out, terrain_pos, [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-60
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, -0.7, -0.5, -0.5, -0.4, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.7, -0.5, -0.4, -0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.5)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-61
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, -0.7, -0.5, -0.5, -0.4, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.6)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.7, -0.5, -0.4, -0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.5)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-62
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, -0.7, -0.5, -0.5, -0.4, -0.4, -0.2)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.7, -0.5, -0.4, -0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.6)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-63
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.8, -0.7, -0.7, -0.5, -0.5, -0.4, -0.4, -0.3)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.7, -0.5, -0.4, -0.1)
    check_body_soil_pos(out.body_soil_pos[5], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.6)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-64
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, NaN, NaN, -0.4, -0.1, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    @test (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14]])

    # Test: RE-RBS-65
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.1, 0.0, NaN, NaN, -0.4, -0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.4, NaN, NaN, -0.3, -0.2)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-66
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.1, 0.0, NaN, NaN, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, NaN, NaN, -0.5, -0.3)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-67
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.5, -0.3, NaN, NaN, -0.8, -0.7, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    posA = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.8, NaN, NaN, -0.7, -0.5)
    check_body_soil_pos(out.body_soil_pos[2], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.5)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-68
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.1, 0.0, NaN, NaN, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, NaN, NaN, -0.5, -0.3)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-69
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.3, -0.2, NaN, NaN, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.2, -0.1, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-70
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.2, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.5, -0.4, NaN, NaN, -0.8, -0.7, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.4, -0.3, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[2], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-71
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.4, -0.3, NaN, NaN, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.3, -0.1, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-72
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, -0.1, 0.0, 0.0, 0.1, -0.4, -0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.4, 0.0, 0.1, -0.3, -0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-73
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.1, 0.0, 0.0, 0.1, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, 0.0, 0.1, -0.5, -0.3)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-74
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.5, -0.5, -0.4, -0.4, 0.1, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.2, 0.0, 0.0, 0.1, -0.6, -0.3, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.4, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.5)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.5, -0.4, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, 0.0, 0.1, -0.3, -0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.4)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-75
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.6, -0.1, 0.0, 0.0, 0.1, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.6, 0.0, 0.1, -0.5, -0.3)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[3].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-76
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.4, -0.3, -0.3, -0.2, -0.6, -0.5, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.2, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.3, -0.1, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-77
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.6, -0.5, -0.5, -0.4, -0.8, -0.7, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.5, -0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-78
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.6, -0.5, -0.5, -0.4, -0.8, -0.7, NaN, NaN)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.5, -0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15]])

    # Test: RE-RBS-79
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.1, 0.0, NaN, NaN, -0.6, -0.5, -0.5, -0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.6, NaN, NaN, -0.5, -0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-80
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.1, 0.0, NaN, NaN, -0.7, -0.6, -0.6, -0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, NaN, NaN, -0.6, -0.3)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-81
    set_RNG_seed!(18)
    set_height(
        out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.4, 0.0, NaN, NaN, -0.7, -0.6, -0.6, -0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.7, NaN, NaN, -0.6, -0.4)
    check_body_soil_pos(out.body_soil_pos[3], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.6)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-82
    set_RNG_seed!(2)
    set_height(
        out, 10, 14, -0.4, -0.4, -0.3, -0.3, -0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.1, 0.0, NaN, NaN, -0.7, -0.6, -0.6, -0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, NaN, NaN, -0.6, -0.3)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-83
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.6, -0.4, -0.3, NaN, NaN, -0.6, -0.5, -0.5, -0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.6, -0.3, -0.2, -0.5, -0.4)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-84
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.5, -0.4, NaN, NaN, -0.7, -0.6, -0.6, -0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, -0.4, -0.2, -0.6, -0.5)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-85
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.7, -0.5, -0.4, NaN, NaN, -0.7, -0.6, -0.6, -0.5)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.6, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.7, -0.4, -0.2, -0.6, -0.5)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-86
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.1, 0.0, 0.0, 0.1, -0.8, -0.7, -0.7, -0.4)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.3)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.8, 0.0, 0.1, -0.7, -0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.1)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-87
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.1, 0.0, 0.0, 0.1, -0.8, -0.7, -0.7, -0.6)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, 0.0, 0.1, -0.7, -0.4)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-88
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.8, -0.7, -0.7, -0.6)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.3, -0.2, -0.7, -0.4)
    check_body_soil_pos(out.body_soil_pos[4], 3, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.5)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-89
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.2, -0.2, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.1, 0.0, 0.0, 0.1, -0.8, -0.7, -0.7, -0.6)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, posA, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, 0.0, 0.1, -0.7, -0.4)
    check_body_soil_pos(out.body_soil_pos[5], 3, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[3].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-90
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.4, -0.4, -0.3, -0.3, 0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.3, -0.2, -0.2, -0.1, -0.8, -0.7, -0.7, -0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.4)
    posA = _calc_bucket_frame_pos(10, 15, -0.2, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.3)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, -0.3, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.2, 0.0, -0.7, -0.4)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.3)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-91
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.1, -0.1, 0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.5, -0.4, -0.4, -0.3, -0.8, -0.7, -0.7, -0.6)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.2)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.4, -0.1, -0.7, -0.6)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-92
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.4, -0.4, -0.1, -0.1, 0.1, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.5, -0.4, -0.4, -0.3, -0.8, -0.7, -0.7, -0.6)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.1, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.4, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.4, 0.0, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.4, -0.1, -0.7, -0.6)
    check_body_soil_pos(out.body_soil_pos[5], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.0)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-93
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(out, 10, 15, -0.4, 0.0, 0.1, NaN, NaN, -0.4, -0.2, -0.2, 0.0)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.4, NaN, NaN, -0.2, 0.0)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [3, 10, 15]])

    # Test: RE-RBS-94
    set_RNG_seed!(2)
    for ii in 9:11  
        for jj in 13:15  
            out.terrain[ii, jj] = 0.2
        end
    end
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.4, -0.1, 0.0, 0.0, 0.1, -0.4, -0.3, -0.3, -0.1)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos0 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos0, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.2)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, 0.0, NaN, NaN)
    check_height(out, 10, 15, -0.4, 0.0, 0.1, -0.3, -0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.7)
    @test (length(out.body_soil_pos) == 3)
    terrain_pos = [
        [9, 13], [9, 14], [9, 15], [10, 13], [10, 14], [10, 15], [11, 13],
        [11, 14], [11, 15]]
    reset_value_and_test(
        out, terrain_pos, [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-95
    set_RNG_seed!(18)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, NaN, NaN, -0.8, -0.7, -0.7, -0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.3)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.3, -0.2, -0.7, -0.4)
    check_body_soil_pos(out.body_soil_pos[3], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.6)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-96
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.6, -0.5, NaN, NaN, -0.8, -0.7, -0.7, -0.6)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.6)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.5, -0.3, -0.7, -0.6)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.5)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-97
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.4, -0.3, -0.3, -0.2, -0.8, -0.7, -0.7, -0.4)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.7)
    posA = _calc_bucket_frame_pos(10, 15, -0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.3)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.1, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.3, -0.1, -0.7, -0.4)
    check_body_soil_pos(out.body_soil_pos[4], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.6)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-98
    set_RNG_seed!(2)
    set_height(out, 10, 14, -0.8, -0.8, -0.7, -0.7, 0.0, NaN, NaN, NaN, NaN)
    set_height(
        out, 10, 15, -0.8, -0.6, -0.5, -0.5, -0.4, -0.8, -0.7, -0.7, -0.6)
    pos0 = _calc_bucket_frame_pos(10, 14, -0.7, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.1)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.6)
    posA = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, posA, 0.1)
    pos2 = _calc_bucket_frame_pos(10, 15, -0.7, grid, bucket)
    push_body_soil_pos(out, 3, 10, 15, pos2, 0.1)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.8, -0.7, -0.2, NaN, NaN)
    check_height(out, 10, 15, -0.8, -0.5, -0.2, -0.7, -0.6)
    check_body_soil_pos(out.body_soil_pos[5], 1, 10, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 10, 15, posA, 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.0)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.5)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, [[10, 14], [10, 15]], [[1, 10, 14], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 14], [1, 10, 15], [3, 10, 15]])

    # Test: RE-RBS-99
    set_RNG_seed!(3)
    set_height(out, 10, 14, -0.6, -0.6, -0.5, -0.5, 0.0, NaN, NaN, NaN, NaN)
    out.terrain[10, 13] = -0.4
    out.terrain[10, 15] = -0.4
    pos0 = _calc_bucket_frame_pos(10, 14, -0.5, grid, bucket)
    push_body_soil_pos(out, 1, 10, 14, pos0, 0.5)
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.6, -0.5, -0.3, NaN, NaN)
    @test (out.terrain[10, 13] ≈ -0.2)
    @test (out.terrain[10, 15] ≈ -0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 1)
    set_RNG_seed!(1)
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 13] = -0.4
    out.terrain[10, 15] = -0.4
    out.body_soil_pos[1].h_soil[1] = 0.5
    _relax_body_soil!(out, grid, bucket, sim, 1e-5)
    check_height(out, 10, 14, -0.6, -0.5, -0.3, NaN, NaN)
    @test (out.terrain[10, 13] ≈ -0.3)
    @test (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 1)
    reset_value_and_test(
        out, [[10, 13], [10, 14], [10, 15]], [[1, 10, 14]], [[1, 10, 14]])
end
