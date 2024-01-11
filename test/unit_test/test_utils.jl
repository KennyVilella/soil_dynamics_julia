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
@testset "_init_sparse_array!" begin
    # Setting dummy values in body
    out.body[1][5:17, 1:16] .= 1.0
    out.body[2][5:17, 1:16] .= 2.0
    out.body[3][4:10, 13:17] .= 0.0
    out.body[4][4:10, 13:17] .= 2*grid.half_length_z

    # Setting dummy values in body_soil
    out.body_soil[1][5:17, 1:16] .= 1.0
    out.body_soil[2][5:17, 1:16] .= 2.0
    out.body_soil[3][4:10, 13:17] .= 0.0
    out.body_soil[4][4:10, 13:17] .= 2*grid.half_length_z

    # Testing that body is properly reset
    _init_sparse_array!(out.body, grid)
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))

    # Testing that body_soil is properly reset
    _init_sparse_array!(out.body_soil, grid)
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    @test isempty(nonzeros(out.body_soil[3]))
    @test isempty(nonzeros(out.body_soil[4]))
end

@testset "_locate_non_zeros" begin
    # Setting dummy values in body_soil
    out.body_soil[1][5, 5] = 0.1
    out.body_soil[1][4, 9] = 0.0
    out.body_soil[1][11, 7] = -0.5
    out.body_soil[1][15, 1] = -0.2

    # Setting dummy values in body
    out.body[2][10, 10] = 0.0
    out.body[2][15, 11] = 0.3
    out.body[2][7, 1] = -0.3
    out.body[2][1, 2] = 0.01

    # Testing that non-empty cells are located properly in body_soil
    non_zeros = _locate_non_zeros(out.body_soil[1])
    @test ([5, 5] in non_zeros) && ([11, 7] in non_zeros) && ([15, 1] in non_zeros)
    @test (length(non_zeros) == 3)

    # Testing that non-empty cells are located properly in body
    non_zeros = _locate_non_zeros(out.body[2])
    @test ([15, 11] in non_zeros) && ([7, 1] in non_zeros) && ([1, 2] in non_zeros)
    @test (length(non_zeros) == 3)

    # Resetting properties
    out.body_soil[1][5, 5] = 0.0
    out.body_soil[1][11, 7] = 0.0
    out.body_soil[1][15, 1] = 0.0
    out.body[2][15, 11] = 0.0
    out.body[2][7, 1] = 0.0
    out.body[2][1, 2] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body[2])
end

@testset "_locate_all_non_zeros" begin
    # Setting dummy values in body_soil
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
    out.body_soil[1][6, 7] = 0.0
    out.body_soil[2][6, 7] = 0.0
    out.body_soil[3][9, 5] = 0.0
    out.body_soil[4][9, 5] = 0.0

    # Setting dummy values in body
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
    out.body[1][16, 7] = 0.0
    out.body[2][16, 7] = 0.0
    out.body[3][19, 5] = 0.0
    out.body[4][19, 5] = 0.0

    # Testing that cells in body_soil are located properly
    body_soil_pos = _locate_all_non_zeros(out.body_soil)
    @test ([1, 5, 5] in body_soil_pos) && ([1, 4, 9] in body_soil_pos)
    @test ([1, 11, 7] in body_soil_pos) && ([3, 1, 1] in body_soil_pos)
    @test ([1, 3, 7] in body_soil_pos) && ([3, 3, 7] in body_soil_pos)
    @test (length(body_soil_pos) == 6)

    # Testing that cells in body are located properly
    body_pos = _locate_all_non_zeros(out.body)
    @test ([1, 15, 5] in body_pos) && ([1, 4, 19] in body_pos)
    @test ([1, 11, 17] in body_pos) && ([3, 3, 3] in body_pos)
    @test ([1, 13, 17] in body_pos) && ([3, 13, 17] in body_pos)
    @test (length(body_soil_pos) == 6)

    # Resetting properties
    out.body_soil[1][5, 5] = 0.0
    out.body_soil[2][5, 5] = 0.0
    out.body_soil[2][4, 9] = 0.0
    out.body_soil[1][11, 7] = 0.0
    out.body_soil[2][11, 7] = 0.0
    out.body_soil[3][1, 1] = 0.0
    out.body_soil[4][1, 1] = 0.0
    out.body_soil[1][3, 7] = 0.0
    out.body_soil[4][3, 7] = 0.0
    out.body[1][15, 5] = 0.0
    out.body[2][15, 5] = 0.0
    out.body[2][4, 19] = 0.0
    out.body[1][11, 17] = 0.0
    out.body[2][11, 17] = 0.0
    out.body[3][3, 3] = 0.0
    out.body[4][3, 3] = 0.0
    out.body[1][13, 17] = 0.0
    out.body[4][13, 17] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])
