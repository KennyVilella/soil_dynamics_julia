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
