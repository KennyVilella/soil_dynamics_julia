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
@testset "_body_to_terrain!" begin
    # Setting a dummy body_soil
    out.body_soil[1][5, 5] = 0.1
    out.body_soil[2][5, 5] = 0.2
    out.body_soil[3][5, 5] = 0.5
    out.body_soil[4][5, 5] = 0.9
    out.body_soil[3][7, 9] = -0.2
    out.body_soil[4][7, 9] = 0.0
    out.body_soil[1][4, 9] = 0.1
    out.body_soil[2][4, 9] = 0.1
    out.body_soil[1][11, 7] = -0.5
    out.body_soil[2][11, 7] = -0.3
    out.body_soil[3][11, 7] = -0.2
    out.body_soil[4][11, 7] = -0.0
    out.body_soil[1][2, 7] = 0.0
    out.body_soil[2][2, 7] = 0.3

    # Testing for partial avalanche (1)
    _body_to_terrain!(out, 5, 5, 1, 1, 2, grid, 0.05)
    @test (out.body_soil[1][5, 5] ≈ 0.1) && (out.body_soil[2][5, 5] ≈ 0.15)
    @test out.terrain[1, 2] ≈ 0.05
    # Resetting terrain
    out.terrain[1, 2] = 0.0

    # Testing for partial avalanche (2)
    _body_to_terrain!(out, 5, 5, 3, 1, 3, grid, 0.2)
    @test (out.body_soil[3][5, 5] ≈ 0.5) && (out.body_soil[4][5, 5] ≈ 0.7)
    @test out.terrain[1, 3] ≈ 0.2
    # Resetting terrain
    out.terrain[1, 3] = 0.0

    # Testing for partial avalanche (3)
    _body_to_terrain!(out, 7, 9, 3, 1, 4, grid, 0.1)
    @test (out.body_soil[3][7, 9] ≈ -0.2) && (out.body_soil[4][7, 9] ≈ -0.1)
    @test out.terrain[1, 4] ≈ 0.1
    # Resetting terrain
    out.terrain[1, 4] = 0.0

    # Testing for full avalanche with default value (1)
    _body_to_terrain!(out, 5, 5, 1, 2, 3, grid)
    @test (out.body_soil[1][5, 5] == 0.0) && (out.body_soil[2][5, 5] == 0.0)
    @test out.terrain[2, 3] ≈ 0.05
    # Resetting terrain
    out.terrain[2, 3] = 0.0

    # Testing for full avalanche with default value (2)
    _body_to_terrain!(out, 5, 5, 3, 2, 4, grid)
    @test (out.body_soil[3][5, 5] == 0.0) && (out.body_soil[4][5, 5] == 0.0)
    @test out.terrain[2, 4] ≈ 0.2
    # Resetting terrain
    out.terrain[2, 4] = 0.0

    # Testing for full avalanche with inputted -1.0 (1)
    _body_to_terrain!(out, 11, 7, 1, 3, 4, grid, 1e8)
    @test (out.body_soil[1][11, 7] == 0.0) && (out.body_soil[2][11, 7] == 0.0)
    @test out.terrain[3, 4] ≈ 0.2
    # Resetting terrain
    out.terrain[3, 4] = 0.0

    # Testing for full avalanche with inputted -1.0 (2)
    _body_to_terrain!(out, 11, 7, 3, 3, 5, grid, 1e8)
    @test (out.body_soil[3][11, 7] == 0.0) && (out.body_soil[4][11, 7] == 0.0)
    @test out.terrain[3, 5] ≈ 0.2
    # Resetting terrain
    out.terrain[3, 5] = 0.0

    # Testing for full avalanche
    _body_to_terrain!(out, 7, 9, 3, 4, 5, grid, 0.1)
    @test (out.body_soil[3][7, 9] == 0.0) && (out.body_soil[4][7, 9] == 0.0)
    @test out.terrain[4, 5] ≈ 0.1
    # Resetting terrain
    out.terrain[4, 5] = 0.0

    # Testing for edge case where no soil is present
    _body_to_terrain!(out, 4, 9, 1, 5, 6, grid, 0.0)
    @test (out.body_soil[1][4, 9] == 0.0) && (out.body_soil[2][4, 9] == 0.0)
    @test out.terrain[5, 6] == 0.0

    # Testing that incorrect request throws an error
    @test_throws ErrorException _body_to_terrain!(out, 4, 9, 1, 6, 7, grid, 0.2)
    @test_throws ErrorException _body_to_terrain!(out, 1, 1, 3, 6, 8, grid, 0.1)
    @test_throws ErrorException _body_to_terrain!(out, 2, 7, 1, 6, 9, grid, 0.8)
    @test_throws ErrorException _body_to_terrain!(out, 2, 7, 3, 6, 9, grid, 0.2)

    # Resetting unused body_soil
    out.body_soil[1][2, 7] = 0.0
    out.body_soil[2][2, 7] = 0.0
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])

    # Testing that body_soil has not been unexpectedly modified
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    @test isempty(nonzeros(out.body_soil[3]))
    @test isempty(nonzeros(out.body_soil[4]))

    # Testing that terrain has not been unexpectedly modified
    @test all(out.terrain[:, :] .== 0.0)
end
