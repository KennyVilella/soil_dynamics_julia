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
@testset "_calc_line_pos" begin
    function _check_results(a, b, line_pos_exp, grid)
        # Checking first input order
        line_pos = sort(unique(_calc_line_pos(a, b, grid)))
        @test (line_pos == line_pos_exp)
        # Checking second input order
        line_pos = sort(unique(_calc_line_pos(b, a, grid)))
        @test (line_pos == line_pos_exp)
    end

    # Test: BP-CL-1
    a = [0.0 + 1e-8, 0.0 - 1e-8, -0.06 + 1e-8]
    b = [1.0 - 1e-8, 0.0 - 1e-8,  0.0  - 1e-8]
    line_pos_exp = [
        [11, 11, 10], [12, 11, 10], [13, 11, 10], [14, 11, 10], [15, 11, 10],
        [16, 11, 10], [17, 11, 10], [18, 11, 10], [19, 11, 10], [20, 11, 10],
        [21, 11, 10]]
    _check_results(a, b, line_pos_exp, grid)

    # Test: BP-CL-2
    a = [0.04 + 1e-8,  0.04 - 1e-8, -0.09 + 1e-8]
    b = [1.04 - 1e-8, -0.04 + 1e-8,  0.0  - 1e-8]
    line_pos_exp = [
        [11, 11, 10], [12, 11, 10], [13, 11, 10], [14, 11, 10], [15, 11, 10],
        [16, 11, 10], [17, 11, 10], [18, 11, 10], [19, 11, 10], [20, 11, 10],
        [21, 11, 10]]
    _check_results(a, b, line_pos_exp, grid)

    # Test: BP-CL-3
    a = [0.0 - 1e-8, 0.0 + 1e-8, 0.0 - 1e-8]
    b = [0.0 - 1e-8, 1.0 - 1e-8, 0.0 - 1e-8]
    line_pos_exp = [
        [11, 11, 10], [11, 12, 10], [11, 13, 10], [11, 14, 10], [11, 15, 10],
        [11, 16, 10], [11, 17, 10], [11, 18, 10], [11, 19, 10], [11, 20, 10],
        [11, 21, 10]]
    _check_results(a, b, line_pos_exp, grid)

    # Test: BP-CL-4
    a = [0.34 + 1e-8, 0.56 + 1e-8, 0.0 - 1e-8]
    b = [0.74 - 1e-8, 0.97 - 1e-8, 0.0 - 1e-8]
    line_pos_exp = [
        [14, 17, 10], [15, 17, 10], [15, 18, 10], [16, 18, 10], [16, 19, 10],
        [17, 19, 10], [17, 20, 10], [18, 20, 10], [18, 21, 10]]
    _check_results(a, b, line_pos_exp, grid)

    # Test: BP-CL-5
    a = [0.34 + 1e-8, 0.0 - 1e-8, 0.56 + 1e-8]
    b = [0.74 - 1e-8, 0.0 - 1e-8, 0.97 - 1e-8]
    line_pos_exp = [
        [14, 11, 16], [15, 11, 16], [15, 11, 17], [16, 11, 17], [16, 11, 18],
        [17, 11, 18], [17, 11, 19], [18, 11, 19], [18, 11, 20]]
    _check_results(a, b, line_pos_exp, grid)

    # Test: BP-CL-6
    a = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    b = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    line_pos_exp = [[16, 16, 15]]
    _check_results(a, b, line_pos_exp, grid)
    a = [0.55 - 1e-8, 0.55 - 1e-8, 0.55 - 1e-8]
    b = [0.55 - 1e-8, 0.55 - 1e-8, 0.55 - 1e-8]
    line_pos_exp = [[16, 16, 16]]
    _check_results(a, b, line_pos_exp, grid)
end

