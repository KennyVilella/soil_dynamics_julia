"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#
grid_size_x = 1.0
grid_size_y = 1.0
grid_size_z = 1.0
cell_size_xy = 0.1
cell_size_z = 0.1
grid = GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)


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