end

@testset "calc_normal" begin
    # Setting dummy coordinates forming a triangle in the XY plane
    a = [0.0, 0.0, 0.0]
    b = [2.3, 0.0, 0.0]
    c = [2.3, 2.45, 0.0]

    # Testing that the unit normal vector follows the Z direction
    @test calc_normal(a, b, c) == [0.0, 0.0, 1.0]

    # Testing the opposite direction
    @test calc_normal(a, c, b) == [0.0, 0.0, -1.0]

    # Setting dummy coordinates forming a triangle in the XZ plane
    a = [1.0, 0.0, -1.3]
    b = [0.3, 0.0, 4.2]
    c = [2.3, 0.0, 3.0]

    # Testing that the unit normal vector follows the Y direction
    @test calc_normal(a, b, c) == [0.0, 1.0, 0.0]

    # Testing the opposite direction
    @test calc_normal(a, c, b) == [0.0, -1.0, 0.0]

    # Setting dummy coordinates forming a triangle in the YZ plane
    a = [0.0, -4.7, 1.3]
    b = [0.0, 7.2, -0.6]
    c = [0.0, -1.0, 54.3]

    # Testing that the unit normal vector follows the X direction
    @test calc_normal(a, b, c) == [1.0, 0.0, 0.0]

    # Testing the opposite direction
    @test calc_normal(a, c, b) == [-1.0, 0.0, 0.0]

    # Setting dummy coordinates following a 45 degrees inclined plane
    a = [1.0, 0.0, 0.0]
    b = [0.0, 1.0, 0.0]
    c = [0.0, 0.0, 1.0]

    # Testing that the unit normal vector follows the inclined plane
    @test calc_normal(a, b, c) ≈ [sqrt(1/3), sqrt(1/3), sqrt(1/3)]

    # Testing the opposite direction
    @test calc_normal(a, c, b) ≈ -[sqrt(1/3), sqrt(1/3), sqrt(1/3)]
end

@testset "set_RNG_seed!" begin
    # As it is difficult to retrieve the seed, instead of checking that the
    # seed is properly set, we rather test the reproducibility of the result

    # Testing for the default seed
    set_RNG_seed!()
    get_rand = rand(1)
    seed!(1234)
    exp_rand = rand(1)
    @test get_rand  == exp_rand

    # Testing with a different seed
    set_RNG_seed!(15034)
    get_rand = rand(1)
    seed!(15034)
    exp_rand = rand(1)
    @test get_rand  == exp_rand
end

