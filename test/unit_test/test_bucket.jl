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
@testset "_calc_line_pos" begin
    # Note that the function does not account for the case where
    # the line follows a cell border.
    # It is therefore necessary to solve this potential ambiguity
    # before calling the function. As a result, a small increment (1e-8)
    # is added or removed to the input in order to make sure that
    # the input coordinates do not correspond to a cell border.

    # Testing for a line following the X axis
    a = [0.0 + 1e-8, 0.0 - 1e-8, -0.06 + 1e-8]
    b = [1.0 - 1e-8, 0.0 - 1e-8,  0.0  - 1e-8]
    delta = 0.1
    line_pos = _calc_line_pos(a, b, delta, grid)
    @test ([11, 11, 11] in line_pos) && ([12, 11, 11] in line_pos)
    @test ([13, 11, 11] in line_pos) && ([14, 11, 11] in line_pos)
    @test ([15, 11, 11] in line_pos) && ([16, 11, 11] in line_pos)
    @test ([17, 11, 11] in line_pos) && ([18, 11, 11] in line_pos)
    @test ([19, 11, 11] in line_pos) && ([20, 11, 11] in line_pos)
    @test ([21, 11, 11] in line_pos)
    @test length(line_pos) == 11

    # Testing for a line following the X axis with a larger delta
    a = [0.0 + 1e-8, 0.0 - 1e-8, 0.0 - 1e-8]
    b = [1.0 - 1e-8, 0.0 - 1e-8, 0.0 - 1e-8]
    delta = 0.5
    line_pos = _calc_line_pos(a, b, delta, grid)
    @test ([11, 11, 11] in line_pos) && ([16, 11, 11] in line_pos)
    @test ([21, 11, 11] in line_pos)
    @test length(line_pos) == 3

    # Testing that the rounding is done properly
    a = [0.04 + 1e-8,  0.04 - 1e-8, -0.09 + 1e-8]
    b = [1.04 - 1e-8, -0.04 + 1e-8,  0.0  - 1e-8]
    delta = 0.1
    line_pos = _calc_line_pos(a, b, delta, grid)
    @test ([11, 11, 11] in line_pos) && ([12, 11, 11] in line_pos)
    @test ([13, 11, 11] in line_pos) && ([14, 11, 11] in line_pos)
    @test ([15, 11, 11] in line_pos) && ([16, 11, 11] in line_pos)
    @test ([17, 11, 11] in line_pos) && ([18, 11, 11] in line_pos)
    @test ([19, 11, 11] in line_pos) && ([20, 11, 11] in line_pos)
    @test ([21, 11, 11] in line_pos)
    @test length(line_pos) == 11

    # Testing for a line following the Y axis
    a = [0.0 - 1e-8, 0.0 + 1e-8, 0.0 - 1e-8]
    b = [0.0 - 1e-8, 1.0 - 1e-8, 0.0 - 1e-8]
    delta = 0.1
    line_pos = unique(_calc_line_pos(a, b, delta, grid))
    @test ([11, 11, 11] in line_pos) && ([11, 12, 11] in line_pos)
    @test ([11, 13, 11] in line_pos) && ([11, 14, 11] in line_pos)
    @test ([11, 15, 11] in line_pos) && ([11, 16, 11] in line_pos)
    @test ([11, 17, 11] in line_pos) && ([11, 18, 11] in line_pos)
    @test ([11, 19, 11] in line_pos) && ([11, 20, 11] in line_pos)
    @test ([11, 21, 11] in line_pos)
    @test length(line_pos) == 11

    # Testing for an arbitrary line (results obtained through hand-drawing)
    a = [0.34 + 1e-8, 0.56 + 1e-8, 0.0 - 1e-8]
    b = [0.74 - 1e-8, 0.97 - 1e-8, 0.0 - 1e-8]
    delta = 0.01
    line_pos = unique(_calc_line_pos(a, b, delta, grid))
    @test ([14, 17, 11] in line_pos) && ([15, 17, 11] in line_pos)
    @test ([15, 18, 11] in line_pos) && ([16, 18, 11] in line_pos)
    @test ([16, 19, 11] in line_pos) && ([17, 19, 11] in line_pos)
    @test ([17, 20, 11] in line_pos) && ([18, 20, 11] in line_pos)
    @test ([18, 21, 11] in line_pos)
    @test length(line_pos) == 9

    # Testing for an arbitrary line in the XZ plane
    a = [0.34 + 1e-8, 0.0 - 1e-8, 0.56 + 1e-8]
    b = [0.74 - 1e-8, 0.0 - 1e-8, 0.97 - 1e-8]
    delta = 0.01
    line_pos = unique(_calc_line_pos(a, b, delta, grid))
    @test ([14, 11, 17] in line_pos) && ([15, 11, 17] in line_pos)
    @test ([15, 11, 18] in line_pos) && ([16, 11, 18] in line_pos)
    @test ([16, 11, 19] in line_pos) && ([17, 11, 19] in line_pos)
    @test ([17, 11, 20] in line_pos) && ([18, 11, 20] in line_pos)
    @test ([18, 11, 21] in line_pos)
    @test length(line_pos) == 9

    # Testing for the edge case where the line is a point
    a = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    b = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    delta = 0.01
    line_pos = unique(_calc_line_pos(a, b, delta, grid))
    @test ([16, 16, 16] in line_pos)
    @test length(line_pos) == 1

    # Testing for the edge case where the line is a point
    a = [0.55 - 1e-8, 0.55 - 1e-8, 0.55 - 1e-8]
    b = [0.55 - 1e-8, 0.55 - 1e-8, 0.55 - 1e-8]
    delta = 0.01
    line_pos = unique(_calc_line_pos(a, b, delta, grid))
    @test ([16, 16, 17] in line_pos)
    @test length(line_pos) == 1
end

