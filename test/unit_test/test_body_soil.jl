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

    # Creating a function to reset the bucket pose
    function _reset_bucket_pose(bucket)
        bucket.pos[:] .= [0.0, 0.0, 0.0]
        bucket.ori[:] .= [1.0, 0.0, 0.0, 0.0]
    end

    # Test: BS-UBS-1
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = Quaternion([1.0, 0.0, 0.0, 0.0])
    set_height(out, 12, 11, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 11, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN)
    push_body_soil_pos(out, 1, 11, 11, [0.0, 0.0, 0.0], 0.1)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 12, 11, NaN, 0.1, 0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 12, 11, [0.0, 0.0, 0.0], 0.1)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[1, 12, 11]], [[1, 12, 11]])

    # Test: BS-UBS-2
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = Quaternion([1.0, 0.0, 0.0, 0.0])
    set_height(out, 12, 11, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 11, 11, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.1, 0.2)
    push_body_soil_pos(out, 3, 11, 11, [0.0, 0.0, 0.0], 0.1)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 12, 11, NaN, 0.1, 0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 12, 11, [0.0, 0.0, 0.0], 0.1)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[1, 12, 11]], [[1, 12, 11]])

    # Test: BS-UBS-3
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = Quaternion([1.0, 0.0, 0.0, 0.0])
    set_height(out, 12, 11, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN)
    set_height(out, 11, 11, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN)
    push_body_soil_pos(out, 1, 11, 11, [0.0, 0.0, 0.0], 0.1)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 12, 11, NaN, NaN, NaN, 0.1, 0.2)
    check_body_soil_pos(out.body_soil_pos[1], 3, 12, 11, [0.0, 0.0, 0.0], 0.1)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[3, 12, 11]], [[3, 12, 11]])

    # Test: BS-UBS-4
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = Quaternion([1.0, 0.0, 0.0, 0.0])
    set_height(out, 12, 11, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN)
    set_height(out, 11, 11, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.1, 0.2)
    push_body_soil_pos(out, 3, 11, 11, [0.0, 0.0, 0.0], 0.1)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 12, 11, NaN, NaN, NaN, 0.1, 0.2)
    check_body_soil_pos(out.body_soil_pos[1], 3, 12, 11, [0.0, 0.0, 0.0], 0.1)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[3, 12, 11]], [[3, 12, 11]])

    # Test: BS-UBS-5
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(-pi / 2, 0.0, 0.0, :ZYX)
    set_height(out, 11, 12, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 11, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN)
    push_body_soil_pos(out, 1, 12, 11, [0.1, 0.0, 0.0], 0.1)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 11, 12, NaN, 0.1, 0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 11, 12, [0.1, 0.0, 0.0], 0.1)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[1, 11, 12]], [[1, 11, 12]])

    # Test: BS-UBS-6
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(-pi / 4, 0.0, 0.0, :ZYX)
    set_height(out, 12, 12, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 11, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN)
    push_body_soil_pos(out, 1, 12, 11, [0.1, 0.0, 0.0], 0.1)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 12, 12, NaN, 0.1, 0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 12, 12, [0.1, 0.0, 0.0], 0.1)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[1, 12, 12]], [[1, 12, 12]])

    # Test: BS-UBS-7
    pos = Vector{Float64}([cell_size_xy, 0.0, 0.0])
    ori = angle_to_quat(-pi / 4, 0.0, 0.0, :ZYX)
    set_height(out, 13, 12, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 11, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN)
    push_body_soil_pos(out, 1, 12, 11, [0.1, 0.0, 0.0], 0.1)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 13, 12, NaN, 0.1, 0.2, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 13, 12, [0.1, 0.0, 0.0], 0.1)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[1, 13, 12]], [[1, 13, 12]])

    # Test: BS-UBS-8
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(0.0, pi, 0.0, :ZYX)
    set_height(out, 12, 11, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN)
    push_body_soil_pos(out, 1, 12, 11, [0.1, 0.0, 0.0], 0.1)
    warning_message = "WARNING\nBody soil could not be updated.\nSoil is moved to the " *
        "terrain to maintain mass conservation."
    @test_logs (:warn, warning_message) match_mode=:any _update_body_soil!(
        out, pos, ori, grid, bucket
    )
    check_height(out, 10, 11, 0.1, NaN, NaN, NaN, NaN)
    _reset_bucket_pose(bucket)
    reset_value_and_test(
        out, [[10, 11]], Vector{Vector{Int64}}(), Vector{Vector{Int64}}()
    )

    # Test: BS-UBS-9
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(0.0, pi / 2, 0.0, :ZYX)
    set_height(out, 11, 11, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 11, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 13, 11, NaN, NaN, NaN, 0.1, 0.3, NaN, NaN, NaN, NaN)
    push_body_soil_pos(out, 1, 12, 11, [0.1, 0.0, 0.0], 0.1)
    push_body_soil_pos(out, 1, 13, 11, [0.2, 0.0, 0.0], 0.2)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 11, 11, NaN, 0.1, 0.4, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 11, 11, [0.1, 0.0, 0.0], 0.1)
    check_body_soil_pos(out.body_soil_pos[2], 1, 11, 11, [0.2, 0.0, 0.0], 0.2)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[1, 11, 11]], [[1, 11, 11]])

    # Test: BS-UBS-10
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(0.0, pi / 2, 0.0, :ZYX)
    set_height(out, 11, 11, NaN, 0.0, 0.1, NaN, NaN, NaN, NaN, NaN, NaN)
    set_height(out, 12, 11, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 13, 11, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.1, 0.3)
    push_body_soil_pos(out, 1, 12, 11, [0.1, 0.0, 0.0], 0.1)
    push_body_soil_pos(out, 3, 13, 11, [0.2, 0.0, 0.0], 0.2)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 11, 11, NaN, 0.1, 0.4, NaN, NaN)
    check_body_soil_pos(out.body_soil_pos[1], 1, 11, 11, [0.1, 0.0, 0.0], 0.1)
    check_body_soil_pos(out.body_soil_pos[2], 1, 11, 11, [0.2, 0.0, 0.0], 0.2)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[1, 11, 11]], [[1, 11, 11]])

    # Test: BS-UBS-11
    pos = Vector{Float64}([0.0, 0.0, 0.0])
    ori = angle_to_quat(0.0, pi / 2, 0.0, :ZYX)
    set_height(out, 11, 11, NaN, NaN, NaN, NaN, NaN, 0.0, 0.1, NaN, NaN)
    set_height(out, 12, 11, NaN, NaN, NaN, 0.1, 0.2, NaN, NaN, NaN, NaN)
    set_height(out, 13, 11, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.1, 0.3)
    push_body_soil_pos(out, 1, 12, 11, [0.1, 0.0, 0.0], 0.1)
    push_body_soil_pos(out, 3, 13, 11, [0.2, 0.0, 0.0], 0.2)
    _update_body_soil!(out, pos, ori, grid, bucket)
    check_height(out, 11, 11, NaN, NaN, NaN, 0.1, 0.4)
    check_body_soil_pos(out.body_soil_pos[1], 3, 11, 11, [0.1, 0.0, 0.0], 0.1)
    check_body_soil_pos(out.body_soil_pos[2], 3, 11, 11, [0.2, 0.0, 0.0], 0.2)
    _reset_bucket_pose(bucket)
    reset_value_and_test(out, Vector{Vector{Int64}}(),  [[3, 11, 11]], [[3, 11, 11]])

    #======================================================================================#
    # The tests below are specific to the current implementation and may become obsolete   #
    # when the implementation change                                                       #
    #======================================================================================#


end
