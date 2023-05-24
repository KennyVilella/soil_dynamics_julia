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
@testset "_locate_intersecting_cells" begin
    # Set dummy values in body and terrain
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
    out.body[1][10, 11:16] .= 0.0
    out.body[2][10, 11:16] .= 0.0
    out.body[3][10, 11:16] .= 0.0
    out.body[4][10, 11:16] .= 0.0
    out.body[1][11, 11] = 0.0
    out.body[2][11, 11] = 0.0
    out.terrain[10, 11:16] .= 0.0
    out.terrain[11, 11] = 0.0
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
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
    _move_intersecting_body!(out, grid)
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][10:12, 16:18] .= 0.0
    out.body[2][10:12, 16:18] .= 0.0

    # Testing randomness of movement
    set_RNG_seed!(1234)
    out.body[1][11, 17] = -0.4
    out.body[2][11, 17] = 0.6
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out, grid)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[12, 16] ≈ 0.9)
    out.terrain[12, 16] = 0.0
    out.terrain[11, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Second call
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out, grid)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[10, 17] ≈ 0.9)
    out.terrain[10, 17] = 0.0
    out.terrain[11, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
end

@testset "_move_intersecting_cells!" begin

end
