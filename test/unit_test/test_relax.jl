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
@testset "_locate_unstable_terrain_cell" begin
    # Setting dummy terrain
    out.terrain[2, 2] = -0.1
    out.terrain[5, 2] = -0.2
    out.terrain[11, 13] = -0.2
    out.terrain[5, 13] = 0.2
    out.terrain[7, 13] = 0.1
    out.terrain[15, 5] = -0.4
    out.terrain[15, 6] = -0.2
    out.impact_area[:, :] .= Int64[[2, 2] [16, 14]]

    # Testing that all unstable cells are properly located
    unstable_cells = _locate_unstable_terrain_cell(out, 0.1)
    @test ([5, 3] in unstable_cells) && ([4, 2] in unstable_cells)
    @test ([6, 2] in unstable_cells) && ([11, 14] in unstable_cells)
    @test ([10, 13] in unstable_cells) && ([12, 13] in unstable_cells)
    @test ([11, 12] in unstable_cells) && ([5, 13] in unstable_cells)
    @test ([14, 5] in unstable_cells) && ([16, 5] in unstable_cells)
    @test ([15, 4] in unstable_cells) && ([15, 6] in unstable_cells)
    @test ([15, 7] in unstable_cells) && ([14, 6] in unstable_cells)
    @test ([16, 6] in unstable_cells)
    @test (length(unstable_cells) == 15)
    # Resetting terrain
    out.terrain[:, :] .= 0.0
    out.impact_area[:, :] .= Int64[[0, 0] [0, 0]]
end

@testset "_check_unstable_terrain_cell!" begin
    # Testing the case where there is no bucket and soil is not unstable
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)

    # Testing the case where there is no bucket and soil is unstable
    out.terrain[10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 40)
    # Resetting values
    out.terrain[10, 15] = 0.0

    # Testing the case where there is the first bucket layer and it has space under it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 10)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0

    # Testing the case where there is the first bucket layer and soil should avalanche on it
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 14)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer and it is high enough to
    # prevent the soil from avalanching
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and it has
    # space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.3
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 10)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # should avalanche on it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.3
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 13)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and it is high
    # enough to prevent the soil from avalanching
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and it has space under it
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.1
    out.body[4][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 20)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and soil should avalanche on
    # it
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 22)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and it is high enough to
    # prevent the soil from avalanching
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and it has
    # space under it
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.3
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 20)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # should avalanche on it
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.3
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 21)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and it is
    # high enough to prevent the soil from avalanching
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and it
    # has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # soil should avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # the second bucket layer is high enough to prevent the soil from avalanching, soil
    # avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = 0.2
    out.body[4][10, 15] = 0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and it
    # has space under it, while the second layer is with bucket soil
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower,
    # second bucket layer with bucket soil, soil avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # the second bucket layer with bucket soil is high enough to prevent the soil from
    # avalanching, soil avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower and has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower, soil avalanche on the first bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower, and the second bucket layer is high enough to prevent the soil from
    # avalanching, soil avalanche on the first bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower, soil fill the space between the two bucket layers, space is available
    # under the bucket
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower, soil fill the space between the two bucket layers, soil avalanche on
    # the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower, soil fill the space between the two bucket layers, second bucket layer
    # is high enough to prevent the soil from avalanching, soil does not avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and it has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, and soil should avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, and the second bucket layer is high enough to prevent the soil from
    # avalanching, soil avalanche on the first bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, soil fill the space between the two bucket layers, space is available
    # under the bucket
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.4
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, soil fill the space between the two bucket layers, soil avalanche on the
    # second bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.4
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, soil fill the space between the two bucket layers, second bucket layer
    # is high enough to prevent the soil from avalanching, soil does not avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.4
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # it has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # soil should avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # the first bucket layer is high enough to prevent the soil from avalanching, soil
    # avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # has space under it, while the first layer is with bucket soil
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower,
    # first bucket layer is with bucket soil, soil avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower,
    # the first bucket layer with bucket soil is high enough to prevent the soil from
    # avalanching, soil avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower and it has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower, soil avalanche on the second bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower, and the first bucket layer is high enough to prevent the soil from
    # avalanching, soil avalanche on the second bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower, soil fill the space between the two bucket layers, space is available
    # under the bucket
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower, soil fill the space between the two bucket layers, soil avalanche on the
    # first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower, soil fill the space between the two bucket layers, first bucket layer is
    # high enough to prevent the soil from avalanching, soil does not avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower, soil avalanche on the second bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower, and the first bucket layer is high enough to prevent the soil from
    # avalanching, soil avalanche on the second bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower, soil fill the space between the two bucket layers, space is available
    # under the bucket
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 30)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower, soil fill the space between the two bucket layers, soil avalanche on the
    # first bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing case where there are two bucket layers with bucket soil, second layer being
    # lower, soil fill the space between the two bucket layers, first bucket layer is high
    # enough to prevent soil from avalanching, soil does not avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the edge case where a lot of space under the bucket is present
    out.terrain[10, 15] = -1.0
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.6)
    @test (status == 10)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0

    # Testing the edge case for soil avalanching on the bucket
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.1
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0

    # Testing the edge case for soil avalanching on terrain
    out.terrain[10, 15] = -0.4
    status = _check_unstable_terrain_cell(out, 10, 15, -0.4)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