@testset "_decompose_vector_rectangle" begin
    # Test: BP-DVR-1
    a_ind = [11.0, 11.0, 11.0]
    ab_ind = [5.0, 0.0, 0.0]
    ad_ind = [0.0, 5.0, 0.0]
    area_min_x = 9
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    c_ab_exp = [
        -0.3 -0.3 -0.3 -0.3 -0.3 -0.3 -0.3 -0.3
        -0.1 -0.1 -0.1 -0.1 -0.1 -0.1 -0.1 -0.1
         0.1  0.1  0.1  0.1  0.1  0.1  0.1  0.1
         0.3  0.3  0.3  0.3  0.3  0.3  0.3  0.3
         0.5  0.5  0.5  0.5  0.5  0.5  0.5  0.5
         0.7  0.7  0.7  0.7  0.7  0.7  0.7  0.7
         0.9  0.9  0.9  0.9  0.9  0.9  0.9  0.9
         1.1  1.1  1.1  1.1  1.1  1.1  1.1  1.1]
    c_ad_exp = [
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1]
    @test (c_ab ≈ c_ab_exp)
    @test (c_ad ≈ c_ad_exp)
    @test all(in_rectangle[3:7, 3:7] .== true)
    in_rectangle[3:7, 3:7] .= false
    @test all(in_rectangle[:, :] .== false)
    @test n_cell == 25 * 4

    # Test: BP-DVR-2
    a_ind = [10.7, 11.3, 5.3]
    ab_ind = [5.7, 0.0, 0.0]
    ad_ind = [0.0, 4.7, 0.0]
    area_min_x = 9
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    c_ab_exp = [
        -1.2 -1.2 -1.2 -1.2 -1.2 -1.2 -1.2 -1.2
        -0.2 -0.2 -0.2 -0.2 -0.2 -0.2 -0.2 -0.2
         0.8  0.8  0.8  0.8  0.8  0.8  0.8  0.8
         1.8  1.8  1.8  1.8  1.8  1.8  1.8  1.8
         2.8  2.8  2.8  2.8  2.8  2.8  2.8  2.8
         3.8  3.8  3.8  3.8  3.8  3.8  3.8  3.8
         4.8  4.8  4.8  4.8  4.8  4.8  4.8  4.8
         5.8  5.8  5.8  5.8  5.8  5.8  5.8  5.8]
    c_ad_exp = [
        -1.8 -0.8 0.2 1.2 2.2 3.2 4.2 5.2
        -1.8 -0.8 0.2 1.2 2.2 3.2 4.2 5.2
        -1.8 -0.8 0.2 1.2 2.2 3.2 4.2 5.2
        -1.8 -0.8 0.2 1.2 2.2 3.2 4.2 5.2
        -1.8 -0.8 0.2 1.2 2.2 3.2 4.2 5.2
        -1.8 -0.8 0.2 1.2 2.2 3.2 4.2 5.2
        -1.8 -0.8 0.2 1.2 2.2 3.2 4.2 5.2
        -1.8 -0.8 0.2 1.2 2.2 3.2 4.2 5.2]
    @test (c_ab ≈ c_ab_exp ./ 5.7)
    @test (c_ad ≈ c_ad_exp ./ 4.7)
    @test all(in_rectangle[3:7, 3:7] .== true)
    in_rectangle[3:7, 3:7] .= false
    @test all(in_rectangle[:, :] .== false)
    @test n_cell == 25 * 4

    # Test: BP-DVR-3
    a_ind = [16.0, 11.0, 6.0]
    ab_ind = [1.0, 0.0, 2.4]
    ad_ind = [0.0, 5.0, -0.3]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    c_ab_exp = [
        -1.5 -1.5 -1.5 -1.5 -1.5 -1.5 -1.5 -1.5
        -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5
         0.5  0.5  0.5  0.5  0.5  0.5  0.5  0.5
         1.5  1.5  1.5  1.5  1.5  1.5  1.5  1.5
         2.5  2.5  2.5  2.5  2.5  2.5  2.5  2.5
         3.5  3.5  3.5  3.5  3.5  3.5  3.5  3.5
         4.5  4.5  4.5  4.5  4.5  4.5  4.5  4.5
         5.5  5.5  5.5  5.5  5.5  5.5  5.5  5.5]
    c_ad_exp = [
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1]
    @test (c_ab ≈ c_ab_exp)
    @test (c_ad ≈ c_ad_exp)
    @test all(in_rectangle[3, 3:7] .== true)
    in_rectangle[3, 3:7] .= false
    @test all(in_rectangle[:, :] .== false)
    @test n_cell == 5 * 4

    # Test: BP-DVR-4
    a_ind = [15.2, 11.3, 6.0]
    ab_ind = [2.3, 1.2, 2.4]
    ad_ind = [4.6, 2.4, -0.3]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    @test all(in_rectangle[:, :] .== false)
    @test n_cell == 0

    # Test: BP-DVR-5
    a_ind = [15.2, 11.3, 6.0]
    ab_ind = [0.0, 0.0, 0.0]
    ad_ind = [0.0, 0.0, 0.0]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    @test all(in_rectangle[:, :] .== false)
    @test n_cell == 0
end

