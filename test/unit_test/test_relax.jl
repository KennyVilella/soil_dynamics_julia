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
@testset "_locate_unstable_terrain_cell" begin
    # Setting dummy terrain
    out.terrain[2, 2] = -0.1
    out.terrain[5, 2] = -0.2
    out.terrain[11, 13] = -0.2
    out.terrain[5, 13] = 0.2
    out.terrain[7, 13] = 0.1
    out.terrain[15, 5] = -0.4
    out.terrain[15, 6] = -0.2

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
end

@testset "_check_unstable_terrain_cell!" begin
    # Testing the case where there is no bucket and soil is not unstable
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)

    # Testing the case where there is no bucket and soil is unstable
    out.terrain[10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 400)
    # Resetting values
    out.terrain[10, 15] = 0.0

    # Testing the case where there is the first bucket layer and it has space under it
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 141)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0

    # Testing the case where there is the first bucket layer and soil should avalanche on it
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 142)
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
    @test (status == 131)
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
    @test (status == 132)
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
    @test (status == 221)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and soil should avalanche on
    # it
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 222)
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
    #  space under it
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.3
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 211)
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
    @test (status == 212)
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

    # Testing the case where there is two bucket layers, the first layer being lower and it
    # has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 321)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the first layer being lower, and
    # soil should avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 322)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the first layer being lower, and
    # the second bucket layer is high enough to prevent the soil from avalanching
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the first layer with bucket soil
    # being lower and has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 321)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the first layer with bucket soil
    # being lower, and soil should avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 322)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the first layer with bucket soil
    # being lower, and the second bucket layer is high enough to prevent the soil from
    # avalanching
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
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

    # Testing the case where there is two bucket layers, the first layer being lower and it
    # has space under it, while the second layer is with bucket soil
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 311)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the first layer with bucket soil
    # being lower, and soil should avalanche on the second bucket layer with bucket soil
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 312)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the first layer with bucket soil
    # being lower, and the second bucket layer with bucket soil is high enough to prevent
    # the soil from avalanching
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
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
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers with bucket soil, the first layer
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
    @test (status == 311)
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

    # Testing the case where there is two bucket layers with bucket soil, the first layer
    # being lower, and soil should avalanche on the second bucket layer
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
    @test (status == 312)
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

    # Testing the case where there is two bucket layers with bucket soil, the first layer
    # being lower, and the second bucket layer is high enough to prevent the soil from
    # avalanching
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

    # Testing the case where there is two bucket layers, the second layer being lower and
    # it has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 341)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the second layer being lower, and
    # soil should avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 342)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the second layer being lower, and
    # the first bucket layer is high enough to prevent the soil from avalanching
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the second layer with bucket soil
    # being lower and it has space under it
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 341)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the second layer with bucket soil
    # being lower, and soil should avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 342)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the second layer with bucket soil
    # being lower, and the first bucket layer is high enough to prevent the soil from
    # avalanching
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[3][10, 15] = -0.6
    out.body_soil[4][10, 15] = -0.5
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

    # Testing the case where there is two bucket layers, the second layer being lower and
    # has space under it, while the first layer is with bucket soil
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 331)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the second layer with bucket soil
    # being lower, and soil should avalanche on the first bucket layer with bucket soil
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
    @test (status == 332)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is two bucket layers, the second layer with bucket soil
    # being lower, and the first bucket layer with bucket soil is high enough to prevent the
    # soil from avalanching
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = 0.0
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

    # Testing the case where there is two bucket layers with bucket soil, the second layer
    # being lower has space under it
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
    @test (status == 331)
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

    # Testing the case where there is two bucket layers with bucket soil, the second layer
    # being lower, and soil should avalanche on the first bucket layer
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
    @test (status == 332)
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

    # Testing the case where there is two bucket layers with bucket soil, the second layer
    # being lower, and the first bucket layer is high enough to prevent the soil from
    # avalanching
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
    @test (status == 141)
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
