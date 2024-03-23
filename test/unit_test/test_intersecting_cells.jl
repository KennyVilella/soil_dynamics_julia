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
@testset "_move_body_soil!" begin
    # Creating a lambda function to set the initial state
    function set_init_state!(out, grid ,bucket)
        # Calculating soil position on the bucket
        pos1 = _calc_bucket_frame_pos(10, 15, 0.7, grid, bucket)
        pos3 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)

        # Setting bucket and soil height
        set_height(out, 10, 15, NaN, 0.3, 0.7, 0.7, 0.9, -0.2, 0.0, 0.0, 0.9)
        push_body_soil_pos(out, 1, 10, 15, pos1, 0.2)
        push_body_soil_pos(out, 3, 10, 15, pos3, 0.9)
    end

    # Test: IC-MBS-1
    set_init_state!(out, grid, bucket)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.terrain[5, 7] ≈ 0.6)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[5, 7]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-2
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.0, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil ≈ 0.6) && (wall_presence == true)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-3
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.terrain[5, 7] ≈ 0.6)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[5, 7]], [[1, 5, 7], [1, 10, 15], [3, 10, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-4
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.0, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.2, grid, bucket)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    check_height(out, 5, 7, NaN, 0.2, 0.8, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 5, 7, posA, 0.6)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[1, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-5
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.0, 0.1, 0.1, 0.4, NaN, NaN, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 5, 7, posA, 0.3)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    check_height(out, 5, 7, NaN, 0.1, 1.0, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[4], 1, 5, 7, posA, 0.6)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[1, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-6
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, NaN, NaN, NaN, NaN, 0.0, 0.6, 0.6, 0.7)
    posA = _calc_bucket_frame_pos(5, 7, 0.6, grid, bucket)
    push_body_soil_pos(out, 3, 5, 7, posA, 0.1)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil ≈ 0.6) && (wall_presence == true)
    check_height(out, 5, 7, NaN, NaN, NaN, 0.6, 0.7)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[3, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-7
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, NaN, NaN, NaN, NaN, 0.3, 0.6, NaN, NaN)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.terrain[5, 7] ≈ 0.6)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[5, 7]], [[3, 5, 7], [1, 10, 15], [3, 10, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-8
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, -0.2, NaN, NaN, NaN, NaN, -0.2, 0.0, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.0, grid, bucket)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    check_height(out, 5, 7, NaN, NaN, NaN, 0.0, 0.6)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[5, 7]], [[3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[3, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-9
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, -0.2, NaN, NaN, NaN, NaN, -0.2, 0.0, 0.0, 0.3)
    posA = _calc_bucket_frame_pos(5, 7, 0.0, grid, bucket)
    push_body_soil_pos(out, 3, 5, 7, posA, 0.3)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    check_height(out, 5, 7, NaN, NaN, NaN, 0.0, 0.9)
    check_body_soil_pos(out.body_soil_pos[4], 3, 5, 7, posA, 0.6)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[5, 7]], [[3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[3, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-10
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.0, 0.1, 0.1, 0.2, 0.2, 0.4, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 5, 7, posA, 0.2)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil ≈ 0.6) && (wall_presence == false)
    @test (ind == 1) && (ii == 5) && (jj == 7)
    check_height(out, 5, 7, NaN, 0.1, 0.2, NaN, NaN)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[1, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-11
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.0, 0.2, NaN, NaN, 0.8, 0.9, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.2, grid, bucket)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    check_height(out, 5, 7, NaN, 0.2, 0.8, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 5, 7, posA, 0.6)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[1, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-12
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.0, 0.1, NaN, NaN, 0.4, 0.9, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.1, grid, bucket)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil ≈ 0.3) && (wall_presence == false)
    @test (ind == 1) && (ii == 5) && (jj == 7)
    check_height(out, 5, 7, NaN, 0.1, 0.4, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[3], 1, 5, 7, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[1, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-13
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.0, 0.1, 0.1, 0.2, 0.9, 1.0, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 5, 7, posA, 0.1)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    check_height(out, 5, 7, NaN, 0.1, 0.8, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[4], 1, 5, 7, posA, 0.6)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[1, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-14
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.0, 0.1, 0.1, 0.2, 0.4, 0.5, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 5, 7, posA, 0.1)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil ≈ 0.4) && (wall_presence == false)
    @test (ind == 1) && (ii == 5) && (jj == 7)
    check_height(out, 5, 7, NaN, 0.1, 0.4, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[4], 1, 5, 7, posA, 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[1, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-15
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, NaN, 0.6, 0.7, NaN, NaN, 0.0, 0.1, 0.1, 0.6)
    posA = _calc_bucket_frame_pos(5, 7, 0.1, grid, bucket)
    push_body_soil_pos(out, 3, 5, 7, posA, 0.5)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil ≈ 0.6) && (wall_presence == false)
    @test (ind == 3) && (ii == 5) && (jj == 7)
    check_height(out, 5, 7, NaN, NaN, NaN, 0.1, 0.6)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[3, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-16
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, -0.1, 0.8, 0.9, NaN, NaN, -0.1, 0.0, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.0, grid, bucket)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    check_height(out, 5, 7, NaN, NaN, NaN, 0.0, 0.6)
    check_body_soil_pos(out.body_soil_pos[3], 3, 5, 7, posA, 0.6)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[5, 7]], [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[3, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-17
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, -0.1, 0.3, 0.9, NaN, NaN, -0.1, 0.2, NaN, NaN)
    posA = _calc_bucket_frame_pos(5, 7, 0.2, grid, bucket)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil ≈ 0.5) && (wall_presence == false)
    @test (ind == 3) && (ii == 5) && (jj == 7)
    check_height(out, 5, 7, NaN, NaN, NaN, 0.2, 0.3)
    check_body_soil_pos(out.body_soil_pos[3], 3, 5, 7, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[5, 7]], [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[3, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-18
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, -0.1, 0.8, 0.9, NaN, NaN, -0.1, 0.0, 0.0, 0.2)
    posA = _calc_bucket_frame_pos(5, 7, 0.0, grid, bucket)
    push_body_soil_pos(out, 3, 5, 7, posA, 0.2)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    check_height(out, 5, 7, NaN, NaN, NaN, 0.0, 0.8)
    check_body_soil_pos(out.body_soil_pos[4], 3, 5, 7, posA, 0.6)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[5, 7]], [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[3, 5, 7], [1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MBS-19
    set_init_state!(out, grid, bucket)
    set_height(out, 5, 7, -0.1, 0.6, 0.9, NaN, NaN, -0.1, 0.0, 0.0, 0.2)
    posA = _calc_bucket_frame_pos(5, 7, 0.0, grid, bucket)
    push_body_soil_pos(out, 3, 5, 7, posA, 0.2)
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false, grid, bucket
    )
    @test (h_soil ≈ 0.2) && (wall_presence == false)
    @test (ind == 3) && (ii == 5) && (jj == 7)
    check_height(out, 5, 7, NaN, NaN, NaN, 0.0, 0.6)
    check_body_soil_pos(out.body_soil_pos[4], 3, 5, 7, posA, 0.4)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[5, 7]], [[1, 5, 7], [3, 5, 7], [1, 10, 15], [3, 10, 15]],
        [[3, 5, 7], [1, 10, 15], [3, 10, 15]]
    )
