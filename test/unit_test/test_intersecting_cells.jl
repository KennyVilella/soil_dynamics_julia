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
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15]]
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
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15]]
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
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]])

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
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15]])

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
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15]])

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
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15]])

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
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [1, 11, 15]],
        [[1, 10, 15], [3, 10, 15]])

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
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15]])

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
        out, [[11, 15]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15]])

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
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]])

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
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]])

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
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]])

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
        [[1, 10, 15], [3, 10, 15], [3, 11, 15]])

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
        out, [[10, 16]], [[1, 10, 15], [3, 10, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15]])

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
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        out, [[12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        out, [[12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]])

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
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]])

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
        out, [[10, 16]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        out, [[12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]])

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
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]])

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
        out, [[10, 16]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [3, 12, 15]],
        [[1, 10, 15], [3, 10, 15], [1, 11, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 12, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, Vector{Vector{Int64}}(), body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]])

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
        [1, 10, 15], [3, 10, 15], [1, 11, 15], [3, 11, 15], [1, 12, 15],
        [3, 12, 15]]
    reset_value_and_test(
        out, [[13, 15]], body_pos,
        [[1, 10, 15], [3, 10, 15], [1, 11, 15], [1, 12, 15], [3, 12, 15]])

end

@testset "_locate_intersecting_cells" begin
    # Setting dummy values in body and terrain
    out.terrain[10, 11:16] .= 0.1
    out.terrain[11, 11] = -0.1
    out.body[1][5, 10] = 0.0
    out.body[2][5, 10] = 0.1
    out.body[3][6, 10] = 0.0
    out.body[4][6, 10] = 0.1
    out.body[1][7, 10] = 0.0
    out.body[2][7, 10] = 0.1
    out.body[3][7, 10] = 0.2
    out.body[4][7, 10] = 0.3
    out.body[1][11, 11] = -0.1
    out.body[2][11, 11] = 0.0
    out.body[1][10, 11] = 0.0
    out.body[2][10, 11] = 0.1
    out.body[3][10, 12] = -0.1
    out.body[4][10, 12] = 0.0
    out.body[1][10, 13] = -0.2
    out.body[2][10, 13] = 0.0
    out.body[3][10, 13] = 0.0
    out.body[4][10, 13] = 0.3
    out.body[1][10, 14] = 0.2
    out.body[2][10, 14] = 0.3
    out.body[3][10, 14] = -0.1
    out.body[4][10, 14] = 0.0
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body[1][10, 16] = -0.3
    out.body[2][10, 16] = -0.2
    out.body[3][10, 16] = -0.6
    out.body[4][10, 16] = -0.4

    # Testing that intersecting cells are properly located
    intersecting_cells = _locate_intersecting_cells(out)
    @test ([1, 10, 11] in intersecting_cells) && ([3, 10, 12] in intersecting_cells)
    @test ([1, 10, 13] in intersecting_cells) && ([3, 10, 13] in intersecting_cells)
    @test ([3, 10, 14] in intersecting_cells) && ([1, 10, 15] in intersecting_cells)
    @test ([1, 10, 13] in intersecting_cells) && ([3, 10, 16] in intersecting_cells)
    @test (length(intersecting_cells) == 8)
    # Resetting body and terrain
    out.body[1][5, 10] = 0.0
    out.body[2][5, 10] = 0.0
    out.body[3][6, 10] = 0.0
    out.body[4][6, 10] = 0.0
    out.body[1][7, 10] = 0.0
    out.body[2][7, 10] = 0.0
    out.body[3][7, 10] = 0.0
    out.body[4][7, 10] = 0.0
    out.body[1][10, 11:16] .= 0.0
    out.body[2][10, 11:16] .= 0.0
    out.body[3][10, 11:16] .= 0.0
    out.body[4][10, 11:16] .= 0.0
    out.body[1][11, 11] = 0.0
    out.body[2][11, 11] = 0.0
    out.terrain[10, 11:16] .= 0.0
    out.terrain[11, 11] = 0.0

    # Removing zeros from Sparse matrices
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])

    # Checking that nothing has been unexpectedly modified
    @test all(out.terrain[:, :] .== 0.0)
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    @test isempty(nonzeros(out.body_soil[3]))
    @test isempty(nonzeros(out.body_soil[4]))