end

@testset "_relax_unstable_terrain_cell!" begin
    # Testing the case where there is no bucket and soil is unstable
    out.terrain[10, 14] = 0.4
    out.terrain[10, 15] = 0.1
    _relax_unstable_terrain_cell!(out, 40, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ 0.3) && (out.terrain[10, 15] ≈ 0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer and it has space under it,
    # the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.5
    out.body[2][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 10, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] ≈ -0.5)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer and it has space under it,
    # the soil partially avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.1
    _relax_unstable_terrain_cell!(out, 10, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.4) && (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer and soil should avalanche on it
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 14, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.4)
    @test (out.body_soil[1][10, 15] ≈ -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer with bucket soil and it has
    # space under it, the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.3
    _relax_unstable_terrain_cell!(out, 10, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] ≈ -0.5) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer with bucket soil and it has
    # space under it, the soil partially avalanche
    out.terrain[10, 15] = -0.7
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.3
    _relax_unstable_terrain_cell!(out, 10, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil[1][10, 15] ≈ -0.1) && (out.body_soil[2][10, 15] ≈ 0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # should avalanche on it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.3
    _relax_unstable_terrain_cell!(out, 13, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] ≈ -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer and it has space under it,
    # the soil fully avalanche
    out.terrain[10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.3
    _relax_unstable_terrain_cell!(out, 20, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.2) && (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer and it has space under it,
    # the soil partially avalanche
    out.terrain[10, 15] = -0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    _relax_unstable_terrain_cell!(out, 20, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] ≈ -0.3)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer and soil should avalanche on
    # it
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    _relax_unstable_terrain_cell!(out, 22, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer with bucket soil and it has
    # space under it, the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.3
    _relax_unstable_terrain_cell!(out, 20, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] == -0.3)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer with bucket soil and it has
    # space under it, the soil partially avalanche
    out.terrain[10, 15] = -0.3
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.5
    _relax_unstable_terrain_cell!(out, 20, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.5)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # should avalanche on it
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.3
    _relax_unstable_terrain_cell!(out, 21, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.8)
    @test (out.body_soil[3][10, 15] ≈ -0.5) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and it
    # has space under it, the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6 
    out.body[3][10, 15] = -0.4 
    out.body[4][10, 15] = -0.3 
    _relax_unstable_terrain_cell!(out, 30, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and it
    # has space under it, the soil partially avalanche
    out.terrain[10, 15] = -0.5
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.2
    out.body[4][10, 15] = 0.4
    _relax_unstable_terrain_cell!(out, 30, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.2) && (out.terrain[10, 15] ≈ -0.3)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # soil should fully avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    _relax_unstable_terrain_cell!(out, 34, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # soil should partially avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.3
    _relax_unstable_terrain_cell!(out, 34, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.2) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] ≈ -0.4)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower,
    # soil fill the space between the two bucket layers, soil should fully avalanche on
    # the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.4
    _relax_unstable_terrain_cell!(out, 32, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.4)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, soil fully avalanche on the first bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.4
    out.body[3][10, 15] = 0.4
    out.body[4][10, 15] = 0.7
    out.body_soil[1][10, 15] = -0.4
    out.body_soil[2][10, 15] = -0.3
    out.body_soil[3][10, 15] = 0.7
    out.body_soil[4][10, 15] = 0.9
    _relax_unstable_terrain_cell!(out, 33, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.8)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.7) && (out.body_soil[4][10, 15] == 0.9)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, soil partially avalanche on the first bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 33, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.8)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] ≈ -0.4)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.2)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, soil fill the space between the two bucket, soil fully avalanche on the
    # second bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.4
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 31, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.4)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # has space under it, soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    _relax_unstable_terrain_cell!(out, 30, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # has space under it, soil partially avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 30, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.4) && (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # soil should fully avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    _relax_unstable_terrain_cell!(out, 32, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower,
    # soil should partially avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.4
    _relax_unstable_terrain_cell!(out, 32, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.8)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.4) && (out.body_soil[4][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower,
    # soil fill the space between the two bucket layers, soil fully avalanche on the
    # first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.6
    _relax_unstable_terrain_cell!(out, 34, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.2) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.6)
    @test (out.body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower, soil should fully avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.5
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.6
    _relax_unstable_terrain_cell!(out, 31, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.1) && (out.body_soil[2][10, 15] == 0.5)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower, soil should partially avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.5
    out.body[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[1][10, 15] = -0.4
    out.body_soil[2][10, 15] = 0.5
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.6
    _relax_unstable_terrain_cell!(out, 31, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] == 0.5)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.5)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower, soil fill the space between the two bucket layers, soil should fully
    # avalanche on the first bucket soil layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.5
    out.body[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[1][10, 15] = -0.4
    out.body_soil[2][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.5
    _relax_unstable_terrain_cell!(out, 33, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.5)
    @test (out.body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
end


"""
@testset "_relax_terrain!" begin
    # Setting impact_area
    out.impact_area[:, :] .= Int64[[5, 10] [15, 20]]

    # Testing the case where there is no bucket and soil is unstable
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the first bucket layer and it has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the first bucket layer and soil should avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.4) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 15]])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the first bucket layer and it is high enough to
    # prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the first bucket layer with bucket soil and it has
    # space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # should avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.3
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.terrain[10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the first bucket layer with bucket soil and it is high
    # enough to prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the second bucket layer and it has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.1
    out.body[4][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the second bucket layer and soil should avalanche on
    # it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[3; 10; 15]])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the second bucket layer and it is high enough to
    # prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the second bucket layer with bucket soil and it has
    # space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.1
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] == -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # should avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there is the second bucket layer with bucket soil and it is
    # high enough to prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the first layer being lower and it
    # has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.1
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # soil should avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[3; 10; 15]])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # the second bucket layer is high enough to prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower and has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower, and soil should avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] ≈ -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[3; 10; 15]])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower, and the second bucket layer is high enough to prevent the soil from
    # avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the first layer being lower and it
    # has space under it, while the second layer is with bucket soil
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = 0.4
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == 0.4)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # soil should avalanche on the second bucket layer with bucket soil
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # the second bucket layer with bucket soil is high enough to prevent the soil from
    # avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and it has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.1
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, and soil should avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower, and the second bucket layer is high enough to prevent the soil from
    # avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the second layer being lower and
    # it has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # soil should avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] ≈ -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 15]])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # the first bucket layer is high enough to prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower and it has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower, and soil should avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] ≈ -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
    @test (out.body_soil_pos == [[1; 10; 15]])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower, and the first bucket layer is high enough to prevent the soil from
    # avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the second layer being lower and
    # has space under it, while the first layer is with bucket soil
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.1
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # soil should avalanche on the first bucket layer with bucket soil
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # the first bucket layer with bucket soil is high enough to prevent the soil from
    # avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = 0.0
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower, and soil should avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower, and the first bucket layer is high enough to prevent the soil from
    # avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the edge case where a lot of space under the bucket is present
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.3)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 16] ≈ -0.1)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.terrain[10, 16] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing the edge case for soil avalanching on terrain
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.2)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.terrain[10, 14] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

    # Testing randomization
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.2
    out.relax_area[:, :] .= Int64[[10, 15] [10, 15]]
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    out.terrain[10, 15] = -0.2
    out.terrain[9, 15] = 0.0
    set_RNG_seed!(1235)
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[10, 14] ≈ -0.1)
    @test (out.body_soil_pos == [])
    @test (out.relax_area == Int64[[5, 10] [15, 20]])
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    empty!(out.body_soil_pos)
    out.relax_area[:, :] .= Int64[[0, 0] [0, 0]]

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

    # Resetting impact_area
    out.impact_area[:, :] .= Int64[[0, 0] [0, 0]]
end
"""


@testset "_check_unstable_body_cell!" begin
    # Testing the case where there is no bucket and soil is unstable
    out.terrain[10, 15] = -0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 40)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the first bucket layer and soil should avalanche on it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = 0.0
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 14)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # should avalanche on it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.0
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 13)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the second bucket layer and soil should avalanche
    # on it
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 22)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # should avalanche on it
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 21)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should avalanche on it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower and soil should avalanche on it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should avalanche on it, while the second layer is with bucket soil
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.2
    out.body_soil[3][10, 15] = 0.2
    out.body_soil[4][10, 15] = 0.3
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should avalanche on it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.2
    out.body_soil[3][10, 15] = 0.2
    out.body_soil[4][10, 15] = 0.3
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should avalanche on the second bucket layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the first layer with bucket soil
    # being lower and soil should avalanche on the second bucket layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should avalanche on the second bucket layer with soil
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should avalanche on the second bucket layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should avalanche on it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower and soil should avalanche on it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should avalanche on it, while the first layer is with bucket soil
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.2
    out.body_soil[1][10, 15] = 0.2
    out.body_soil[2][10, 15] = 0.3
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should avalanche on it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.2
    out.body_soil[1][10, 15] = 0.2
    out.body_soil[2][10, 15] = 0.3
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should avalanche on the first bucket layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the second layer with bucket soil
    # being lower and soil should avalanche on the first bucket layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should avalanche on the first bucket layer with soil
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should avalanche on the first bucket layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil fully cover the space between the two layers, the first bucket layer it too high
    # for soil to avalanche
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = 0.2
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers with soil, the second layer being
    # lower and soil fully cover the space between the two layers, the first bucket soil
    # layer it too high for soil to avalanche
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.2
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil fully cover the space between the two layers, the second bucket layer it too high
    # for soil to avalanche
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.1
    out.body[4][10, 15] = 0.5
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers with soil, the first layer being
    # lower and soil fully cover the space between the two layers, the second bucket soil
    # layer it too high for soil to avalanche
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.1
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil fully cover the space between the two layers, but the soil can avalanche on the
    # first bucket layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 34)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers with soil, the second layer being
    # lower and soil fully cover the space between the two layers, but the soil can
    # avalanche on the first bucket soil layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 33)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil fully cover the space between the two layers, but the soil can avalanche on the
    # second bucket layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 32)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers with soil, the first layer being
    # lower and soil fully cover the space between the two layers, but the soil can
    # avalanche on the second bucket soil layer
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.4
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 31)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is no bucket and soil is not unstable
    out.terrain[10, 15] = 0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the first bucket layer and soil is not unstable
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = 0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # is not unstable
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the second bucket layer and soil is not unstable
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # is not unstable
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers and soil is not unstable (1)
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.1
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers and soil is not unstable (2)
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.2
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = 0.1
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers and soil is not unstable (3)
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.1
    out.body_soil[3][10, 15] = 0.1
    out.body_soil[4][10, 15] = 0.3
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.4
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, 0.3)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there are two bucket layers and soil is not unstable (4)
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.2
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.4
    status = _check_unstable_body_cell(out, 10, 14, 1, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
end

@testset "_relax_unstable_body_cell!" begin
    # Testing the case where there is no bucket and soil should partially avalanche
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = 0.0
    _relax_unstable_body_cell!(out, 40, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] ≈ 0.1) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is no bucket and soil should fully avalanche
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    _relax_unstable_body_cell!(out, 40, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] ≈ 0.0) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the first bucket layer and soil should partially
    # avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 14, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] ≈ 0.0) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer and soil should fully
    # avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    _relax_unstable_body_cell!(out, 14, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] ≈ -0.2) && (out.body_soil[2][10, 15] ≈ 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # should partially avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 13, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # should fully avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = -0.1
    _relax_unstable_body_cell!(out, 13, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and soil should partially
    # avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 22, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.0) && (out.body_soil[4][10, 15] ≈ 0.1)
    @test (new_body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and soil should fully
    # avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    _relax_unstable_body_cell!(out, 22, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.1) && (out.body_soil[4][10, 15] ≈ 0.0)
    @test (new_body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # should partially avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 21, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.1) && (out.body_soil[4][10, 15] ≈ 0.1)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # should fully avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 21, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.1) && (out.body_soil[4][10, 15] ≈ 0.1)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should partially avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.3
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    _relax_unstable_body_cell!(out, 34, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] ≈ -0.1) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should fully avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.1
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    _relax_unstable_body_cell!(out, 34, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] ≈ -0.1) && (out.body_soil[2][10, 15] ≈ 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should partially avalanche on it but there is not enough space for all the soil
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.5
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    _relax_unstable_body_cell!(out, 34, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.3)
    @test (out.body_soil[1][10, 15] ≈ -0.1) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should partially avalanche on the second bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.5
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    _relax_unstable_body_cell!(out, 32, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.3) && (out.body_soil[4][10, 15] ≈ 0.4)
    @test (new_body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should fully avalanche on the second bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.5
    out.body_soil[1][10, 14] = 0.5
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.2
    _relax_unstable_body_cell!(out, 32, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.2) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (new_body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should partially avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.3
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.5
    _relax_unstable_body_cell!(out, 33, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.5)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should fully avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.3
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.2
    out.body[4][10, 15] = 0.3
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.5
    _relax_unstable_body_cell!(out, 33, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.5)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should partially avalanche on it but there is not enough space
    # for all the soil
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.9
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.2
    out.body[4][10, 15] = 0.3
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.5
    _relax_unstable_body_cell!(out, 33, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.6)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.2)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.5)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should partially avalanche on the second bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.9
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.5
    _relax_unstable_body_cell!(out, 31, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.7)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.7)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should fully avalanche on the second bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.7
    out.body_soil[1][10, 14] = 0.7
    out.body_soil[2][10, 14] = 0.9
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.5
    _relax_unstable_body_cell!(out, 31, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.7)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should partially avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.3
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    _relax_unstable_body_cell!(out, 32, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.1) && (out.body_soil[4][10, 15] ≈ 0.1)
    @test (new_body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should fully avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.3
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = 0.2
    out.body[2][10, 15] = 0.4
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 32, new_body_soil_pos, 0.0, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.0) && (out.body_soil[4][10, 15] ≈ 0.2)
    @test (new_body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should partially avalanche on it but there is not enough space for all the soil
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = 0.2
    out.body[2][10, 15] = 0.4
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 32, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.6)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.0) && (out.body_soil[4][10, 15] ≈ 0.2)
    @test (new_body_soil_pos == [[3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should partially avalanche on the first bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.4
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 34, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.6)
    @test (out.body_soil[1][10, 15] == 0.4) && (out.body_soil[2][10, 15] ≈ 0.6)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should fully avalanche on the first bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.6
    out.body_soil[1][10, 14] = 0.6
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 34, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.2) && (out.body_soil[2][10, 15] ≈ 0.4)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (new_body_soil_pos == [[1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should partially avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.3
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.2
    out.body_soil[4][10, 15] = -0.1
    _relax_unstable_body_cell!(out, 31, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] == 0.8)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ 0.1)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should fully avalanche on it
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.1
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.2
    out.body_soil[4][10, 15] = -0.1
    _relax_unstable_body_cell!(out, 31, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] == 0.8)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ 0.0)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should partially avalanche on it but there is not enough space
    # for all the soil
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.2
    out.body_soil[4][10, 15] = -0.1
    _relax_unstable_body_cell!(out, 31, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.6)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] == 0.8)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ 0.1)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should partially avalanche on the first bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.5
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.2
    out.body_soil[4][10, 15] = -0.1
    _relax_unstable_body_cell!(out, 33, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.7)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.6)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] == -0.1)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should fully avalanche on the first bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.6
    out.body_soil[1][10, 14] = 0.6
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.4
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.2
    out.body_soil[4][10, 15] = -0.1
    _relax_unstable_body_cell!(out, 33, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.6)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] == -0.1)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should partially avalanche on it but there is no space at all
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = 0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    _relax_unstable_body_cell!(out, 33, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.8)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.8)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should partially avalanche on it but there is no space at all
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = 0.1
    out.body[2][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.2
    out.body_soil[4][10, 15] = 0.1
    _relax_unstable_body_cell!(out, 31, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.8)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] == 0.8)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] == 0.1)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil fully cover the space between the two layers, the soil can partially avalanche
    # to the second bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = 0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.2
    _relax_unstable_body_cell!(out, 32, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.5)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == 0.2) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (new_body_soil_pos == [[3, 10, 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil fully cover the space between the two layers, the soil can partially avalanche
    # to the second bucket soil layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = 0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.2
    out.body_soil[3][10, 15] = 0.2
    out.body_soil[4][10, 15] = 0.4
    _relax_unstable_body_cell!(out, 31, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.6)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == 0.2) && (out.body_soil[4][10, 15] ≈ 0.6)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil fully cover the space between the two layers, the soil can partially avalanche
    # to the first bucket layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = 0.4
    out.body[2][10, 15] = 0.5
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.2
    out.body_soil[4][10, 15] = 0.4
    _relax_unstable_body_cell!(out, 34, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.7)
    @test (out.body_soil[1][10, 15] == 0.5) && (out.body_soil[2][10, 15] ≈ 0.6)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] == 0.4)
    @test (new_body_soil_pos == [[1, 10, 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil fully cover the space between the two layers, the soil can partially avalanche
    # to the first bucket soil layer
    new_body_soil_pos = Vector{Vector{Int64}}()
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.8
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = 0.4
    out.body[2][10, 15] = 0.5
    out.body_soil[1][10, 15] = 0.5
    out.body_soil[2][10, 15] = 0.6
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.2
    out.body_soil[4][10, 15] = 0.4
    _relax_unstable_body_cell!(out, 33, new_body_soil_pos, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.7)
    @test (out.body_soil[1][10, 15] == 0.5) && (out.body_soil[2][10, 15] ≈ 0.7)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] == 0.4)
    @test (new_body_soil_pos == [])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
end

@testset "_relax_body_soil!" begin
    # Testing the case where there is no bucket and soil should partially avalanche
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.3
    out.body[1][10, 14] = -0.3
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.2
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.3) && (out.terrain[10, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[3][10, 14] == 0.0) && (out.body_soil[4][10, 14] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14]])
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is no bucket and soil should fully avalanche
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.3
    out.body[1][10, 14] = -0.3
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.3) && (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 14] == 0.0) && (out.body_soil[4][10, 14] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14]])
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer and soil should partially
    # avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer and soil should fully
    # avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # should partially avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # should fully avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.7
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer and soil should partially
    # avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer and soil should fully
    # avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.6
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # should partially avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # should fully avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.7
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should partially avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should fully avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should partially avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.2
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should fully avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.7
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer with soil being
    # lower and soil should partially avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.3
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer with soil being
    # lower and soil should fully avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.2
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.4
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer with soil being
    # lower and soil should partially avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.7
    out.body_soil[1][10, 15] = -0.7
    out.body_soil[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.2
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.7) && (out.body_soil[2][10, 15] == -0.6)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer with soil being
    # lower and soil should fully avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.7
    out.body_soil[1][10, 15] = -0.7
    out.body_soil[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.5
    out.body[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.7) && (out.body_soil[2][10, 15] == -0.6)
    @test (out.body_soil[3][10, 15] == -0.4) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should partially avalanche on it, while the second layer is with bucket soil
    set_RNG_seed!(3000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.1
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.1
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
    @test (out.body_soil_pos == [[3; 10; 15], [1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should fully avalanche on it, while the second layer is with bucket soil
    set_RNG_seed!(3000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.5
    out.body[1][10, 15] = -0.5
    out.body[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.1
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.1
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.5) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
    @test (out.body_soil_pos == [[3; 10; 15], [1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should partially avalanche on the second bucket layer with soil
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.3
    out.body[1][10, 14] = -0.3
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.3)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should fully avalanche on the second bucket layer with soil
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.3
    out.body[1][10, 14] = -0.3
    out.body[2][10, 14] = -0.1
    out.body_soil[1][10, 14] = -0.1
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.3)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should partially avalanche on it
    set_RNG_seed!(5000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.1) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[3; 10; 15], [1; 10; 15], [1; 10; 14]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should fully avalanche on it
    set_RNG_seed!(5000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.7
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    out.body_soil[3][10, 15] = -0.1
    out.body_soil[4][10, 15] = 0.0
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == -0.1) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[3; 10; 15], [1; 10; 15], [1; 10; 14]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should partially avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.1
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    out.body_soil[3][10, 15] = -0.2
    out.body_soil[4][10, 15] = -0.1
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] == -0.4)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should fully avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.7
    out.body_soil[1][10, 15] = -0.7
    out.body_soil[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.7) && (out.body_soil[2][10, 15] == -0.6)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil should partially avalanche on it but there is not enough space for all the soil
    set_RNG_seed!(2000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.3
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should partially avalanche on it but there is not enough space
    # for all the soil
    set_RNG_seed!(2100)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.1
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
    @test (out.body_soil_pos == [[3; 10; 15], [1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and soil should partially avalanche on it but there is no space at all
    set_RNG_seed!(3000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.1
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.1
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] == 0.1)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] == -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
    @test (out.body_soil_pos == [[1; 10; 15], [1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should partially avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should fully avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should partially avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should fully avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.2
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.5
    out.body[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer with soil being
    # lower and soil should partially avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer with soil being
    # lower and soil should fully avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.7
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer with soil being
    # lower and soil should partially avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] == -0.4)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer with soil being
    # lower and soil should fully avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.7
    out.body[1][10, 15] = -0.5
    out.body[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should partially avalanche on it, while the first layer is with bucket soil
    set_RNG_seed!(3000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.1
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[1; 10; 15], [1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should fully avalanche on it, while the first layer is with bucket soil
    set_RNG_seed!(3000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.1
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should partially avalanche on the first bucket layer with soil
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should fully avalanche on the first bucket layer with soil
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.4 
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should partially avalanche on it
    set_RNG_seed!(3000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.1
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[1; 10; 15], [1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should fully avalanche on it
    set_RNG_seed!(3000)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.1
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.6
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.4)
    @test (out.body_soil_pos == [[1; 10; 15], [1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should partially avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = 0.1
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.0)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.4)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should fully avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.4
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.6
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.6)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil should partially avalanche on it but there is not enough space for all the soil
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.5
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.5)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should partially avalanche on it but there is not enough space
    # for all the soil
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.6
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.2)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.4)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, the second layer
    # being lower and soil should partially avalanche on it but there is no space at all
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.4)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil fully cover the space between the two layers, the soil can partially avalanche
    # to the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.7
    out.body_soil[1][10, 15] = -0.7
    out.body_soil[2][10, 15] = -0.5
    out.body[3][10, 15] = -0.5
    out.body[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.7) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.4) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the first layer being lower and
    # soil fully cover the space between the two layers, the soil can partially avalanche
    # to the second bucket soil layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.7
    out.body_soil[1][10, 15] = -0.7
    out.body_soil[2][10, 15] = -0.5
    out.body[3][10, 15] = -0.5
    out.body[4][10, 15] = -0.4
    out.body_soil[3][10, 15] = -0.4
    out.body_soil[4][10, 15] = -0.2
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.7) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.4) && (out.body_soil[4][10, 15] ≈ -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil fully cover the space between the two layers, the soil can partially avalanche
    # to the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.4)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, the second layer being lower and
    # soil fully cover the space between the two layers, the soil can partially avalanche
    # to the first bucket soil layer
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.7
    out.body_soil[3][10, 15] = -0.7
    out.body_soil[4][10, 15] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.4)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is no bucket and soil is not unstable
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer and soil is not unstable
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # is not unstable
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    out.body_soil[1][10, 15] = -0.2
    out.body_soil[2][10, 15] = 0.0
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer and soil is not unstable
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.1
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # is not unstable
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.1
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, first layer being lower and soil
    # is not unstable
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, first layer with bucket soil
    # being lower and soil is not unstable
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.1
    out.body[4][10, 15] = 0.3
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, first layer
    # being lower and soil is not unstable
    set_RNG_seed!(1234)
    out.terrain[9:11, 13:15] .= 0.2
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.1
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.1
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[9:11, 13:15] .= 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, second layer being lower and soil
    # is not unstable
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.1
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.1
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    @test (out.body_soil_pos == [[1; 10; 14]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers, second layer with bucket soil
    # being lower and soil is not unstable
    set_RNG_seed!(1234)
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.1
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.1
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [3; 10; 15]])
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing the case where there are two bucket layers with bucket soil, second layer
    # being lower and soil is not unstable
    set_RNG_seed!(1234)
    out.terrain[9:11, 13:15] .= 0.2
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.1
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.1
    push!(out.body_soil_pos, [1; 10; 14])
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.1)
    @test (out.body_soil_pos == [[1; 10; 14], [1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[9:11, 13:15] .= 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing randomization
    set_RNG_seed!(3000)
    out.terrain[10, 14] = -0.6
    out.body[1][10, 14] = -0.6
    out.body[2][10, 14] = -0.5
    out.body_soil[1][10, 14] = -0.5
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.terrain[10, 13] = -0.4
    push!(out.body_soil_pos, [1; 10; 14])
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.6)
    @test (out.terrain[10, 15] ≈ -0.3) && (out.terrain[10, 13] ≈ -0.2)
    @test (out.body_soil[1][10, 14] == -0.5) && (out.body_soil[2][10, 14] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 14]])
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.terrain[10, 13] = -0.4
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.6)
    @test (out.terrain[10, 15] ≈ -0.2) && (out.terrain[10, 13] ≈ -0.3)
    @test (out.body_soil[1][10, 14] == -0.5) && (out.body_soil[2][10, 14] ≈ -0.3)
    @test (out.body_soil_pos == [[1; 10; 14]])
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.terrain[10, 13] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    empty!(out.body_soil_pos)

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
