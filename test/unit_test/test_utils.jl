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

# Terrain properties
terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
out = SimOut(terrain, grid)


#==========================================================================================#
#                                                                                          #
#                                         Testing                                          #
#                                                                                          #
#==========================================================================================#
@testset "_calc_bucket_corner_pos" begin
    # Setting up the environment
    o_pos = Vector{Float64}([0.0, 0.0, 0.0])
    j_pos = Vector{Float64}([0.0, 0.0, 0.0])
    b_pos = Vector{Float64}([0.0, 0.0, -0.5])
    t_pos = Vector{Float64}([0.7, 0.0, -0.5])
    bucket = BucketParam(o_pos, j_pos, b_pos, t_pos, 0.5)

    # Test: UT-CBC-1
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = Quaternion(1.0, 0.0, 0.0, 0.0)
    j_r_pos, j_l_pos, b_r_pos, b_l_pos, t_r_pos, t_l_pos = _calc_bucket_corner_pos(
        pos, ori, bucket
    )
    @test (j_r_pos == Vector{Float64}([0.0, -0.25, 0.0]))
    @test (j_l_pos == Vector{Float64}([0.0, 0.25, 0.0]))
    @test (b_r_pos == Vector{Float64}([0.0, -0.25, -0.5]))
    @test (b_l_pos == Vector{Float64}([0.0, 0.25, -0.5]))
    @test (t_r_pos == Vector{Float64}([0.7, -0.25, -0.5]))
    @test (t_l_pos == Vector{Float64}([0.7, 0.25, -0.5]))

    # Test: UT-CBC-2
    pos = Vector{Float64}([0.1, -0.1, 0.2])
    ori = Quaternion(1.0, 0.0, 0.0, 0.0)
    j_r_pos, j_l_pos, b_r_pos, b_l_pos, t_r_pos, t_l_pos = _calc_bucket_corner_pos(
        pos, ori, bucket
    )
    @test (j_r_pos ≈ Vector{Float64}([0.1, -0.35, 0.2]))
    @test (j_l_pos ≈ Vector{Float64}([0.1, 0.15, 0.2]))
    @test (b_r_pos ≈ Vector{Float64}([0.1, -0.35, -0.3]))
    @test (b_l_pos ≈ Vector{Float64}([0.1, 0.15, -0.3]))
    @test (t_r_pos ≈ Vector{Float64}([0.8, -0.35, -0.3]))
    @test (t_l_pos ≈ Vector{Float64}([0.8, 0.15, -0.3]))

    # Test: UT-CBC-3
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = Quaternion(0.707107, 0.0, 0.0, -0.707107)
    j_r_pos, j_l_pos, b_r_pos, b_l_pos, t_r_pos, t_l_pos = _calc_bucket_corner_pos(
        pos, ori, bucket
    )
    @test (j_r_pos ≈ Vector{Float64}([0.25, 0.0, 0.0]))
    @test (j_l_pos ≈ Vector{Float64}([-0.25, 0.0, 0.0]))
    @test (b_r_pos ≈ Vector{Float64}([0.25, 0.0, -0.5]))
    @test (b_l_pos ≈ Vector{Float64}([-0.25, 0.0, -0.5]))
    @test (t_r_pos ≈ Vector{Float64}([0.25, 0.7, -0.5]))
    @test (t_l_pos ≈ Vector{Float64}([-0.25, 0.7, -0.5]))

    # Test: UT-CBC-4
    pos = Vector{Float64}([0.1, -0.1, 0.2])
    ori = Quaternion(0.707107, 0.0, 0.0, -0.707107)
    j_r_pos, j_l_pos, b_r_pos, b_l_pos, t_r_pos, t_l_pos = _calc_bucket_corner_pos(
        pos, ori, bucket
    )
    @test (j_r_pos ≈ Vector{Float64}([0.35, -0.1, 0.2]))
    @test (j_l_pos ≈ Vector{Float64}([-0.15, -0.1, 0.2]))
    @test (b_r_pos ≈ Vector{Float64}([0.35, -0.1, -0.3]))
    @test (b_l_pos ≈ Vector{Float64}([-0.15, -0.1, -0.3]))
    @test (t_r_pos ≈ Vector{Float64}([0.35, 0.6, -0.3]))
    @test (t_l_pos ≈ Vector{Float64}([-0.15, 0.6, -0.3]))