end

@testset "_move_intersecting_body_soil!" begin
    # Test: IC-MIBS-1
    set_RNG_seed!(3000)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[11, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-2
    set_RNG_seed!(3000)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[11, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-3
    set_RNG_seed!(3000)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.4, 1.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[11, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-4
    set_RNG_seed!(3000)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, 0.3, 0.4, 1.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[11, 15] ≈ 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-5
    set_RNG_seed!(3000)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.5, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-6
    set_RNG_seed!(3000)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.4, 0.7, 0.7, 0.8, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, 0.3, 0.7, 0.8, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-7
    set_RNG_seed!(3000)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, 0.4, 0.4, 0.7, 0.7, 0.8, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, 0.7, 0.7, 0.8, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-8
    set_RNG_seed!(3000)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.2, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.5, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 1, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-9
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-10
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.4, 1.0, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[11, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-11
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, 0.3, NaN, NaN, NaN, NaN, 0.4, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[11, 15] ≈ 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-12
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-13
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.4, 0.5, 0.5, 0.8)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.3)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, 0.3, NaN, NaN, 0.5, 0.8)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-14
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, 0.3, NaN, NaN, NaN, NaN, 0.4, 0.5, 0.5, 0.6)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, 0.6, NaN, NaN, 0.5, 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-15
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.1, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-16
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-17
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.4, 1.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[11, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-18
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, 0.4, 0.4, 1.0, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[11, 15] ≈ 0.7)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-19
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.5, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-20
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.4, 1.0, 1.0, 2.0, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 1.0, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 1.0)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, 0.3, 1.0, 2.0, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-21
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, 0.4, 0.4, 0.5, 0.5, 0.6, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, 0.7, 0.5, 0.6, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-22
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.2, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.5, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 1, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-23
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-24
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.4, 1.0, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[11, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-25
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, 0.2, NaN, NaN, NaN, NaN, 0.4, 1.0, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[11, 15] ≈ 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-26
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-27
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.4, 0.5, 0.5, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.5, grid, bucket)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, 0.3, NaN, NaN, 0.5, 0.9)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-28
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, 0.2, NaN, NaN, NaN, NaN, 0.4, 1.0, 1.0, 1.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos3 = _calc_bucket_frame_pos(11, 15, 1.0, grid, bucket)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, 0.5, NaN, NaN, 1.0, 1.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-29
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.1, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-30
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.3, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-31
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.5, 0.7, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.5, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-32
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.4, 0.7, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.terrain[12, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-33
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, 0.2, 0.3, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-34
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-35
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.6, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-36
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.2, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-37
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, 0.2, NaN, NaN, NaN, NaN, 0.3, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-38
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-39
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.4, NaN, NaN, 0.6, 0.8, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.4, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.4, 0.6, NaN, NaN)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.1, 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 1, 11, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-40
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.2, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-41
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, 0.7, 0.8, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-42
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.8, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos, [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-43
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.7, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.5, 0.8, 0.9)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-44
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.4, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.8, 0.9)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-45
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.3, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-46
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.7, 0.8, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-47
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.3, 0.8, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos, [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-48
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.8, 0.9, 0.2, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-49
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.4, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.8, 0.9, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-50
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.3, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-51
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.2, 0.5, 0.7, 0.7, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.5, 0.7, 0.9)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-52
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.2, 0.4, 0.7, 0.7, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.4, 0.7, 0.9)
    @test (out.terrain[12, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-53
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, 0.1, 0.2, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-54
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.0, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-55
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.0, 0.3, 0.3, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.3, 0.6, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 7)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-56
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-57
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, 0.1, NaN, NaN, NaN, NaN, 0.2, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-58
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-59
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, 0.3, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 7)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-60
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.3, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-61
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.7, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.4, 0.6, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-62
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.5, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.4, 0.5, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-63
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.7, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.2, 0.5, 0.9, 1.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-64
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.9, 1.3)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-65
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.4, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-66
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.7, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-67
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.5, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.5)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-68
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.7, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-69
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-70
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-71
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.4, 0.4, 0.7, 0.7, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.3)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-72
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, 0.1, 0.2, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-73
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.0, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.3, 0.6, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-74
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.0, 0.3, 0.3, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.3, 0.7, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-75
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-76
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, 0.1, NaN, NaN, NaN, NaN, 0.2, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-77
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-78
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, 0.3, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.7)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-79
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.3, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 16]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-80
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.7, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.4, 0.7, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-81
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.5, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.4, 0.5, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-82
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.7, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.2, 0.6, 0.9, 1.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-83
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.9, 1.3)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-84
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.4, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[13, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-85
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.7, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.7)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-86
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.5, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.5)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-87
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.7, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-88
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-89
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[13, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-90
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-91
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.4, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.terrain[12, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-92
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, 0.2, 0.3, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-93
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-94
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.6, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-95
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.2, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-96
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, 0.2, NaN, NaN, NaN, NaN, 0.3, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-97
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-98
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.6, 0.8, NaN, NaN, 0.0, 0.4, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.4, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.4, 0.6)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.1, 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 11, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-99
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.2, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-100
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, 0.7, 0.8, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-101
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.8, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos, [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-102
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.7, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.5, 0.8, 0.9)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-103
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.4, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.8, 0.9)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-104
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.3, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
   )

    # Test: IC-MIBS-105
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.7, 0.8, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-106
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.3, 0.8, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos, [[1, 10, 15], [3, 10, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-107
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.8, 0.9, 0.2, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-108
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.4, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.8, 0.9, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-109
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.3, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-110
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.7, 0.7, 0.9, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.7, 0.9, 0.1, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-111
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.4, 0.7, 0.7, 0.9, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.7, 0.9, 0.1, 0.4)
    @test (out.terrain[12, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-112
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, 0.1, 0.2, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-113
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, 0.0, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-114
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, 0.0, 0.3, 0.3, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.3, 0.6, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 7)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-115
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-116
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, 0.1, NaN, NaN, NaN, NaN, 0.2, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-117
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-118
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, 0.3, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 7)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-119
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.3, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-120
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.7, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.4, 0.6, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-121
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.5, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.4, 0.5, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-122
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.7, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.2, 0.5, 0.9, 1.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-123
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.9, 1.3)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-124
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.4, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-125
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.7, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-126
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.5, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.5)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-127
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.7, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.5)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-128
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-129
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-130
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.4, 0.7, 0.7, 0.9, 0.0, 0.1, 0.1, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.3)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-131
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, 0.1, 0.2, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-132
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, 0.0, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.3, 0.6, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-133
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, 0.0, 0.3, 0.3, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.3, 0.7, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-134
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-135
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, 0.1, NaN, NaN, NaN, NaN, 0.2, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-136
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-137
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, 0.3, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.7)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-138
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.3, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-139
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.7, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.4, 0.7, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-140
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.5, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.4, 0.5, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-141
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.7, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.2, 0.6, 0.9, 1.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-142
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.9, 1.3)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-143
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.4, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[13, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-144
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.7, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.7)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-145
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.5, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.5)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-146
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.7, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.6)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-147
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-148
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[13, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-149
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.5, 0.7, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.5, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-150
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.4, 0.7, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.terrain[12, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-151
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, 0.2, 0.3, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-152
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-153
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.6, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-154
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.2, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-155
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, 0.2, NaN, NaN, NaN, NaN, 0.3, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-156
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-157
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.4, NaN, NaN, 0.6, 0.8, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.4, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.4, 0.6, NaN, NaN)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.1, 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 1, 11, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-158
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.2, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-159
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, 0.7, 0.8, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-160
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.8, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos, [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-161
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.7, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.5, 0.8, 0.9)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-162
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.4, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.8, 0.9)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-163
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.3, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-164
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.7, 0.8, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-165
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.3, 0.8, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos, [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-166
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.8, 0.9, 0.2, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-167
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.4, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    check_height(out, 12, 15, NaN, 0.8, 0.9, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-168
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.3, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-169
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.2, 0.5, 0.7, 0.7, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.5, 0.7, 0.9)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-170
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.2, 0.4, 0.7, 0.7, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.4, 0.7, 0.9)
    @test (out.terrain[12, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-171
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, 0.1, 0.2, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-172
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.0, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-173
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.0, 0.3, 0.3, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.3, 0.6, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 7)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-174
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-175
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, 0.1, NaN, NaN, NaN, NaN, 0.2, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-176
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-177
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, 0.3, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.6)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 7)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-178
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.3, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.3, 0.5, 0.8, 0.9)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-179
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.7, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.4, 0.6, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-180
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.5, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.4, 0.5, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-181
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.7, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.2, 0.5, 0.9, 1.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-182
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.9, 1.3)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-183
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.4, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-184
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.7, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.6)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-185
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.5, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.5)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-186
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.7, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-187
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-188
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.6, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.5)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.1, 0.7, 0.8, 0.9)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-189
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.4, 0.4, 0.7, 0.7, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.3)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-190
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, 0.1, 0.2, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-191
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.0, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.3, 0.6, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-192
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.0, 0.3, 0.3, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.3, 0.7, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-193
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-194
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, 0.1, NaN, NaN, NaN, NaN, 0.2, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-195
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.6)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-196
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, 0.3, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.7)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-197
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.3, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-198
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.7, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.4, 0.7, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-199
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.5, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.4, 0.5, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-200
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.7, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.2, 0.6, 0.9, 1.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-201
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.9, 1.3)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-202
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.4, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[13, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-203
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.7, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.7)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-204
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.5, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.5)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-205
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.7, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.6)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-206
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-207
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.0, 0.1, 0.1, 0.7, 0.7, 0.8, 0.8, 0.9)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.6)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.1)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[13, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-208
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-209
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.4, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.terrain[12, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-210
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, 0.2, 0.3, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-211
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-212
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.6, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-213
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.2, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-214
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, 0.2, NaN, NaN, NaN, NaN, 0.3, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-215
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-216
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.6, 0.8, NaN, NaN, 0.0, 0.4, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.4, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.4, 0.6)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.1, 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 11, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-217
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.2, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-218
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, 0.7, 0.8, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.4, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-219
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, NaN, NaN, 0.3, 0.8, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.3, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos, [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-220
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.7, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.5, 0.8, 0.9)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-221
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.4, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.8, 0.9)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-222
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.2, 0.2, 0.3, 0.3, 0.8, 0.8, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-223
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.7, 0.8, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-224
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.3, 0.8, NaN, NaN, 0.0, 0.2, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[3], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[4], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 4)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos, [[1, 10, 15], [3, 10, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-225
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.8, 0.9, 0.2, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-226
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.4, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    check_height(out, 12, 15, NaN, 0.8, 0.9, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-227
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.3, 0.7, NaN, NaN, 0.0, 0.2, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.3, 0.8, 0.8, 0.9, 0.0, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.3)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-228
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.7, 0.7, 0.9, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.7, 0.9, 0.1, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-229
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.4, 0.7, 0.7, 0.9, 0.0, 0.1, 0.1, 0.2)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.7, 0.9, 0.1, 0.4)
    @test (out.terrain[12, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.2)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-230
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, 0.1, 0.2, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-231
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, 0.0, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-232
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, 0.0, 0.3, 0.3, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.3, 0.6, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 7)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-233
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-234
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, 0.1, NaN, NaN, NaN, NaN, 0.2, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-235
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-236
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, 0.3, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    posB = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.6)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 7)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-237
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.4)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.3, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-238
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.7, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.4, 0.6, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-239
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.5, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.4, 0.5, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-240
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.7, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.2, 0.5, 0.9, 1.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 1, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-241
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posB, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.9, 1.3)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 1, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-242
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.4, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-243
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.7, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.6)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-244
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.5, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    posB = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.5)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-245
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.7, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.5)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 3, 12, 15, posB, 0.2)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-246
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posB = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posB, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.1)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    check_body_soil_pos(out.body_soil_pos[8], 3, 12, 15, posB, 0.1)
    @test (length(out.body_soil_pos) == 8)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-247
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.6)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    posA = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.5)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 11, 15, NaN, 0.8, 0.9, 0.1, 0.7)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 11, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-248
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.4, 0.7, 0.7, 0.9, 0.0, 0.1, 0.1, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.7, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.3)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[12, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-249
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, 0.1, 0.2, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-250
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, 0.0, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.3, 0.6, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-251
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, 0.0, 0.3, 0.3, 0.4, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.3, 0.7, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-252
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-253
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, 0.1, NaN, NaN, NaN, NaN, 0.2, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[12, 15] ≈ 0.4)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[12, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-254
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.6)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-255
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.3, 0.3, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    posA = _calc_bucket_frame_pos(12, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.3, 0.7)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[6], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 6)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-256
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.5, 0.8, 0.8, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 12, 15, NaN, NaN, NaN, NaN, NaN, 0.3, 0.5, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[10, 16] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-257
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.7, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.4, 0.7, NaN, NaN)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-258
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.4, NaN, NaN, 0.5, 0.9, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.4, 0.5, NaN, NaN)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 1, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]]
    )

    # Test: IC-MIBS-259
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.7, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.2, 0.6, 0.9, 1.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-260
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.3, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, posA, 0.1)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.2, 0.4, 0.9, 1.3)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 1, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-261
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.1, 0.2, 0.2, 0.4, 0.4, 0.9, 0.9, 1.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.2)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.4)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[13, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-262
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.7, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.7)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-263
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.5, 0.9, NaN, NaN, 0.1, 0.4, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    posA = _calc_bucket_frame_pos(12, 15, 0.4, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, NaN, NaN, 0.4, 0.5)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[5], 3, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 5)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]]
    )

    # Test: IC-MIBS-264
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.7, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.6)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-265
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.3)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    posA = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, posA, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    check_height(out, 12, 15, NaN, 0.9, 1.3, 0.2, 0.4)
    @test (out.terrain[13, 15] ≈ 0.2)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[7], 3, 12, 15, posA, 0.1)
    @test (length(out.body_soil_pos) == 7)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-266
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.7, 0.0, 0.3, 0.3, 0.8)
    set_height(out, 11, 15, NaN, 0.7, 0.8, 0.8, 0.9, 0.0, 0.1, 0.1, 0.7)
    set_height(out, 12, 15, NaN, 0.4, 0.9, 0.9, 1.3, 0.1, 0.2, 0.2, 0.4)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.5)
    pos1 = _calc_bucket_frame_pos(11, 15, 0.8, grid, bucket)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.6)
    pos1 = _calc_bucket_frame_pos(12, 15, 0.9, grid, bucket)
    pos3 = _calc_bucket_frame_pos(12, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 12, 15, pos1, 0.4)
    push_body_soil_pos(out, 3, 12, 15, pos3, 0.2)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.7, 0.3, 0.5)
    @test (out.terrain[13, 15] ≈ 0.3)
    @test (out.body_soil_pos[2].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 6)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [3, 12, 15]
    ]
    reset_value_and_test(out, [[13, 15]], body_pos, body_soil_pos)

    # Test: IC-MIBS-267
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.2, 0.2, 0.8, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.6)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.2, 1.1, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 1, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]]
    )

    # Test: IC-MIBS-268
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.2, 0.2, 0.5)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 3, 11, 15, posA, 0.3)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.2, 0.8)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    check_body_soil_pos(out.body_soil_pos[4], 3, 11, 15, posA, 0.3)
    @test (length(out.body_soil_pos) == 4)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-269
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, -0.6, -0.5, -0.5, 0.0, -0.3, 0.0, 0.0, 0.1)
    pos1 = _calc_bucket_frame_pos(10, 15, -0.5, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.0, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, -0.5, -0.3, 0.0, 0.1)
    @test (out.terrain[11, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-270
    set_RNG_seed!(926)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 1.2, 0.8, 0.9, 0.9, 1.7)
    set_height(out, 11, 15, NaN, 0.1, 0.2, 0.2, 0.4, NaN, NaN, NaN, NaN)
    set_height(out, 11, 16, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 14, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.9, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.2)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.1)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.8)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.2)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.4)
    posA = _calc_bucket_frame_pos(11, 15, 0.2, grid, bucket)
    push_body_soil_pos(out, 1, 11, 15, posA, 0.2)
    posB = _calc_bucket_frame_pos(11, 16, 0.1, grid, bucket)
    posC = _calc_bucket_frame_pos(11, 14, 0.1, grid, bucket)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.8, 0.9, 1.7)
    check_height(out, 11, 15, NaN, 0.2, 0.6, NaN, NaN)
    check_height(out, 11, 16, NaN, 0.1, 0.2, NaN, NaN)
    check_height(out, 11, 14, NaN, 0.1, 0.2, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] == 0.0)
    @test (out.body_soil_pos[2].h_soil[1] == 0.0)
    @test (out.body_soil_pos[4].h_soil[1] ≈ 0.1)
    check_body_soil_pos(out.body_soil_pos[7], 1, 11, 15, posA, 0.2)
    check_body_soil_pos(out.body_soil_pos[8], 1, 11, 16, posB, 0.1)
    check_body_soil_pos(out.body_soil_pos[9], 1, 11, 14, posC, 0.1)
    @test (length(out.body_soil_pos) == 9)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(),
        [[1, 10, 15], [3, 10, 15], [1, 11, 14], [1, 11, 15], [1, 11, 16]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 14], [1, 11, 15], [1, 11, 16]]
    )

    # Test: IC-MIBS-271
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.5, 0.6, 0.6, 0.9, 0.0, 0.3, 0.3, 0.5)
    set_height(out, 11, 15, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, 0.1, 0.9)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.3)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.2)
    pos3 = _calc_bucket_frame_pos(11, 15, 0.1, grid, bucket)
    push_body_soil_pos(out, 3, 11, 15, pos3, 0.8)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.6, 0.9, 0.3, 0.5)
    check_height(out, 11, 15, NaN, NaN, NaN, 0.1, 0.9)
    @test (length(out.body_soil_pos) == 3)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]]
    )

    # Test: IC-MIBS-272
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 1.3, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.3, NaN, NaN, 0.4, 0.7, NaN, NaN)
    set_height(out, 12, 15, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 16, NaN, 0.0, 0.3, NaN, NaN, 0.4, 0.7, NaN, NaN)
    set_height(out, 12, 17, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 10, 16, NaN, 0.0, 0.3, NaN, NaN, 0.4, 0.7, NaN, NaN)
    set_height(out, 10, 17, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 9, 16, NaN, 0.0, 0.3, NaN, NaN, 0.4, 0.7, NaN, NaN)
    set_height(out, 8, 17, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 9, 15, NaN, 0.0, 0.3, NaN, NaN, 0.4, 0.7, NaN, NaN)
    set_height(out, 8, 15, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 9, 14, NaN, 0.0, 0.3, NaN, NaN, 0.4, 0.7, NaN, NaN)
    set_height(out, 8, 13, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 10, 14, NaN, 0.0, 0.3, NaN, NaN, 0.4, 0.7, NaN, NaN)
    set_height(out, 10, 13, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 14, NaN, 0.0, 0.3, NaN, NaN, 0.4, 0.7, NaN, NaN)
    set_height(out, 12, 13, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 1.0)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    check_height(out, 11, 15, NaN, 0.3, 0.4, NaN, NaN)
    check_height(out, 11, 16, NaN, 0.3, 0.4, NaN, NaN)
    check_height(out, 10, 16, NaN, 0.3, 0.4, NaN, NaN)
    check_height(out, 9, 16, NaN, 0.3, 0.4, NaN, NaN)
    check_height(out, 9, 15, NaN, 0.3, 0.4, NaN, NaN)
    check_height(out, 9, 14, NaN, 0.3, 0.4, NaN, NaN)
    check_height(out, 10, 14, NaN, 0.3, 0.4, NaN, NaN)
    check_height(out, 11, 14, NaN, 0.3, 0.4, NaN, NaN)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 10)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15], [1, 11, 16],
        [3, 11, 16], [1, 12, 17], [1, 10, 16], [3, 10, 16], [1, 10, 17], [1, 9, 16],
        [3, 9, 16], [1, 8, 17], [1, 9, 15], [3, 9, 15], [1, 8, 15], [1, 9, 14], [3, 9, 14],
        [1, 8, 13], [1, 10, 14], [3, 10, 14], [1, 10, 13], [1, 11, 14], [3, 11, 14],
        [1, 12, 13]
    ]
    body_soil_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 11, 16], [1, 10, 16], [1, 9, 16],
        [1, 9, 15], [1, 9, 14], [1, 10, 14], [1, 11, 14]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, body_soil_pos)

    # Test: IC-MIBS-273
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[11, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    # Repeating the same movement with a different seed
    set_RNG_seed!(8)
    out.terrain[11, 15] = 0.0
    out.body_soil[2][10, 15] = 0.8
    out.body_soil_pos[1].h_soil[1] = 0.5
    _move_intersecting_body_soil!(out, grid, bucket)
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.terrain[9, 15] ≈ 0.3)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    reset_value_and_test(
        out, [[9, 15]], [[1, 10, 15], [3, 10, 15]], [[1, 10, 15], [3, 10, 15]]
    )

    # Test: IC-MIBS-274
    set_RNG_seed!(7)
    set_height(out, 10, 15, NaN, 0.0, 0.3, 0.3, 0.8, 0.5, 0.6, 0.6, 0.7)
    set_height(out, 11, 15, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 16, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 10, 16, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 9, 16, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 9, 15, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 9, 14, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 10, 14, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 14, NaN, 0.0, 0.7, NaN, NaN, NaN, NaN, NaN, NaN)
    pos1 = _calc_bucket_frame_pos(10, 15, 0.3, grid, bucket)
    pos3 = _calc_bucket_frame_pos(10, 15, 0.6, grid, bucket)
    push_body_soil_pos(out, 1, 10, 15, pos1, 0.5)
    push_body_soil_pos(out, 3, 10, 15, pos3, 0.1)
    warning_message = "Not all soil intersecting with a bucket layer could be moved\n" *
        "The extra soil has been arbitrarily removed"
    @test_logs (:warn, warning_message) match_mode=:any _move_intersecting_body_soil!(
        out, grid, bucket
    )
    check_height(out, 10, 15, NaN, 0.3, 0.5, 0.6, 0.7)
    @test (out.body_soil_pos[1].h_soil[1] ≈ 0.2)
    @test (length(out.body_soil_pos) == 2)
    body_pos = [
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 11, 16], [1, 10, 16], [1, 9, 16],
        [1, 9, 15], [1, 9, 14], [1, 10, 14], [1, 11, 14]
    ]
    reset_value_and_test(out, Vector{Vector{Int64}}(), body_pos, [[1, 10, 15], [3, 10, 15]])