@testset "check_volume" begin
    # Setting dummy properties
    init_volume = 0.0

    # Testing that no warning is sent for correct initial volume
    @test_logs check_volume(out, init_volume, grid)

    # Testing that warning is sent for incorrect initial volume
    @test_logs (:warn,) match_mode=:any check_volume(out, 1.0, grid)
    @test_logs (:warn,) match_mode=:any check_volume(
            out, init_volume - 0.6 * grid.cell_volume, grid
        )
    @test_logs (:warn,) match_mode=:any check_volume(
            out, init_volume + 0.6 * grid.cell_volume, grid
        )

    # Setting non-zero terrain
    out.terrain[1, 2] = 0.2
    init_volume =  0.2 * (grid.cell_size_xy * grid.cell_size_xy)

    # Testing that no warning is sent for correct initial volume
    @test_logs check_volume(out, init_volume, grid)

    # Testing that warning is sent for incorrect initial volume
    @test_logs (:warn,) match_mode=:any check_volume(out, 0.0, grid)
    @test_logs (:warn,) match_mode=:any check_volume(
            out, init_volume - 0.6 * grid.cell_volume, grid
        )
    @test_logs (:warn,) match_mode=:any check_volume(
            out, init_volume + 0.6 * grid.cell_volume, grid
        )
    @test_logs (:warn,) match_mode=:any check_volume(out, -init_volume, grid)

    # Setting non-zero body soil
    out.terrain[1, 2] = 0.0
    out.body_soil[1][2, 2] = -0.1
    out.body_soil[2][2, 2] = 0.0
    out.body_soil[3][2, 2] = 0.2
    out.body_soil[4][2, 2] = 0.27
    out.body_soil[1][1, 1] = 0.0
    out.body_soil[2][1, 1] = 0.08
    out.body_soil[3][2, 1] = 0.0
    out.body_soil[4][2, 1] = 0.15

    init_volume =  0.4 * (grid.cell_size_xy * grid.cell_size_xy)

    # Testing that no warning is sent for correct initial volume
    @test_logs check_volume(out, init_volume, grid)

    # Testing that warning is sent for incorrect initial volume
    @test_logs (:warn,) match_mode=:any check_volume(out, 0.0, grid)

    # Resetting body_soil
    out.body_soil[1][2, 2] = 0.0
    out.body_soil[2][2, 2] = 0.0
    out.body_soil[3][2, 2] = 0.0
    out.body_soil[4][2, 2] = 0.0
    out.body_soil[1][1, 1] = 0.0
    out.body_soil[2][1, 1] = 0.0
    out.body_soil[3][2, 1] = 0.0
    out.body_soil[4][2, 1] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])
end