@testset "_decompose_vector_triangle" begin
    # Test: BP-DVT-1
    a_ind = [11.0, 11.0, 11.0]
    ab_ind = [10.0, 0.0, 0.0]
    ac_ind = [0.0, 10.0, 0.0]
    area_min_x = 10
    area_min_y = 10
    area_length_x = 11
    area_length_y = 10
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    in_tri_exp = [
        false false false false false false false false false false
        false true  true  true  true  true  true  true  true  true
        false true  true  true  true  true  true  true  true  false
        false true  true  true  true  true  true  true  false false
        false true  true  true  true  true  true  false false false
        false true  true  true  true  true  false false false false
        false true  true  true  true  false false false false false
        false true  true  true  false false false false false false
        false true  true  false false false false false false false
        false true  false false false false false false false false
        false false false false false false false false false false]
    c_ab_exp = [
        -0.05 -0.05 -0.05 -0.05 -0.05 -0.05 -0.05 -0.05 -0.05 -0.05
         0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05
         0.15  0.15  0.15  0.15  0.15  0.15  0.15  0.15  0.15  0.15
         0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25
         0.35  0.35  0.35  0.35  0.35  0.35  0.35  0.35  0.35  0.35
         0.45  0.45  0.45  0.45  0.45  0.45  0.45  0.45  0.45  0.45
         0.55  0.55  0.55  0.55  0.55  0.55  0.55  0.55  0.55  0.55
         0.65  0.65  0.65  0.65  0.65  0.65  0.65  0.65  0.65  0.65
         0.75  0.75  0.75  0.75  0.75  0.75  0.75  0.75  0.75  0.75
         0.85  0.85  0.85  0.85  0.85  0.85  0.85  0.85  0.85  0.85
         0.95  0.95  0.95  0.95  0.95  0.95  0.95  0.95  0.95  0.95]
    c_ac_exp = [
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85
        -0.05 0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85]
    @test (c_ab ≈ c_ab_exp)
    @test (c_ac ≈ c_ac_exp)
    @test (in_triangle == in_tri_exp)
    @test n_cell == 45 * 4

    # Test: BP-DVT-2
    a_ind = [10.9, 10.7, 11.0]
    ab_ind = [9.7, 0.0, 0.0]
    ac_ind = [0.0, 10.4, 0.0]
    area_min_x = 10
    area_min_y = 10
    area_length_x = 11
    area_length_y = 10
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    in_tri_exp = [
        false false false false false false false false false false
        false true  true  true  true  true  true  true  true  true
        false true  true  true  true  true  true  true  true  false
        false true  true  true  true  true  true  true  false false
        false true  true  true  true  true  true  false false false
        false true  true  true  true  true  false false false false
        false true  true  true  true  false false false false false
        false true  true  true  false false false false false false
        false true  true  false false false false false false false
        false true  false false false false false false false false
        false false false false false false false false false false]
    c_ab_exp = [
        -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4
        0.6  0.6  0.6  0.6  0.6  0.6  0.6  0.6  0.6  0.6
        1.6  1.6  1.6  1.6  1.6  1.6  1.6  1.6  1.6  1.6
        2.6  2.6  2.6  2.6  2.6  2.6  2.6  2.6  2.6  2.6
        3.6  3.6  3.6  3.6  3.6  3.6  3.6  3.6  3.6  3.6
        4.6  4.6  4.6  4.6  4.6  4.6  4.6  4.6  4.6  4.6
        5.6  5.6  5.6  5.6  5.6  5.6  5.6  5.6  5.6  5.6
        6.6  6.6  6.6  6.6  6.6  6.6  6.6  6.6  6.6  6.6
        7.6  7.6  7.6  7.6  7.6  7.6  7.6  7.6  7.6  7.6
        8.6  8.6  8.6  8.6  8.6  8.6  8.6  8.6  8.6  8.6
        9.6  9.6  9.6  9.6  9.6  9.6  9.6  9.6  9.6  9.6]
    c_ac_exp = [
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8
        -0.2 0.8 1.8 2.8 3.8 4.8 5.8 6.8 7.8 8.8]
    @test (c_ab ≈ c_ab_exp ./ 9.7)
    @test (c_ac ≈ c_ac_exp ./ 10.4)
    @test (in_triangle == in_tri_exp)
    @test n_cell == 45 * 4

    # Test: BP-DVT-3
    a_ind = [16.0, 11.0, 11.0]
    ab_ind = [1.0, 0.0, 0.0]
    ac_ind = [1.0, 5.0, 0.0]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    in_tri_exp = [
        false false false false false false false false
        false false false false false false false false
        false false true  true  false false false false
        false false false false false false false false
        false false false false false false false false
        false false false false false false false false
        false false false false false false false false
        false false false false false false false false]
    c_ab_exp = [
        -1.2 -1.4 -1.6 -1.8 -2.0 -2.2 -2.4 -2.6
        -0.2 -0.4 -0.6 -0.8 -1.0 -1.2 -1.4 -1.6
         0.8  0.6  0.4  0.2  0.0 -0.2 -0.4 -0.6
         1.8  1.6  1.4  1.2  1.0  0.8  0.6  0.4
         2.8  2.6  2.4  2.2  2.0  1.8  1.6  1.4
         3.8  3.6  3.4  3.2  3.0  2.8  2.6  2.4
         4.8  4.6  4.4  4.2  4.0  3.8  3.6  3.4
         5.8  5.6  5.4  5.2  5.0  4.8  4.6  4.4]
    c_ac_exp = [
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1
        -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1]
    @test (c_ab ≈ c_ab_exp)
    @test (c_ac ≈ c_ac_exp)
    @test (in_triangle == in_tri_exp)
    @test n_cell == 2 * 4

    # Test: BP-DVT-4
    a_ind = [16.0, 11.0, 11.0]
    ab_ind = [1.4, 0.7, 0.0]
    ac_ind = [2.8, 1.4, 0.0]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    @test all(in_triangle[:, :] .== false)
    @test n_cell == 0

    # Test: BP-DVT-5
    a_ind = [16.0, 11.0, 11.0]
    ab_ind = [0.0, 0.0, 0.0]
    ac_ind = [0.0, 0.0, 0.0]
    area_min_x = 14
    area_min_y = 9
    area_length_x = 8
    area_length_y = 8
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
    )
    @test all(in_triangle[:, :] .== false)
    @test n_cell == 0
end

