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
sim = SimParam(repose_angle, max_iterations)

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
    # space under it
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

    # Testing the case where there are two bucket layers, the first layer being lower and it
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

    # Testing the case where there are two bucket layers, the first layer being lower, and
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

    # Testing the case where there are two bucket layers, the first layer being lower, and
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
    @test (status == 321)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer with bucket soil
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

    # Testing the case where there are two bucket layers, the first layer with bucket soil
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
    @test (status == 311)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # soil should avalanche on the second bucket layer with bucket soil
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

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # the second bucket layer with bucket soil is high enough to prevent the soil from
    # avalanching
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

    # Testing the case where there are two bucket layers with bucket soil, the first layer
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

    # Testing the case where there are two bucket layers with bucket soil, the first layer
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

    # Testing the case where there are two bucket layers, the second layer being lower and
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

    # Testing the case where there are two bucket layers, the second layer being lower, and
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

    # Testing the case where there are two bucket layers, the second layer being lower, and
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
    @test (status == 341)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer with bucket soil
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

    # Testing the case where there are two bucket layers, the second layer with bucket soil
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
    @test (status == 331)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # soil should avalanche on the first bucket layer with bucket soil
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

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # the first bucket layer with bucket soil is high enough to prevent the soil from
    # avalanching
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

    # Testing the case where there are two bucket layers with bucket soil, the second layer
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

    # Testing the case where there are two bucket layers with bucket soil, the second layer
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