end

@testset "_move_intersecting_body!" begin
    # Testing for a single intersecting cells in the -X direction
    out.body[1][11:12, 16:18] .= 0.0
    out.body[2][11:12, 16:18] .= 0.5
    out.body[1][10, 16] = 0.0
    out.body[2][10, 16] = 0.5
    out.body[1][10, 18] = 0.0
    out.body[2][10, 18] = 0.5
    out.terrain[11, 17] = 0.1
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 17] ≈ 0.1)
    out.terrain[10, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells in the +X direction
    out.body[1][10:11, 16:18] .= 0.0
    out.body[2][10:11, 16:18] .= 0.5
    out.body[1][12, 16] = 0.0
    out.body[2][12, 16] = 0.5
    out.body[1][12, 18] = 0.0
    out.body[2][12, 18] = 0.5
    out.terrain[11, 17] = 0.2
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[12, 17] ≈ 0.2)
    out.terrain[12, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells in the -Y direction
    out.body[1][10:12, 17:18] .= 0.0
    out.body[2][10:12, 17:18] .= 0.5
    out.body[1][10, 16] = 0.0
    out.body[2][10, 16] = 0.5
    out.body[1][12, 16] = 0.0
    out.body[2][12, 16] = 0.5
    out.terrain[11, 17] = 0.05
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[11, 16] ≈ 0.05)
    out.terrain[11, 16] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells in the +Y direction
    out.body[1][10:12, 16:17] .= 0.0
    out.body[2][10:12, 16:17] .= 0.5
    out.body[1][10, 18] = 0.0
    out.body[2][10, 18] = 0.5
    out.body[1][12, 18] = 0.0
    out.body[2][12, 18] = 0.5
    out.terrain[11, 17] = 0.25
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[11, 18] ≈ 0.25)
    out.terrain[11, 18] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells in the -X-Y direction
    out.body[1][10:12, 17:18] .= 0.0
    out.body[2][10:12, 17:18] .= 0.5
    out.body[1][11, 16] = 0.0
    out.body[2][11, 16] = 0.5
    out.body[1][12, 16] = 0.0
    out.body[2][12, 16] = 0.5
    out.terrain[11, 17] = 0.4
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 16] ≈ 0.4)
    out.terrain[10, 16] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells in the +X-Y direction
    out.body[1][10:12, 17:18] .= 0.0
    out.body[2][10:12, 17:18] .= 0.5
    out.body[1][10, 16] = 0.0
    out.body[2][10, 16] = 0.5
    out.body[1][11, 16] = 0.0
    out.body[2][11, 16] = 0.5
    out.terrain[11, 17] = 0.1
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[12, 16] ≈ 0.1)
    out.terrain[12, 16] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells in the -X+Y direction
    out.body[1][10:12, 16:17] .= 0.0
    out.body[2][10:12, 16:17] .= 0.5
    out.body[1][11, 18] = 0.0
    out.body[2][11, 18] = 0.5
    out.body[1][12, 18] = 0.0
    out.body[2][12, 18] = 0.5
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 18] ≈ 0.5)
    out.terrain[10, 18] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells in the +X+Y direction
    out.body[1][10:12, 16:17] .= 0.0
    out.body[2][10:12, 16:17] .= 0.5
    out.body[1][10, 18] = 0.0
    out.body[2][10, 18] = 0.5
    out.body[1][11, 18] = 0.0
    out.body[2][11, 18] = 0.5
    out.terrain[11, 17] = 0.8
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[12, 18] ≈ 0.8)
    out.terrain[12, 18] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells in the second bucket layer
    out.body[3][10:12, 16:17] .= 0.0
    out.body[4][10:12, 16:17] .= 0.5
    out.body[3][11, 18] = 0.0
    out.body[4][11, 18] = 0.5
    out.body[3][12, 18] = 0.0
    out.body[4][12, 18] = 0.5
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 18] ≈ 0.5)
    out.terrain[10, 18] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[3][10:12, 16:18] .= 0.0
    out.body[4][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells with various bucket layer
    out.body[3][10, 16:17] .= 0.0
    out.body[4][10, 16:17] .= 0.5
    out.body[1][11, 16:17] .= 0.0
    out.body[2][11, 16:17] .= 0.5
    out.body[1][12, 16:17] .= 0.0
    out.body[2][12, 16:17] .= 0.5
    out.body[3][12, 16:17] .= 0.6
    out.body[4][12, 16:17] .= 0.8
    out.body[1][11, 18] = 0.0
    out.body[2][11, 18] = 0.5
    out.body[3][12, 18] = 0.0
    out.body[4][12, 18] = 0.5
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ 0.0) && (out.terrain[10, 18] ≈ 0.5)
    out.terrain[10, 18] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[3][10:12, 16:18] .= 0.0
    out.body[4][10:12, 16:18] .= 0.0

    # Testing for a single intersecting cells with all bucket under terrain
    out.body[1][10:12, 16:17] .= 0.0
    out.body[2][10:12, 16:17] .= 0.2
    out.body[1][10, 18] = 0.0
    out.body[2][10, 18] = 0.5
    out.body[1][11, 18] = 0.0
    out.body[2][11, 18] = 0.5
    out.body[1][11, 17] = 0.5
    out.body[2][11, 17] = 0.6
    out.body[3][11, 17] = -0.2
    out.body[4][11, 17] = 0.3
    out.terrain[11, 17] = 0.8
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.2) && (out.terrain[12, 18] ≈ 1.0)
    out.terrain[12, 18] = 0.0
    out.terrain[11, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0
    out.body[3][11, 17] = 0.0
    out.body[4][11, 17] = 0.0

    # Testing for a single intersecting cells under a large bucket
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    out.body[1][11, 17] = -0.4
    out.body[2][11, 17] = 0.6
    out.body[1][8, 17] = 0.0
    out.body[2][8, 17] = 0.0
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[8, 17] ≈ 0.9)
    out.terrain[8, 17] = 0.0
    out.terrain[11, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.0

    # Testing when soil is moved by small amount (1)
    # Soil is fitting under the bucket
    set_RNG_seed!(1234)
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    out.body[1][11, 17] = -0.5
    out.body[2][11, 17] = 0.6
    out.body[1][10, 17] = 0.1
    out.body[2][10, 17] = 0.2
    out.body[1][8, 17] = 0.25
    out.body[2][8, 17] = 0.4
    out.body[1][12, 17] = 0.2
    out.body[2][12, 17] = 0.3
    out.body[1][13, 17] = 0.05
    out.body[2][13, 17] = 0.4
    out.body[3][13, 17] = 0.6
    out.body[4][13, 17] = 0.7
    out.body[1][13, 19] = 0.3
    out.body[2][13, 19] = 0.5
    out.body[3][14, 20] = 0.2
    out.body[4][14, 20] = 0.4
    out.body[1][14, 20] = 0.0
    out.body[2][14, 20] = 0.0
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.5) && (out.terrain[10, 17] ≈ 0.1)
    @test (out.terrain[8, 17] ≈ 0.15) && (out.terrain[12, 17] ≈ 0.2)
    @test (out.terrain[13, 17] ≈ 0.05) && (out.terrain[13, 19] ≈ 0.3)
    @test (out.terrain[14, 20] ≈ 0.2)
    out.terrain[11, 17] = 0.0
    out.terrain[10, 17] = 0.0
    out.terrain[8, 17] = 0.0
    out.terrain[12, 17] = 0.0
    out.terrain[13, 17] = 0.0
    out.terrain[13, 19] = 0.0
    out.terrain[14, 20] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.0
    out.body[3][8:14, 14:20] .= 0.0
    out.body[4][8:14, 14:20] .= 0.0

    # Testing when soil is moved by small amount (2)
    # Soil is going out of the bucket
    set_RNG_seed!(1234)
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    out.body[1][11, 17] = -0.5
    out.body[2][11, 17] = 0.6
    out.body[1][10, 17] = 0.1
    out.body[2][10, 17] = 0.2
    out.body[1][8, 17] = 0.25
    out.body[2][8, 17] = 0.4
    out.body[1][12, 17] = 0.2
    out.body[2][12, 17] = 0.3
    out.body[1][13, 17] = 0.05
    out.body[2][13, 17] = 0.4
    out.body[3][13, 17] = 0.6
    out.body[4][13, 17] = 0.7
    out.body[1][13, 19] = 0.3
    out.body[2][13, 19] = 0.5
    out.body[3][14, 20] = 0.2
    out.body[4][14, 20] = 0.4
    out.body[1][14, 20] = 0.0
    out.body[2][14, 20] = 0.0
    out.terrain[11, 17] = 0.8
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.5) && (out.terrain[10, 17] ≈ 0.1)
    @test (out.terrain[8, 17] ≈ 0.25) && (out.terrain[12, 17] ≈ 0.2)
    @test (out.terrain[13, 17] ≈ 0.05) && (out.terrain[13, 19] ≈ 0.3)
    @test (out.terrain[14, 20] ≈ 0.2) && (out.terrain[15, 13] ≈ 0.2)
    out.terrain[11, 17] = 0.0
    out.terrain[10, 17] = 0.0
    out.terrain[8, 17] = 0.0
    out.terrain[12, 17] = 0.0
    out.terrain[13, 17] = 0.0
    out.terrain[13, 19] = 0.0
    out.terrain[14, 20] = 0.0
    out.terrain[15, 13] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.0
    out.body[3][8:14, 14:20] .= 0.0
    out.body[4][8:14, 14:20] .= 0.0

    # Testing when soil is moved by small amount (3)
    # Soil is just fitting under the bucket
    set_RNG_seed!(1234)
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    out.body[1][11, 17] = -0.5
    out.body[2][11, 17] = 0.6
    out.body[1][10, 17] = 0.1
    out.body[2][10, 17] = 0.2
    out.body[1][8, 17] = 0.25
    out.body[2][8, 17] = 0.4
    out.body[1][12, 17] = 0.2
    out.body[2][12, 17] = 0.3
    out.body[1][13, 17] = 0.05
    out.body[2][13, 17] = 0.4
    out.body[3][13, 17] = 0.6
    out.body[4][13, 17] = 0.7
    out.body[1][13, 19] = 0.3
    out.body[2][13, 19] = 0.5
    out.body[3][14, 20] = 0.2
    out.body[4][14, 20] = 0.4
    out.body[1][14, 20] = 0.0
    out.body[2][14, 20] = 0.0
    out.terrain[11, 17] = 0.6
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.5) && (out.terrain[10, 17] ≈ 0.1)
    @test (out.terrain[8, 17] ≈ 0.25) && (out.terrain[12, 17] ≈ 0.2)
    @test (out.terrain[13, 17] ≈ 0.05) && (out.terrain[13, 19] ≈ 0.3)
    @test (out.terrain[14, 20] ≈ 0.2)
    out.terrain[11, 17] = 0.0
    out.terrain[10, 17] = 0.0
    out.terrain[8, 17] = 0.0
    out.terrain[12, 17] = 0.0
    out.terrain[13, 17] = 0.0
    out.terrain[13, 19] = 0.0
    out.terrain[14, 20] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.0
    out.body[3][8:14, 14:20] .= 0.0
    out.body[4][8:14, 14:20] .= 0.0

    # Testing when there is nothing to move
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.2
    _move_intersecting_body!(out)
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.0

    # Testing randomness of movement
    set_RNG_seed!(1234)
    out.body[1][11, 17] = -0.4
    out.body[2][11, 17] = 0.6
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[12, 16] ≈ 0.9)
    out.terrain[12, 16] = 0.0
    out.terrain[11, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Second call
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[10, 17] ≈ 0.9)
    out.terrain[10, 17] = 0.0
    out.terrain[11, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][11, 17] = 0.0
    out.body[2][11, 17] = 0.0

    # Removing zeros from Sparse matrices
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])

    # Checking that nothing has been unexpectedly modified
    @test all(out.terrain[:, :] .== 0.0)
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    @test isempty(nonzeros(out.body_soil[3]))
    @test isempty(nonzeros(out.body_soil[4]))
end