@testset "check_soil" begin
    # Testing that no warning is sent when everything is at zero
    @test_logs check_soil(out)

    # Changing terrain to an arbitrary shape
    out.terrain[1, 1] = -0.2
    out.terrain[1, 2] = -0.15
    out.terrain[2, 1] = 0.0
    out.terrain[2, 2] = 0.0

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Setting the bucket
    out.body[1][1, 1] = -0.2
    out.body[2][1, 1] = 0.0
    out.body[1][1, 2] = -0.15
    out.body[2][1, 2] = 0.0
    out.body[3][1, 2] = 0.1
    out.body[4][1, 2] = 0.2
    out.body[3][2, 1] = 0.0
    out.body[4][2, 1] = 0.15
    out.body[1][2, 2] = 0.1
    out.body[2][2, 2] = 0.1

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Setting the bucket soil
    out.body_soil[1][1, 1] = 0.0
    out.body_soil[2][1, 1] = 0.1
    out.body_soil[1][1, 2] = 0.0
    out.body_soil[2][1, 2] = 0.1
    out.body_soil[3][1, 2] = 0.2
    out.body_soil[4][1, 2] = 0.3
    out.body_soil[3][2, 1] = 0.15
    out.body_soil[4][2, 1] = 0.25
    out.body_soil[1][2, 2] = 0.1
    out.body_soil[2][2, 2] = 0.1

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Testing that warning is sent when terrain is above the bucket
    out.terrain[1, 1] = 0.5
    warning_message = "Terrain is above the bucket\nLocation: (1, 1)\n" *
        "Terrain height: 0.5\nBucket minimum height: -0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.terrain[1, 1] = -0.19
    warning_message = "Terrain is above the bucket\nLocation: (1, 1)\n" *
        "Terrain height: -0.19\nBucket minimum height: -0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    # Resetting value
    out.terrain[1, 1] = -0.2

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Testing that warning is sent when body is not set properly
    out.body[1][1, 1] = 0.0
    out.body[2][1, 1] = -0.1
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.0\n" *
        "Bucket maximum height: -0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body_soil[1][1, 1] = 0.0
    out.body_soil[2][1, 1] = 0.0
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.0\n" *
        "Bucket maximum height: -0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[1][1, 1] = 0.41
    out.body[2][1, 1] = 0.4
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.41\n" *
        "Bucket maximum height: 0.4"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[2][1, 1] = 0.0
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.41\n" *
        "Bucket maximum height: 0.0"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[1][1, 1] = 0.0
    out.body[2][1, 1] = -0.4
    warning_message = "Minimum height of the bucket is above its maximum height\n" *
        "Location: (1, 1)\nBucket minimum height: 0.0\n" *
        "Bucket maximum height: -0.4"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    # Resetting value
    out.body[1][1, 1] = -0.2
    out.body[2][1, 1] = 0.0
    out.body_soil[1][1, 1] = 0.0
    out.body_soil[2][1, 1] = 0.1

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Testing that warning is sent when bucket soil is not set properly
    out.body_soil[1][1, 1] = 0.0
    out.body_soil[2][1, 1] = -0.1
    warning_message = "Minimum height of the bucket soil is above its maximum height\n" *
        "Location: (1, 1)\nBucket soil minimum height: 0.0\n" *
        "Bucket soil maximum height: -0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body_soil[1][1, 1] = 0.2
    out.body_soil[2][1, 1] = 0.0
    warning_message = "Minimum height of the bucket soil is above its maximum height\n" *
        "Location: (1, 1)\nBucket soil minimum height: 0.2\n" *
        "Bucket soil maximum height: 0.0"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    # Resetting value
    out.body_soil[1][1, 1] = 0.0
    out.body_soil[2][1, 1] = 0.1

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Testing that warning is sent when the bucket is above the bucket soil
    out.body[2][1, 1] = 0.05
    warning_message = "Bucket is above the bucket soil\nLocation: (1, 1)\n" *
        "Bucket maximum height: 0.05\nBucket soil minimum height: 0.0"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[4][1, 2] = 0.25
    warning_message = "Bucket is above the bucket soil\nLocation: (1, 2)\n" *
        "Bucket maximum height: 0.25\nBucket soil minimum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[4][1, 2] = 0.45
    warning_message = "Bucket is above the bucket soil\nLocation: (1, 2)\n" *
        "Bucket maximum height: 0.45\nBucket soil minimum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    # Resetting value
    out.body[2][1, 1] = 0.0
    out.body[4][1, 2] = 0.2

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Testing that warning is sent when there is a gap between bucket and bucket soil
    out.body_soil[1][1, 1] = 0.1
    warning_message = "Bucket soil is not above the bucket\nLocation: (1, 1)\n" *
        "Terrain height: -0.2\nBucket maximum height: 0.0\nBucket soil minimum height: 0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body_soil[1][1, 1] = 0.05
    warning_message = "Bucket soil is not above the bucket\nLocation: (1, 1)\n" *
        "Terrain height: -0.2\nBucket maximum height: 0.0\nBucket soil minimum height: 0.05"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    # Resetting value
    out.body_soil[1][1, 1] = 0.0

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Testing that warning is sent when there is bucket soil but no bucket
    out.body[3][1, 2] = 0.0
    out.body[4][1, 2] = 0.0
    warning_message = "Bucket soil is present but there is no bucket\nLocation: (1, 2)\n" *
        "Bucket soil minimum height: 0.2\nBucket soil maximum height: 0.3"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[3][1, 2] = 0.1
    out.body[4][1, 2] = 0.2
    out.body[1][1, 1] = 0.0
    out.body[2][1, 1] = 0.0
    warning_message = "Bucket soil is present but there is no bucket\nLocation: (1, 1)\n" *
        "Bucket soil minimum height: 0.0\nBucket soil maximum height: 0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    # Resetting value
    out.body[1][1, 1] = -0.2
    out.body[2][1, 1] = 0.0

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Testing that warning is sent when two bucket layers are intersecting
    out.terrain[3, 2] = -0.2
    out.body[1][3, 2] = -0.15
    out.body[2][3, 2] = 0.1
    out.body[3][3, 2] = 0.0
    out.body[4][3, 2] = 0.2
    warning_message = "The two bucket layers are intersecting\nLocation: (3, 2)\n" *
        "Bucket 1 minimum height: -0.15\nBucket 1 maximum height: 0.1\n" *
        "Bucket 2 minimum height: 0.0\nBucket 2 maximum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[2][3, 2] = 0.0
    warning_message = "The two bucket layers are intersecting\nLocation: (3, 2)\n" *
        "Bucket 1 minimum height: -0.15\nBucket 1 maximum height: 0.0\n" *
        "Bucket 2 minimum height: 0.0\nBucket 2 maximum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[1][3, 2] = 0.0
    out.body[2][3, 2] = 0.2
    out.body[3][3, 2] = -0.2
    out.body[4][3, 2] = 0.1
    warning_message = "The two bucket layers are intersecting\nLocation: (3, 2)\n" *
        "Bucket 1 minimum height: 0.0\nBucket 1 maximum height: 0.2\n" *
        "Bucket 2 minimum height: -0.2\nBucket 2 maximum height: 0.1"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body[4][3, 2] = 0.0
    warning_message = "The two bucket layers are intersecting\nLocation: (3, 2)\n" *
        "Bucket 1 minimum height: 0.0\nBucket 1 maximum height: 0.2\n" *
        "Bucket 2 minimum height: -0.2\nBucket 2 maximum height: 0.0"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    # Resetting value
    out.body[1][3, 2] = 0.0
    out.body[2][3, 2] = 0.0
    out.body[3][3, 2] = 0.0
    out.body[4][3, 2] = 0.0
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])

    # Testing that no warning is sent
    @test_logs check_soil(out)

    # Testing that warning is sent when a bucket layer and a bucket soil layer are
    # intersecting
    out.body[1][3, 2] = -0.15
    out.body[2][3, 2] = 0.0
    out.body[3][3, 2] = 0.1
    out.body[4][3, 2] = 0.2
    out.body_soil[1][3, 2] = 0.0
    out.body_soil[2][3, 2] = 0.15
    warning_message = "A bucket layer and a bucket soil layer are intersecting\n" *
        "Location: (3, 2)\nBucket soil 1 minimum height: 0.0\n" *
        "Bucket soil 1 maximum height: 0.15\nBucket 2 minimum height: 0.1\n" *
        "Bucket 2 maximum height: 0.2"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    out.body_soil[1][3, 2] = 0.0
    out.body_soil[2][3, 2] = 0.0
    out.body[3][3, 2] = -0.15
    out.body[4][3, 2] = 0.0
    out.body[1][3, 2] = 0.1
    out.body[2][3, 2] = 0.2
    out.body_soil[3][3, 2] = 0.0
    out.body_soil[4][3, 2] = 0.15
    warning_message = "A bucket layer and a bucket soil layer are intersecting\n" *
        "Location: (3, 2)\nBucket 1 minimum height: 0.1\nBucket 1 maximum height: 0.2\n" *
        "Bucket soil 2 minimum height: 0.0\nBucket soil 2 maximum height: 0.15"
    @test_logs (:warn, warning_message) match_mode=:any check_soil(out)
    # Checking that no warning is sent when at same height
    out.body_soil[4][3, 2] = 0.1
    @test_logs check_soil(out)
    # Resetting value
    out.body[1][3, 2] = 0.0
    out.body[2][3, 2] = 0.0
    out.body[3][3, 2] = 0.0
    out.body[4][3, 2] = 0.0
    out.body_soil[3][3, 2] = 0.0
    out.body_soil[4][3, 2] = 0.0
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])

    # Testing that no warning is sent
    @test_logs check_soil(out)
end