@testset "_calc_rectangle_pos" begin
    function _check_results(a, b, c, d, rect_pos_exp, grid)
        # Checking first input order
        rect_pos = sort(unique(_calc_rectangle_pos(a, b, c, d, grid)))
        @test (rect_pos == rect_pos_exp)
        # Checking second input order
        rect_pos = sort(unique(_calc_rectangle_pos(a, d, c, b, grid)))
        @test (rect_pos == rect_pos_exp)
        # Checking third input order
        rect_pos = sort(unique(_calc_rectangle_pos(c, b, a, d, grid)))
        @test (rect_pos == rect_pos_exp)
        # Checking fourth input order
        rect_pos = sort(unique(_calc_rectangle_pos(b, c, d, a, grid)))
        @test (rect_pos == rect_pos_exp)
        # Checking fifth input order
        rect_pos = sort(unique(_calc_rectangle_pos(c, d, a, b, grid)))
        @test (rect_pos == rect_pos_exp)
        # Checking sixth input order
        rect_pos = sort(unique(_calc_rectangle_pos(d, a, b, c, grid)))
        @test (rect_pos == rect_pos_exp)
        # Checking seventh input order
        rect_pos = sort(unique(_calc_rectangle_pos(d, c, b, a, grid)))
        @test (rect_pos == rect_pos_exp)
        # Checking eighth input order
        rect_pos = sort(unique(_calc_rectangle_pos(b, a, d, c, grid)))
        @test (rect_pos == rect_pos_exp)
    end

    # Test: BP-CR-1
    a = [0.0 + 1e-8, 0.0 + 1e-8, 0.0 - 1e-8]
    b = [0.5 - 1e-8, 0.0 + 1e-8, 0.0 - 1e-8]
    c = [0.5 - 1e-8, 0.5 - 1e-8, 0.0 - 1e-8]
    d = [0.0 + 1e-8, 0.5 - 1e-8, 0.0 - 1e-8]
    rect_pos_exp = [
        [11, 11, 10], [11, 12, 10], [11, 13, 10], [11, 14, 10], [11, 15, 10],
        [11, 16, 10], [12, 11, 10], [12, 12, 10], [12, 13, 10], [12, 14, 10],
        [12, 15, 10], [12, 16, 10], [13, 11, 10], [13, 12, 10], [13, 13, 10],
        [13, 14, 10], [13, 15, 10], [13, 16, 10], [14, 11, 10], [14, 12, 10],
        [14, 13, 10], [14, 14, 10], [14, 15, 10], [14, 16, 10], [15, 11, 10],
        [15, 12, 10], [15, 13, 10], [15, 14, 10], [15, 15, 10], [15, 16, 10],
        [16, 11, 10], [16, 12, 10], [16, 13, 10], [16, 14, 10], [16, 15, 10],
        [16, 16, 10]]
    _check_results(a, b, c, d, rect_pos_exp, grid)

    # Test: BP-CR-2
    a = [0.0 + 1e-8, 0.0 - 1e-8, 0.0 + 1e-8]
    b = [0.5 - 1e-8, 0.0 - 1e-8, 0.0 + 1e-8]
    c = [0.5 - 1e-8, 0.0 - 1e-8, 0.5 - 1e-8]
    d = [0.0 + 1e-8, 0.0 - 1e-8, 0.5 - 1e-8]
    rect_pos_exp = [
        [11, 11, 11], [11, 11, 12], [11, 11, 13], [11, 11, 14], [11, 11, 15],
        [12, 11, 11], [12, 11, 15], [13, 11, 11], [13, 11, 15], [14, 11, 11],
        [14, 11, 15], [15, 11, 11], [15, 11, 15], [16, 11, 11], [16, 11, 12],
        [16, 11, 13], [16, 11, 14], [16, 11, 15]]
    _check_results(a, b, c, d, rect_pos_exp, grid)

    # Test: BP-CR-3
    a = [0.5 + 1e-8, 0.0 + 1e-8, 0.5 + 1e-8]
    b = [0.6 - 1e-8, 0.0 + 1e-8, 0.6 - 1e-8]
    c = [0.6 - 1e-8, 0.5 - 1e-8, 0.6 - 1e-8]
    d = [0.5 + 1e-8, 0.5 - 1e-8, 0.5 + 1e-8]
    rect_pos_exp = [
        [16, 11, 16], [16, 12, 16], [16, 13, 16], [16, 14, 16], [16, 15, 16],
        [16, 16, 16], [17, 11, 16], [17, 12, 16], [17, 13, 16], [17, 14, 16],
        [17, 15, 16], [17, 16, 16]]
    _check_results(a, b, c, d, rect_pos_exp, grid)

    # Test: BP-CR-4
    a = [0.34 + 1e-8, 0.57 + 1e-8, 0.0 - 1e-8]
    b = [0.74 - 1e-8, 0.97 - 1e-8, 0.0 - 1e-8]
    c = [0.44 + 1e-8, 0.67 + 1e-8, 0.0 - 1e-8]
    d = [0.64 - 1e-8, 0.87 - 1e-8, 0.0 - 1e-8]
    rect_pos_exp = [
        [14, 17, 10], [15, 17, 10], [15, 18, 10], [16, 18, 10], [16, 19, 10],
        [17, 19, 10], [17, 20, 10], [18, 20, 10], [18, 21, 10]]
    _check_results(a, b, c, d, rect_pos_exp, grid)

    # Test: BP-CR-5
    a = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    b = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    c = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    d = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    rect_pos_exp = [[16, 16, 15]]
    _check_results(a, b, c, d, rect_pos_exp, grid)
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
    tri_pos = unique(_calc_triangle_pos(a, b, c, grid))
    @test ([11, 11, 11] in tri_pos) && ([12, 11, 11] in tri_pos)
    @test ([14, 11, 11] in tri_pos) && ([13, 11, 11] in tri_pos)
    @test ([15, 11, 11] in tri_pos) && ([16, 11, 11] in tri_pos)
    @test ([17, 11, 11] in tri_pos) && ([18, 11, 11] in tri_pos)
    @test ([20, 11, 11] in tri_pos) && ([19, 11, 11] in tri_pos)
    #@test ([21, 11, 11] in tri_pos) && ([11, 12, 11] in tri_pos)
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
    #@test ([12, 20, 11] in tri_pos) && ([11, 21, 11] in tri_pos)
    #@test length(tri_pos) == 66

    # Testing that the input order does not influence the results (1)
    tri_pos = unique(_calc_triangle_pos(b, a, c, grid))
    @test ([11, 11, 11] in tri_pos) && ([12, 11, 11] in tri_pos)
    @test ([14, 11, 11] in tri_pos) && ([13, 11, 11] in tri_pos)
    @test ([15, 11, 11] in tri_pos) && ([16, 11, 11] in tri_pos)
    @test ([17, 11, 11] in tri_pos) && ([18, 11, 11] in tri_pos)
    @test ([20, 11, 11] in tri_pos) && ([19, 11, 11] in tri_pos)
    #@test ([21, 11, 11] in tri_pos) && ([11, 12, 11] in tri_pos)
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
    #@test ([12, 20, 11] in tri_pos) && ([11, 21, 11] in tri_pos)
    #@test length(tri_pos) == 66

    # Testing that the input order does not influence the results (2)
    tri_pos = unique(_calc_triangle_pos(c, a, b, grid))
    @test ([11, 11, 11] in tri_pos) && ([12, 11, 11] in tri_pos)
    @test ([14, 11, 11] in tri_pos) && ([13, 11, 11] in tri_pos)
    @test ([15, 11, 11] in tri_pos) && ([16, 11, 11] in tri_pos)
    @test ([17, 11, 11] in tri_pos) && ([18, 11, 11] in tri_pos)
    @test ([20, 11, 11] in tri_pos) && ([19, 11, 11] in tri_pos)
    #@test ([21, 11, 11] in tri_pos) && ([11, 12, 11] in tri_pos)
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
    #@test ([12, 20, 11] in tri_pos) && ([11, 21, 11] in tri_pos)
    #@test length(tri_pos) == 66

    # Testing that the input order does not influence the results (3)
    tri_pos = unique(_calc_triangle_pos(a, c, b, grid))
    #@test length(tri_pos) == 66
    tri_pos = unique(_calc_triangle_pos(b, c, a, grid))
    #@test length(tri_pos) == 66
    tri_pos = unique(_calc_triangle_pos(c, b, a, grid))
    #@test length(tri_pos) == 66

    # Testing for a simple triangle in the XZ plane
    a = [0.0 + 1e-8, 0.0 - 1e-8, 0.0 + 1e-8]
    b = [1.0 - 1e-8, 0.0 - 1e-8, 0.0 + 1e-8]
    c = [0.0 + 1e-8, 0.0 - 1e-8, 1.0 - 1e-8]
    tri_pos = unique(_calc_triangle_pos(a, b, c, grid))
    #@test ([11, 11, 12] in tri_pos) && ([12, 11, 12] in tri_pos)
    #@test ([13, 11, 12] in tri_pos) && ([14, 11, 12] in tri_pos)
    #@test ([15, 11, 12] in tri_pos) && ([16, 11, 12] in tri_pos)
    #@test ([17, 11, 12] in tri_pos) && ([18, 11, 12] in tri_pos)
    @test ([19, 11, 12] in tri_pos) && ([20, 11, 12] in tri_pos)
    #@test ([21, 11, 12] in tri_pos) && ([11, 11, 13] in tri_pos)
    @test ([11, 11, 14] in tri_pos) && ([11, 11, 15] in tri_pos)
    @test ([11, 11, 16] in tri_pos) && ([11, 11, 17] in tri_pos)
    @test ([11, 11, 18] in tri_pos) && ([11, 11, 19] in tri_pos)
    #@test ([11, 11, 20] in tri_pos) && ([11, 11, 21] in tri_pos)
    #@test ([20, 11, 13] in tri_pos) && ([19, 11, 14] in tri_pos)
    #@test ([18, 11, 15] in tri_pos) && ([17, 11, 16] in tri_pos)
    #@test ([16, 11, 17] in tri_pos) && ([15, 11, 18] in tri_pos)
    #@test ([14, 11, 19] in tri_pos) && ([13, 11, 20] in tri_pos)
    #@test ([12, 11, 21] in tri_pos) && ([19, 11, 13] in tri_pos)
    @test ([18, 11, 14] in tri_pos) && ([17, 11, 15] in tri_pos)
    @test ([16, 11, 16] in tri_pos) && ([15, 11, 17] in tri_pos)
    @test ([14, 11, 18] in tri_pos) && ([13, 11, 19] in tri_pos)
    @test ([12, 11, 20] in tri_pos)
    @test length(tri_pos) == 37

    # Testing that the input order does not influence the results
    tri_pos = unique(_calc_triangle_pos(a, c, b, grid))
    @test length(tri_pos) == 37
    tri_pos = unique(_calc_triangle_pos(b, a, c, grid))
    @test length(tri_pos) == 37
    tri_pos = unique(_calc_triangle_pos(b, c, a, grid))
    @test length(tri_pos) == 37
    tri_pos = unique(_calc_triangle_pos(c, a, b, grid))
    @test length(tri_pos) == 37
    tri_pos = unique(_calc_triangle_pos(c, b, a, grid))
    @test length(tri_pos) == 37

    # Testing for a simple triangle in the XYZ plane
    a = [0.5 + 1e-8, 0.0 + 1e-8, 0.5 + 1e-8]
    b = [0.6 - 1e-8, 0.0 + 1e-8, 0.6 - 1e-8]
    c = [0.6 - 1e-8, 0.5 - 1e-8, 0.6 - 1e-8]
    tri_pos = unique(_calc_triangle_pos(a, b, c, grid))
    @test ([16, 11, 17] in tri_pos) && ([17, 11, 17] in tri_pos)
    @test ([16, 12, 17] in tri_pos) && ([17, 12, 17] in tri_pos)
    @test ([16, 13, 17] in tri_pos) && ([17, 13, 17] in tri_pos)
    #@test ([17, 14, 17] in tri_pos) && ([17, 15, 17] in tri_pos)
    #@test ([17, 16, 17] in tri_pos) && ([16, 14, 17] in tri_pos)
    #@test length(tri_pos) == 10

    # Testing that the input order does not influence the results
    tri_pos = unique(_calc_triangle_pos(a, c, b, grid))
    #@test length(tri_pos) == 10
    tri_pos = unique(_calc_triangle_pos(b, a, c, grid))
    #@test length(tri_pos) == 10
    tri_pos = unique(_calc_triangle_pos(b, c, a, grid))
    #@test length(tri_pos) == 10
    tri_pos = unique(_calc_triangle_pos(c, a, b, grid))
    #@test length(tri_pos) == 10
    tri_pos = unique(_calc_triangle_pos(c, b, a, grid))
    #@test length(tri_pos) == 10

    # Testing for the edge case where the triangle is a line
    a = [0.34 + 1e-8, 0.56 + 1e-8, 0.0 - 1e-8]
    b = [0.74 - 1e-8, 0.97 - 1e-8, 0.0 - 1e-8]
    c = [0.74 - 1e-8, 0.97 - 1e-8, 0.0 - 1e-8]
    tri_pos = unique(_calc_triangle_pos(a, b, c, grid))
    #@test ([14, 17, 11] in tri_pos) && ([15, 17, 11] in tri_pos)
    #@test ([15, 18, 11] in tri_pos) && ([16, 18, 11] in tri_pos)
    #@test ([16, 19, 11] in tri_pos) && ([17, 19, 11] in tri_pos)
    #@test ([17, 20, 11] in tri_pos) && ([18, 20, 11] in tri_pos)
    #@test ([18, 21, 11] in tri_pos)
    @test length(tri_pos) == 9

    # Testing for the edge case where the triangle is a point
    a = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    b = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    c = [0.5 - 1e-8, 0.5 - 1e-8, 0.5 - 1e-8]
    tri_pos = unique(_calc_triangle_pos(a, b, c, grid))
    #@test ([16, 16, 16] in tri_pos)
    @test length(tri_pos) == 1