@testset "_decompose_vector_rectangle" begin
    # Note that the function does not account for the case where
    # the rectangle follows a cell border.
    # It is therefore necessary to solve this potential ambiguity
    # before calling the function. As a result, a small increment (1e-12)
    # is sometimes added or removed to the input in order to make sure that
    # the input coordinates do not correspond to a cell border.

    # Testing for a simple rectangle in the XY plane
    a_ind = [11.0, 11.0, 11.0]
    ab_ind = [5.0, 0.0, 0.0]
    ad_ind = [0.0, 5.0, 0.0]
    area_min_x = 9
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    delta = 0.01
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking decomposition in terms of AB component
    @test (c_ab[3, 3] ≈ 0.1) && (c_ab[3, 4] ≈ 0.1) && (c_ab[3, 5] ≈ 0.1)
    @test (c_ab[3, 6] ≈ 0.1) && (c_ab[3, 7] ≈ 0.1) && (c_ab[3, 8] ≈ 0.1)
    @test (c_ab[4, 3] ≈ 0.3) && (c_ab[4, 4] ≈ 0.3) && (c_ab[4, 5] ≈ 0.3)
    @test (c_ab[4, 6] ≈ 0.3) && (c_ab[4, 7] ≈ 0.3) && (c_ab[4, 8] ≈ 0.3)
    @test (c_ab[5, 3] ≈ 0.5) && (c_ab[5, 4] ≈ 0.5) && (c_ab[5, 5] ≈ 0.5)
    @test (c_ab[5, 6] ≈ 0.5) && (c_ab[5, 7] ≈ 0.5) && (c_ab[5, 8] ≈ 0.5)
    @test (c_ab[6, 3] ≈ 0.7) && (c_ab[6, 4] ≈ 0.7) && (c_ab[6, 5] ≈ 0.7)
    @test (c_ab[6, 6] ≈ 0.7) && (c_ab[6, 7] ≈ 0.7) && (c_ab[6, 8] ≈ 0.7)
    @test (c_ab[7, 3] ≈ 0.9) && (c_ab[7, 4] ≈ 0.9) && (c_ab[7, 5] ≈ 0.9)
    @test (c_ab[7, 6] ≈ 0.9) && (c_ab[7, 7] ≈ 0.9) && (c_ab[7, 8] ≈ 0.9)
    # Checking decomposition in terms of AD component
    @test (c_ad[3, 3] ≈ 0.1) && (c_ad[3, 4] ≈ 0.3) && (c_ad[3, 5] ≈ 0.5)
    @test (c_ad[3, 6] ≈ 0.7) && (c_ad[3, 7] ≈ 0.9) && (c_ad[3, 8] ≈ 1.1)
    @test (c_ad[4, 3] ≈ 0.1) && (c_ad[4, 4] ≈ 0.3) && (c_ad[4, 5] ≈ 0.5)
    @test (c_ad[4, 6] ≈ 0.7) && (c_ad[4, 7] ≈ 0.9) && (c_ad[4, 8] ≈ 1.1)
    @test (c_ad[5, 3] ≈ 0.1) && (c_ad[5, 4] ≈ 0.3) && (c_ad[5, 5] ≈ 0.5)
    @test (c_ad[5, 6] ≈ 0.7) && (c_ad[5, 7] ≈ 0.9) && (c_ad[5, 8] ≈ 1.1)
    @test (c_ad[6, 3] ≈ 0.1) && (c_ad[6, 4] ≈ 0.3) && (c_ad[6, 5] ≈ 0.5)
    @test (c_ad[6, 6] ≈ 0.7) && (c_ad[6, 7] ≈ 0.9) && (c_ad[6, 8] ≈ 1.1)
    @test (c_ad[7, 3] ≈ 0.1) && (c_ad[7, 4] ≈ 0.3) && (c_ad[7, 5] ≈ 0.5)
    @test (c_ad[7, 6] ≈ 0.7) && (c_ad[7, 7] ≈ 0.9) && (c_ad[7, 8] ≈ 1.1)
    # Checking cells inside the rectangle area
    @test all(in_rectangle[3:7, 3:7] .== true)
    in_rectangle[3:7, 3:7] .= false
    @test all(in_rectangle[:, :] .== false)
    # Checking the number of cells inside the rectangle area
    @test n_cell == 25 * 4

    # Testing for not rounded indices
    a_ind = [10.7, 11.3, 5.3]
    ab_ind = [5.7, 0.0, 0.0]
    ad_ind = [0.0, 4.7, 0.0]
    area_min_x = 9
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    delta = 0.01
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking cells inside the rectangle area
    @test all(in_rectangle[3:7, 3:7] .== true)
    in_rectangle[3:7, 3:7] .= false
    @test all(in_rectangle[:, :] .== false)
    # Checking the number of cells inside the rectangle area
    @test n_cell == 25 * 4

    # Testing for a simple rectangle in the XY plane at cell border
    a_ind = [11 + 1e-12, 10.5 + 1e-12, 6.0]
    ab_ind = [5.0 - 1e-12, 0.0, 2.4]
    ad_ind = [0.0, 3.0 - 1e-12, -0.3]
    area_min_x = 9
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    delta = 0.01
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking decomposition in terms of AB component
    @test (c_ab[3, 3] ≈ 0.1) && (c_ab[3, 4] ≈ 0.1) && (c_ab[3, 5] ≈ 0.1)
    @test (c_ab[3, 6] ≈ 0.1) && (c_ab[3, 7] ≈ 0.1) && (c_ab[3, 8] ≈ 0.1)
    @test (c_ab[4, 3] ≈ 0.3) && (c_ab[4, 4] ≈ 0.3) && (c_ab[4, 5] ≈ 0.3)
    @test (c_ab[4, 6] ≈ 0.3) && (c_ab[4, 7] ≈ 0.3) && (c_ab[4, 8] ≈ 0.3)
    @test (c_ab[5, 3] ≈ 0.5) && (c_ab[5, 4] ≈ 0.5) && (c_ab[5, 5] ≈ 0.5)
    @test (c_ab[5, 6] ≈ 0.5) && (c_ab[5, 7] ≈ 0.5) && (c_ab[5, 8] ≈ 0.5)
    @test (c_ab[6, 3] ≈ 0.7) && (c_ab[6, 4] ≈ 0.7) && (c_ab[6, 5] ≈ 0.7)
    @test (c_ab[6, 6] ≈ 0.7) && (c_ab[6, 7] ≈ 0.7) && (c_ab[6, 8] ≈ 0.7)
    @test (c_ab[7, 3] ≈ 0.9) && (c_ab[7, 4] ≈ 0.9) && (c_ab[7, 5] ≈ 0.9)
    @test (c_ab[7, 6] ≈ 0.9) && (c_ab[7, 7] ≈ 0.9) && (c_ab[7, 8] ≈ 0.9)
    # Checking decomposition in terms of AD component
    @test (c_ad[3, 3] ≈ 1/3) && (c_ad[3, 4] ≈ 2/3) && (c_ad[3, 5] ≈ 1.0)
    @test (c_ad[4, 3] ≈ 1/3) && (c_ad[4, 4] ≈ 2/3) && (c_ad[4, 5] ≈ 1.0)
    @test (c_ad[5, 3] ≈ 1/3) && (c_ad[5, 4] ≈ 2/3) && (c_ad[5, 5] ≈ 1.0)
    @test (c_ad[6, 3] ≈ 1/3) && (c_ad[6, 4] ≈ 2/3) && (c_ad[6, 5] ≈ 1.0)
    @test (c_ad[7, 3] ≈ 1/3) && (c_ad[7, 4] ≈ 2/3) && (c_ad[7, 5] ≈ 1.0)
    # Checking cells inside the rectangle area
    @test all(in_rectangle[3:7, 3:4] .== true)
    in_rectangle[3:7, 3:4] .= false
    @test all(in_rectangle[:, :] .== false)
    # Checking the number of cells inside the rectangle area
    @test n_cell == 10 * 4

    # Testing for a simple rectangle in the XYZ plane
    a_ind = [16.0, 11.0, 6.0]
    ab_ind = [1.0, 0.0, 2.4]
    ad_ind = [0.0, 5.0, -0.3]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    delta = 0.01
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking decomposition in terms of AB component
    @test (c_ab[3, 3] ≈ 0.5) && (c_ab[3, 4] ≈ 0.5) && (c_ab[3, 5] ≈ 0.5)
    @test (c_ab[3, 6] ≈ 0.5) && (c_ab[3, 7] ≈ 0.5) && (c_ab[3, 8] ≈ 0.5)
    @test (c_ab[4, 3] ≈ 1.5) && (c_ab[4, 4] ≈ 1.5) && (c_ab[4, 5] ≈ 1.5)
    @test (c_ab[4, 6] ≈ 1.5) && (c_ab[4, 7] ≈ 1.5) && (c_ab[4, 8] ≈ 1.5)
    # Checking decomposition in terms of AD component
    @test (c_ad[3, 3] ≈ 0.1) && (c_ad[3, 4] ≈ 0.3) && (c_ad[3, 5] ≈ 0.5)
    @test (c_ad[3, 6] ≈ 0.7) && (c_ad[3, 7] ≈ 0.9) && (c_ad[3, 8] ≈ 1.1)
    @test (c_ad[4, 3] ≈ 0.1) && (c_ad[4, 4] ≈ 0.3) && (c_ad[4, 5] ≈ 0.5)
    @test (c_ad[4, 6] ≈ 0.7) && (c_ad[4, 7] ≈ 0.9) && (c_ad[4, 8] ≈ 1.1)
    # Checking cells inside the rectangle area
    @test all(in_rectangle[3, 3:7] .== true)
    in_rectangle[3, 3:7] .= false
    @test all(in_rectangle[:, :] .== false)
    # Checking the number of cells inside the rectangle area
    @test n_cell == 5 * 4

    # Testing for the edge case where the rectangle is a line
    # Note that no decomposition can be mathematically made
    a_ind = [15.2, 11.3, 6.0]
    ab_ind = [2.3, 1.2, 2.4]
    ad_ind = [4.6, 2.4, -0.3]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    delta = 0.01
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking there is no cell in the rectangle area
    @test all(in_rectangle[:, :] .== false)
    # Checking the number of cells inside the rectangle area
    @test n_cell == 0

    # Testing for the edge case where the rectangle is a point
    # Note that no decomposition can be mathematically made
    a_ind = [15.2, 11.3, 6.0]
    ab_ind = [0.0, 0.0, 0.0]
    ad_ind = [0.0, 0.0, 0.0]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    delta = 0.01
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking there is no cell in the rectangle area
    @test all(in_rectangle[:, :] .== false)
    # Checking the number of cells inside the rectangle area
    @test n_cell == 0
end