@testset "_relax_unstable_terrain_cell!" begin
    # Testing the case where there is no bucket and soil is unstable
    out.terrain[10, 14] = 0.4
    out.terrain[10, 15] = 0.1
    _relax_unstable_terrain_cell!(out, 400, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ 0.3) && (out.terrain[10, 15] ≈ 0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and it has
    # space under it, the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.3
    _relax_unstable_terrain_cell!(out, 211, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] == -0.3)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and it has
    # space under it, the soil partially avalanche
    out.terrain[10, 15] = -0.3
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.5
    _relax_unstable_terrain_cell!(out, 211, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.5)
    # Resetting values
    out.terrain[10, 14] = 0.0
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
    _relax_unstable_terrain_cell!(out, 212, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.8)
    @test (out.body_soil[3][10, 15] ≈ -0.5) && (out.body_soil[4][10, 15] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and it has space under it,
    # the soil fully avalanche
    out.terrain[10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.3
    _relax_unstable_terrain_cell!(out, 221, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.2) && (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and it has space under it,
    # the soil partially avalanche
    out.terrain[10, 15] = -0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    _relax_unstable_terrain_cell!(out, 221, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] ≈ -0.3)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and soil should avalanche on
    # it
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    _relax_unstable_terrain_cell!(out, 222, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and it has
    # space under it, the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.3
    _relax_unstable_terrain_cell!(out, 131, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] ≈ -0.5) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and it has
    # space under it, the soil partially avalanche
    out.terrain[10, 15] = -0.7
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.3
    _relax_unstable_terrain_cell!(out, 131, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil[1][10, 15] ≈ -0.1) && (out.body_soil[2][10, 15] ≈ 0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
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
    _relax_unstable_terrain_cell!(out, 132, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] ≈ -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer and it has space under it,
    # the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.5 
    out.body[2][10, 15] = -0.2 
    _relax_unstable_terrain_cell!(out, 141, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] ≈ -0.5)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer and it has space under it,
    # the soil partially avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.1
    _relax_unstable_terrain_cell!(out, 141, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.4) && (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer and soil should avalanche on it
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 142, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.4)
    @test (out.body_soil[1][10, 15] ≈ -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and it has space under it, the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.6
    out.body_soil[2][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.3
    out.body_soil[4][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 311, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.2)
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

    # Testing the case where there are two bucket layers with bucket soil, the first layer
    # being lower and it has space under it, the soil partially avalanche
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = 0.3
    out.body[4][10, 15] = 0.5
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.2
    out.body_soil[3][10, 15] = 0.5
    out.body_soil[4][10, 15] = 0.7
    _relax_unstable_terrain_cell!(out, 311, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.3) && (out.terrain[10, 15] ≈ -0.3)
    @test (out.body_soil[1][10, 15] == -0.1) && (out.body_soil[2][10, 15] == 0.2)
    @test (out.body_soil[3][10, 15] == 0.5) && (out.body_soil[4][10, 15] == 0.7)
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

    # Testing the case where there are two bucket layers with bucket soil, the first layer
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
    _relax_unstable_terrain_cell!(out, 312, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
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

    # Testing the case where there are two bucket layers, the first layer being lower and it
    # has space under it, the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6 
    out.body[3][10, 15] = -0.4 
    out.body[4][10, 15] = -0.3 
    _relax_unstable_terrain_cell!(out, 321, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and it
    # has space under it, the soil partially avalanche
    out.terrain[10, 15] = -0.5
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.2
    out.body[4][10, 15] = 0.4
    _relax_unstable_terrain_cell!(out, 321, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.2) && (out.terrain[10, 15] ≈ -0.3)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # soil should avalanche on the second bucket layer
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    _relax_unstable_terrain_cell!(out, 322, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # has space under it, while the first layer is with bucket soil, the soil fully
    # avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 331, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # has space under it, while the first layer is with bucket soil, the soil partially
    # avalanche
    out.terrain[10, 15] = -0.9
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    out.body_soil[1][10, 15] = -0.1
    out.body_soil[2][10, 15] = 0.0
    _relax_unstable_terrain_cell!(out, 331, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.4) && (out.terrain[10, 15] ≈ -0.5)
    @test (out.body_soil[1][10, 15] == -0.1) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # soil should avalanche on the first bucket layer with bucket soil
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    out.body_soil[1][10, 15] = -0.3
    out.body_soil[2][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 332, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # it has space under it, the soil fully avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    _relax_unstable_terrain_cell!(out, 341, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] ≈ -0.7)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower and
    # it has space under it, the soil partially avalanche
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = -0.2
    _relax_unstable_terrain_cell!(out, 341, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.4) && (out.terrain[10, 15] ≈ -0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # soil should avalanche on the first bucket layer
    out.terrain[10, 15] = -0.8 
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    _relax_unstable_terrain_cell!(out, 342, 0.1, 10, 14, 10, 15, grid)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 15] == -0.8)
    @test (out.body_soil[1][10, 15] ≈ -0.3) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
end

@testset "_relax_terrain!" begin
    # Testing the case where there is no bucket and soil is unstable
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.2
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.1)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0

    # Testing the case where there is the first bucket layer and it has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.1
    out.body[2][10, 15] = 0.0
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.1)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer and soil should avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.4) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer and it is high enough to
    # prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and it has
    # space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = 0.0
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # should avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = -0.3
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.terrain[10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and it is high
    # enough to prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.5
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = 0.0
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and it has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.1
    out.body[4][10, 15] = 0.0
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.1)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and soil should avalanche on
    # it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.2
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer and it is high enough to
    # prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and it has
    # space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.1
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] == -0.1)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # should avalanche on it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = -0.2
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.1)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and it is
    # high enough to prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.5
    out.body_soil[3][10, 15] = -0.5
    out.body_soil[4][10, 15] = 0.0
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower and it
    # has space under it
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.7
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.1
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # soil should avalanche on the second bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.2
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the first layer being lower, and
    # the second bucket layer is high enough to prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.8
    out.body[2][10, 15] = -0.6
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = 0.0
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] ≈ -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == 0.4)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.1)
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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
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
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] == -0.5)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == 0.0)
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
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.1
    out.body[3][10, 15] = -0.7
    out.body[4][10, 15] = -0.6
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # soil should avalanche on the first bucket layer
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.2
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] ≈ -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

    # Testing the case where there are two bucket layers, the second layer being lower, and
    # the first bucket layer is high enough to prevent the soil from avalanching
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.8
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = -0.8
    out.body[4][10, 15] = -0.6
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] ≈ -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0

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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.7) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
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
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[9, 15] == 0.0)
    @test (out.terrain[10, 14] == 0.0) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
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
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.2
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.3)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 16] ≈ -0.1)
    @test (out.terrain[11, 15] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.terrain[10, 16] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0

    # Testing the edge case for soil avalanching on terrain
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.4
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.2)
    @test (out.terrain[10, 14] ≈ -0.1) && (out.terrain[10, 16] == 0.0)
    @test (out.terrain[11, 15] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[9, 15] = 0.0
    out.terrain[10, 14] = 0.0

    # Testing randomization
    set_RNG_seed!(1234)
    out.terrain[10, 15] = -0.2
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[9, 15] ≈ -0.1)
    out.terrain[10, 15] = -0.2
    out.terrain[9, 15] = 0.0
    set_RNG_seed!(1235)
    _relax_terrain!(out, grid, sim)
    @test (out.terrain[10, 15] ≈ -0.1) && (out.terrain[10, 14] ≈ -0.1)
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0

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
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = 0.0
    _relax_unstable_body_cell!(out, 40, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] ≈ 0.1) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is no bucket and soil should fully avalanche
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    _relax_unstable_body_cell!(out, 40, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] ≈ 0.0) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the first bucket layer and soil should partially
    # avalanche on it
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    out.body[1][10, 15] = -0.2
    out.body[2][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 14, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] ≈ 0.0) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.3
    out.body[1][10, 15] = -0.3
    out.body[2][10, 15] = -0.2
    _relax_unstable_body_cell!(out, 14, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] ≈ -0.2) && (out.body_soil[2][10, 15] ≈ 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_unstable_body_cell!(out, 13, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_unstable_body_cell!(out, 13, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    _relax_unstable_body_cell!(out, 22, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.0) && (out.body_soil[4][10, 15] ≈ 0.1)
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
    out.terrain[10, 14] = -0.2
    out.body[1][10, 14] = -0.2
    out.body[2][10, 14] = 0.1
    out.body_soil[1][10, 14] = 0.1
    out.body_soil[2][10, 14] = 0.2
    out.terrain[10, 15] = -0.2
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = -0.1
    _relax_unstable_body_cell!(out, 22, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.1) && (out.body_soil[4][10, 15] ≈ 0.0)
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
    _relax_unstable_body_cell!(out, 21, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.1) && (out.body_soil[4][10, 15] ≈ 0.1)
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
    _relax_unstable_body_cell!(out, 21, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.1) && (out.body_soil[4][10, 15] ≈ 0.1)
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
    _relax_unstable_body_cell!(out, 34, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] ≈ -0.1) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_unstable_body_cell!(out, 34, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] ≈ -0.1) && (out.body_soil[2][10, 15] ≈ 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_unstable_body_cell!(out, 34, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.3)
    @test (out.body_soil[1][10, 15] ≈ -0.1) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_unstable_body_cell!(out, 32, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.4)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.3) && (out.body_soil[4][10, 15] ≈ 0.4)
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
    _relax_unstable_body_cell!(out, 32, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.2) && (out.body_soil[4][10, 15] ≈ 0.5)
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
    _relax_unstable_body_cell!(out, 33, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.5)
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
    _relax_unstable_body_cell!(out, 33, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.5)
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
    _relax_unstable_body_cell!(out, 33, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.6)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.2)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.5)
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
    _relax_unstable_body_cell!(out, 31, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.7)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.7)
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
    _relax_unstable_body_cell!(out, 31, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.7)
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
    _relax_unstable_body_cell!(out, 32, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ -0.1) && (out.body_soil[4][10, 15] ≈ 0.1)
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
    _relax_unstable_body_cell!(out, 32, 0.0, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.0) && (out.body_soil[4][10, 15] ≈ 0.2)
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
    _relax_unstable_body_cell!(out, 32, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.6)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] ≈ 0.0) && (out.body_soil[4][10, 15] ≈ 0.2)
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
    _relax_unstable_body_cell!(out, 34, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.6)
    @test (out.body_soil[1][10, 15] == 0.4) && (out.body_soil[2][10, 15] ≈ 0.6)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_unstable_body_cell!(out, 34, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.2) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.2) && (out.body_soil[2][10, 15] ≈ 0.4)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_unstable_body_cell!(out, 31, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] == 0.8)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ 0.1)
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
    _relax_unstable_body_cell!(out, 31, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] == 0.8)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ 0.0)
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
    _relax_unstable_body_cell!(out, 31, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] ≈ 0.6)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] == 0.8)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ 0.1)
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
    _relax_unstable_body_cell!(out, 33, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.1) && (out.body_soil[2][10, 14] ≈ 0.7)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.6)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] == -0.1)
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
    _relax_unstable_body_cell!(out, 33, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.6)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] == -0.1)
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
    _relax_unstable_body_cell!(out, 33, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.8)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.8)
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
    _relax_unstable_body_cell!(out, 31, 0.1, 10, 14, 1, 10, 15, grid)
    @test (out.terrain[10, 15] == -0.3) && (out.terrain[10, 14] == -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.8)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] == 0.8)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] == 0.1)
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
    out.terrain[10, 14] = -0.3
    out.body[1][10, 14] = -0.3
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.2
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.3) && (out.terrain[10, 15] ≈ -0.1)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[3][10, 14] == 0.0) && (out.body_soil[4][10, 14] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is no bucket and soil should fully avalanche
    out.terrain[10, 14] = -0.3
    out.body[1][10, 14] = -0.3
    out.body[2][10, 14] = -0.2
    out.body_soil[1][10, 14] = -0.2
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.3) && (out.terrain[10, 15] ≈ -0.2)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 14] == 0.0) && (out.body_soil[4][10, 14] == 0.0)
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the first bucket layer and soil should partially
    # avalanche on it
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = -0.3
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.2)
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
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.6
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.3)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] ≈ -0.3)
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
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.3
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
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
    out.terrain[10, 14] = -0.4
    out.body[1][10, 14] = -0.4
    out.body[2][10, 14] = -0.3
    out.body_soil[1][10, 14] = -0.3
    out.body_soil[2][10, 14] = -0.1
    out.terrain[10, 15] = -0.6
    out.body[3][10, 15] = -0.6
    out.body[4][10, 15] = -0.5
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.3)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] ≈ -0.3)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.3)
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

    # Testing the case where there are two bucket layers, the first layer with soil being
    # lower and soil should partially avalanche on it
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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

    # Testing the case where there are two bucket layers, the first layer with soil being
    # lower and soil should fully avalanche on it
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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

    # Testing the case where there are two bucket layers, the first layer with soil being
    # lower and soil should partially avalanche on the second bucket layer
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.7) && (out.body_soil[2][10, 15] == -0.6)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ -0.1)
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

    # Testing the case where there are two bucket layers, the first layer with soil being
    # lower and soil should fully avalanche on the second bucket layer
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.7) && (out.body_soil[2][10, 15] == -0.6)
    @test (out.body_soil[3][10, 15] == -0.4) && (out.body_soil[4][10, 15] ≈ -0.2)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.5) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
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
    # soil should partially avalanche on the second bucket layer with soil
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.3)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
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
    # soil should fully avalanche on the second bucket layer with soil
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.3)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.1)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.1) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.6) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == -0.1) && (out.body_soil[4][10, 15] == 0.0)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] == -0.4)
    @test (out.body_soil[3][10, 15] == -0.2) && (out.body_soil[4][10, 15] ≈ 0.0)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.7) && (out.body_soil[2][10, 15] == -0.6)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.2)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    set_RNG_seed!(3000)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ 0.1)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] == 0.1)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] == -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
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
    # soil should fully avalanche on it
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.3)
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
    # soil should partially avalanche on the first bucket layer
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    # soil should fully avalanche on the first bucket layer
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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

    # Testing the case where there are two bucket layers, the second layer with soil being
    # lower and soil should partially avalanche on it
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.2)
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

    # Testing the case where there are two bucket layers, the second layer with soil being
    # lower and soil should fully avalanche on it
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] ≈ -0.3)
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

    # Testing the case where there are two bucket layers, the second layer with soil being
    # lower and soil should partially avalanche on the first bucket layer
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] == -0.4)
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

    # Testing the case where there are two bucket layers, the second layer with soil being
    # lower and soil should fully avalanche on the first bucket layer
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.7) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.4) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.6) && (out.body_soil[4][10, 15] == -0.5)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] ≈ -0.2)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.5) && (out.body_soil[4][10, 15] ≈ -0.3)
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
    # soil should partially avalanche on the first bucket layer with soil
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.6) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.2) && (out.body_soil[2][10, 14] ≈ -0.1)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] ≈ -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    # soil should fully avalanche on the first bucket layer with soil
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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
    # being lower and soil should partially avalanche on it
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.2)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.4)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == -0.3) && (out.body_soil[2][10, 14] ≈ 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] ≈ 0.0)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.4)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.4)
    @test (out.body_soil[1][10, 14] == 0.0) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.2)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.6)
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
    # soil should partially avalanche on it but there is not enough space for all the soil
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.5)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] ≈ -0.2)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.2)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] ≈ -0.4)
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.8) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.2)
    @test (out.body_soil[3][10, 15] == -0.7) && (out.body_soil[4][10, 15] == -0.4)
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

    # Testing the case where there is no bucket and soil is not unstable
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the first bucket layer and soil is not unstable
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[1][10, 15] = -0.4
    out.body[2][10, 15] = 0.0
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

    # Testing the case where there is the first bucket layer with bucket soil and soil
    # is not unstable
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.2) && (out.body_soil[2][10, 15] == 0.0)
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

    # Testing the case where there is the second bucket layer and soil is not unstable
    out.terrain[10, 14] = -0.8
    out.body[1][10, 14] = -0.8
    out.body[2][10, 14] = -0.7
    out.body_soil[1][10, 14] = -0.7
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.body[3][10, 15] = -0.4
    out.body[4][10, 15] = -0.1
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
    # Resetting values
    out.terrain[10, 14] = 0.0
    out.terrain[10, 15] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0

    # Testing the case where there is the second bucket layer with bucket soil and soil
    # is not unstable
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.1)
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

    # Testing the case where there are two bucket layers, first layer being lower and soil
    # is not unstable
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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

    # Testing the case where there are two bucket layers, first layer with bucket soil
    # being lower and soil is not unstable
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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

    # Testing the case where there are two bucket layers with bucket soil, first layer
    # being lower and soil is not unstable
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == -0.3) && (out.body_soil[2][10, 15] == -0.1)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
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

    # Testing the case where there are two bucket layers, second layer being lower and soil
    # is not unstable
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.0)
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

    # Testing the case where there are two bucket layers, second layer with bucket soil
    # being lower and soil is not unstable
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.0)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.1)
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

    # Testing the case where there are two bucket layers with bucket soil, second layer
    # being lower and soil is not unstable
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
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 15] == -0.4) && (out.terrain[10, 14] == -0.8)
    @test (out.body_soil[1][10, 14] == -0.7) && (out.body_soil[2][10, 14] == 0.0)
    @test (out.body_soil[1][10, 15] == 0.0) && (out.body_soil[2][10, 15] == 0.1)
    @test (out.body_soil[3][10, 15] == -0.3) && (out.body_soil[4][10, 15] == -0.1)
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

    # Testing randomization
    set_RNG_seed!(3000)
    out.terrain[10, 14] = -0.6
    out.body[1][10, 14] = -0.6
    out.body[2][10, 14] = -0.5
    out.body_soil[1][10, 14] = -0.5
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.terrain[10, 13] = -0.4
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.6)
    @test (out.terrain[10, 15] ≈ -0.3) && (out.terrain[10, 13] ≈ -0.2)
    @test (out.body_soil[1][10, 14] == -0.5) && (out.body_soil[2][10, 14] ≈ -0.3)
    out.body_soil[2][10, 14] = 0.0
    out.terrain[10, 15] = -0.4
    out.terrain[10, 13] = -0.4
    _relax_body_soil!(out, grid, sim)
    @test (out.terrain[10, 14] == -0.6)
    @test (out.terrain[10, 15] ≈ -0.2) && (out.terrain[10, 13] ≈ -0.3)
    @test (out.body_soil[1][10, 14] == -0.5) && (out.body_soil[2][10, 14] ≈ -0.3)
    out.terrain[10, 15] = 0.0
    out.terrain[10, 14] = 0.0
    out.terrain[10, 13] = 0.0
    out.body[1][10, 14] = 0.0
    out.body[2][10, 14] = 0.0
    out.body_soil[1][10, 14] = 0.0
    out.body_soil[2][10, 14] = 0.0

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