end

@testset "_include_new_body_pos!" begin
    # Setting a dummy body
    _init_sparse_array!(out.body, grid)
    out.body[1][7, 10] = 1.0
    out.body[2][7, 10] = 2.0
    out.body[1][9, 12] = 0.5
    out.body[2][9, 12] = 0.6
    out.body[3][9, 12] = 0.8
    out.body[4][9, 12] = 0.9
    out.body[3][10, 9] = 1.2
    out.body[4][10, 9] = 1.4

    # Testing to add a position when there is no existing position
    _include_new_body_pos!(out, 6, 6, 0.1, 0.2)
    @test (out.body[1][6, 6] ≈ 0.1) && (out.body[2][6, 6] ≈ 0.2)

    # Testing to add a position distinct from existing positions (1)
    _include_new_body_pos!(out, 7, 10, 0.1, 0.2)
    @test (out.body[1][7, 10] ≈ 1.0) && (out.body[2][7, 10] ≈ 2.0)
    @test (out.body[3][7, 10] ≈ 0.1) && (out.body[4][7, 10] ≈ 0.2)

    # Testing to add a position distinct from existing positions (2)
    _include_new_body_pos!(out, 10, 9, 1.6, 1.7)
    @test (out.body[1][10, 9] ≈ 1.6) && (out.body[2][10, 9] ≈ 1.7)
    @test (out.body[3][10, 9] ≈ 1.2) && (out.body[4][10, 9] ≈ 1.4)

    # Testing to add a position overlapping with an existing position (1)
    _include_new_body_pos!(out, 7, 10, 0.2, 0.4)
    @test (out.body[1][7, 10] ≈ 1.0) && (out.body[2][7, 10] ≈ 2.0)
    @test (out.body[3][7, 10] ≈ 0.1) && (out.body[4][7, 10] ≈ 0.4)

    # Testing to add a position overlapping with an existing position (2)
    _include_new_body_pos!(out, 7, 10, -0.2, 0.1)
    @test (out.body[1][7, 10] ≈ 1.0) && (out.body[2][7, 10] ≈ 2.0)
    @test (out.body[3][7, 10] ≈ -0.2) && (out.body[4][7, 10] ≈ 0.4)

    # Testing to add a position overlapping with an existing position (3)
    _include_new_body_pos!(out, 7, 10, 2.0, 2.5)
    @test (out.body[1][7, 10] ≈ 1.0) && (out.body[2][7, 10] ≈ 2.5)
    @test (out.body[3][7, 10] ≈ -0.2) && (out.body[4][7, 10] ≈ 0.4)

    # Testing to add a position overlapping with an existing position (4)
    _include_new_body_pos!(out, 7, 10, 0.7, 1.0)
    @test (out.body[1][7, 10] ≈ 0.7) && (out.body[2][7, 10] ≈ 2.5)
    @test (out.body[3][7, 10] ≈ -0.2) && (out.body[4][7, 10] ≈ 0.4)

    # Testing to add a position overlapping with an existing position (5)
    _include_new_body_pos!(out, 7, 10, -0.4, 0.6)
    @test (out.body[1][7, 10] ≈ 0.7) && (out.body[2][7, 10] ≈ 2.5)
    @test (out.body[3][7, 10] ≈ -0.4) && (out.body[4][7, 10] ≈ 0.6)

    # Testing to add a position overlapping with the two existing positions
    _include_new_body_pos!(out, 9, 12, 0.6, 0.8)
    @test (out.body[1][9, 12] ≈ 0.5) && (out.body[2][9, 12] ≈ 0.9)

    # Testing to add a position within an existing position (1)
    _include_new_body_pos!(out, 7, 10, 0.9, 2.5)
    @test (out.body[1][7, 10] ≈ 0.7) && (out.body[2][7, 10] ≈ 2.5)
    @test (out.body[3][7, 10] ≈ -0.4) && (out.body[4][7, 10] ≈ 0.6)

    # Testing to add a position within an existing position (2)
    _include_new_body_pos!(out, 7, 10, -0.4, 0.6)
    @test (out.body[1][7, 10] ≈ 0.7) && (out.body[2][7, 10] ≈ 2.5)
    @test (out.body[3][7, 10] ≈ -0.4) && (out.body[4][7, 10] ≈ 0.6)

    # Testing to add a position within an existing position (3)
    _include_new_body_pos!(out, 6, 6, 0.1, 0.2)
    @test (out.body[1][6, 6] ≈ 0.1) && (out.body[2][6, 6] ≈ 0.2)
    @test (out.body[3][6, 6] == 0.0) && (out.body[4][6, 6] == 0.0)

    # Testing to add a position within an existing position (4)
    _include_new_body_pos!(out, 6, 6, 0.15, 0.18)
    @test (out.body[1][6, 6] ≈ 0.1) && (out.body[2][6, 6] ≈ 0.2)
    @test (out.body[3][6, 6] == 0.0) && (out.body[4][6, 6] == 0.0)

    # Testing that incorrect request throws an error
    #@test_throws ErrorException _include_new_body_pos!(out, 7, 10, 3.0, 3.1)

    # Resetting bucket position
    out.body[1][6, 6] = 0.0
    out.body[2][6, 6] = 0.0
    out.body[1][7, 10] = 0.0
    out.body[2][7, 10] = 0.0
    out.body[3][7, 10] = 0.0
    out.body[4][7, 10] = 0.0
    out.body[1][10, 9] = 0.0
    out.body[2][10, 9] = 0.0
    out.body[3][10, 9] = 0.0
    out.body[4][10, 9] = 0.0
    out.body[1][9, 12] = 0.0
    out.body[2][9, 12] = 0.0
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])

    # Testing that no extra bucket position has been added
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))
end