@testset "_calc_rectangle_pos" begin
    # Note that the function does not account for the case where
    # the rectangle follows a cell border.
    # It is therefore necessary to solve this potential ambiguity
    # before calling the function. As a result, a small increment (1e-8)
    # is added or removed to the input in order to make sure that
    # the input coordinates do not correspond to a cell border.

    # Testing for a simple rectangle in the XY plane
    a = [0.0 + 1e-8, 0.0 + 1e-8, 0.0 - 1e-8]
    b = [0.5 - 1e-8, 0.0 + 1e-8, 0.0 - 1e-8]
    c = [0.5 - 1e-8, 0.5 - 1e-8, 0.0 - 1e-8]
    d = [0.0 + 1e-8, 0.5 - 1e-8, 0.0 - 1e-8]
    delta = 0.01
    rec_pos = unique(_calc_rectangle_pos(a, b, c, d, delta, grid))
    @test ([11, 11, 11] in rec_pos) && ([11, 12, 11] in rec_pos)
    @test ([11, 13, 11] in rec_pos) && ([11, 14, 11] in rec_pos)
    @test ([11, 15, 11] in rec_pos) && ([11, 16, 11] in rec_pos)
    @test ([12, 11, 11] in rec_pos) && ([12, 12, 11] in rec_pos)
    @test ([12, 13, 11] in rec_pos) && ([12, 14, 11] in rec_pos)
    @test ([12, 15, 11] in rec_pos) && ([12, 16, 11] in rec_pos)
    @test ([13, 11, 11] in rec_pos) && ([13, 12, 11] in rec_pos)
    @test ([13, 13, 11] in rec_pos) && ([13, 14, 11] in rec_pos)
    @test ([13, 15, 11] in rec_pos) && ([13, 16, 11] in rec_pos)
    @test ([14, 11, 11] in rec_pos) && ([14, 12, 11] in rec_pos)
    @test ([14, 13, 11] in rec_pos) && ([14, 14, 11] in rec_pos)
    @test ([14, 15, 11] in rec_pos) && ([14, 16, 11] in rec_pos)
    @test ([15, 11, 11] in rec_pos) && ([15, 12, 11] in rec_pos)
    @test ([15, 13, 11] in rec_pos) && ([15, 14, 11] in rec_pos)
    @test ([15, 15, 11] in rec_pos) && ([15, 16, 11] in rec_pos)
    @test ([16, 11, 11] in rec_pos) && ([16, 12, 11] in rec_pos)
    @test ([16, 13, 11] in rec_pos) && ([16, 14, 11] in rec_pos)
    @test ([16, 15, 11] in rec_pos) && ([16, 16, 11] in rec_pos)
    @test length(rec_pos) == 36

    # Testing that the input order does not influence the results (1)
    rec_pos = unique(_calc_rectangle_pos(a, d, c, b, delta, grid))
    @test ([11, 11, 11] in rec_pos) && ([11, 12, 11] in rec_pos)
    @test ([11, 13, 11] in rec_pos) && ([11, 14, 11] in rec_pos)
    @test ([11, 15, 11] in rec_pos) && ([11, 16, 11] in rec_pos)
    @test ([12, 11, 11] in rec_pos) && ([12, 12, 11] in rec_pos)
    @test ([12, 13, 11] in rec_pos) && ([12, 14, 11] in rec_pos)
    @test ([12, 15, 11] in rec_pos) && ([12, 16, 11] in rec_pos)
    @test ([13, 11, 11] in rec_pos) && ([13, 12, 11] in rec_pos)
    @test ([13, 13, 11] in rec_pos) && ([13, 14, 11] in rec_pos)
    @test ([13, 15, 11] in rec_pos) && ([13, 16, 11] in rec_pos)
    @test ([14, 11, 11] in rec_pos) && ([14, 12, 11] in rec_pos)
    @test ([14, 13, 11] in rec_pos) && ([14, 14, 11] in rec_pos)
    @test ([14, 15, 11] in rec_pos) && ([14, 16, 11] in rec_pos)
    @test ([15, 11, 11] in rec_pos) && ([15, 12, 11] in rec_pos)
    @test ([15, 13, 11] in rec_pos) && ([15, 14, 11] in rec_pos)
    @test ([15, 15, 11] in rec_pos) && ([15, 16, 11] in rec_pos)
    @test ([16, 11, 11] in rec_pos) && ([16, 12, 11] in rec_pos)
    @test ([16, 13, 11] in rec_pos) && ([16, 14, 11] in rec_pos)
    @test ([16, 15, 11] in rec_pos) && ([16, 16, 11] in rec_pos)
    @test length(rec_pos) == 36

    # Testing that the input order does not influence the results (2)
    rec_pos = unique(_calc_rectangle_pos(c, b, a, d, delta, grid))
    @test ([11, 11, 11] in rec_pos) && ([11, 12, 11] in rec_pos)
    @test ([11, 13, 11] in rec_pos) && ([11, 14, 11] in rec_pos)
    @test ([11, 15, 11] in rec_pos) && ([11, 16, 11] in rec_pos)
    @test ([12, 11, 11] in rec_pos) && ([12, 12, 11] in rec_pos)
    @test ([12, 13, 11] in rec_pos) && ([12, 14, 11] in rec_pos)
    @test ([12, 15, 11] in rec_pos) && ([12, 16, 11] in rec_pos)
    @test ([13, 11, 11] in rec_pos) && ([13, 12, 11] in rec_pos)
    @test ([13, 13, 11] in rec_pos) && ([13, 14, 11] in rec_pos)
    @test ([13, 15, 11] in rec_pos) && ([13, 16, 11] in rec_pos)
    @test ([14, 11, 11] in rec_pos) && ([14, 12, 11] in rec_pos)
    @test ([14, 13, 11] in rec_pos) && ([14, 14, 11] in rec_pos)
    @test ([14, 15, 11] in rec_pos) && ([14, 16, 11] in rec_pos)
    @test ([15, 11, 11] in rec_pos) && ([15, 12, 11] in rec_pos)
    @test ([15, 13, 11] in rec_pos) && ([15, 14, 11] in rec_pos)
    @test ([15, 15, 11] in rec_pos) && ([15, 16, 11] in rec_pos)
    @test ([16, 11, 11] in rec_pos) && ([16, 12, 11] in rec_pos)
    @test ([16, 13, 11] in rec_pos) && ([16, 14, 11] in rec_pos)
    @test ([16, 15, 11] in rec_pos) && ([16, 16, 11] in rec_pos)
    @test length(rec_pos) == 36

    # Testing that the input order does not influence the results (3)
    rec_pos = unique(_calc_rectangle_pos(b, c, d, a, delta, grid))
    @test length(rec_pos) == 36
    rec_pos = unique(_calc_rectangle_pos(c, d, a, b, delta, grid))
    @test length(rec_pos) == 36
    rec_pos = unique(_calc_rectangle_pos(d, a, b, c, delta, grid))
    @test length(rec_pos) == 36
    rec_pos = unique(_calc_rectangle_pos(d, c, b, a, delta, grid))
    @test length(rec_pos) == 36
    rec_pos = unique(_calc_rectangle_pos(b, a, d, c, delta, grid))
    @test length(rec_pos) == 36

    # Testing for a simple rectangle in the XY plane at cell border
    a = [0.0 + 1e-8, -0.05 + 1e-8, 0.0 - 1e-8]
    b = [0.5 - 1e-8, -0.05 + 1e-8, 0.0 - 1e-8]
    c = [0.5 - 1e-8,  0.25 - 1e-8, 0.0 - 1e-8]
    d = [0.0 + 1e-8,  0.25 - 1e-8, 0.0 - 1e-8]
    delta = 0.01
    rec_pos = unique(_calc_rectangle_pos(a, b, c, d, delta, grid))
    @test ([11, 11, 11] in rec_pos) && ([11, 12, 11] in rec_pos)
    @test ([11, 13, 11] in rec_pos) && ([12, 11, 11] in rec_pos)
    @test ([12, 12, 11] in rec_pos) && ([12, 13, 11] in rec_pos)
    @test ([13, 11, 11] in rec_pos) && ([13, 12, 11] in rec_pos)
    @test ([13, 13, 11] in rec_pos) && ([14, 11, 11] in rec_pos)
    @test ([14, 12, 11] in rec_pos) && ([14, 13, 11] in rec_pos)
    @test ([15, 11, 11] in rec_pos) && ([15, 12, 11] in rec_pos)
    @test ([15, 13, 11] in rec_pos) && ([16, 11, 11] in rec_pos)
    @test ([16, 12, 11] in rec_pos) && ([16, 13, 11] in rec_pos)
    @test length(rec_pos) == 18

    # Testing that the input order does not influence the results
    rec_pos = unique(_calc_rectangle_pos(b, c, d, a, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(c, d, a, b, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(d, a, b, c, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(d, c, b, a, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(b, a, d, c, delta, grid))
    @test length(rec_pos) == 18

    # Testing for a simple rectangle in the XZ plane
    a = [0.0 + 1e-8, 0.0 - 1e-8, 0.0 + 1e-8]
    b = [0.5 - 1e-8, 0.0 - 1e-8, 0.0 + 1e-8]
    c = [0.5 - 1e-8, 0.0 - 1e-8, 0.5 - 1e-8]
    d = [0.0 + 1e-8, 0.0 - 1e-8, 0.5 - 1e-8]
    delta = 0.01
    rec_pos = unique(_calc_rectangle_pos(a, b, c, d, delta, grid))
    @test ([11, 11, 12] in rec_pos) && ([11, 11, 13] in rec_pos)
    @test ([11, 11, 14] in rec_pos) && ([11, 11, 15] in rec_pos)
    @test ([11, 11, 16] in rec_pos) && ([16, 11, 12] in rec_pos)
    @test ([16, 11, 13] in rec_pos) && ([16, 11, 14] in rec_pos)
    @test ([16, 11, 15] in rec_pos) && ([16, 11, 16] in rec_pos)
    @test ([12, 11, 12] in rec_pos) && ([13, 11, 12] in rec_pos)
    @test ([14, 11, 12] in rec_pos) && ([15, 11, 12] in rec_pos)
    @test ([12, 11, 16] in rec_pos) && ([13, 11, 16] in rec_pos)
    @test ([14, 11, 16] in rec_pos) && ([15, 11, 16] in rec_pos)
    @test length(rec_pos) == 18

    # Testing that the input order does not influence the results
    rec_pos = unique(_calc_rectangle_pos(b, c, d, a, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(c, d, a, b, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(d, a, b, c, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(a, d, c, b, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(d, c, b, a, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(c, b, a, d, delta, grid))
    @test length(rec_pos) == 18
    rec_pos = unique(_calc_rectangle_pos(b, a, d, c, delta, grid))
    @test length(rec_pos) == 18

    # Testing for a simple rectangle in the XYZ plane
    a = [0.5 + 1e-8, 0.0 + 1e-8, 0.5 + 1e-8]
    b = [0.6 - 1e-8, 0.0 + 1e-8, 0.6 - 1e-8]
    c = [0.6 - 1e-8, 0.5 - 1e-8, 0.6 - 1e-8]
    d = [0.5 + 1e-8, 0.5 - 1e-8, 0.5 + 1e-8]
    delta = 0.01
    rec_pos = unique(_calc_rectangle_pos(a, b, c, d, delta, grid))
    @test ([17, 11, 17] in rec_pos) && ([17, 12, 17] in rec_pos)
    @test ([17, 13, 17] in rec_pos) && ([17, 14, 17] in rec_pos)
    @test ([17, 15, 17] in rec_pos) && ([17, 16, 17] in rec_pos)
    @test ([16, 11, 17] in rec_pos) && ([16, 12, 17] in rec_pos)
    @test ([16, 13, 17] in rec_pos) && ([16, 14, 17] in rec_pos)
    @test ([16, 15, 17] in rec_pos) && ([16, 16, 17] in rec_pos)
    @test length(rec_pos) == 12

    rec_pos = unique(_calc_rectangle_pos(b, c, d, a, delta, grid))
    @test length(rec_pos) == 12
    rec_pos = unique(_calc_rectangle_pos(c, d, a, b, delta, grid))
    @test length(rec_pos) == 12
    rec_pos = unique(_calc_rectangle_pos(d, a, b, c, delta, grid))
    @test length(rec_pos) == 12
    rec_pos = unique(_calc_rectangle_pos(a, d, c, b, delta, grid))
    @test length(rec_pos) == 12
    rec_pos = unique(_calc_rectangle_pos(d, c, b, a, delta, grid))
    @test length(rec_pos) == 12
    rec_pos = unique(_calc_rectangle_pos(c, b, a, d, delta, grid))
    @test length(rec_pos) == 12
    rec_pos = unique(_calc_rectangle_pos(b, a, d, c, delta, grid))
    @test length(rec_pos) == 12

    # Testing for the edge case where the rectangle is a line
    a = [0.34 + 1e-8, 0.57 + 1e-8, 0.0 - 1e-8]
    b = [0.74 - 1e-8, 0.97 - 1e-8, 0.0 - 1e-8]
    c = [0.44 + 1e-8, 0.67 + 1e-8, 0.0 - 1e-8]
    d = [0.64 - 1e-8, 0.87 - 1e-8, 0.0 - 1e-8]
    delta = 0.01
    rec_pos = unique(_calc_rectangle_pos(b, a, c, d, delta, grid))
    @test ([14, 17, 11] in rec_pos) && ([15, 17, 11] in rec_pos)
    @test ([15, 18, 11] in rec_pos) && ([16, 18, 11] in rec_pos)
    @test ([16, 19, 11] in rec_pos) && ([17, 19, 11] in rec_pos)
    @test ([17, 20, 11] in rec_pos) && ([18, 20, 11] in rec_pos)
    @test ([18, 21, 11] in rec_pos)
    @test length(rec_pos) == 9

    # Testing for the edge case where the rectangle is a point
    a = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    b = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    c = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    d = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    delta = 0.01
    rec_pos = unique(_calc_rectangle_pos(b, a, c, d, delta, grid))
    @test ([16, 16, 16] in rec_pos)
    @test length(rec_pos) == 1

    # Testing for the edge case where the rectangle is a point on the edge of a cell
    a = [0.55 - 1e-8, 0.55 - 1e-8, 0.5 - 1e-8]
    b = [0.55 - 1e-8, 0.55 - 1e-8, 0.5 - 1e-8]
    c = [0.55 - 1e-8, 0.55 - 1e-8, 0.5 - 1e-8]
    d = [0.55 - 1e-8, 0.55 - 1e-8, 0.5 - 1e-8]
    delta = 0.01
    rec_pos = unique(_calc_rectangle_pos(b, a, c, d, delta, grid))
    @test ([16, 16, 16] in rec_pos)
    @test length(rec_pos) == 1
end

@testset "_decompose_vector_triangle" begin
    # Note that the function does not account for the case where
    # the triangle follows a cell border.

    # Testing for a simple triangle in the XY plane
    a_ind = [11.0, 11.0, 11.0]
    ab_ind = [10.0, 0.0, 0.0]
    ac_ind = [0.0, 10.0, 0.0]
    area_min_x = 9
    area_min_y = 9
    area_length_x = 15
    area_length_y = 15
    delta = 0.01
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking decomposition in terms of AB component
    @test (c_ab[3, 3] ≈ 0.05) && (c_ab[3, 4] ≈ 0.05) && (c_ab[3, 5] ≈ 0.05)
    @test (c_ab[3, 6] ≈ 0.05) && (c_ab[3, 7] ≈ 0.05) && (c_ab[3, 8] ≈ 0.05)
    @test (c_ab[3, 9] ≈ 0.05) && (c_ab[3, 10] ≈ 0.05) && (c_ab[3, 11] ≈ 0.05)
    @test (c_ab[3, 12] ≈ 0.05) && (c_ab[3, 13] ≈ 0.05)
    @test (c_ab[4, 3] ≈ 0.15) && (c_ab[4, 4] ≈ 0.15) && (c_ab[4, 5] ≈ 0.15)
    @test (c_ab[4, 6] ≈ 0.15) && (c_ab[4, 7] ≈ 0.15) && (c_ab[4, 8] ≈ 0.15)
    @test (c_ab[4, 9] ≈ 0.15) && (c_ab[4, 10] ≈ 0.15) && (c_ab[4, 11] ≈ 0.15)
    @test (c_ab[4, 12] ≈ 0.15)
    @test (c_ab[5, 3] ≈ 0.25) && (c_ab[5, 4] ≈ 0.25) && (c_ab[5, 5] ≈ 0.25)
    @test (c_ab[5, 6] ≈ 0.25) && (c_ab[5, 7] ≈ 0.25) && (c_ab[5, 8] ≈ 0.25)
    @test (c_ab[5, 9] ≈ 0.25) && (c_ab[5, 10] ≈ 0.25) && (c_ab[5, 11] ≈ 0.25)
    @test (c_ab[6, 3] ≈ 0.35) && (c_ab[6, 4] ≈ 0.35) && (c_ab[6, 5] ≈ 0.35)
    @test (c_ab[6, 6] ≈ 0.35) && (c_ab[6, 7] ≈ 0.35) && (c_ab[6, 8] ≈ 0.35)
    @test (c_ab[6, 9] ≈ 0.35) && (c_ab[6, 10] ≈ 0.35)
    @test (c_ab[7, 3] ≈ 0.45) && (c_ab[7, 4] ≈ 0.45) && (c_ab[7, 5] ≈ 0.45)
    @test (c_ab[7, 6] ≈ 0.45) && (c_ab[7, 7] ≈ 0.45) && (c_ab[7, 8] ≈ 0.45)
    @test (c_ab[7, 9] ≈ 0.45)
    @test (c_ab[8, 3] ≈ 0.55) && (c_ab[8, 4] ≈ 0.55) && (c_ab[8, 5] ≈ 0.55)
    @test (c_ab[8, 6] ≈ 0.55) && (c_ab[8, 7] ≈ 0.55) && (c_ab[8, 8] ≈ 0.55)
    @test (c_ab[9, 3] ≈ 0.65) && (c_ab[9, 4] ≈ 0.65) && (c_ab[9, 5] ≈ 0.65)
    @test (c_ab[9, 6] ≈ 0.65) && (c_ab[9, 7] ≈ 0.65)
    @test (c_ab[10, 3] ≈ 0.75) && (c_ab[10, 4] ≈ 0.75) && (c_ab[10, 5] ≈ 0.75)
    @test (c_ab[10, 6] ≈ 0.75)
    @test (c_ab[11, 3] ≈ 0.85) && (c_ab[11, 4] ≈ 0.85) && (c_ab[11, 5] ≈ 0.85)
    @test (c_ab[12, 3] ≈ 0.95) && (c_ab[12, 4] ≈ 0.95)
    # Checking decomposition in terms of AC component
    @test (c_ac[3, 3] ≈ 0.05) && (c_ac[3, 4] ≈ 0.15) && (c_ac[3, 5] ≈ 0.25)
    @test (c_ac[3, 6] ≈ 0.35) && (c_ac[3, 7] ≈ 0.45) && (c_ac[3, 8] ≈ 0.55)
    @test (c_ac[3, 9] ≈ 0.65) && (c_ac[3, 10] ≈ 0.75) && (c_ac[3, 11] ≈ 0.85)
    @test (c_ac[3, 12] ≈ 0.95) && (c_ac[3, 13] ≈ 1.05)
    @test (c_ac[4, 3] ≈ 0.05) && (c_ac[4, 4] ≈ 0.15) && (c_ac[4, 5] ≈ 0.25)
    @test (c_ac[4, 6] ≈ 0.35) && (c_ac[4, 7] ≈ 0.45) && (c_ac[4, 8] ≈ 0.55)
    @test (c_ac[4, 9] ≈ 0.65) && (c_ac[4, 10] ≈ 0.75) && (c_ac[4, 11] ≈ 0.85)
    @test (c_ac[4, 12] ≈ 0.95)
    @test (c_ac[5, 3] ≈ 0.05) && (c_ac[5, 4] ≈ 0.15) && (c_ac[5, 5] ≈ 0.25)
    @test (c_ac[5, 6] ≈ 0.35) && (c_ac[5, 7] ≈ 0.45) && (c_ac[5, 8] ≈ 0.55)
    @test (c_ac[5, 9] ≈ 0.65) && (c_ac[5, 10] ≈ 0.75) && (c_ac[5, 11] ≈ 0.85)
    @test (c_ac[6, 3] ≈ 0.05) && (c_ac[6, 4] ≈ 0.15) && (c_ac[6, 5] ≈ 0.25)
    @test (c_ac[6, 6] ≈ 0.35) && (c_ac[6, 7] ≈ 0.45) && (c_ac[6, 8] ≈ 0.55)
    @test (c_ac[6, 9] ≈ 0.65) && (c_ac[6, 10] ≈ 0.75)
    @test (c_ac[7, 3] ≈ 0.05) && (c_ac[7, 4] ≈ 0.15) && (c_ac[7, 5] ≈ 0.25)
    @test (c_ac[7, 6] ≈ 0.35) && (c_ac[7, 7] ≈ 0.45) && (c_ac[7, 8] ≈ 0.55)
    @test (c_ac[7, 9] ≈ 0.65)
    @test (c_ac[8, 3] ≈ 0.05) && (c_ac[8, 4] ≈ 0.15) && (c_ac[8, 5] ≈ 0.25)
    @test (c_ac[8, 6] ≈ 0.35) && (c_ac[8, 7] ≈ 0.45) && (c_ac[8, 8] ≈ 0.55)
    @test (c_ac[9, 3] ≈ 0.05) && (c_ac[9, 4] ≈ 0.15) && (c_ac[9, 5] ≈ 0.25)
    @test (c_ac[9, 6] ≈ 0.35) && (c_ac[9, 7] ≈ 0.45)
    @test (c_ac[10, 3] ≈ 0.05) && (c_ac[10, 4] ≈ 0.15) && (c_ac[10, 5] ≈ 0.25)
    @test (c_ac[10, 6] ≈ 0.35)
    @test (c_ac[11, 3] ≈ 0.05) && (c_ac[11, 4] ≈ 0.15) && (c_ac[11, 5] ≈ 0.25)
    @test (c_ac[12, 3] ≈ 0.05) && (c_ac[12, 4] ≈ 0.15)
    # Checking cells inside the triangle area
    @test all(in_triangle[3, 3:11] .== true)
    @test all(in_triangle[4, 3:10] .== true)
    @test all(in_triangle[5, 3:9] .== true)
    @test all(in_triangle[6, 3:8] .== true)
    @test all(in_triangle[7, 3:7] .== true)
    @test all(in_triangle[8, 3:6] .== true)
    @test all(in_triangle[9, 3:5] .== true)
    @test all(in_triangle[10, 3:4] .== true)
    @test all(in_triangle[11, 3] == true)
    in_triangle[3, 3:11] .= false
    in_triangle[4, 3:10] .= false
    in_triangle[5, 3:9] .= false
    in_triangle[6, 3:8] .= false
    in_triangle[7, 3:7] .= false
    in_triangle[8, 3:6] .= false
    in_triangle[9, 3:5] .= false
    in_triangle[10, 3:4] .= false
    in_triangle[11, 3] = false
    @test all(in_triangle[:, :] .== false)
    # Checking the number of cells inside the triangle area
    @test n_cell == 45 * 4

    # Testing for not rounded indices
    a_ind = [10.9, 10.7, 11.0]
    ab_ind = [9.7, 0.0, 0.0]
    ac_ind = [0.0, 10.4, 0.0]
    area_min_x = 9
    area_min_y = 9
    area_length_x = 15
    area_length_y = 15
    delta = 0.01
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking cells inside the triangle area
    @test all(in_triangle[3, 3:11] .== true)
    @test all(in_triangle[4, 3:10] .== true)
    @test all(in_triangle[5, 3:9] .== true)
    @test all(in_triangle[6, 3:8] .== true)
    @test all(in_triangle[7, 3:7] .== true)
    @test all(in_triangle[8, 3:6] .== true)
    @test all(in_triangle[9, 3:5] .== true)
    @test all(in_triangle[10, 3:4] .== true)
    @test all(in_triangle[11, 3] == true)
    in_triangle[3, 3:11] .= false
    in_triangle[4, 3:10] .= false
    in_triangle[5, 3:9] .= false
    in_triangle[6, 3:8] .= false
    in_triangle[7, 3:7] .= false
    in_triangle[8, 3:6] .= false
    in_triangle[9, 3:5] .= false
    in_triangle[10, 3:4] .= false
    in_triangle[11, 3] = false
    @test all(in_triangle[:, :] .== false)
    # Checking the number of cells inside the triangle area
    @test n_cell == 45 * 4

    # Testing for a simple triangle in the XYZ plane
    a_ind = [16.0, 11.0, 11.0]
    ab_ind = [1.0, 0.0, 0.0]
    ac_ind = [1.0, 5.0, 0.0]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    delta = 0.01
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking decomposition in terms of AB component
    @test (c_ab[3, 3] ≈ 0.4) && (c_ab[3, 4] ≈ 0.2) && (c_ab[3, 5] ≈ 0.0)
    @test (c_ab[3, 6] ≈ -0.2)
    @test (c_ab[4, 3] ≈ 1.4) && (c_ab[4, 4] ≈ 1.2) && (c_ab[4, 5] ≈ 1.0)
    @test (c_ab[4, 6] ≈ 0.8) && (c_ab[4, 7] ≈ 0.6) && (c_ab[4, 8] ≈ 0.4)
    # Checking decomposition in terms of AC component
    @test (c_ac[3, 3] ≈ 0.1) && (c_ac[3, 4] ≈ 0.3) && (c_ac[3, 5] ≈ 0.5)
    @test (c_ac[3, 6] ≈ 0.7)
    @test (c_ac[4, 3] ≈ 0.1) && (c_ac[4, 4] ≈ 0.3) && (c_ac[4, 5] ≈ 0.5)
    @test (c_ac[4, 6] ≈ 0.7) && (c_ac[4, 7] ≈ 0.9) && (c_ac[4, 8] ≈ 1.1)
    # Checking cells inside the triangle area
    @test all(in_triangle[3, 3:4] .== true)
    in_triangle[3, 3:4] .= false
    @test all(in_triangle[:, :] .== false)
    # Checking the number of cells inside the triangle area
    @test n_cell == 2 * 4

    # Testing for the edge case where the triangle is a line
    # Note that no decomposition can be mathematically made
    a_ind = [16.0, 11.0, 11.0]
    ab_ind = [1.4, 0.7, 0.0]
    ac_ind = [2.8, 1.4, 0.0]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    delta = 0.01
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking there is no cell in the triangle area
    @test all(in_triangle[:, :] .== false)
    # Checking the number of cells inside the triangle area
    @test n_cell == 0

    # Testing for the edge case where the triangle is a point
    # Note that no decomposition can be mathematically made
    a_ind = [16.0, 11.0, 11.0]
    ab_ind = [0.0, 0.0, 0.0]
    ac_ind = [0.0, 0.0, 0.0]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    delta = 0.01
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    # Checking there is no cell in the triangle area
    @test all(in_triangle[:, :] .== false)
    # Checking the number of cells inside the triangle area
    @test n_cell == 0
end

@testset "_calc_triangle_pos" begin
    # Note that the function does not account for the case where
    # the triangle follows a cell border.
    # It is therefore necessary to solve this potential ambiguity
    # before calling the function. As a result, a small increment (1e-8)
    # is added or removed to the input in order to make sure that
    # the input coordinates do not correspond to a cell border.

    # Testing for a simple triangle in the XY plane
    a = [0.0 + 1e-8, 0.0 + 1e-8, 0.0 - 1e-8]
    b = [1.0 - 1e-8, 0.0 + 1e-8, 0.0 - 1e-8]
    c = [0.0 + 1e-8, 1.0 - 1e-8, 0.0 - 1e-8]
    delta = 0.01
    tri_pos = unique(_calc_triangle_pos(a, b, c, delta, grid))
    @test ([11, 11, 11] in tri_pos) && ([12, 11, 11] in tri_pos)
    @test ([14, 11, 11] in tri_pos) && ([13, 11, 11] in tri_pos)
    @test ([15, 11, 11] in tri_pos) && ([16, 11, 11] in tri_pos)
    @test ([17, 11, 11] in tri_pos) && ([18, 11, 11] in tri_pos)
    @test ([20, 11, 11] in tri_pos) && ([19, 11, 11] in tri_pos)
    @test ([21, 11, 11] in tri_pos) && ([11, 12, 11] in tri_pos)
    @test ([12, 12, 11] in tri_pos) && ([13, 12, 11] in tri_pos)
    @test ([15, 12, 11] in tri_pos) && ([14, 12, 11] in tri_pos)
    @test ([16, 12, 11] in tri_pos) && ([17, 12, 11] in tri_pos)
    @test ([18, 12, 11] in tri_pos) && ([19, 12, 11] in tri_pos)
    @test ([11, 13, 11] in tri_pos) && ([20, 12, 11] in tri_pos)
    @test ([12, 13, 11] in tri_pos) && ([13, 13, 11] in tri_pos)
    @test ([14, 13, 11] in tri_pos) && ([15, 13, 11] in tri_pos)
    @test ([17, 13, 11] in tri_pos) && ([16, 13, 11] in tri_pos)
    @test ([18, 13, 11] in tri_pos) && ([19, 13, 11] in tri_pos)
    @test ([11, 14, 11] in tri_pos) && ([12, 14, 11] in tri_pos)
    @test ([14, 14, 11] in tri_pos) && ([13, 14, 11] in tri_pos)
    @test ([15, 14, 11] in tri_pos) && ([16, 14, 11] in tri_pos)
    @test ([17, 14, 11] in tri_pos) && ([18, 14, 11] in tri_pos)
    @test ([12, 15, 11] in tri_pos) && ([11, 15, 11] in tri_pos)
    @test ([13, 15, 11] in tri_pos) && ([14, 15, 11] in tri_pos)
    @test ([15, 15, 11] in tri_pos) && ([16, 15, 11] in tri_pos)
    @test ([11, 16, 11] in tri_pos) && ([17, 15, 11] in tri_pos)
    @test ([12, 16, 11] in tri_pos) && ([13, 16, 11] in tri_pos)
    @test ([14, 16, 11] in tri_pos) && ([15, 16, 11] in tri_pos)
    @test ([11, 17, 11] in tri_pos) && ([16, 16, 11] in tri_pos)
    @test ([12, 17, 11] in tri_pos) && ([13, 17, 11] in tri_pos)
    @test ([14, 17, 11] in tri_pos) && ([15, 17, 11] in tri_pos)
    @test ([12, 18, 11] in tri_pos) && ([11, 18, 11] in tri_pos)
    @test ([13, 18, 11] in tri_pos) && ([14, 18, 11] in tri_pos)
    @test ([11, 19, 11] in tri_pos) && ([12, 19, 11] in tri_pos)
    @test ([11, 20, 11] in tri_pos) && ([13, 19, 11] in tri_pos)
    @test ([12, 20, 11] in tri_pos) && ([11, 21, 11] in tri_pos)
    @test length(tri_pos) == 66

    # Testing that the input order does not influence the results (1)
    tri_pos = unique(_calc_triangle_pos(b, a, c, delta, grid))
    @test ([11, 11, 11] in tri_pos) && ([12, 11, 11] in tri_pos)
    @test ([14, 11, 11] in tri_pos) && ([13, 11, 11] in tri_pos)
    @test ([15, 11, 11] in tri_pos) && ([16, 11, 11] in tri_pos)
    @test ([17, 11, 11] in tri_pos) && ([18, 11, 11] in tri_pos)
    @test ([20, 11, 11] in tri_pos) && ([19, 11, 11] in tri_pos)
    @test ([21, 11, 11] in tri_pos) && ([11, 12, 11] in tri_pos)
    @test ([12, 12, 11] in tri_pos) && ([13, 12, 11] in tri_pos)
    @test ([15, 12, 11] in tri_pos) && ([14, 12, 11] in tri_pos)
    @test ([16, 12, 11] in tri_pos) && ([17, 12, 11] in tri_pos)
    @test ([18, 12, 11] in tri_pos) && ([19, 12, 11] in tri_pos)
    @test ([11, 13, 11] in tri_pos) && ([20, 12, 11] in tri_pos)
    @test ([12, 13, 11] in tri_pos) && ([13, 13, 11] in tri_pos)
    @test ([14, 13, 11] in tri_pos) && ([15, 13, 11] in tri_pos)
    @test ([17, 13, 11] in tri_pos) && ([16, 13, 11] in tri_pos)
    @test ([18, 13, 11] in tri_pos) && ([19, 13, 11] in tri_pos)
    @test ([11, 14, 11] in tri_pos) && ([12, 14, 11] in tri_pos)
    @test ([14, 14, 11] in tri_pos) && ([13, 14, 11] in tri_pos)
    @test ([15, 14, 11] in tri_pos) && ([16, 14, 11] in tri_pos)
    @test ([17, 14, 11] in tri_pos) && ([18, 14, 11] in tri_pos)
    @test ([12, 15, 11] in tri_pos) && ([11, 15, 11] in tri_pos)
    @test ([13, 15, 11] in tri_pos) && ([14, 15, 11] in tri_pos)
    @test ([15, 15, 11] in tri_pos) && ([16, 15, 11] in tri_pos)
    @test ([11, 16, 11] in tri_pos) && ([17, 15, 11] in tri_pos)
    @test ([12, 16, 11] in tri_pos) && ([13, 16, 11] in tri_pos)
    @test ([14, 16, 11] in tri_pos) && ([15, 16, 11] in tri_pos)
    @test ([11, 17, 11] in tri_pos) && ([16, 16, 11] in tri_pos)
    @test ([12, 17, 11] in tri_pos) && ([13, 17, 11] in tri_pos)
    @test ([14, 17, 11] in tri_pos) && ([15, 17, 11] in tri_pos)
    @test ([12, 18, 11] in tri_pos) && ([11, 18, 11] in tri_pos)
    @test ([13, 18, 11] in tri_pos) && ([14, 18, 11] in tri_pos)
    @test ([11, 19, 11] in tri_pos) && ([12, 19, 11] in tri_pos)
    @test ([11, 20, 11] in tri_pos) && ([13, 19, 11] in tri_pos)
    @test ([12, 20, 11] in tri_pos) && ([11, 21, 11] in tri_pos)
    @test length(tri_pos) == 66

    # Testing that the input order does not influence the results (2)
    tri_pos = unique(_calc_triangle_pos(c, a, b, delta, grid))
    @test ([11, 11, 11] in tri_pos) && ([12, 11, 11] in tri_pos)
    @test ([14, 11, 11] in tri_pos) && ([13, 11, 11] in tri_pos)
    @test ([15, 11, 11] in tri_pos) && ([16, 11, 11] in tri_pos)
    @test ([17, 11, 11] in tri_pos) && ([18, 11, 11] in tri_pos)
    @test ([20, 11, 11] in tri_pos) && ([19, 11, 11] in tri_pos)
    @test ([21, 11, 11] in tri_pos) && ([11, 12, 11] in tri_pos)
    @test ([12, 12, 11] in tri_pos) && ([13, 12, 11] in tri_pos)
    @test ([15, 12, 11] in tri_pos) && ([14, 12, 11] in tri_pos)
    @test ([16, 12, 11] in tri_pos) && ([17, 12, 11] in tri_pos)
    @test ([18, 12, 11] in tri_pos) && ([19, 12, 11] in tri_pos)
    @test ([11, 13, 11] in tri_pos) && ([20, 12, 11] in tri_pos)
    @test ([12, 13, 11] in tri_pos) && ([13, 13, 11] in tri_pos)
    @test ([14, 13, 11] in tri_pos) && ([15, 13, 11] in tri_pos)
    @test ([17, 13, 11] in tri_pos) && ([16, 13, 11] in tri_pos)
    @test ([18, 13, 11] in tri_pos) && ([19, 13, 11] in tri_pos)
    @test ([11, 14, 11] in tri_pos) && ([12, 14, 11] in tri_pos)
    @test ([14, 14, 11] in tri_pos) && ([13, 14, 11] in tri_pos)
    @test ([15, 14, 11] in tri_pos) && ([16, 14, 11] in tri_pos)
    @test ([17, 14, 11] in tri_pos) && ([18, 14, 11] in tri_pos)
    @test ([12, 15, 11] in tri_pos) && ([11, 15, 11] in tri_pos)
    @test ([13, 15, 11] in tri_pos) && ([14, 15, 11] in tri_pos)
    @test ([15, 15, 11] in tri_pos) && ([16, 15, 11] in tri_pos)
    @test ([11, 16, 11] in tri_pos) && ([17, 15, 11] in tri_pos)
    @test ([12, 16, 11] in tri_pos) && ([13, 16, 11] in tri_pos)
    @test ([14, 16, 11] in tri_pos) && ([15, 16, 11] in tri_pos)
    @test ([11, 17, 11] in tri_pos) && ([16, 16, 11] in tri_pos)
    @test ([12, 17, 11] in tri_pos) && ([13, 17, 11] in tri_pos)
    @test ([14, 17, 11] in tri_pos) && ([15, 17, 11] in tri_pos)
    @test ([12, 18, 11] in tri_pos) && ([11, 18, 11] in tri_pos)
    @test ([13, 18, 11] in tri_pos) && ([14, 18, 11] in tri_pos)
    @test ([11, 19, 11] in tri_pos) && ([12, 19, 11] in tri_pos)
    @test ([11, 20, 11] in tri_pos) && ([13, 19, 11] in tri_pos)
    @test ([12, 20, 11] in tri_pos) && ([11, 21, 11] in tri_pos)
    @test length(tri_pos) == 66

    # Testing that the input order does not influence the results (3)
    tri_pos = unique(_calc_triangle_pos(a, c, b, delta, grid))
    @test length(tri_pos) == 66
    tri_pos = unique(_calc_triangle_pos(b, c, a, delta, grid))
    @test length(tri_pos) == 66
    tri_pos = unique(_calc_triangle_pos(c, b, a, delta, grid))
    @test length(tri_pos) == 66

    # Testing for a simple triangle in the XZ plane
    a = [0.0 + 1e-8, 0.0 - 1e-8, 0.0 + 1e-8]
    b = [1.0 - 1e-8, 0.0 - 1e-8, 0.0 + 1e-8]
    c = [0.0 + 1e-8, 0.0 - 1e-8, 1.0 - 1e-8]
    delta = 0.01
    tri_pos = unique(_calc_triangle_pos(a, b, c, delta, grid))
    @test ([11, 11, 12] in tri_pos) && ([12, 11, 12] in tri_pos)
    @test ([13, 11, 12] in tri_pos) && ([14, 11, 12] in tri_pos)
    @test ([15, 11, 12] in tri_pos) && ([16, 11, 12] in tri_pos)
    @test ([17, 11, 12] in tri_pos) && ([18, 11, 12] in tri_pos)
    @test ([19, 11, 12] in tri_pos) && ([20, 11, 12] in tri_pos)
    @test ([21, 11, 12] in tri_pos) && ([11, 11, 13] in tri_pos)
    @test ([11, 11, 14] in tri_pos) && ([11, 11, 15] in tri_pos)
    @test ([11, 11, 16] in tri_pos) && ([11, 11, 17] in tri_pos)
    @test ([11, 11, 18] in tri_pos) && ([11, 11, 19] in tri_pos)
    @test ([11, 11, 20] in tri_pos) && ([11, 11, 21] in tri_pos)
    @test ([20, 11, 13] in tri_pos) && ([19, 11, 14] in tri_pos)
    @test ([18, 11, 15] in tri_pos) && ([17, 11, 16] in tri_pos)
    @test ([16, 11, 17] in tri_pos) && ([15, 11, 18] in tri_pos)
    @test ([14, 11, 19] in tri_pos) && ([13, 11, 20] in tri_pos)
    @test ([12, 11, 21] in tri_pos) && ([19, 11, 13] in tri_pos)
    @test ([18, 11, 14] in tri_pos) && ([17, 11, 15] in tri_pos)
    @test ([16, 11, 16] in tri_pos) && ([15, 11, 17] in tri_pos)
    @test ([14, 11, 18] in tri_pos) && ([13, 11, 19] in tri_pos)
    @test ([12, 11, 20] in tri_pos)
    @test length(tri_pos) == 37

    # Testing that the input order does not influence the results
    tri_pos = unique(_calc_triangle_pos(a, c, b, delta, grid))
    @test length(tri_pos) == 37
    tri_pos = unique(_calc_triangle_pos(b, a, c, delta, grid))
    @test length(tri_pos) == 37
    tri_pos = unique(_calc_triangle_pos(b, c, a, delta, grid))
    @test length(tri_pos) == 37
    tri_pos = unique(_calc_triangle_pos(c, a, b, delta, grid))
    @test length(tri_pos) == 37
    tri_pos = unique(_calc_triangle_pos(c, b, a, delta, grid))
    @test length(tri_pos) == 37

    # Testing for a simple triangle in the XYZ plane
    a = [0.5 + 1e-8, 0.0 + 1e-8, 0.5 + 1e-8]
    b = [0.6 - 1e-8, 0.0 + 1e-8, 0.6 - 1e-8]
    c = [0.6 - 1e-8, 0.5 - 1e-8, 0.6 - 1e-8]
    delta = 0.01
    tri_pos = unique(_calc_triangle_pos(a, b, c, delta, grid))
    @test ([16, 11, 17] in tri_pos) && ([17, 11, 17] in tri_pos)
    @test ([16, 12, 17] in tri_pos) && ([17, 12, 17] in tri_pos)
    @test ([16, 13, 17] in tri_pos) && ([17, 13, 17] in tri_pos)
    @test ([17, 14, 17] in tri_pos) && ([17, 15, 17] in tri_pos)
    @test ([17, 16, 17] in tri_pos) && ([16, 14, 17] in tri_pos)
    @test length(tri_pos) == 10

    # Testing that the input order does not influence the results
    tri_pos = unique(_calc_triangle_pos(a, c, b, delta, grid))
    @test length(tri_pos) == 10
    tri_pos = unique(_calc_triangle_pos(b, a, c, delta, grid))
    @test length(tri_pos) == 10
    tri_pos = unique(_calc_triangle_pos(b, c, a, delta, grid))
    @test length(tri_pos) == 10
    tri_pos = unique(_calc_triangle_pos(c, a, b, delta, grid))
    @test length(tri_pos) == 10
    tri_pos = unique(_calc_triangle_pos(c, b, a, delta, grid))
    @test length(tri_pos) == 10

    # Testing for the edge case where the triangle is a line
    a = [0.34 + 1e-8, 0.56 + 1e-8, 0.0 - 1e-8]
    b = [0.74 - 1e-8, 0.97 - 1e-8, 0.0 - 1e-8]
    c = [0.74 - 1e-8, 0.97 - 1e-8, 0.0 - 1e-8]
    delta = 0.01
    tri_pos = unique(_calc_triangle_pos(a, b, c, delta, grid))
    @test ([14, 17, 11] in tri_pos) && ([15, 17, 11] in tri_pos)
    @test ([15, 18, 11] in tri_pos) && ([16, 18, 11] in tri_pos)
    @test ([16, 19, 11] in tri_pos) && ([17, 19, 11] in tri_pos)
    @test ([17, 20, 11] in tri_pos) && ([18, 20, 11] in tri_pos)
    @test ([18, 21, 11] in tri_pos)
    @test length(tri_pos) == 9

    # Testing for the edge case where the triangle is a point
    a = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    b = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    c = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    delta = 0.01
    tri_pos = unique(_calc_triangle_pos(a, b, c, delta, grid))
    @test ([16, 16, 16] in tri_pos)
    @test length(tri_pos) == 1
end

@testset "_init_body!" begin
    # Setting dummy values in body
    out.body[1][5:17, 1:16] .= 1.0
    out.body[2][5:17, 1:16] .= 2.0
    out.body[3][4:10, 13:17] .= 0.0
    out.body[4][4:10, 13:17] .= 2*grid.half_length_z

    # Testing that body is properly reset
    _init_body!(out, grid)
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))
end

@testset "_calc_bucket_pos" begin
    # Setting a dummy bucket geometry in the XZ plane
    bucket.j_pos_init .= Vector{Float64}([0.0, 0.0, 0.0])
    bucket.b_pos_init .= Vector{Float64}([0.5, 0.01, 0.0])
    bucket.t_pos_init .= Vector{Float64}([0.5, 0.0, 0.0])
    ori = angle_to_quat(0.0, 0.0, 0.0, :ZYX)
    position = Vector{Float64}([0.0, 0.0, 0.0])

    # Testing for a bucket in the XZ plane
    bucket_pos  = _calc_bucket_pos(out, position, ori, grid, bucket)
    # Checking the bucket position
    a = [0.5, 0.0, -0.25]
    b = [0.5, 0.0, 0.25]
    c = [0.0, 0.0, 0.25]
    d = [0.0, 0.0, -0.25]
    bucket_pos_exp = unique(_calc_rectangle_pos(a, b, c, d, 0.01, grid), dims=1)
    @test all(in.(bucket_pos_exp, Ref(bucket_pos)))
    @test length(bucket_pos) == length(bucket_pos_exp)

    # Setting a dummy bucket geometry in the XY plane
    bucket.j_pos_init .= Vector{Float64}([0.0, 0.0, 0.0])
    bucket.b_pos_init .= Vector{Float64}([0.5, 0.0, -0.01])
    bucket.t_pos_init .= Vector{Float64}([0.5, 0.0, 0.0])
    ori = angle_to_quat(0.0, 0.0, 0.0, :ZYX)
    position = Vector{Float64}([0.0, 0.0, 0.0])

    # Testing for a bucket in the XY plane
    bucket_pos = _calc_bucket_pos(out, position, ori, grid, bucket)
    # Checking the bucket position
    a = [0.5 - 1e-8, -0.25 + 1e-8, 0.0 - 1e-8]
    b = [0.5 - 1e-8,  0.25 - 1e-8, 0.0 - 1e-8]
    c = [0.0 + 1e-8,  0.25 - 1e-8, 0.0 - 1e-8]
    d = [0.0 + 1e-8, -0.25 + 1e-8, 0.0 - 1e-8]
    bucket_pos_exp = unique(_calc_rectangle_pos(a, b, c, d, 0.01, grid), dims=1)
    @test all(in.(bucket_pos_exp, Ref(bucket_pos)))
    @test length(bucket_pos) == length(bucket_pos_exp)

    # Setting a dummy bucket geometry
    bucket.j_pos_init .= Vector{Float64}([0.0, 0.0, 0.0])
    bucket.b_pos_init .= Vector{Float64}([0.0, 0.0, -0.5])
    bucket.t_pos_init .= Vector{Float64}([0.5, 0.0, -0.5])
    ori = angle_to_quat(0.0, -pi / 2, 0.0, :ZYX)
    position = Vector{Float64}([0.0, 0.0, -0.1])
    j_r_pos = [ 0.0 - 1e-8, -0.25 + 1e-8, -0.1 - 1e-8]
    j_l_pos = [ 0.0 - 1e-8,  0.25 - 1e-8, -0.1 - 1e-8]
    b_r_pos = [-0.5 + 1e-8, -0.25 + 1e-8, -0.1 - 1e-8]
    b_l_pos = [-0.5 + 1e-8,  0.25 - 1e-8, -0.1 - 1e-8]
    t_r_pos = [-0.5 + 1e-8, -0.25 + 1e-8, -0.6 + 1e-8]
    t_l_pos = [-0.5 + 1e-8,  0.25 - 1e-8, -0.6 + 1e-8]

    # Testing for a bucket in a dummy position
    bucket_pos = _calc_bucket_pos(out, position, ori, grid, bucket)
    # Checking that the bucket base position is included in the bucket position
    base_pos_exp = unique(
        _calc_rectangle_pos(b_l_pos, b_r_pos, t_r_pos, t_l_pos, 0.01, grid), dims=1
    )
    @test all(in.(base_pos_exp, Ref(bucket_pos)))
    # Checking that the bucket back position is included in the bucket position
    back_pos_exp = unique(
        _calc_rectangle_pos(j_l_pos, j_r_pos, b_r_pos, b_l_pos, 0.01, grid), dims=1
   )
    @test all(in.(back_pos_exp, Ref(bucket_pos)))
    # Checking that the bucket left side position is included in the bucket position
    left_side_pos_exp = unique(
        _calc_triangle_pos(j_l_pos, b_l_pos, t_l_pos, 0.01, grid), dims=1
    )
    @test all(in.(left_side_pos_exp, Ref(bucket_pos)))
    # Checking that the bucket right side position is included in the bucket position
    right_side_pos_exp = unique(
        _calc_triangle_pos(j_r_pos, b_r_pos, t_r_pos, 0.01, grid), dims=1
    )
    @test all(in.(right_side_pos_exp, Ref(bucket_pos)))
    # Checking the length of the bucket position
    bucket_pos_exp = unique(
        [base_pos_exp; back_pos_exp; right_side_pos_exp; left_side_pos_exp], dims=1
    )
    @test length(bucket_pos) == length(bucket_pos_exp)
end