end

@testset "" begin

end

@testset "_init_sparse_array!" begin
    # Test: UT-IS-1
    out.body[1][5:17, 1:16] .= 1.0
    out.body[2][5:17, 1:16] .= 2.0
    out.body[3][4:10, 13:17] .= 0.0
    out.body[4][4:10, 13:17] .= 2*grid.half_length_z
    _init_sparse_array!(out.body, grid)
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))

    # Test: UT-IS-2
    out.body_soil[1][5:17, 1:16] .= 1.0
    out.body_soil[2][5:17, 1:16] .= 2.0
    out.body_soil[3][4:10, 13:17] .= 0.0
    out.body_soil[4][4:10, 13:17] .= 2*grid.half_length_z
    _init_sparse_array!(out.body_soil, grid)
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    @test isempty(nonzeros(out.body_soil[3]))
    @test isempty(nonzeros(out.body_soil[4]))
end

@testset "_locate_non_zeros" begin
    # Test: UT-LN-1
    out.body[2][15, 11] = 0.3
    out.body[2][7, 1] = -0.3
    out.body[2][1, 2] = 0.01
    non_zeros = _locate_non_zeros(out.body[2])
    @test ([15, 11] in non_zeros) && ([7, 1] in non_zeros) && ([1, 2] in non_zeros)
    @test (length(non_zeros) == 3)
    out.body[2][15, 11] = 0.0
    out.body[2][7, 1] = 0.0
    out.body[2][1, 2] = 0.0
    dropzeros!(out.body[2])

    # Test: UT-LN-2
    out.body[2][10, 10] = 0.0
    non_zeros = _locate_non_zeros(out.body[2])
    @test isempty(non_zeros)
    dropzeros!(out.body[2])

    # Test: UT-LN-3
    out.body_soil[1][5, 5] = 0.1
    out.body_soil[1][11, 7] = -0.5
    out.body_soil[1][15, 1] = -0.2
    non_zeros = _locate_non_zeros(out.body_soil[1])
    @test ([5, 5] in non_zeros) && ([11, 7] in non_zeros) && ([15, 1] in non_zeros)
    @test (length(non_zeros) == 3)
    out.body_soil[1][5, 5] = 0.0
    out.body_soil[1][11, 7] = 0.0
    out.body_soil[1][15, 1] = 0.0
    dropzeros!(out.body_soil[1])

    # Test: UT-LN-4
    out.body_soil[1][4, 9] = 0.0
    non_zeros = _locate_non_zeros(out.body_soil[1])
    @test isempty(non_zeros)
    dropzeros!(out.body_soil[1])
end