@testset "_update_body!" begin
    # Resetting bucket position
    _init_sparse_array!(out.body, grid)

    # Creating a dummy bucket wall
    area_pos = Vector{Vector{Int64}}()
    push!(area_pos, [5, 5, 11])
    push!(area_pos, [5, 5, 15])
    push!(area_pos, [6, 6, 17])
    push!(area_pos, [7, 11, 11])
    push!(area_pos, [7, 11, 12])
    push!(area_pos, [7, 12, 12])
    push!(area_pos, [7, 12, 13])
    push!(area_pos, [7, 13, 11])
    push!(area_pos, [10, 10, 11])

    # Testing for a first bucket wall
    _update_body!(area_pos, out, grid)
    @test (out.body[1][5, 5] ≈ -0.1) && (out.body[2][5, 5] ≈ 0.4)
    @test (out.body[1][6, 6] ≈ 0.5) && (out.body[2][6, 6] ≈ 0.6)
    @test (out.body[1][7, 11] ≈ -0.1) && (out.body[2][7, 11] ≈ 0.1)
    @test (out.body[1][7, 12] ≈ 0.0) && (out.body[2][7, 12] ≈ 0.2)
    @test (out.body[1][7, 13] ≈ -0.1) && (out.body[2][7, 13] ≈ 0.0)
    @test (out.body[1][10, 10] ≈ -0.1) && (out.body[2][10, 10] ≈ 0.0)

    # Creating a dummy bucket wall
    area_pos = Vector{Vector{Int64}}()
    push!(area_pos, [4, 4, 11])
    push!(area_pos, [5, 5, 15])
    push!(area_pos, [6, 6, 10])
    push!(area_pos, [7, 11, 12])
    push!(area_pos, [7, 11, 15])
    push!(area_pos, [7, 12, 9])
    push!(area_pos, [7, 12, 12])
    push!(area_pos, [7, 13, 9])
    push!(area_pos, [7, 13, 14])
    push!(area_pos, [10, 10, 13])

    # Testing for a second bucket wall
    _update_body!(area_pos, out, grid)
    @test (out.body[1][4, 4] ≈ -0.1) && (out.body[2][4, 4] ≈ 0.0)
    @test (out.body[1][5, 5] ≈ -0.1) && (out.body[2][5, 5] ≈ 0.4)
    @test (out.body[1][6, 6] ≈ 0.5) && (out.body[2][6, 6] ≈ 0.6)
    @test (out.body[3][6, 6] ≈ -0.2) && (out.body[4][6, 6] ≈ -0.1)
    @test (out.body[1][7, 11] ≈ -0.1) && (out.body[2][7, 11] ≈ 0.4)
    @test (out.body[1][7, 12] ≈ -0.3) && (out.body[2][7, 12] ≈ 0.2)
    @test (out.body[1][7, 13] ≈ -0.3) && (out.body[2][7, 13] ≈ 0.3)
    @test (out.body[1][10, 10] ≈ -0.1) && (out.body[2][10, 10] ≈ 0.0)
    @test (out.body[3][10, 10] ≈ 0.1) && (out.body[4][10, 10] ≈ 0.2)

    # Creating a dummy bucket wall
    area_pos = Vector{Vector{Int64}}()
    push!(area_pos, [6, 6, 8])
    push!(area_pos, [6, 6, 19])

    # Testing for a third bucket wall
    _update_body!(area_pos, out, grid)
    @test (out.body[1][6, 6] ≈ -0.4) && (out.body[2][6, 6] ≈ 0.8)
    @test (out.body[3][6, 6] ≈ 0.0) && (out.body[4][6, 6] ≈ 0.0)

    # Creating a dummy bucket wall
    area_pos = Vector{Vector{Int64}}()
    push!(area_pos, [10, 10, 15])

    # Testing that incorrect request throws an error
    #@test_throws ErrorException _update_body!(area_pos, out, grid)

    # Resetting bucket position
    out.body[1][4, 4] = 0.0
    out.body[2][4, 4] = 0.0
    out.body[1][5, 5] = 0.0
    out.body[2][5, 5] = 0.0
    out.body[1][6, 6] = 0.0
    out.body[2][6, 6] = 0.0
    out.body[1][7, 11] = 0.0
    out.body[2][7, 11] = 0.0
    out.body[1][7, 12] = 0.0
    out.body[2][7, 12] = 0.0
    out.body[1][7, 13] = 0.0
    out.body[2][7, 13] = 0.0
    out.body[1][10, 10] = 0.0
    out.body[2][10, 10] = 0.0
    out.body[3][10, 10] = 0.0
    out.body[4][10, 10] = 0.0
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])

    # Testing that no extra bucket position has been added
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))
end