end

@testset "_locate_intersecting_cells" begin
    # Setting up the environment
    out.bucket_area[1, 1] = 4
    out.bucket_area[1, 2] = 12
    out.bucket_area[2, 1] = 8
    out.bucket_area[2, 2] = 17

    # Test: IC-LIC-1
    set_height(out, 5, 10, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (length(intersecting_cells) == 0)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 5, 10]], Vector{Vector{Int64}}()
    )

    # Test: IC-LIC-2
    set_height(out, 11, 11, -0.1, -0.1, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (length(intersecting_cells) == 0)
    reset_value_and_test(out, [[11, 11]], [[1, 11, 11]], Vector{Vector{Int64}}())

    # Test: IC-LIC-3
    set_height(out, 6, 10, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (length(intersecting_cells) == 0)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[3, 6, 10]], Vector{Vector{Int64}}()
    )

    # Test: IC-LIC-4
    set_height(out, 7, 10, NaN, 0.0, 0.1, NaN, NaN, 0.2, 0.3, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (length(intersecting_cells) == 0)
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), [[1, 7, 10], [3, 7, 10]], Vector{Vector{Int64}}()
    )

    # Test: IC-LIC-5
    set_height(out, 10, 11, 0.1, -0.1, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (intersecting_cells == [[1, 10, 11]])
    reset_value_and_test(out, [[10, 11]], [[1, 10, 11]], Vector{Vector{Int64}}())

    # Test: IC-LIC-6
    set_height(out, 10, 12, 0.1, NaN, NaN, NaN, NaN, -0.1, 0.0, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (intersecting_cells == [[3, 10, 12]])
    reset_value_and_test(out, [[10, 12]], [[3, 10, 12]], Vector{Vector{Int64}}())

    # Test: IC-LIC-7
    set_height(out, 10, 13, 0.1, -0.2, 0.0, NaN, NaN, 0.0, 0.3, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (intersecting_cells[1] == [1, 10, 13])
    @test (intersecting_cells[2] == [3, 10, 13])
    @test (length(intersecting_cells) == 2)
    reset_value_and_test(
        out, [[10, 13]], [[1, 10, 13], [3, 10, 13]], Vector{Vector{Int64}}()
    )

    # Test: IC-LIC-8
    set_height(out, 10, 14, 0.1, 0.2, 0.3, NaN, NaN, -0.1, 0.0, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (intersecting_cells == [[3, 10, 14]])
    reset_value_and_test(
        out, [[10, 14]], [[1, 10, 14], [3, 10, 14]], Vector{Vector{Int64}}()
    )

    # Test: IC-LIC-9
    set_height(out, 10, 15, 0.1, -0.3, -0.2, NaN, NaN, 0.5, 0.6, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (intersecting_cells == [[1, 10, 15]])
    reset_value_and_test(
        out, [[10, 15]], [[1, 10, 15], [3, 10, 15]], Vector{Vector{Int64}}()
    )

    # Test: IC-LIC-10
    set_height(out, 10, 16, 0.1, -0.3, -0.2, NaN, NaN, -0.6, -0.4, NaN, NaN)
    intersecting_cells = _locate_intersecting_cells(out)
    @test (intersecting_cells[1] == [1, 10, 16])
    @test (intersecting_cells[2] == [3, 10, 16])
    @test (length(intersecting_cells) == 2)
    reset_value_and_test(
        out, [[10, 16]], [[1, 10, 16], [3, 10, 16]], Vector{Vector{Int64}}()
    )
end

@testset "_move_intersecting_body!" begin
    # Test: IC-MIB-1
    out.body[1][11:12, 16:18] .= 0.0
    out.body[2][11:12, 16:18] .= 0.5
    set_height(out, 10, 16, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 10, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    out.terrain[11, 17] = 0.1
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 17] ≈ 0.1)
    body_pos = [
        [1, 10, 16], [1, 10, 18], [1, 11, 16], [1, 11, 17], [1, 11, 18], [1, 12, 16],
        [1, 12, 17], [1, 12, 18]
    ]
    reset_value_and_test(out, [[10, 17]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-2
    out.body[1][10:11, 16:18] .= 0.0
    out.body[2][10:11, 16:18] .= 0.5
    set_height(out, 12, 16, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    out.terrain[11, 17] = 0.2
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[12, 17] ≈ 0.2)
    body_pos = [
        [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 11, 16], [1, 11, 17], [1, 11, 18],
        [1, 12, 16], [1, 12, 18]
    ]
    reset_value_and_test(out, [[12, 17]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-3
    out.body[1][10:12, 17:18] .= 0.0
    out.body[2][10:12, 17:18] .= 0.5
    set_height(out, 10, 16, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 16, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    out.terrain[11, 17] = 0.05
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[11, 16] ≈ 0.05)
    body_pos = [
        [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 11, 17], [1, 11, 18], [1, 12, 16],
        [1, 12, 17], [1, 12, 18]
    ]
    reset_value_and_test(out, [[11, 16]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-4
    out.body[1][10:12, 16:17] .= 0.0
    out.body[2][10:12, 16:17] .= 0.5
    set_height(out, 10, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    out.terrain[11, 17] = 0.25
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[11, 18] ≈ 0.25)
    body_pos = [
        [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 11, 16], [1, 11, 17], [1, 12, 16],
        [1, 12, 17], [1, 12, 18]
    ]
    reset_value_and_test(out, [[11, 18]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-5
    out.body[1][10:12, 17:18] .= 0.0
    out.body[2][10:12, 17:18] .= 0.5
    set_height(out, 11, 16, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 16, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    out.terrain[11, 17] = 0.4
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 16] ≈ 0.4)
    body_pos = [
        [1, 10, 17], [1, 10, 18], [1, 11, 16], [1, 11, 17], [1, 11, 18], [1, 12, 16],
        [1, 12, 17], [1, 12, 18]
    ]
    reset_value_and_test(out, [[10, 16]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-6
    out.body[1][10:12, 17:18] .= 0.0
    out.body[2][10:12, 17:18] .= 0.5
    set_height(out, 10, 16, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 16, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    out.terrain[11, 17] = 0.1
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[12, 16] ≈ 0.1)
    body_pos = [
        [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 11, 16], [1, 11, 17], [1, 11, 18],
        [1, 12, 17], [1, 12, 18]
    ]
    reset_value_and_test(out, [[12, 16]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-7
    out.body[1][10:12, 16:17] .= 0.0
    out.body[2][10:12, 16:17] .= 0.5
    set_height(out, 11, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 18] ≈ 0.5)
    body_pos = [
        [1, 10, 16], [1, 10, 17], [1, 11, 16], [1, 11, 17], [1, 11, 18], [1, 12, 16],
        [1, 12, 17], [1, 12, 18]
    ]
    reset_value_and_test(out, [[10, 18]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-8
    out.body[1][10:12, 16:17] .= 0.0
    out.body[2][10:12, 16:17] .= 0.5
    set_height(out, 10, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    out.terrain[11, 17] = 0.8
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[12, 18] ≈ 0.8)
    body_pos = [
        [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 11, 16], [1, 11, 17], [1, 11, 18],
        [1, 12, 16], [1, 12, 17]
    ]
    reset_value_and_test(out, [[12, 18]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-9
    out.body[3][10:12, 16:17] .= 0.0
    out.body[4][10:12, 16:17] .= 0.5
    set_height(out, 11, 18, NaN, NaN, NaN, NaN, NaN, 0.0, 0.5, NaN, NaN)
    set_height(out, 12, 18, NaN, NaN, NaN, NaN, NaN, 0.0, 0.5, NaN, NaN)
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 18] ≈ 0.5)
    body_pos = [
        [3, 10, 16], [3, 10, 17], [3, 11, 16], [3, 11, 17], [3, 11, 18], [3, 12, 16],
        [3, 12, 17], [3, 12, 18]
    ]
    reset_value_and_test(out, [[10, 18]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-10
    set_height(out, 10, 16, NaN, NaN, NaN, NaN, NaN, 0.0, 0.5, NaN, NaN)
    set_height(out, 10, 17, NaN, NaN, NaN, NaN, NaN, 0.0, 0.5, NaN, NaN)
    set_height(out, 11, 16, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 17, 0.5, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 16, NaN, 0.0, 0.5, NaN, NaN, 0.6, 0.8, NaN, NaN)
    set_height(out, 12, 17, NaN, 0.0, 0.5, NaN, NaN, 0.6, 0.8, NaN, NaN)
    set_height(out, 12, 18, NaN, NaN, NaN, NaN, NaN, 0.0, 0.5, NaN, NaN)
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 18] ≈ 0.5)
    body_pos = [
        [3, 10, 16], [3, 10, 17], [1, 11, 16], [1, 11, 17], [1, 11, 18], [1, 12, 16],
        [3, 12, 16], [1, 12, 17], [3, 12, 17], [3, 12, 18]
    ]
    reset_value_and_test(out, [[10, 18]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-11
    out.body[1][10:12, 16:17] .= 0.0
    out.body[2][10:12, 16:17] .= 0.2
    set_height(out, 10, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 18, NaN, 0.0, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 17, 0.8, 0.5, 0.6, NaN, NaN, -0.2, 0.3, NaN, NaN)
    out.terrain[11, 17] = 0.8
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ -0.2) && (out.terrain[12, 18] ≈ 1.0)
    body_pos = [
        [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 11, 16], [1, 11, 17], [3, 11, 17],
        [1, 11, 18], [1, 12, 16], [1, 12, 17]
    ]
    reset_value_and_test(out, [[12, 18], [11, 17]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-12
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    set_height(out, 8, 17, NaN, 0.0, 0.0, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 17, 0.5, -0.4, 0.6, NaN, NaN, NaN, NaN, NaN, NaN)
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[8, 17] ≈ 0.9)
    body_pos = Vector{Vector{Int64}}()
    for ii in 8:14
        for jj in 14:20
            push!(body_pos, [1, ii, jj])
        end
    end
    reset_value_and_test(out, [[8, 17], [11, 17]], body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-13
    set_RNG_seed!(1234)
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    set_height(out, 8, 17, NaN, 0.25, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 10, 17, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 17, 0.5, -0.5, 0.6, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 17, NaN, 0.2, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 13, 17, NaN, 0.05, 0.4, NaN, NaN, 0.6, 0.7, NaN, NaN)
    set_height(out, 13, 19, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 14, 20, NaN, 0.0, 0.0, NaN, NaN, 0.2, 0.4, NaN, NaN)
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ -0.5) && (out.terrain[10, 17] ≈ 0.1)
    @test (out.terrain[8, 17] ≈ 0.15) && (out.terrain[12, 17] ≈ 0.2)
    @test (out.terrain[13, 17] ≈ 0.05) && (out.terrain[13, 19] ≈ 0.3)
    @test (out.terrain[14, 20] ≈ 0.2)
    body_pos = [
        [1, 8, 14], [1, 8, 15], [1, 8, 16], [1, 8, 17], [1, 8, 18], [1, 8, 19], [1, 8, 20],
        [1, 9, 14], [1, 9, 15], [1, 9, 16], [1, 9, 17], [1, 9, 18], [1, 9, 19], [1, 9, 20],
        [1, 10, 14], [1, 10, 15], [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 10, 19],
        [1, 10, 20], [1, 11, 14], [1, 11, 15], [1, 11, 16], [1, 11, 17], [1, 11, 18],
        [1, 11, 19], [1, 11, 20], [1, 12, 14], [1, 12, 15], [1, 12, 16], [1, 12, 17],
        [1, 12, 18], [1, 12, 19], [1, 12, 20], [1, 13, 14], [1, 13, 15], [1, 13, 16],
        [1, 13, 17], [1, 13, 18], [1, 13, 19], [1, 13, 20], [1, 14, 14], [1, 14, 15],
        [1, 14, 16], [1, 14, 17], [1, 14, 18], [1, 14, 19], [3, 13, 17], [3, 14, 20]
    ]
    reset_value_and_test(
        out, [[11, 17], [10, 17], [8, 17], [12, 17], [13, 17], [13, 19], [14, 20]],
        body_pos, Vector{Vector{Int64}}()
    )

    # Test: IC-MIB-14
    set_RNG_seed!(1234)
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    set_height(out, 8, 17, NaN, 0.25, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 10, 17, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 17, 0.8, -0.5, 0.6, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 17, NaN, 0.2, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 13, 17, NaN, 0.05, 0.4, NaN, NaN, 0.6, 0.7, NaN, NaN)
    set_height(out, 13, 19, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 14, 20, NaN, 0.0, 0.0, NaN, NaN, 0.2, 0.4, NaN, NaN)
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.5) && (out.terrain[10, 17] ≈ 0.1)
    @test (out.terrain[8, 17] ≈ 0.25) && (out.terrain[12, 17] ≈ 0.2)
    @test (out.terrain[13, 17] ≈ 0.05) && (out.terrain[13, 19] ≈ 0.3)
    @test (out.terrain[14, 20] ≈ 0.2) && (out.terrain[15, 13] ≈ 0.2)
    terrain_pos = [
        [11, 17], [10, 17], [8, 17], [12, 17], [13, 17], [13, 19], [14, 20], [15, 13]
    ]
    body_pos = [
        [1, 8, 14], [1, 8, 15], [1, 8, 16], [1, 8, 17], [1, 8, 18], [1, 8, 19], [1, 8, 20],
        [1, 9, 14], [1, 9, 15], [1, 9, 16], [1, 9, 17], [1, 9, 18], [1, 9, 19], [1, 9, 20],
        [1, 10, 14], [1, 10, 15], [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 10, 19],
        [1, 10, 20], [1, 11, 14], [1, 11, 15], [1, 11, 16], [1, 11, 17], [1, 11, 18],
        [1, 11, 19], [1, 11, 20], [1, 12, 14], [1, 12, 15], [1, 12, 16], [1, 12, 17],
        [1, 12, 18], [1, 12, 19], [1, 12, 20], [1, 13, 14], [1, 13, 15], [1, 13, 16],
        [1, 13, 17], [1, 13, 18], [1, 13, 19], [1, 13, 20], [1, 14, 14], [1, 14, 15],
        [1, 14, 16], [1, 14, 17], [1, 14, 18], [1, 14, 19], [3, 13, 17], [3, 14, 20]
    ]
    reset_value_and_test(out, terrain_pos, body_pos, Vector{Vector{Int64}}())

    # Test: IC-MIB-15
    set_RNG_seed!(1234)
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    set_height(out, 8, 17, NaN, 0.25, 0.4, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 10, 17, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 17, 0.6, -0.5, 0.6, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 17, NaN, 0.2, 0.3, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 13, 17, NaN, 0.05, 0.4, NaN, NaN, 0.6, 0.7, NaN, NaN)
    set_height(out, 13, 19, NaN, 0.3, 0.5, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 14, 20, NaN, 0.0, 0.0, NaN, NaN, 0.2, 0.4, NaN, NaN)
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ -0.5) && (out.terrain[10, 17] ≈ 0.1)
    @test (out.terrain[8, 17] ≈ 0.25) && (out.terrain[12, 17] ≈ 0.2)
    @test (out.terrain[13, 17] ≈ 0.05) && (out.terrain[13, 19] ≈ 0.3)
    @test (out.terrain[14, 20] ≈ 0.2)
    body_pos = [
        [1, 8, 14], [1, 8, 15], [1, 8, 16], [1, 8, 17], [1, 8, 18], [1, 8, 19], [1, 8, 20],
        [1, 9, 14], [1, 9, 15], [1, 9, 16], [1, 9, 17], [1, 9, 18], [1, 9, 19], [1, 9, 20],
        [1, 10, 14], [1, 10, 15], [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 10, 19],
        [1, 10, 20], [1, 11, 14], [1, 11, 15], [1, 11, 16], [1, 11, 17], [1, 11, 18],
        [1, 11, 19], [1, 11, 20], [1, 12, 14], [1, 12, 15], [1, 12, 16], [1, 12, 17],
        [1, 12, 18], [1, 12, 19], [1, 12, 20], [1, 13, 14], [1, 13, 15], [1, 13, 16],
        [1, 13, 17], [1, 13, 18], [1, 13, 19], [1, 13, 20], [1, 14, 14], [1, 14, 15],
        [1, 14, 16], [1, 14, 17], [1, 14, 18], [1, 14, 19], [3, 13, 17], [3, 14, 20]
    ]
    reset_value_and_test(
        out, [[11, 17], [10, 17], [8, 17], [12, 17], [13, 17], [13, 19], [14, 20]],
        body_pos, Vector{Vector{Int64}}()
    )


    # Test: IC-MIB-16
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    _move_intersecting_body!(out)
    body_pos = [
        [1, 8, 14], [1, 8, 15], [1, 8, 16], [1, 8, 17], [1, 8, 18], [1, 8, 19], [1, 8, 20],
        [1, 9, 14], [1, 9, 15], [1, 9, 16], [1, 9, 17], [1, 9, 18], [1, 9, 19], [1, 9, 20],
        [1, 10, 14], [1, 10, 15], [1, 10, 16], [1, 10, 17], [1, 10, 18], [1, 10, 19],
        [1, 10, 20], [1, 11, 14], [1, 11, 15], [1, 11, 16], [1, 11, 17], [1, 11, 18],
        [1, 11, 19], [1, 11, 20], [1, 12, 14], [1, 12, 15], [1, 12, 16], [1, 12, 17],
        [1, 12, 18], [1, 12, 19], [1, 12, 20], [1, 13, 14], [1, 13, 15], [1, 13, 16],
        [1, 13, 17], [1, 13, 18], [1, 13, 19], [1, 13, 20], [1, 14, 14], [1, 14, 15],
        [1, 14, 16], [1, 14, 17], [1, 14, 18], [1, 14, 19], [1, 14, 20]
    ]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos, Vector{Vector{Int64}}()
    )

    # Test: IC-MIB-17
    set_RNG_seed!(1234)
    out.body[1][11, 17] = -0.4
    out.body[2][11, 17] = 0.6
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[12, 16] ≈ 0.9)
    out.terrain[12, 16] = 0.0
    # Repeating the same movement with a different seed
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[10, 17] ≈ 0.9)
    reset_value_and_test(
        out, [[11, 17], [10, 17]], [[1, 11, 17]], Vector{Vector{Int64}}()
    )
end