@testset "_locate_all_non_zeros" begin
    # Test: UT-LA-1
    out.body[1][15, 5] = -0.3
    out.body[2][15, 5] = 0.3
    out.body[1][4, 19] = 0.0
    out.body[2][4, 19] = 0.5
    out.body[1][11, 17] = -0.5
    out.body[2][11, 17] = -0.5
    out.body[3][3, 3] = 0.4
    out.body[4][3, 3] = -0.3
    out.body[1][13, 17] = -0.5
    out.body[2][13, 17] = 0.0
    out.body[3][13, 17] = 0.0
    out.body[4][13, 17] = 0.9
    body_pos = _locate_all_non_zeros(out.body)
    @test ([1, 15, 5] in body_pos) && ([1, 4, 19] in body_pos)
    @test ([1, 11, 17] in body_pos) && ([3, 3, 3] in body_pos)
    @test ([1, 13, 17] in body_pos) && ([3, 13, 17] in body_pos)
    @test (length(body_pos) == 6)
    out.body[1][15, 5] = 0.0
    out.body[2][15, 5] = 0.0
    out.body[2][4, 19] = 0.0
    out.body[1][11, 17] = 0.0
    out.body[2][11, 17] = 0.0
    out.body[3][3, 3] = 0.0
    out.body[4][3, 3] = 0.0
    out.body[1][13, 17] = 0.0
    out.body[4][13, 17] = 0.0
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])

    # Test: UT-LA-2
    out.body[1][16, 7] = 0.0
    out.body[2][16, 7] = 0.0
    out.body[3][19, 5] = 0.0
    out.body[4][19, 5] = 0.0
    body_pos = _locate_all_non_zeros(out.body)
    @test isempty(body_pos)
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])

    # Test: UT-LA-3
    out.body_soil[1][5, 5] = 0.1
    out.body_soil[2][5, 5] = 0.2
    out.body_soil[1][4, 9] = 0.0
    out.body_soil[2][4, 9] = 0.1
    out.body_soil[1][11, 7] = -0.5
    out.body_soil[2][11, 7] = -0.3
    out.body_soil[3][1, 1] = -0.2
    out.body_soil[4][1, 1] = -0.1
    out.body_soil[1][3, 7] = -0.2
    out.body_soil[2][3, 7] = 0.0
    out.body_soil[3][3, 7] = 0.0
    out.body_soil[4][3, 7] = 0.5
    body_soil_pos = _locate_all_non_zeros(out.body_soil)
    @test ([1, 5, 5] in body_soil_pos) && ([1, 4, 9] in body_soil_pos)
    @test ([1, 11, 7] in body_soil_pos) && ([3, 1, 1] in body_soil_pos)
    @test ([1, 3, 7] in body_soil_pos) && ([3, 3, 7] in body_soil_pos)
    @test (length(body_soil_pos) == 6)
    out.body_soil[1][5, 5] = 0.0
    out.body_soil[2][5, 5] = 0.0
    out.body_soil[2][4, 9] = 0.0
    out.body_soil[1][11, 7] = 0.0
    out.body_soil[2][11, 7] = 0.0
    out.body_soil[3][1, 1] = 0.0
    out.body_soil[4][1, 1] = 0.0
    out.body_soil[1][3, 7] = 0.0
    out.body_soil[4][3, 7] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])

    # Test: UT-LA-4
    out.body_soil[1][6, 7] = 0.0
    out.body_soil[2][6, 7] = 0.0
    out.body_soil[3][9, 5] = 0.0
    out.body_soil[4][9, 5] = 0.0
    body_soil_pos = _locate_all_non_zeros(out.body_soil)
    @test isempty(body_soil_pos)
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])
end

@testset "calc_normal" begin
    # Test: UT-CN-1
    a = [0.0, 0.0, 0.0]
    b = [2.3, 0.0, 0.0]
    c = [2.3, 2.45, 0.0]
    @test calc_normal(a, b, c) == [0.0, 0.0, 1.0]
    @test calc_normal(a, c, b) == [0.0, 0.0, -1.0]

    # Test: UT-CN-2
    a = [1.0, 0.0, -1.3]
    b = [0.3, 0.0, 4.2]
    c = [2.3, 0.0, 3.0]
    @test calc_normal(a, b, c) == [0.0, 1.0, 0.0]
    @test calc_normal(a, c, b) == [0.0, -1.0, 0.0]

    # Test: UT-CN-3
    a = [0.0, -4.7, 1.3]
    b = [0.0, 7.2, -0.6]
    c = [0.0, -1.0, 54.3]
    @test calc_normal(a, b, c) == [1.0, 0.0, 0.0]
    @test calc_normal(a, c, b) == [-1.0, 0.0, 0.0]

    # Test: UT-CN-4
    a = [1.0, 0.0, 0.0]
    b = [0.0, 1.0, 0.0]
    c = [0.0, 0.0, 1.0]
    @test calc_normal(a, b, c) ≈ [sqrt(1/3), sqrt(1/3), sqrt(1/3)]
    @test calc_normal(a, c, b) ≈ [-sqrt(1/3), -sqrt(1/3), -sqrt(1/3)]
end

@testset "set_RNG_seed!" begin
    # Test: UT-SR-1
    set_RNG_seed!()
    get_rand = rand(1)
    seed!(1234)
    exp_rand = rand(1)
    @test get_rand  == exp_rand

    # Test: UT-SR-2
    set_RNG_seed!(15034)
    get_rand = rand(1)
    seed!(15034)
    exp_rand = rand(1)
    @test get_rand  == exp_rand
end