@testset "_calc_bucket_pos!" begin
    # Setting a dummy bucket geometry in the XZ plane
    bucket.j_pos_init .= Vector{Float64}([0.0, 0.0, 0.0])
    bucket.b_pos_init .= Vector{Float64}([0.5, 0.01, 0.0])
    bucket.t_pos_init .= Vector{Float64}([0.5, 0.0, 0.0])
    ori = angle_to_quat(0.0, 0.0, 0.0, :ZYX)
    pos = Vector{Float64}([0.0, 0.0, 0.0])

    # Testing for a bucket in the XZ plane
    _calc_bucket_pos!(out, pos, ori, grid, bucket, sim)
    # Checking the bucket position
    #@test (out.body[1][11, 11] ≈ -0.3) && (out.body[2][11, 11] ≈ 0.3)
    #@test (out.body[1][12, 11] ≈ -0.3) && (out.body[2][12, 11] ≈ 0.3)
    #@test (out.body[1][13, 11] ≈ -0.3) && (out.body[2][13, 11] ≈ 0.3)
    #@test (out.body[1][14, 11] ≈ -0.3) && (out.body[2][14, 11] ≈ 0.3)
    #@test (out.body[1][15, 11] ≈ -0.3) && (out.body[2][15, 11] ≈ 0.3)
    #@test (out.body[1][16, 11] ≈ -0.3) && (out.body[2][16, 11] ≈ 0.3)
    @test (out.bucket_area[1, 1] == 7) && (out.bucket_area[1, 2] == 20)
    @test (out.bucket_area[2, 1] == 7) && (out.bucket_area[2, 2] == 15)
    # Resetting the bucket position
    out.body[1][11:16, 11] .= 0.0
    out.body[2][11:16, 11] .= 0.0
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    # Checking that no extra bucket position has been added
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))

    # Setting a dummy bucket geometry in the XY plane
    bucket.j_pos_init .= Vector{Float64}([0.0, 0.0, 0.0])
    bucket.b_pos_init .= Vector{Float64}([0.5, 0.0, -0.01])
    bucket.t_pos_init .= Vector{Float64}([0.5, 0.0, 0.0])
    ori = angle_to_quat(0.0, 0.0, 0.0, :ZYX)
    pos = Vector{Float64}([0.0, 0.0, 0.0])

    # Testing for a bucket in the XY plane
    _calc_bucket_pos!(out, pos, ori, grid, bucket, sim)
    # Checking the bucket position
    #@test all(out.body[1][11:16, 9:13] .≈ -0.1)
    #@test all(out.body[2][11:16, 9:13] .≈ 0.0)
    @test (out.bucket_area[1, 1] == 7) && (out.bucket_area[1, 2] == 20)
    @test (out.bucket_area[2, 1] == 5) && (out.bucket_area[2, 2] == 17)
    # Resetting the bucket position
    out.body[1][11:16, 9:13] .= 0.0
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    # Checking that no extra bucket position has been added
    @test isempty(nonzeros(out.body[1]))
    #@test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))

    # Setting a dummy bucket geometry
    bucket.j_pos_init .= Vector{Float64}([0.0, 0.0, 0.0])
    bucket.b_pos_init .= Vector{Float64}([0.0, 0.0, -0.5])
    bucket.t_pos_init .= Vector{Float64}([0.5, 0.0, -0.5])
    ori = angle_to_quat(0.0, -pi / 2, 0.0, :ZYX)
    pos = Vector{Float64}([0.0, 0.0, -0.1])

    # Testing for a bucket in a dummy position
    _calc_bucket_pos!(out, pos, ori, grid, bucket, sim)
    # Checking the bucket position
    #@test all(out.body[1][6, 9:13] .≈ -0.6)
    #@test all(out.body[2][6, 9:13] .≈ -0.1)
    #@test all(out.body[1][7, 10:12] .≈ -0.2)
    #@test (out.body[1][7, 9] ≈ -0.6) && (out.body[1][7, 13] ≈ -0.6)
    #@test all(out.body[2][7, 9:13] .≈ -0.1)
    #@test all(out.body[1][8, 10:12] .≈ -0.2)
    #@test (out.body[1][8, 9] ≈ -0.5) && (out.body[1][8, 13] ≈ -0.5)
    #@test all(out.body[2][8, 9:13] .≈ -0.1)
    #@test all(out.body[1][9, 10:12] .≈ -0.2)
    #@test (out.body[1][9, 9] ≈ -0.4) && (out.body[1][9, 13] ≈ -0.4)
    #@test all(out.body[2][9, 9:13] .≈ -0.1)
    #@test all(out.body[1][10, 10:12] .≈ -0.2)
    #@test (out.body[1][10, 9] ≈ -0.3) && (out.body[1][10, 13] ≈ -0.3)
    #@test all(out.body[2][10, 9:13] .≈ -0.1)
    #@test all(out.body[1][11, 9:13] .≈ -0.2)
    #@test all(out.body[2][11, 9:13] .≈ -0.1)
    @test (out.bucket_area[1, 1] == 2) && (out.bucket_area[1, 2] == 15)
    @test (out.bucket_area[2, 1] == 5) && (out.bucket_area[2, 2] == 17)
    # Resetting the bucket position
    out.body[1][6:11, 9:13] .= 0.0
    out.body[2][6:11, 9:13] .= 0.0
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    # Checking that no extra bucket position has been added
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))
end
