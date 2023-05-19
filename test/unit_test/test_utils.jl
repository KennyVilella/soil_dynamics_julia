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
    body_soil_pos = _locate_all_non_zeros(out, out.body_soil)
    @test ([1, 5, 5] in body_soil_pos) && ([1, 4, 9] in body_soil_pos)
    @test ([1, 11, 7] in body_soil_pos) && ([3, 1, 1] in body_soil_pos)
    @test ([1, 3, 7] in body_soil_pos) && ([3, 3, 7] in body_soil_pos)
    @test (length(body_soil_pos) == 6)

    # Testing that cells in body are located properly
    body_pos = _locate_all_non_zeros(out, out.body)
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