@testset "check_volume" begin
    # Setting dummy properties
    init_volume = 0.0

    # Test: UT-CV-1
    @test_logs check_volume(out, init_volume, grid)
    @test_logs (:warn,) match_mode=:any check_volume(out, 1.0, grid)
    @test_logs (:warn,) match_mode=:any check_volume(
            out, init_volume - 0.6 * grid.cell_volume, grid
        )
    @test_logs (:warn,) match_mode=:any check_volume(
            out, init_volume + 0.6 * grid.cell_volume, grid
        )

    # Test: UT-CV-2
    out.terrain[1, 2] = 0.2
    init_volume =  0.2 * (grid.cell_size_xy * grid.cell_size_xy)
    @test_logs check_volume(out, init_volume, grid)
    @test_logs (:warn,) match_mode=:any check_volume(out, 0.0, grid)
    @test_logs (:warn,) match_mode=:any check_volume(
            out, init_volume - 0.6 * grid.cell_volume, grid
        )
    @test_logs (:warn,) match_mode=:any check_volume(
            out, init_volume + 0.6 * grid.cell_volume, grid
        )
    @test_logs (:warn,) match_mode=:any check_volume(out, -init_volume, grid)

    # Test: UT-CV-3
    out.terrain[1, 2] = 0.0
    set_height(out, 1, 1, NaN, NaN, NaN, 0.0, 0.08, NaN, NaN, NaN, NaN)
    set_height(out, 2, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.0, 0.15)
    set_height(out, 2, 2, NaN, NaN, NaN, -0.1, 0.0, NaN, NaN, 0.2, 0.27)
    push_body_soil_pos(out, 1, 1, 1, [0.0, 0.0, 0.0], 0.08)
    push_body_soil_pos(out, 3, 2, 1, [0.0, 0.0, 0.0], 0.15)
    push_body_soil_pos(out, 1, 2, 2, [0.0, 0.0, 0.0], 0.1)
    push_body_soil_pos(out, 3, 2, 2, [0.0, 0.0, 0.0], 0.07)
    init_volume =  0.4 * (grid.cell_size_xy * grid.cell_size_xy)
    @test_logs check_volume(out, init_volume, grid)
    @test_logs (:warn,) match_mode=:any check_volume(out, 0.0, grid)

    # Test: UT-CV-4
    out.body_soil_pos[3].h_soil[1] = 0.0
    @test_logs (:warn,) match_mode=:any check_volume(out, init_volume, grid)
    out.body_soil_pos[3].h_soil[1] = 0.1
    push_body_soil_pos(out, 1, 2, 2, [0.0, 0.0, 0.0], 0.05)
    @test_logs (:warn,) match_mode=:any check_volume(out, init_volume, grid)
    out.body_soil[2][2, 2] = 0.05
    init_volume += 0.05 * grid.cell_area
    @test_logs check_volume(out, init_volume, grid)
    push_body_soil_pos(out, 1, 5, 5, [0.0, 0.0, 0.0], 0.05)
    @test_logs (:warn,) match_mode=:any check_volume(out, init_volume, grid)

    # Resetting everything
    set_height(out, 1, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    set_height(out, 2, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    set_height(out, 2, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])
end

@testset "check_soil" begin
    # Test: UT-CS-1
    @test_logs check_soil(out)

    # Test: UT-CS-2
    out.terrain[1, 1] = -0.2
    out.terrain[1, 2] = -0.15
    out.terrain[2, 1] = 0.0
    out.terrain[2, 2] = 0.0
    @test_logs check_soil(out)

    # Test: UT-CS-3
    set_height(out, 1, 1, NaN, -0.2, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 1, 2, NaN, -0.15, 0.0, NaN, NaN, 0.1, 0.2, NaN, NaN)
    set_height(out, 2, 1, NaN, NaN, NaN, NaN, NaN, 0.0, 0.15, NaN, NaN)
    set_height(out, 2, 2, NaN, 0.05, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    @test_logs check_soil(out)

    # Test: UT-CS-4
    set_height(out, 1, 1, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN)
    set_height(out, 1, 2, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN, 0.2, 0.3)
    set_height(out, 2, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.15, 0.25)
    set_height(out, 2, 2, NaN, NaN, NaN, 0.1, 0.15, NaN, NaN, NaN, NaN)
    push_body_soil_pos(out, 1, 1, 1, [0.0, 0.0, 0.0], 0.1)
    push_body_soil_pos(out, 1, 1, 2, [0.0, 0.0, 0.0], 0.1)
    push_body_soil_pos(out, 3, 1, 2, [0.0, 0.0, 0.0], 0.1)
    push_body_soil_pos(out, 3, 2, 1, [0.0, 0.0, 0.0], 0.1)
    push_body_soil_pos(out, 1, 2, 2, [0.0, 0.0, 0.0], 0.05)
    @test_logs check_soil(out)

    # Test: UT-CS-5
    out.terrain[1, 1] = 0.5
    warning_message = "Terrain is above the bucket\nLocation: (1, 1)\n" *
        "Terrain height: 0.5\nBucket minimum height: -0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.terrain[1, 1] = -0.2
    out.terrain[2, 1] = 0.05
    warning_message = "Terrain is above the bucket\nLocation: (2, 1)\n" *
        "Terrain height: 0.05\nBucket minimum height: 0.0"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.terrain[2, 1] = 0.0
    @test_logs check_soil(out)

    # Test: UT-CS-6
    set_height(out, 1, 1, NaN, 0.0, -0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.0\n" *
        "Bucket maximum height: -0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, 0.0, -0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.0\n" *
        "Bucket maximum height: -0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, 0.41, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.41\n" *
        "Bucket maximum height: 0.4"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, 0.41, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.41\n" *
        "Bucket maximum height: 0.0"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, 0.0, -0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.0\n" *
        "Bucket maximum height: -0.4"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, -0.2, 0.0, 0.0, 0.1, NaN, NaN, NaN, NaN)
    set_height(out, 2, 1, NaN, NaN, NaN, NaN, NaN, 0.16, 0.15, NaN, NaN)
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (2, 1)\nBucket minimum height: 0.16\n" *
        "Bucket maximum height: 0.15"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 2, 1, NaN, NaN, NaN, NaN, NaN, 0.0, 0.15, NaN, NaN)
    @test_logs check_soil(out)

    # Test: UT-CS-7
    set_height(out, 1, 1, NaN, NaN, NaN, 0.0, -0.1, NaN, NaN, NaN, NaN)
    warning_message = "Minimum height of the bucket soil is above its maximum height\n" *
        "Location: (1, 1)\nBucket soil minimum height: 0.0\n" *
        "Bucket soil maximum height: -0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, NaN, NaN, 0.2, 0.0, NaN, NaN, NaN, NaN)
    warning_message = "Minimum height of the bucket soil is above its maximum height\n" *
        "Location: (1, 1)\nBucket soil minimum height: 0.2\n" *
        "Bucket soil maximum height: 0.0"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN)
    set_height(out, 2, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.15, 0.14)
    warning_message = "Minimum height of the bucket soil is above its maximum height\n" *
        "Location: (2, 1)\nBucket soil minimum height: 0.15\n" *
        "Bucket soil maximum height: 0.14"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 2, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.15, 0.25)
    @test_logs check_soil(out)

    # Test: UT-CS-8
    set_height(out, 1, 1, NaN, -0.2, 0.05, NaN, NaN, NaN, NaN, NaN, NaN)
    warning_message = "Bucket is above the bucket soil\nLocation: (1, 1)\n" *
        "Bucket maximum height: 0.05\nBucket soil minimum height: 0.0"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, -0.2, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 1, 2, NaN, NaN, NaN, NaN, NaN, 0.1, 0.25, NaN, NaN)
    warning_message = "Bucket is above the bucket soil\nLocation: (1, 2)\n" *
        "Bucket maximum height: 0.25\nBucket soil minimum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 2, NaN, NaN, NaN, NaN, NaN, 0.1, 0.45, NaN, NaN)
    warning_message = "Bucket is above the bucket soil\nLocation: (1, 2)\n" *
        "Bucket maximum height: 0.45\nBucket soil minimum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 2, NaN, NaN, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN)
    @test_logs check_soil(out)

    # Test: UT-CS-9
    set_height(out, 1, 1, NaN, NaN, NaN, 0.1, 0.1, NaN, NaN, NaN, NaN)
    warning_message = "Bucket soil is not above the bucket\nLocation: (1, 1)\n" *
        "Bucket maximum height: 0.0\nBucket soil minimum height: 0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, NaN, NaN, 0.05, 0.1, NaN, NaN, NaN, NaN)
    warning_message = "Bucket soil is not above the bucket\nLocation: (1, 1)\n" *
        "Bucket maximum height: 0.0\nBucket soil minimum height: 0.05"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN)
    set_height(out, 2, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.2, 0.25)
    warning_message = "Bucket soil is not above the bucket\nLocation: (2, 1)\n" *
        "Bucket maximum height: 0.15\nBucket soil minimum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 2, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.15, 0.25)
    @test_logs check_soil(out)

    # Test: UT-CS-10
    set_height(out, 1, 2, NaN, NaN, NaN, NaN, NaN, 0.0, 0.0, NaN, NaN)
    warning_message = "Bucket soil is present but there is no bucket\nLocation: (1, 2)\n" *
        "Bucket soil minimum height: 0.2\nBucket soil maximum height: 0.3"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 2, NaN, NaN, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN)
    set_height(out, 1, 1, NaN, 0.0, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    warning_message = "Bucket soil is present but there is no bucket\nLocation: (1, 1)\n" *
        "Bucket soil minimum height: 0.0\nBucket soil maximum height: 0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 1, 1, NaN, -0.2, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    @test_logs check_soil(out)

    # Test: UT-CS-11
    set_height(out, 3, 2, -0.2, -0.15, 0.1, NaN, NaN, 0.0, 0.2, NaN, NaN)
    warning_message = "The two bucket layers are intersecting\nLocation: (3, 2)\n" *
        "Bucket 1 minimum height: -0.15\nBucket 1 maximum height: 0.1\n" *
        "Bucket 2 minimum height: 0.0\nBucket 2 maximum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[2][3, 2] = 0.0
    warning_message = "The two bucket layers are intersecting\nLocation: (3, 2)\n" *
        "Bucket 1 minimum height: -0.15\nBucket 1 maximum height: 0.0\n" *
        "Bucket 2 minimum height: 0.0\nBucket 2 maximum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 3, 2, NaN, 0.0, 0.2, NaN, NaN, -0.2, 0.1, NaN, NaN)
    warning_message = "The two bucket layers are intersecting\nLocation: (3, 2)\n" *
        "Bucket 1 minimum height: 0.0\nBucket 1 maximum height: 0.2\n" *
        "Bucket 2 minimum height: -0.2\nBucket 2 maximum height: 0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[4][3, 2] = 0.0
    warning_message = "The two bucket layers are intersecting\nLocation: (3, 2)\n" *
        "Bucket 1 minimum height: 0.0\nBucket 1 maximum height: 0.2\n" *
        "Bucket 2 minimum height: -0.2\nBucket 2 maximum height: 0.0"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 3, 2, 0.0, 0.0, 0.0, NaN, NaN, 0.0, 0.0, NaN, NaN)
    @test_logs check_soil(out)

    # Test: UT-CS-12
    set_height(out, 3, 2, -0.2, -0.15, 0.0, 0.0, 0.15, 0.1, 0.2, NaN, NaN)
    warning_message = "A bucket layer and a bucket soil layer are intersecting\n" *
        "Location: (3, 2)\nBucket soil 1 minimum height: 0.0\n" *
        "Bucket soil 1 maximum height: 0.15\nBucket 2 minimum height: 0.1\n" *
        "Bucket 2 maximum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    set_height(out, 3, 2, NaN, 0.1, 0.2, 0.0, 0.0, -0.15, 0.0, 0.0, 0.15)
    warning_message = "A bucket layer and a bucket soil layer are intersecting\n" *
        "Location: (3, 2)\nBucket 1 minimum height: 0.1\nBucket 1 maximum height: 0.2\n" *
        "Bucket soil 2 minimum height: 0.0\nBucket soil 2 maximum height: 0.15"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body_soil[4][3, 2] = 0.1
    @test_logs check_soil(out)
    set_height(out, 3, 2, 0.0, 0.0, 0.0, NaN, NaN, 0.0, 0.0, 0.0, 0.0)
    @test_logs check_soil(out)

    # Resetting value
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])
end
