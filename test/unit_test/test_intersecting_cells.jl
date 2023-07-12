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
@testset "_move_body_soil!" begin
    # Setting dummy bucket
    out.body[1][10, 15] = 0.3
    out.body[2][10, 15] = 0.7
    out.body[3][10, 15] = -0.2
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.7
    out.body_soil[2][10, 15] = 0.9
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.9

    # Testing when soil is avalanching on the terrain
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.terrain[5, 7] ≈ 0.6)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the first bucket layer
    out.body[1][5, 7] = 0.1
    out.body[2][5, 7] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.terrain[5, 7] ≈ 0.6)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[5, 7] = 0.0
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when the first bucket layer is blocking the movement
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.3
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.6) && (wall_presence == true)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there is a lot of soil on the first bucket layer but soil is still
    # avalanching on it
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.1
    out.body_soil[1][5, 7] = 0.1
    out.body_soil[2][5, 7] = 0.4
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[1][5, 7] == 0.1) && (out.body_soil[2][5, 7] ≈ 1.0)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when the soil is fully avalanching on the first bucket layer
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[1][5, 7] == 0.2) && (out.body_soil[2][5, 7] ≈ 0.8)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when the soil is fully avalanching on the first bucket soil layer
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.1
    out.body_soil[1][5, 7] = 0.1
    out.body_soil[2][5, 7] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[1][5, 7] == 0.1) && (out.body_soil[2][5, 7] ≈ 0.8)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the second bucket layer
    out.body[3][5, 7] = 0.3
    out.body[4][5, 7] = 0.6
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.terrain[5, 7] ≈ 0.6)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when the second bucket layer is blocking the movement
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.6
    out.body_soil[3][5, 7] = 0.6
    out.body_soil[4][5, 7] = 0.7
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.6) && (wall_presence == true)
    @test (out.body_soil[3][5, 7] == 0.6) && (out.body_soil[4][5, 7] == 0.7)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.terrain[5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there is a lot of soil on the second bucket layer but soil is still
    # avalanching on it
    out.body[3][5, 7] = -0.2
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.3
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[3][5, 7] == 0.0) && (out.body_soil[4][5, 7] ≈ 0.9)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.terrain[5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when the soil is fully avalanching on the second bucket layer
    out.body[3][5, 7] = -0.2
    out.body[4][5, 7] = 0.0
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[3][5, 7] == 0.0) && (out.body_soil[4][5, 7] ≈ 0.6)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.terrain[5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when the soil is fully avalanching on the second bucket soil layer
    out.body[3][5, 7] = -0.2
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[3][5, 7] == 0.0) && (out.body_soil[4][5, 7] ≈ 0.8)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.terrain[5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully filling the space (1)
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.1
    out.body_soil[1][5, 7] = 0.1
    out.body_soil[2][5, 7] = 0.2
    out.body[3][5, 7] = 0.2
    out.body[4][5, 7] = 0.4
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.6) && (wall_presence == false)
    @test (ind == 1) && (ii == 5) && (jj == 7)
    @test (out.body_soil[1][5, 7] == 0.1) && (out.body_soil[2][5, 7] == 0.2)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully filling the space (2)
    out.body[1][5, 7] = 0.6
    out.body[2][5, 7] = 0.7
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.1
    out.body_soil[3][5, 7] = 0.1
    out.body_soil[4][5, 7] = 0.6
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.6) && (wall_presence == false)
    @test (ind == 3) && (ii == 5) && (jj == 7)
    @test (out.body_soil[3][5, 7] == 0.1) && (out.body_soil[4][5, 7] == 0.6)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is fully avalanching on the
    # bucket (1)
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.2
    out.body[3][5, 7] = 0.8
    out.body[4][5, 7] = 0.9
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[1][5, 7] == 0.2) && (out.body_soil[2][5, 7] ≈ 0.8)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is fully avalanching on the
    # bucket (2)
    out.body[1][5, 7] = 0.8
    out.body[2][5, 7] = 0.9
    out.body[3][5, 7] = -0.1
    out.body[4][5, 7] = 0.0
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[3][5, 7] == 0.0) && (out.body_soil[4][5, 7] ≈ 0.6)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is fully avalanching on the
    # bucket soil (1)
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.1
    out.body_soil[1][5, 7] = 0.1
    out.body_soil[2][5, 7] = 0.2
    out.body[3][5, 7] = 0.9
    out.body[4][5, 7] = 1.0
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[1][5, 7] == 0.1) && (out.body_soil[2][5, 7] ≈ 0.8)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is fully avalanching on the
    # bucket soil (2)
    out.body[1][5, 7] = 0.8
    out.body[2][5, 7] = 0.9
    out.body[3][5, 7] = -0.1
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[3][5, 7] == 0.0) && (out.body_soil[4][5, 7] ≈ 0.8)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is fully avalanching on the
    # bucket soil (3)
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.2
    out.body_soil[1][5, 7] = 0.2
    out.body_soil[2][5, 7] = 0.3
    out.body[3][5, 7] = 0.9
    out.body[4][5, 7] = 1.0
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[1][5, 7] == 0.2) && (out.body_soil[2][5, 7] ≈ 0.9)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is fully avalanching on the
    # bucket soil (4)
    out.body[1][5, 7] = 0.9
    out.body[2][5, 7] = 1.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.1
    out.body_soil[3][5, 7] = 0.1
    out.body_soil[4][5, 7] = 0.6
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.1, false
    )
    @test (h_soil == 0.0) && (wall_presence == false)
    @test (out.body_soil[3][5, 7] == 0.1) && (out.body_soil[4][5, 7] ≈ 0.7)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # bucket (1)
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.1
    out.body[3][5, 7] = 0.4
    out.body[4][5, 7] = 0.9
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil ≈ 0.3) && (wall_presence == false)
    @test (ind == 1) && (ii == 5) && (jj == 7)
    @test (out.body_soil[1][5, 7] == 0.1) && (out.body_soil[2][5, 7] ≈ 0.4)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # bucket (2)
    out.body[1][5, 7] = 0.3
    out.body[2][5, 7] = 0.9
    out.body[3][5, 7] = -0.1
    out.body[4][5, 7] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil ≈ 0.5) && (wall_presence == false)
    @test (ind == 3) && (ii == 5) && (jj == 7)
    @test (out.body_soil[3][5, 7] == 0.2) && (out.body_soil[4][5, 7] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # bucket soil (1)
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.1
    out.body_soil[1][5, 7] = 0.1
    out.body_soil[2][5, 7] = 0.2
    out.body[3][5, 7] = 0.4
    out.body[4][5, 7] = 0.5
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil ≈ 0.4) && (wall_presence == false)
    @test (ind == 1) && (ii == 5) && (jj == 7)
    @test (out.body_soil[1][5, 7] == 0.1) && (out.body_soil[2][5, 7] ≈ 0.4)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # bucket soil (2)
    out.body[1][5, 7] = 0.6
    out.body[2][5, 7] = 0.9
    out.body[3][5, 7] = -0.1
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.6, false
    )
    @test (h_soil ≈ 0.2) && (wall_presence == false)
    @test (ind == 3) && (ii == 5) && (jj == 7)
    @test (out.body_soil[3][5, 7] == 0.0) && (out.body_soil[4][5, 7] ≈ 0.6)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # bucket soil (3)
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.2
    out.body_soil[1][5, 7] = 0.2
    out.body_soil[2][5, 7] = 0.3
    out.body[3][5, 7] = 0.4
    out.body[4][5, 7] = 0.5
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.3, false
    )
    @test (h_soil ≈ 0.2) && (wall_presence == false)
    @test (out.body_soil[1][5, 7] == 0.2) && (out.body_soil[2][5, 7] ≈ 0.4)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body_soil[1][5, 7] = 0.0
    out.body_soil[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # bucket soil (4)
    out.body[1][5, 7] = 0.7
    out.body[2][5, 7] = 0.8
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.1
    out.body_soil[3][5, 7] = 0.1
    out.body_soil[4][5, 7] = 0.6
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 5; 7])
    ind, ii, jj, h_soil, wall_presence = _move_body_soil!(
        out, 3, 10, 15, 0.3, 5, 7, 0.3, false
    )
    @test (h_soil ≈ 0.2) && (wall_presence == false)
    @test (out.body_soil[3][5, 7] == 0.1) && (out.body_soil[4][5, 7] ≈ 0.7)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 5; 7]])
    # Resetting values
    out.body[1][5, 7] = 0.0
    out.body[2][5, 7] = 0.0
    out.body[3][5, 7] = 0.0
    out.body[4][5, 7] = 0.0
    out.body_soil[3][5, 7] = 0.0
    out.body_soil[4][5, 7] = 0.0
    empty!(out.body_soil_pos)

    # Resetting dummy bucket value
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0

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

@testset "_move_intersecting_body_soil!" begin
    # Testing when soil is avalanching on the terrain (1)
    # First bucket layer at bottom
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching on the terrain (2)
    # Second bucket layer at bottom
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching on the terrain (3)
    # Bucket undergroumd
    set_RNG_seed!(1234)
    out.body[1][10, 15] = -0.6
    out.body[2][10, 15] = -0.5
    out.body[3][10, 15] = -0.3
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = -0.5
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.1
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == -0.5) && (out.body_soil[2][10, 15] ≈ -0.3)
    @test (out.body_soil[3][10, 15] == 0.0) && (out.body_soil[4][10, 15] == 0.1)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the first bucket layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 1.0
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the first bucket layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 0.5
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the first bucket layer (3)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 1.0
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the first bucket layer despite the lack of
    # available space
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.terrain[11, 14] = 0.4
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 0.7
    out.body_soil[1][11, 14] = 0.7
    out.body_soil[2][11, 14] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.7) && (out.body_soil[2][11, 14] == 0.8)
    @test (out.terrain[11, 14] ≈ 0.7)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the second bucket layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[3][11, 14] = 0.4
    out.body[4][11, 14] = 1.0
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the second bucket layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[3][11, 14] = 0.4
    out.body[4][11, 14] = 0.5
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the second bucket layer (3)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[3][11, 14] = 0.4
    out.body[4][11, 14] = 1.0
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is avalanching below the second bucket layer despite the lack of
    # available space
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[3][11, 14] = 0.4
    out.body[4][11, 14] = 0.5
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[11, 14] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is fully avalanching on the first bucket layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] ≈ 0.2) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is fully avalanching on the first bucket layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[1][11, 14] ≈ 0.2) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is fully avalanching on the second bucket layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] ≈ 0.2) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is fully avalanching on the second bucket layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[3][11, 14] ≈ 0.2) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is fully avalanching on the first bucket soil layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.1) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is fully avalanching on the first bucket soil layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[1][11, 14] == 0.1) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is fully avalanching on the second bucket soil layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.1
    out.body_soil[3][11, 14] = 0.1
    out.body_soil[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] == 0.1) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when soil is fully avalanching on the second bucket soil layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.1
    out.body_soil[3][11, 14] = 0.1
    out.body_soil[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[3][11, 14] == 0.1) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully avalanching on the
    # first bucket layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.7
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] ≈ 0.2) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully avalanching on the
    # first bucket layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.7
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[1][11, 14] ≈ 0.2) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully avalanching on the
    # second bucket layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] ≈ 0.2) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully avalanching on the
    # second bucket layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[3][11, 14] ≈ 0.2) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully avalanching on the
    # first bucket soil layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.7
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.1) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully avalanching on the
    # first bucket soil layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.7
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[1][11, 14] ≈ 0.1) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully avalanching on the
    # second bucket soil layer (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.1
    out.body_soil[3][11, 14] = 0.1
    out.body_soil[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] ≈ 0.1) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is fully avalanching on the
    # second bucket soil layer (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.1
    out.body_soil[3][11, 14] = 0.1
    out.body_soil[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[3][11, 14] ≈ 0.1) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is partially avalanching on the
    # first bucket layer and then on the terrain (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    out.body[3][11, 14] = 0.4
    out.body[4][11, 14] = 0.7
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] ≈ 0.2) && (out.body_soil[2][11, 14] ≈ 0.4)
    @test (out.terrain[12, 13] ≈ 0.1)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is partially avalanching on the
    # first bucket layer and then on the terrain (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    out.body[3][11, 14] = 0.4
    out.body[4][11, 14] = 0.7
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[1][11, 14] ≈ 0.2) && (out.body_soil[2][11, 14] ≈ 0.4)
    @test (out.terrain[12, 13] ≈ 0.1)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is partially avalanching on the
    # second bucket layer and then on the terrain (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] ≈ 0.2) && (out.body_soil[4][11, 14] ≈ 0.4)
    @test (out.terrain[12, 13] ≈ 0.1)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is partially avalanching on the
    # second bucket layer and then on the terrain (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[3][11, 14] ≈ 0.2) && (out.body_soil[4][11, 14] ≈ 0.4)
    @test (out.terrain[12, 13] ≈ 0.1)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is partially avalanching on the
    # first bucket soil layer and then on the terrain (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body[3][11, 14] = 0.4
    out.body[4][11, 14] = 0.7
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.1) && (out.body_soil[2][11, 14] ≈ 0.4)
    @test (out.terrain[12, 13] ≈ 0.1)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is partially avalanching on the
    # first bucket soil layer and then on the terrain (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body[3][11, 14] = 0.4
    out.body[4][11, 14] = 0.7
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[1][11, 14] ≈ 0.1) && (out.body_soil[2][11, 14] ≈ 0.4)
    @test (out.terrain[12, 13] ≈ 0.1)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is partially avalanching on the
    # second bucket soil layer and then on the terrain (1)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.1
    out.body_soil[3][11, 14] = 0.1
    out.body_soil[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] ≈ 0.1) && (out.body_soil[4][11, 14] ≈ 0.4)
    @test (out.terrain[12, 13] ≈ 0.1)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is partially avalanching on the
    # second bucket soil layer and then on the terrain (2)
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.8
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.1
    out.body_soil[3][11, 14] = 0.1
    out.body_soil[4][11, 14] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[3][11, 14] ≈ 0.1) && (out.body_soil[4][11, 14] ≈ 0.4)
    @test (out.terrain[12, 13] ≈ 0.1)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there is a lot of soil on the first bucket layer but soil is still
    # avalanching on it
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    out.body_soil[1][11, 14] = 0.2
    out.body_soil[2][11, 14] = 0.5
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.2) && (out.body_soil[2][11, 14] ≈ 0.8)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [1; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there is a lot of soil on the second bucket layer but soil is still
    # avalanching on it
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.2
    out.body_soil[3][11, 14] = 0.2
    out.body_soil[4][11, 14] = 0.5
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] == 0.2) && (out.body_soil[4][11, 14] ≈ 0.8)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket soil layer, then the soil is avalanching on the terrain below the first
    # bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body[3][11, 14] = 0.7
    out.body[4][11, 14] = 0.8
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.6
    out.body_soil[3][11, 14] = 0.8
    out.body_soil[4][11, 14] = 0.9
    out.body[1][12, 13] = 0.2
    out.body[2][12, 13] = 0.4
    out.body_soil[1][12, 13] = 0.4
    out.body_soil[2][12, 13] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.1) && (out.body_soil[2][11, 14] ≈ 0.7)
    @test (out.body_soil[3][11, 14] == 0.8) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil[1][12, 13] == 0.4) && (out.body_soil[2][12, 13] == 0.8)
    @test (out.terrain[12, 13] ≈ 0.2)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [1; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # second bucket soil layer, then the soil is avalanching on the terrain below the first
    # bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.9
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.8
    out.body[2][11, 14] = 0.9
    out.body[3][11, 14] = 0.3
    out.body[4][11, 14] = 0.4
    out.body_soil[1][11, 14] = 0.9
    out.body_soil[2][11, 14] = 1.2
    out.body_soil[3][11, 14] = 0.4
    out.body_soil[4][11, 14] = 0.5
    out.body[1][12, 13] = 0.5
    out.body[2][12, 13] = 0.6
    out.body_soil[1][12, 13] = 0.6
    out.body_soil[2][12, 13] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.9) && (out.body_soil[2][11, 14] == 1.2)
    @test (out.body_soil[3][11, 14] == 0.4) && (out.body_soil[4][11, 14] ≈ 0.8)
    @test (out.body_soil[1][12, 13] == 0.6) && (out.body_soil[2][12, 13] == 0.8)
    @test (out.terrain[12, 13] ≈ 0.1)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [1; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the first bucket layer is
    # blocking the movement, then the soil is avalanching on the terrain below the second
    # bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.1
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = -0.1
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.8
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.5
    out.body_soil[3][11, 14] = 0.8
    out.body_soil[4][11, 14] = 0.9
    out.body[3][12, 13] = 0.1
    out.body[4][12, 13] = 0.4
    out.body_soil[3][12, 13] = 0.4
    out.body_soil[4][12, 13] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.0) && (out.body_soil[2][11, 14] == 0.5)
    @test (out.body_soil[3][11, 14] == 0.8) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil[3][12, 13] == 0.4) && (out.body_soil[4][12, 13] == 0.8)
    @test (out.terrain[12, 13] ≈ 0.6)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the second bucket layer is
    # blocking the movement, then the soil is avalanching on the terrain below the second
    # bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.1
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.8
    out.body[3][11, 14] = 0.1
    out.body[4][11, 14] = 0.4
    out.body_soil[1][11, 14] = 0.8
    out.body_soil[2][11, 14] = 0.9
    out.body_soil[3][11, 14] = 0.4
    out.body_soil[4][11, 14] = 0.5
    out.body[3][12, 13] = 0.5
    out.body[4][12, 13] = 0.6
    out.body_soil[3][12, 13] = 0.6
    out.body_soil[4][12, 13] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.8) && (out.body_soil[2][11, 14] == 0.9)
    @test (out.body_soil[3][11, 14] == 0.4) && (out.body_soil[4][11, 14] == 0.5)
    @test (out.body_soil[3][12, 13] == 0.6) && (out.body_soil[4][12, 13] == 0.8)
    @test (out.terrain[12, 13] ≈ 0.6)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the first bucket layer is
    # blocking the movement, then the soil is avalanching on the first bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.3
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.8
    out.body_soil[1][11, 14] = 0.3
    out.body_soil[2][11, 14] = 0.5
    out.body_soil[3][11, 14] = 0.8
    out.body_soil[4][11, 14] = 0.9
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.3
    out.body_soil[1][12, 13] = 0.3
    out.body_soil[2][12, 13] = 0.4
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.3) && (out.body_soil[2][11, 14] == 0.5)
    @test (out.body_soil[3][11, 14] == 0.8) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil[1][12, 13] == 0.3) && (out.body_soil[2][12, 13] ≈ 0.7)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [1; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the second bucket layer is
    # blocking the movement, then the soil is avalanching on the first bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.8
    out.body[3][11, 14] = 0.3
    out.body[4][11, 14] = 0.4
    out.body_soil[1][11, 14] = 0.8
    out.body_soil[2][11, 14] = 0.9
    out.body_soil[3][11, 14] = 0.4
    out.body_soil[4][11, 14] = 0.5
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.1
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.8) && (out.body_soil[2][11, 14] == 0.9)
    @test (out.body_soil[3][11, 14] == 0.4) && (out.body_soil[4][11, 14] == 0.5)
    @test (out.body_soil[1][12, 13] == 0.1) && (out.body_soil[2][12, 13] ≈ 0.4)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [1; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the first bucket layer is
    # blocking the movement, then the soil is avalanching on the second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body[3][11, 14] = 0.7
    out.body[4][11, 14] = 0.8
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.7
    out.body_soil[3][11, 14] = 0.8
    out.body_soil[4][11, 14] = 0.9
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.1
    out.body_soil[3][12, 13] = 0.1
    out.body_soil[4][12, 13] = 0.3
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.1) && (out.body_soil[2][11, 14] == 0.7)
    @test (out.body_soil[3][11, 14] == 0.8) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil[3][12, 13] == 0.1) && (out.body_soil[4][12, 13] ≈ 0.6)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # second bucket soil layer, then the soil is avalanching on the second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.6
    out.body[2][11, 14] = 0.8
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.2
    out.body_soil[1][11, 14] = 0.8
    out.body_soil[2][11, 14] = 0.9
    out.body_soil[3][11, 14] = 0.2
    out.body_soil[4][11, 14] = 0.5
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.8) && (out.body_soil[2][11, 14] == 0.9)
    @test (out.body_soil[3][11, 14] == 0.2) && (out.body_soil[4][11, 14] ≈ 0.6)
    @test (out.body_soil[3][12, 13] == 0.2) && (out.body_soil[4][12, 13] ≈ 0.4)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket layer, then the soil is avalanching on the terrain below the first
    # bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.8
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.3
    out.body_soil[3][11, 14] = 0.8
    out.body_soil[4][11, 14] = 0.9
    out.body[1][12, 13] = 0.2
    out.body[2][12, 13] = 0.4
    out.body_soil[1][12, 13] = 0.4
    out.body_soil[2][12, 13] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.1) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil[3][11, 14] == 0.8) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil[1][12, 13] == 0.4) && (out.body_soil[2][12, 13] == 0.8)
    @test (out.terrain[12, 13] ≈ 0.1)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [1; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # second bucket layer, then the soil is avalanching on the terrain below the first
    # bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 0.9
    out.body[3][11, 14] = 0.1
    out.body[4][11, 14] = 0.2
    out.body_soil[1][11, 14] = 0.9
    out.body_soil[2][11, 14] = 1.2
    out.body_soil[3][11, 14] = 0.2
    out.body_soil[4][11, 14] = 0.3
    out.body[1][12, 13] = 0.5
    out.body[2][12, 13] = 0.6
    out.body_soil[1][12, 13] = 0.6
    out.body_soil[2][12, 13] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.9) && (out.body_soil[2][11, 14] == 1.2)
    @test (out.body_soil[3][11, 14] == 0.2) && (out.body_soil[4][11, 14] ≈ 0.4)
    @test (out.body_soil[1][12, 13] == 0.6) && (out.body_soil[2][12, 13] == 0.8)
    @test (out.terrain[12, 13] ≈ 0.2)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [1; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket layer, then the soil is avalanching on the terrain below the second
    # bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.1
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = -0.1
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.8
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.4
    out.body_soil[3][11, 14] = 0.8
    out.body_soil[4][11, 14] = 0.9
    out.body[3][12, 13] = 0.1
    out.body[4][12, 13] = 0.4
    out.body_soil[3][12, 13] = 0.4
    out.body_soil[4][12, 13] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.0) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil[3][11, 14] == 0.8) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil[3][12, 13] == 0.4) && (out.body_soil[4][12, 13] == 0.8)
    @test (out.terrain[12, 13] ≈ 0.5)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # second bucket layer, then the soil is avalanching on the terrain below the second
    # bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.1
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.8
    out.body[3][11, 14] = 0.1
    out.body[4][11, 14] = 0.2
    out.body_soil[1][11, 14] = 0.8
    out.body_soil[2][11, 14] = 0.9
    out.body_soil[3][11, 14] = 0.2
    out.body_soil[4][11, 14] = 0.3
    out.body[3][12, 13] = 0.5
    out.body[4][12, 13] = 0.6
    out.body_soil[3][12, 13] = 0.6
    out.body_soil[4][12, 13] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.8) && (out.body_soil[2][11, 14] == 0.9)
    @test (out.body_soil[3][11, 14] == 0.2) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil[3][12, 13] == 0.6) && (out.body_soil[4][12, 13] == 0.8)
    @test (out.terrain[12, 13] ≈ 0.4)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.terrain[12, 13] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket layer, then the soil is avalanching on the first bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.3
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.8
    out.body_soil[1][11, 14] = 0.3
    out.body_soil[2][11, 14] = 0.4
    out.body_soil[3][11, 14] = 0.8
    out.body_soil[4][11, 14] = 0.9
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.3
    out.body_soil[1][12, 13] = 0.3
    out.body_soil[2][12, 13] = 0.4
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.3) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil[3][11, 14] == 0.8) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil[1][12, 13] == 0.3) && (out.body_soil[2][12, 13] ≈ 0.6)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [1; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # second bucket layer, then the soil is avalanching on the first bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.8
    out.body[3][11, 14] = 0.3
    out.body[4][11, 14] = 0.4
    out.body_soil[1][11, 14] = 0.8
    out.body_soil[2][11, 14] = 0.9
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.1
    out.body_soil[1][12, 13] = 0.1
    out.body_soil[2][12, 13] = 0.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.8) && (out.body_soil[2][11, 14] == 0.9)
    @test (out.body_soil[3][11, 14] == 0.4) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil[1][12, 13] == 0.1) && (out.body_soil[2][12, 13] ≈ 0.4)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [1; 12; 13], [3; 11; 14]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket layer, then the soil is avalanching on the second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.4
    out.body[3][11, 14] = 0.6
    out.body[4][11, 14] = 0.8
    out.body_soil[3][11, 14] = 0.8
    out.body_soil[4][11, 14] = 0.9
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.1
    out.body_soil[3][12, 13] = 0.1
    out.body_soil[4][12, 13] = 0.3
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.4) && (out.body_soil[2][11, 14] ≈ 0.6)
    @test (out.body_soil[3][11, 14] == 0.8) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil[3][12, 13] == 0.1) && (out.body_soil[4][12, 13] ≈ 0.4)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [3; 11; 14], [3; 12; 13], [1; 11; 14]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # second bucket layer, then the soil is avalanching on the second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.8
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.3
    out.body_soil[1][11, 14] = 0.8
    out.body_soil[2][11, 14] = 0.9
    out.body_soil[3][11, 14] = 0.3
    out.body_soil[4][11, 14] = 0.4
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.2
    out.body_soil[3][12, 13] = 0.2
    out.body_soil[4][12, 13] = 0.3
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.8) && (out.body_soil[2][11, 14] == 0.9)
    @test (out.body_soil[3][11, 14] == 0.3) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil[3][12, 13] == 0.2) && (out.body_soil[4][12, 13] ≈ 0.5)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the first bucket layer is
    # blocking the movement, then the first bucket layer is blocking the movement. New
    # direction, two bucket layers and the soil on the second bucket layer is blocking the
    # movement, then the first bucket layer is blocking the movement. New direction, two
    # bucket layers and the soil on the first bucket layer is blocking the movement, then
    # the second bucket layer is blocking the movement. New direction, two bucket layers and
    # the soil on the second bucket layer is blocking the movement, then the second bucket
    # layer is blocking the movement. New direction, two bucket layers and the soil on the
    # first bucket layer is blocking the movement, then two bucket layers and the soil is
    # fully avalanching on the first bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    out.body_soil[1][11, 14] = 0.2
    out.body_soil[2][11, 14] = 0.5
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.7
    out.body[1][12, 13] = 0.2
    out.body[2][12, 13] = 0.5
    out.body[1][11, 15] = 0.7
    out.body[2][11, 15] = 0.8
    out.body[3][11, 15] = 0.0
    out.body[4][11, 15] = 0.1
    out.body_soil[3][11, 15] = 0.1
    out.body_soil[4][11, 15] = 0.7
    out.body[3][12, 15] = 0.0
    out.body[4][12, 15] = 0.5
    out.body[1][9, 14] = 0.0
    out.body[2][9, 14] = 0.1
    out.body_soil[1][9, 14] = 0.1
    out.body_soil[2][9, 14] = 0.9
    out.body[3][9, 14] = 0.9
    out.body[4][9, 14] = 1.0
    out.body[3][8, 13] = 0.1
    out.body[4][8, 13] = 0.7
    out.body[1][10, 16] = 0.5
    out.body[2][10, 16] = 0.7
    out.body[3][10, 16] = 0.0
    out.body[4][10, 16] = 0.4
    out.body_soil[3][10, 16] = 0.4
    out.body_soil[4][10, 16] = 0.5
    out.body[3][10, 17] = -0.2
    out.body[4][10, 17] = 1.0
    out.body[1][11, 16] = 0.0
    out.body[2][11, 16] = 0.1
    out.body_soil[1][11, 16] = 0.1
    out.body_soil[2][11, 16] = 0.8
    out.body[3][11, 16] = 0.8
    out.body[4][11, 16] = 0.9
    out.body[1][12, 17] = 0.1
    out.body[2][12, 17] = 0.3
    out.body[3][12, 17] = 0.6
    out.body[4][12, 17] = 0.7
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 15])
    push!(out.body_soil_pos, [1; 9; 14])
    push!(out.body_soil_pos, [3; 10; 16])
    push!(out.body_soil_pos, [1; 11; 16])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.2) && (out.body_soil[2][11, 14] == 0.5)
    @test (out.body_soil[3][11, 15] == 0.1) && (out.body_soil[4][11, 15] == 0.7)
    @test (out.body_soil[1][9, 14] == 0.1) && (out.body_soil[2][9, 14] == 0.9)
    @test (out.body_soil[3][10, 16] == 0.4) && (out.body_soil[4][10, 16] == 0.5)
    @test (out.body_soil[1][11, 16] == 0.1) && (out.body_soil[2][11, 16] == 0.8)
    @test (out.body_soil[1][12, 17] == 0.3) && (out.body_soil[2][12, 17] ≈ 0.6)
    res_body_soil_pos = [
        [1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 15], [1; 9; 14], [3; 10; 16],
        [1; 11; 16], [1; 12; 17],
    ]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body[1][11, 15] = 0.0
    out.body[2][11, 15] = 0.0
    out.body[3][11, 15] = 0.0
    out.body[4][11, 15] = 0.0
    out.body[3][12, 15] = 0.0
    out.body[4][12, 15] = 0.0
    out.body[1][9, 14] = 0.0
    out.body[2][9, 14] = 0.0
    out.body[3][9, 14] = 0.0
    out.body[4][9, 14] = 0.0
    out.body[3][8, 13] = 0.0
    out.body[4][8, 13] = 0.0
    out.body[1][10, 16] = 0.0
    out.body[2][10, 16] = 0.0
    out.body[3][10, 16] = 0.0
    out.body[4][10, 16] = 0.0
    out.body[3][10, 17] = 0.0
    out.body[4][10, 17] = 0.0
    out.body[1][11, 16] = 0.0
    out.body[2][11, 16] = 0.0
    out.body[3][11, 16] = 0.0
    out.body[4][11, 16] = 0.0
    out.body[1][12, 17] = 0.0
    out.body[2][12, 17] = 0.0
    out.body[3][12, 17] = 0.0
    out.body[4][12, 17] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 15] = 0.0
    out.body_soil[4][11, 15] = 0.0
    out.body_soil[1][9, 14] = 0.0
    out.body_soil[2][9, 14] = 0.0
    out.body_soil[3][10, 16] = 0.0
    out.body_soil[4][10, 16] = 0.0
    out.body_soil[1][11, 16] = 0.0
    out.body_soil[2][11, 16] = 0.0
    out.body_soil[1][12, 17] = 0.0
    out.body_soil[2][12, 17] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket layer, then the first bucket layer is blocking the movement. New
    # direction, two bucket layers and the soil is partially avalanching on the second
    # bucket layer, then the first bucket layer is blocking the movement. New direction, two
    # bucket layers and the soil is partially avalanching on the first bucket layer, then
    # the second bucket layer is blocking the movement. New direction two bucket layers and
    # the soil is partially avalanching on the second bucket layer, then the second bucket
    # layer is blocking the movement. New direction, two bucket layers and  the soil on the
    # first bucket layer is blocking the movement, then two bucket layers and the soil is
    # fully avalanching on the second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.5
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    out.body_soil[1][11, 14] = 0.2
    out.body_soil[2][11, 14] = 0.3
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.7
    out.body[1][12, 13] = 0.2
    out.body[2][12, 13] = 0.5
    out.body[1][11, 15] = 0.7
    out.body[2][11, 15] = 0.8
    out.body[3][11, 15] = 0.0
    out.body[4][11, 15] = 0.1
    out.body_soil[3][11, 15] = 0.1
    out.body_soil[4][11, 15] = 0.4
    out.body[3][12, 15] = 0.0
    out.body[4][12, 15] = 0.5
    out.body[1][9, 14] = 0.0
    out.body[2][9, 14] = 0.1
    out.body_soil[1][9, 14] = 0.1
    out.body_soil[2][9, 14] = 0.2
    out.body[3][9, 14] = 0.4
    out.body[4][9, 14] = 1.0
    out.body[3][8, 13] = 0.1
    out.body[4][8, 13] = 0.7
    out.body[1][10, 16] = 0.5
    out.body[2][10, 16] = 0.7
    out.body[3][10, 16] = 0.0
    out.body[4][10, 16] = 0.3
    out.body_soil[3][10, 16] = 0.3
    out.body_soil[4][10, 16] = 0.4
    out.body[3][10, 17] = -0.2
    out.body[4][10, 17] = 1.0
    out.body[1][11, 16] = 0.0
    out.body[2][11, 16] = 0.1
    out.body_soil[1][11, 16] = 0.1
    out.body_soil[2][11, 16] = 0.8
    out.body[3][11, 16] = 0.8
    out.body[4][11, 16] = 0.9
    out.body[1][12, 17] = 1.5
    out.body[2][12, 17] = 1.7
    out.body[3][12, 17] = 0.1
    out.body[4][12, 17] = 0.3
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 11; 15])
    push!(out.body_soil_pos, [1; 9; 14])
    push!(out.body_soil_pos, [3; 10; 16])
    push!(out.body_soil_pos, [1; 11; 16])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.2) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil[3][11, 15] == 0.1) && (out.body_soil[4][11, 15] ≈ 0.7)
    @test (out.body_soil[1][9, 14] == 0.1) && (out.body_soil[2][9, 14] ≈ 0.4)
    @test (out.body_soil[3][10, 16] == 0.3) && (out.body_soil[4][10, 16] ≈ 0.5)
    @test (out.body_soil[1][11, 16] == 0.1) && (out.body_soil[2][11, 16] == 0.8)
    @test (out.body_soil[3][12, 17] == 0.3) && (out.body_soil[4][12, 17] ≈ 0.5)
    res_body_soil_pos = [
        [1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 11; 15], [1; 9; 14], [3; 10; 16],
        [1; 11; 16], [3; 12; 17]
    ]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body[1][11, 15] = 0.0
    out.body[2][11, 15] = 0.0
    out.body[3][11, 15] = 0.0
    out.body[4][11, 15] = 0.0
    out.body[3][12, 15] = 0.0
    out.body[4][12, 15] = 0.0
    out.body[1][9, 14] = 0.0
    out.body[2][9, 14] = 0.0
    out.body[3][9, 14] = 0.0
    out.body[4][9, 14] = 0.0
    out.body[3][8, 13] = 0.0
    out.body[4][8, 13] = 0.0
    out.body[1][10, 16] = 0.0
    out.body[2][10, 16] = 0.0
    out.body[3][10, 16] = 0.0
    out.body[4][10, 16] = 0.0
    out.body[3][10, 17] = 0.0
    out.body[4][10, 17] = 0.0
    out.body[1][11, 16] = 0.0
    out.body[2][11, 16] = 0.0
    out.body[3][11, 16] = 0.0
    out.body[4][11, 16] = 0.0
    out.body[1][12, 17] = 0.0
    out.body[2][12, 17] = 0.0
    out.body[3][12, 17] = 0.0
    out.body[4][12, 17] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][11, 15] = 0.0
    out.body_soil[4][11, 15] = 0.0
    out.body_soil[1][9, 14] = 0.0
    out.body_soil[2][9, 14] = 0.0
    out.body_soil[3][10, 16] = 0.0
    out.body_soil[4][10, 16] = 0.0
    out.body_soil[1][11, 16] = 0.0
    out.body_soil[2][11, 16] = 0.0
    out.body_soil[3][12, 17] = 0.0
    out.body_soil[4][12, 17] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the first bucket layer is
    # blocking the movement, then the soil is fully avalanching on the second bucket soil
    # layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.5
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    out.body_soil[1][11, 14] = 0.2
    out.body_soil[2][11, 14] = 0.5
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.7
    out.body[3][12, 13] = 0.1
    out.body[4][12, 13] = 0.2
    out.body_soil[3][12, 13] = 0.2
    out.body_soil[4][12, 13] = 0.5
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.2) && (out.body_soil[2][11, 14] == 0.5)
    @test (out.body_soil[3][12, 13] == 0.2) && (out.body_soil[4][12, 13] ≈ 1.5)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the second bucket layer is
    # blocking the movement, then the soil is fully avalanching on the second bucket soil
    # layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.5
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 0.9
    out.body[3][11, 14] = 0.1
    out.body[4][11, 14] = 0.2
    out.body_soil[3][11, 14] = 0.2
    out.body_soil[4][11, 14] = 0.4
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.3
    out.body_soil[3][12, 13] = 0.3
    out.body_soil[4][12, 13] = 0.8
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] == 0.2) && (out.body_soil[4][11, 14] == 0.4)
    @test (out.body_soil[3][12, 13] == 0.3) && (out.body_soil[4][12, 13] ≈ 1.8)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket layer, then the soil is fully avalanching on the second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.5
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.1
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.6
    out.body[3][11, 14] = 0.7
    out.body[4][11, 14] = 0.8
    out.body[3][12, 13] = 0.1
    out.body[4][12, 13] = 0.2
    out.body_soil[3][12, 13] = 0.2
    out.body_soil[4][12, 13] = 0.9
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [3; 12; 13])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.1) && (out.body_soil[2][11, 14] ≈ 0.7)
    @test (out.body_soil[3][12, 13] == 0.2) && (out.body_soil[4][12, 13] ≈ 1.8)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [1; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # second bucket layer, then the soil is fully avalanching on the second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.5
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.4
    out.body[2][11, 14] = 0.9
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.1
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.3
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] == 0.1) && (out.body_soil[4][11, 14] ≈ 0.4)
    @test (out.body_soil[3][12, 13] == 0.3) && (out.body_soil[4][12, 13] ≈ 1.0)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the second bucket layer is
    # blocking the movement, then two bucket layers and the soil is fully avalanching on
    # the second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.9
    out.body[2][11, 14] = 1.4
    out.body[3][11, 14] = 0.3
    out.body[4][11, 14] = 0.4
    out.body_soil[3][11, 14] = 0.4
    out.body_soil[4][11, 14] = 0.9
    out.body[1][12, 13] = 0.7
    out.body[2][12, 13] = 0.8
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.1
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] == 0.4) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil[3][12, 13] == 0.1) && (out.body_soil[4][12, 13] ≈ 0.4)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket layer, then two bucket layers and soil is partially avalanching on the
    # first bucket layer that is higher, then two bucket layers and soil is partially
    # avalanching on the first bucket layer that is higher, then two bucket layers and soil
    # is partially avalanching on the first bucket layer, then two bucket layers and soil is
    # partially avalanching on the first bucket layer, then two bucket layers and soil is
    # partially avalanching on the second bucket layer that is higher, then two bucket
    # layers and soil is partially avalanching on the second bucket layer that is higher,
    # then two bucket layers and soil is partially avalanching on the first bucket layer
    # that is higher, then two bucket layers and soil is partially avalanching on the second
    # bucket layer, then two bucket layers and the soil is fully avalanching on the first
    # bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 3.0
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.2
    out.body[3][11, 14] = 0.5
    out.body[4][11, 14] = 0.7
    out.body[1][12, 13] = 0.3
    out.body[2][12, 13] = 0.4
    out.body_soil[1][12, 13] = 0.4
    out.body_soil[2][12, 13] = 0.5
    out.body[3][12, 13] = 0.6
    out.body[4][12, 13] = 0.7
    out.body[1][13, 12] = 0.4
    out.body[2][13, 12] = 0.5
    out.body_soil[1][13, 12] = 0.5
    out.body_soil[2][13, 12] = 0.7
    out.body[3][13, 12] = 0.9
    out.body[4][13, 12] = 1.0
    out.body[1][14, 11] = 0.0
    out.body[2][14, 11] = 0.2
    out.body[3][14, 11] = 0.6
    out.body[4][14, 11] = 0.7
    out.body[1][15, 10] = 0.0
    out.body[2][15, 10] = 0.2
    out.body_soil[1][15, 10] = 0.2
    out.body_soil[2][15, 10] = 0.4
    out.body[3][15, 10] = 0.6
    out.body[4][15, 10] = 0.7
    out.body[1][16, 9] = 0.7
    out.body[2][16, 9] = 0.8
    out.body[3][16, 9] = 0.0
    out.body[4][16, 9] = 0.5
    out.body[1][17, 8] = 0.9
    out.body[2][17, 8] = 1.0
    out.body[3][17, 8] = 0.5
    out.body[4][17, 8] = 0.6
    out.body_soil[3][17, 8] = 0.6
    out.body_soil[4][17, 8] = 0.8
    out.body[1][18, 7] = 0.0
    out.body[2][18, 7] = 0.8
    out.body[3][18, 7] = 0.9
    out.body[4][18, 7] = 1.0
    out.body[1][19, 6] = 0.9
    out.body[2][19, 6] = 1.0
    out.body[3][19, 6] = 0.0
    out.body[4][19, 6] = 0.4
    out.body[1][20, 5] = 0.0
    out.body[2][20, 5] = 0.1
    out.body[3][20, 5] = 0.9
    out.body[4][20, 5] = 1.0
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 12; 13])
    push!(out.body_soil_pos, [1; 13; 12])
    push!(out.body_soil_pos, [1; 15; 10])
    push!(out.body_soil_pos, [3; 17; 8])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.2) && (out.body_soil[2][11, 14] ≈ 0.5)
    @test (out.body_soil[1][12, 13] == 0.4) && (out.body_soil[2][12, 13] ≈ 0.6)
    @test (out.body_soil[1][13, 12] == 0.5) && (out.body_soil[2][13, 12] ≈ 0.9)
    @test (out.body_soil[1][14, 11] == 0.2) && (out.body_soil[2][14, 11] ≈ 0.6)
    @test (out.body_soil[1][15, 10] == 0.2) && (out.body_soil[2][15, 10] ≈ 0.6)
    @test (out.body_soil[3][16, 9] == 0.5) && (out.body_soil[4][16, 9] ≈ 0.7)
    @test (out.body_soil[3][17, 8] == 0.6) && (out.body_soil[4][17, 8] ≈ 0.9)
    @test (out.body_soil[1][18, 7] == 0.8) && (out.body_soil[2][18, 7] ≈ 0.9)
    @test (out.body_soil[3][19, 6] == 0.4) && (out.body_soil[4][19, 6] ≈ 0.9)
    @test (out.body_soil[1][20, 5] == 0.1) && (out.body_soil[2][20, 5] ≈ 0.5)
    res_body_soil_pos = [
        [1; 10; 15], [3; 10; 15], [1; 12; 13], [1; 13; 12], [1; 15; 10], [3; 17; 8],
        [1; 11; 14], [1; 14; 11], [3; 16; 9], [1; 18; 7], [3; 19; 6], [1; 20; 5]
    ]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body[1][13, 12] = 0.0
    out.body[2][13, 12] = 0.0
    out.body[3][13, 12] = 0.0
    out.body[4][13, 12] = 0.0
    out.body[1][14, 11] = 0.0
    out.body[2][14, 11] = 0.0
    out.body[3][14, 11] = 0.0
    out.body[4][14, 11] = 0.0
    out.body[1][15, 10] = 0.0
    out.body[2][15, 10] = 0.0
    out.body[3][15, 10] = 0.0
    out.body[4][15, 10] = 0.0
    out.body[1][16, 9] = 0.0
    out.body[2][16, 9] = 0.0
    out.body[3][16, 9] = 0.0
    out.body[4][16, 9] = 0.0
    out.body[1][17, 8] = 0.0
    out.body[2][17, 8] = 0.0
    out.body[3][17, 8] = 0.0
    out.body[4][17, 8] = 0.0
    out.body[1][18, 7] = 0.0
    out.body[2][18, 7] = 0.0
    out.body[3][18, 7] = 0.0
    out.body[4][18, 7] = 0.0
    out.body[1][19, 6] = 0.0
    out.body[2][19, 6] = 0.0
    out.body[3][19, 6] = 0.0
    out.body[4][19, 6] = 0.0
    out.body[1][20, 5] = 0.0
    out.body[2][20, 5] = 0.0
    out.body[3][20, 5] = 0.0
    out.body[4][20, 5] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    out.body_soil[1][13, 12] = 0.0
    out.body_soil[2][13, 12] = 0.0
    out.body_soil[1][14, 11] = 0.0
    out.body_soil[2][14, 11] = 0.0
    out.body_soil[1][15, 10] = 0.0
    out.body_soil[2][15, 10] = 0.0
    out.body_soil[3][16, 9] = 0.0
    out.body_soil[4][16, 9] = 0.0
    out.body_soil[3][17, 8] = 0.0
    out.body_soil[4][17, 8] = 0.0
    out.body_soil[1][18, 7] = 0.0
    out.body_soil[2][18, 7] = 0.0
    out.body_soil[3][19, 6] = 0.0
    out.body_soil[4][19, 6] = 0.0
    out.body_soil[1][20, 5] = 0.0
    out.body_soil[2][20, 5] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and soil is partially avalanching on the
    # second bucket layer, then two bucket layers and soil is partially avalanching on the
    # first bucket layer, then two bucket layers and soil is partially avalanching on the
    # second bucket layer, then two bucket layers and soil is partially avalanching on the
    # second bucket layer, then two bucket layers and soil is partially avalanching on the
    # second bucket layer that is higher, then two bucket layers and soil is partially
    # avalanching on the first bucket layer, then two bucket layers and soil is partially
    # avalanching on the first bucket layer that is higher, then two bucket layers and soil
    # is partially avalanching on the second bucket layer, then two bucket layers and soil
    # is partially avalanching on the first bucket layer that is higher, then two bucket
    # layers and soil is partially avalanching on the second bucket layer that is higher,
    # then two bucket layers and the soil is fully avalanching on the first bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 3.0
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.5
    out.body[2][11, 14] = 0.6
    out.body[3][11, 14] = 0.1
    out.body[4][11, 14] = 0.3
    out.body_soil[3][11, 14] = 0.3
    out.body_soil[4][11, 14] = 0.4
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.2
    out.body_soil[1][12, 13] = 0.2
    out.body_soil[2][12, 13] = 0.3
    out.body[3][12, 13] = 0.5
    out.body[4][12, 13] = 0.6
    out.body[1][13, 12] = 0.4
    out.body[2][13, 12] = 0.5
    out.body[3][13, 12] = 0.1
    out.body[4][13, 12] = 0.2
    out.body[1][14, 11] = 0.3
    out.body[2][14, 11] = 0.4
    out.body[3][14, 11] = -0.2
    out.body[4][14, 11] = -0.1
    out.body_soil[3][14, 11] = -0.1
    out.body_soil[4][14, 11] = 0.0
    out.body[1][15, 10] = 0.4
    out.body[2][15, 10] = 0.5
    out.body[3][15, 10] = 0.0
    out.body[4][15, 10] = 0.2
    out.body[1][16, 9] = 0.0
    out.body[2][16, 9] = 0.1
    out.body_soil[1][16, 9] = 0.1
    out.body_soil[2][16, 9] = 0.2
    out.body[3][16, 9] = 0.6
    out.body[4][16, 9] = 0.7
    out.body[1][17, 8] = 0.4
    out.body[2][17, 8] = 0.5
    out.body_soil[1][17, 8] = 0.5
    out.body_soil[2][17, 8] = 0.9
    out.body[3][17, 8] = 1.0
    out.body[4][17, 8] = 1.1
    out.body[1][18, 7] = 0.9
    out.body[2][18, 7] = 1.1
    out.body[3][18, 7] = 0.6
    out.body[4][18, 7] = 0.7
    out.body[1][19, 6] = 0.6
    out.body[2][19, 6] = 0.8
    out.body[3][19, 6] = 1.0
    out.body[4][19, 6] = 1.1
    out.body[1][20, 5] = 1.5
    out.body[2][20, 5] = 1.6
    out.body[3][20, 5] = 0.6
    out.body[4][20, 5] = 0.9
    out.body_soil[3][20, 5] = 0.9
    out.body_soil[4][20, 5] = 1.2
    out.body[1][21, 4] = 0.0
    out.body[2][21, 4] = 0.1
    out.body_soil[1][21, 4] = 0.1
    out.body_soil[2][21, 4] = 0.3
    out.body[3][21, 4] = 0.9
    out.body[4][21, 4] = 1.2
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    push!(out.body_soil_pos, [3; 14; 11])
    push!(out.body_soil_pos, [1; 16; 9])
    push!(out.body_soil_pos, [1; 17; 8])
    push!(out.body_soil_pos, [3; 20; 5])
    push!(out.body_soil_pos, [1; 21; 4])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] == 0.3) && (out.body_soil[4][11, 14] ≈ 0.5)
    @test (out.body_soil[1][12, 13] == 0.2) && (out.body_soil[2][12, 13] ≈ 0.5)
    @test (out.body_soil[3][13, 12] == 0.2) && (out.body_soil[4][13, 12] ≈ 0.4)
    @test (out.body_soil[3][14, 11] == -0.1) && (out.body_soil[4][14, 11] ≈ 0.3)
    @test (out.body_soil[3][15, 10] == 0.2) && (out.body_soil[4][15, 10] ≈ 0.4)
    @test (out.body_soil[1][16, 9] == 0.1) && (out.body_soil[2][16, 9] ≈ 0.6)
    @test (out.body_soil[1][17, 8] == 0.5) && (out.body_soil[2][17, 8] ≈ 1.0)
    @test (out.body_soil[3][18, 7] == 0.7) && (out.body_soil[4][18, 7] ≈ 0.9)
    @test (out.body_soil[1][19, 6] == 0.8) && (out.body_soil[2][19, 6] ≈ 1.0)
    @test (out.body_soil[3][20, 5] == 0.9) && (out.body_soil[4][20, 5] ≈ 1.5)
    @test (out.body_soil[1][21, 4] == 0.1) && (out.body_soil[2][21, 4] ≈ 0.6)
    res_body_soil_pos = [
        [1; 10; 15], [3; 10; 15], [3; 11; 14], [1; 12; 13], [3; 14; 11], [1; 16; 9],
        [1; 17; 8], [3; 20; 5], [1; 21; 4], [3; 13; 12], [3; 15; 10], [3; 18; 7], [1; 19; 6]
    ]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body[1][13, 12] = 0.0
    out.body[2][13, 12] = 0.0
    out.body[3][13, 12] = 0.0
    out.body[4][13, 12] = 0.0
    out.body[1][14, 11] = 0.0
    out.body[2][14, 11] = 0.0
    out.body[3][14, 11] = 0.0
    out.body[4][14, 11] = 0.0
    out.body[1][15, 10] = 0.0
    out.body[2][15, 10] = 0.0
    out.body[3][15, 10] = 0.0
    out.body[4][15, 10] = 0.0
    out.body[1][16, 9] = 0.0
    out.body[2][16, 9] = 0.0
    out.body[3][16, 9] = 0.0
    out.body[4][16, 9] = 0.0
    out.body[1][17, 8] = 0.0
    out.body[2][17, 8] = 0.0
    out.body[3][17, 8] = 0.0
    out.body[4][17, 8] = 0.0
    out.body[1][18, 7] = 0.0
    out.body[2][18, 7] = 0.0
    out.body[3][18, 7] = 0.0
    out.body[4][18, 7] = 0.0
    out.body[1][19, 6] = 0.0
    out.body[2][19, 6] = 0.0
    out.body[3][19, 6] = 0.0
    out.body[4][19, 6] = 0.0
    out.body[1][20, 5] = 0.0
    out.body[2][20, 5] = 0.0
    out.body[3][20, 5] = 0.0
    out.body[4][20, 5] = 0.0
    out.body[1][21, 4] = 0.0
    out.body[2][21, 4] = 0.0
    out.body[3][21, 4] = 0.0
    out.body[4][21, 4] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    out.body_soil[3][13, 12] = 0.0
    out.body_soil[4][13, 12] = 0.0
    out.body_soil[3][14, 11] = 0.0
    out.body_soil[4][14, 11] = 0.0
    out.body_soil[3][15, 10] = 0.0
    out.body_soil[4][15, 10] = 0.0
    out.body_soil[1][16, 9] = 0.0
    out.body_soil[2][16, 9] = 0.0
    out.body_soil[1][17, 8] = 0.0
    out.body_soil[2][17, 8] = 0.0
    out.body_soil[3][18, 7] = 0.0
    out.body_soil[4][18, 7] = 0.0
    out.body_soil[1][19, 6] = 0.0
    out.body_soil[2][19, 6] = 0.0
    out.body_soil[3][20, 5] = 0.0
    out.body_soil[4][20, 5] = 0.0
    out.body_soil[1][21, 4] = 0.0
    out.body_soil[2][21, 4] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil on the first bucket layer is
    # blocking the movement, then two bucket layers and the soil on the first bucket layer
    # is blocking the movement, then two bucket layers and the soil on the second bucket
    # layer is blocking the movement, then two bucket layers and the soil on the second
    # bucket layer is blocking the movement, then two bucket layers and the soil on the
    # first bucket layer is blocking the movement, then two bucket layers and the soil is
    # fully avalanching on the first bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.0 
    out.body[2][11, 14] = 0.1
    out.body_soil[1][11, 14] = 0.1
    out.body_soil[2][11, 14] = 0.4
    out.body[3][11, 14] = 0.4
    out.body[4][11, 14] = 0.5
    out.body[1][12, 13] = -0.2
    out.body[2][12, 13] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.2
    out.body[3][12, 13] = 0.2
    out.body[4][12, 13] = 0.4
    out.body[1][13, 12] = 0.4
    out.body[2][13, 12] = 0.6
    out.body[3][13, 12] = 0.0
    out.body[4][13, 12] = 0.1
    out.body_soil[3][13, 12] = 0.1
    out.body_soil[4][13, 12] = 0.4
    out.body[1][14, 11] = 0.4
    out.body[2][14, 11] = 0.9
    out.body[3][14, 11] = 0.2
    out.body[4][14, 11] = 0.3
    out.body_soil[3][14, 11] = 0.3
    out.body_soil[4][14, 11] = 0.4
    out.body[1][15, 10] = 0.0
    out.body[2][15, 10] = 0.4
    out.body_soil[1][15, 10] = 0.4
    out.body_soil[2][15, 10] = 0.6
    out.body[3][15, 10] = 0.6
    out.body[4][15, 10] = 0.8
    out.body[1][16, 9] = 0.1
    out.body[2][16, 9] = 0.2
    out.body_soil[1][16, 9] = 0.2
    out.body_soil[2][16, 9] = 0.3
    out.body[3][16, 9] = 0.9
    out.body[4][16, 9] = 1.1
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    push!(out.body_soil_pos, [3; 13; 12])
    push!(out.body_soil_pos, [3; 14; 11])
    push!(out.body_soil_pos, [1; 15; 10])
    push!(out.body_soil_pos, [1; 16; 9])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.1) && (out.body_soil[2][11, 14] == 0.4)
    @test (out.body_soil[1][12, 13] == 0.0) && (out.body_soil[2][12, 13] == 0.2)
    @test (out.body_soil[3][13, 12] == 0.1) && (out.body_soil[4][13, 12] == 0.4)
    @test (out.body_soil[3][14, 11] == 0.3) && (out.body_soil[4][14, 11] == 0.4)
    @test (out.body_soil[1][15, 10] == 0.4) && (out.body_soil[2][15, 10] == 0.6)
    @test (out.body_soil[1][16, 9] == 0.2) && (out.body_soil[2][16, 9] ≈ 0.6)
    res_body_soil_pos = [
        [1; 10; 15], [3; 10; 15], [1; 11; 14], [1; 12; 13], [3; 13; 12], [3; 14; 11],
        [1; 15; 10], [1; 16; 9]
    ]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body[1][13, 12] = 0.0
    out.body[2][13, 12] = 0.0
    out.body[3][13, 12] = 0.0
    out.body[4][13, 12] = 0.0
    out.body[1][14, 11] = 0.0
    out.body[2][14, 11] = 0.0
    out.body[3][14, 11] = 0.0
    out.body[4][14, 11] = 0.0
    out.body[1][15, 10] = 0.0
    out.body[2][15, 10] = 0.0
    out.body[3][15, 10] = 0.0
    out.body[4][15, 10] = 0.0
    out.body[1][16, 9] = 0.0
    out.body[2][16, 9] = 0.0
    out.body[3][16, 9] = 0.0
    out.body[4][16, 9] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    out.body_soil[3][13, 12] = 0.0
    out.body_soil[4][13, 12] = 0.0
    out.body_soil[3][14, 11] = 0.0
    out.body_soil[4][14, 11] = 0.0
    out.body_soil[1][15, 10] = 0.0
    out.body_soil[2][15, 10] = 0.0
    out.body_soil[1][16, 9] = 0.0
    out.body_soil[2][16, 9] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket layer, then two bucket layers and the soil is partially avalanching on
    # the first bucket layer, then two bucket layers and the soil is partially avalanching
    # on the second bucket layer, then two bucket layers and the soil is partially
    # avalanching on the second bucket layer, then two bucket layers and the soil is
    # partially avalanching on the first bucket layer, then two bucket layers and the soil
    # is fully avalanching on the second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.2
    out.body[2][11, 14] = 0.3
    out.body_soil[1][11, 14] = 0.3
    out.body_soil[2][11, 14] = 0.4
    out.body[3][11, 14] = 0.6
    out.body[4][11, 14] = 0.7
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.1
    out.body_soil[1][12, 13] = 0.1
    out.body_soil[2][12, 13] = 0.2
    out.body[3][12, 13] = 0.4
    out.body[4][12, 13] = 0.6
    out.body[1][13, 12] = 0.7
    out.body[2][13, 12] = 0.8
    out.body[3][13, 12] = 0.1
    out.body[4][13, 12] = 0.2
    out.body[1][14, 11] = 0.5
    out.body[2][14, 11] = 0.7
    out.body[3][14, 11] = 0.0
    out.body[4][14, 11] = 0.3
    out.body_soil[3][14, 11] = 0.3
    out.body_soil[4][14, 11] = 0.4
    out.body[1][15, 10] = 0.0
    out.body[2][15, 10] = 0.1
    out.body[3][15, 10] = 0.3
    out.body[4][15, 10] = 0.7
    out.body[1][16, 9] = 1.1
    out.body[2][16, 9] = 1.2
    out.body[3][16, 9] = 0.2
    out.body[4][16, 9] = 0.3
    out.body_soil[3][16, 9] = 0.3
    out.body_soil[4][16, 9] = 0.4
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    push!(out.body_soil_pos, [3; 14; 11])
    push!(out.body_soil_pos, [3; 16; 9])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.3) && (out.body_soil[2][11, 14] ≈ 0.6)
    @test (out.body_soil[1][12, 13] == 0.1) && (out.body_soil[2][12, 13] ≈ 0.4)
    @test (out.body_soil[3][13, 12] == 0.2) && (out.body_soil[4][13, 12] ≈ 0.7)
    @test (out.body_soil[3][14, 11] == 0.3) && (out.body_soil[4][14, 11] ≈ 0.5)
    @test (out.body_soil[1][15, 10] == 0.1) && (out.body_soil[2][15, 10] ≈ 0.3)
    @test (out.body_soil[3][16, 9] == 0.3) && (out.body_soil[4][16, 9] ≈ 0.5)
    res_body_soil_pos = [
        [1; 10; 15], [3; 10; 15], [1; 11; 14], [1; 12; 13], [3; 14; 11], [3; 16; 9],
        [3; 13; 12], [1; 15; 10]
    ]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body[1][13, 12] = 0.0
    out.body[2][13, 12] = 0.0
    out.body[3][13, 12] = 0.0
    out.body[4][13, 12] = 0.0
    out.body[1][14, 11] = 0.0
    out.body[2][14, 11] = 0.0
    out.body[3][14, 11] = 0.0
    out.body[4][14, 11] = 0.0
    out.body[1][15, 10] = 0.0
    out.body[2][15, 10] = 0.0
    out.body[3][15, 10] = 0.0
    out.body[4][15, 10] = 0.0
    out.body[1][16, 9] = 0.0
    out.body[2][16, 9] = 0.0
    out.body[3][16, 9] = 0.0
    out.body[4][16, 9] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    out.body_soil[3][13, 12] = 0.0
    out.body_soil[4][13, 12] = 0.0
    out.body_soil[3][14, 11] = 0.0
    out.body_soil[4][14, 11] = 0.0
    out.body_soil[1][15, 10] = 0.0
    out.body_soil[2][15, 10] = 0.0
    out.body_soil[3][16, 9] = 0.0
    out.body_soil[4][16, 9] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # first bucket layer, then two bucket layers and the soil on the first bucket layer is
    # blocking the movement, then two bucket layers and the soil is partially avalanching
    # on the first bucket layer, then two bucket layers and the soil on the second bucket
    # layer is blocking the movement, then two bucket layers and the soil is partially
    # avalanching on the second bucket layer, then two bucket layers and the soil on the
    # first bucket layer is blocking the movement, then two bucket layers and the soil is
    # partially avalanching on the second bucket layer, then two bucket layers and the soil
    # on the second bucket layer is blocking the movement, then two bucket layers and the
    # soil is partially avalanching on the first bucket layer, then two bucket layers and
    # the soil is fully avalanching on the first bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 0.2 
    out.body[2][11, 14] = 0.3
    out.body_soil[1][11, 14] = 0.3
    out.body_soil[2][11, 14] = 0.4
    out.body[3][11, 14] = 0.7
    out.body[4][11, 14] = 0.8
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.1
    out.body_soil[1][12, 13] = 0.1
    out.body_soil[2][12, 13] = 0.4
    out.body[3][12, 13] = 0.4
    out.body[4][12, 13] = 0.5
    out.body[1][13, 12] = 0.0
    out.body[2][13, 12] = 0.3
    out.body_soil[1][13, 12] = 0.3
    out.body_soil[2][13, 12] = 0.4
    out.body[3][13, 12] = 0.5
    out.body[4][13, 12] = 0.9
    out.body[1][14, 11] = 0.7
    out.body[2][14, 11] = 0.8
    out.body[3][14, 11] = 0.3
    out.body[4][14, 11] = 0.4
    out.body_soil[3][14, 11] = 0.4
    out.body_soil[4][14, 11] = 0.7
    out.body[1][15, 10] = 0.5
    out.body[2][15, 10] = 0.9
    out.body[3][15, 10] = 0.0
    out.body[4][15, 10] = 0.1
    out.body_soil[3][15, 10] = 0.1
    out.body_soil[4][15, 10] = 0.2
    out.body[1][16, 9] = 0.1
    out.body[2][16, 9] = 0.2
    out.body_soil[1][16, 9] = 0.2
    out.body_soil[2][16, 9] = 0.3
    out.body[3][16, 9] = 0.3
    out.body[4][16, 9] = 0.4
    out.body[1][17, 8] = 0.6
    out.body[2][17, 8] = 1.2
    out.body[3][17, 8] = 0.0
    out.body[4][17, 8] = 0.1
    out.body_soil[3][17, 8] = 0.1
    out.body_soil[4][17, 8] = 0.4
    out.body[1][18, 7] = 0.8
    out.body[2][18, 7] = 0.9
    out.body[3][18, 7] = 0.0
    out.body[4][18, 7] = 0.4
    out.body_soil[3][18, 7] = 0.4
    out.body_soil[4][18, 7] = 0.8
    out.body[1][19, 6] = 0.1
    out.body[2][19, 6] = 0.2
    out.body_soil[1][19, 6] = 0.2
    out.body_soil[2][19, 6] = 0.4
    out.body[3][19, 6] = 0.6
    out.body[4][19, 6] = 0.9
    out.body[1][20, 5] = -0.1
    out.body[2][20, 5] = 0.0
    out.body_soil[1][20, 5] = 0.0
    out.body_soil[2][20, 5] = 0.1
    out.body[3][20, 5] = 0.9
    out.body[4][20, 5] = 1.5
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 14])
    push!(out.body_soil_pos, [1; 12; 13])
    push!(out.body_soil_pos, [1; 13; 12])
    push!(out.body_soil_pos, [3; 14; 11])
    push!(out.body_soil_pos, [3; 15; 10])
    push!(out.body_soil_pos, [1; 16; 9])
    push!(out.body_soil_pos, [3; 17; 8])
    push!(out.body_soil_pos, [3; 18; 7])
    push!(out.body_soil_pos, [1; 19; 6])
    push!(out.body_soil_pos, [1; 20; 5])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[1][11, 14] == 0.3) && (out.body_soil[2][11, 14] ≈ 0.7)
    @test (out.body_soil[1][12, 13] == 0.1) && (out.body_soil[2][12, 13] == 0.4)
    @test (out.body_soil[1][13, 12] == 0.3) && (out.body_soil[2][13, 12] ≈ 0.5)
    @test (out.body_soil[3][14, 11] == 0.4) && (out.body_soil[4][14, 11] == 0.7)
    @test (out.body_soil[3][15, 10] == 0.1) && (out.body_soil[4][15, 10] ≈ 0.5)
    @test (out.body_soil[1][16, 9] == 0.2) && (out.body_soil[2][16, 9] == 0.3)
    @test (out.body_soil[3][17, 8] == 0.1) && (out.body_soil[4][17, 8] ≈ 0.6)
    @test (out.body_soil[3][18, 7] == 0.4) && (out.body_soil[4][18, 7] == 0.8)
    @test (out.body_soil[1][19, 6] == 0.2) && (out.body_soil[2][19, 6] ≈ 0.6)
    @test (out.body_soil[1][20, 5] == 0.0) && (out.body_soil[2][20, 5] ≈ 0.3)
    res_body_soil_pos = [
        [1; 10; 15], [3; 10; 15], [1; 11; 14], [1; 12; 13], [1; 13; 12], [3; 14; 11],
        [3; 15; 10], [1; 16; 9], [3; 17; 8], [3; 18; 7], [1; 19; 6], [1; 20; 5]
    ]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body[1][13, 12] = 0.0
    out.body[2][13, 12] = 0.0
    out.body[3][13, 12] = 0.0
    out.body[4][13, 12] = 0.0
    out.body[1][14, 11] = 0.0
    out.body[2][14, 11] = 0.0
    out.body[3][14, 11] = 0.0
    out.body[4][14, 11] = 0.0
    out.body[1][15, 10] = 0.0
    out.body[2][15, 10] = 0.0
    out.body[3][15, 10] = 0.0
    out.body[4][15, 10] = 0.0
    out.body[1][16, 9] = 0.0
    out.body[2][16, 9] = 0.0
    out.body[3][16, 9] = 0.0
    out.body[4][16, 9] = 0.0
    out.body[1][17, 8] = 0.0
    out.body[2][17, 8] = 0.0
    out.body[3][17, 8] = 0.0
    out.body[4][17, 8] = 0.0
    out.body[1][18, 7] = 0.0
    out.body[2][18, 7] = 0.0
    out.body[3][18, 7] = 0.0
    out.body[4][18, 7] = 0.0
    out.body[1][19, 6] = 0.0
    out.body[2][19, 6] = 0.0
    out.body[3][19, 6] = 0.0
    out.body[4][19, 6] = 0.0
    out.body[1][20, 5] = 0.0
    out.body[2][20, 5] = 0.0
    out.body[3][20, 5] = 0.0
    out.body[4][20, 5] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[1][11, 14] = 0.0
    out.body_soil[2][11, 14] = 0.0
    out.body_soil[1][12, 13] = 0.0
    out.body_soil[2][12, 13] = 0.0
    out.body_soil[1][13, 12] = 0.0
    out.body_soil[2][13, 12] = 0.0
    out.body_soil[3][14, 11] = 0.0
    out.body_soil[4][14, 11] = 0.0
    out.body_soil[3][15, 10] = 0.0
    out.body_soil[4][15, 10] = 0.0
    out.body_soil[1][16, 9] = 0.0
    out.body_soil[2][16, 9] = 0.0
    out.body_soil[3][17, 8] = 0.0
    out.body_soil[4][17, 8] = 0.0
    out.body_soil[3][18, 7] = 0.0
    out.body_soil[4][18, 7] = 0.0
    out.body_soil[1][19, 6] = 0.0
    out.body_soil[2][19, 6] = 0.0
    out.body_soil[1][20, 5] = 0.0
    out.body_soil[2][20, 5] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there are two bucket layers and the soil is partially avalanching on the
    # second bucket layer, then two bucket layers and the soil is fully avalanching on the
    # second bucket layer
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 1.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    out.body[1][11, 14] = 1.0
    out.body[2][11, 14] = 1.2
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.2
    out.body_soil[3][11, 14] = 0.3 
    out.body_soil[4][11, 14] = 0.4
    out.body[1][12, 13] = 0.9
    out.body[2][12, 13] = 1.2
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.1
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.body_soil[3][11, 14] == 0.3) && (out.body_soil[4][11, 14] ≈ 1.0)
    @test (out.body_soil[3][12, 13] == 0.1) && (out.body_soil[4][12, 13] ≈ 0.8)
    res_body_soil_pos = [[1; 10; 15], [3; 10; 15], [3; 11; 14], [3; 12; 13]]
    @test (out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[1][11, 14] = 0.0
    out.body[2][11, 14] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body[1][12, 13] = 0.0
    out.body[2][12, 13] = 0.0
    out.body[3][12, 13] = 0.0
    out.body[4][12, 13] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    out.body_soil[3][12, 13] = 0.0
    out.body_soil[4][12, 13] = 0.0
    empty!(out.body_soil_pos)

    # Testing when there is nothing to move
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.9
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.5
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.1
    out.body_soil[3][11, 14] = 0.1
    out.body_soil[4][11, 14] = 0.9
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [3; 11; 14])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.9)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] == 0.5)
    @test (out.body_soil[3][11, 14] == 0.1) && (out.body_soil[4][11, 14] == 0.9)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15], [3; 11; 14]])
    # Resetting values
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body[3][11, 14] = 0.0
    out.body[4][11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    out.body_soil[3][11, 14] = 0.0
    out.body_soil[4][11, 14] = 0.0
    empty!(out.body_soil_pos)

    # Testing randomness of movement
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.3
    out.body[3][10, 15] = 0.5
    out.body[4][10, 15] = 0.6
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    out.body_soil[3][10, 15] = 0.6
    out.body_soil[4][10, 15] = 0.7
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.terrain[11, 14] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    out.terrain[11, 14] = 0.0
    out.body_soil[1][10, 15] = 0.3
    out.body_soil[2][10, 15] = 0.8
    set_RNG_seed!(1236)
    _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.3) && (out.body_soil[2][10, 15] ≈ 0.5)
    @test (out.body_soil[3][10, 15] == 0.6) && (out.body_soil[4][10, 15] == 0.7)
    @test (out.terrain[9, 16] ≈ 0.3)
    @test (out.body_soil_pos == [[1; 10; 15], [3; 10; 15]])
    # Resetting values
    out.terrain[9, 16] = 0.0
    out.body[1][10, 15] = 0.0
    out.body[2][10, 15] = 0.0
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.0
    out.body_soil[1][10, 15] = 0.0
    out.body_soil[2][10, 15] = 0.0
    out.body_soil[3][10, 15] = 0.0
    out.body_soil[4][10, 15] = 0.0
    empty!(out.body_soil_pos)

    # Testing that warning is properly sent when soil cannot be moved
    warning_message = "Not all soil intersecting with a bucket layer could be moved\n" *
        "The extra soil has been arbitrarily removed"
    set_RNG_seed!(1234)
    out.body[1][10, 15] = 0.5
    out.body[2][10, 15] = 0.6
    out.body[3][10, 15] = 0.0
    out.body[4][10, 15] = 0.3
    out.body_soil[1][10, 15] = 0.6
    out.body_soil[2][10, 15] = 0.7
    out.body_soil[3][10, 15] = 0.3
    out.body_soil[4][10, 15] = 0.9
    out.body[1][9, 14] = 0.2
    out.body[2][9, 14] = 0.9
    out.body[3][10, 14] = 0.2
    out.body[4][10, 14] = 0.7
    out.body[3][11, 14] = 0.3
    out.body[4][11, 14] = 0.5
    out.body[1][9, 15] = 0.3
    out.body[2][9, 15] = 0.5
    out.body[1][11, 15] = 0.0
    out.body[2][11, 15] = 0.5
    out.body_soil[1][11, 15] = 0.5
    out.body_soil[2][11, 15] = 0.7
    out.body[3][9, 16] = 0.1
    out.body[4][9, 16] = 0.6
    out.body_soil[3][9, 16] = 0.6
    out.body_soil[4][9, 16] = 0.9
    out.body[1][10, 16] = 0.5
    out.body[2][10, 16] = 0.8
    out.body[3][10, 16] = 0.2
    out.body[4][10, 16] = 0.3
    out.body_soil[3][10, 16] = 0.3
    out.body_soil[4][10, 16] = 0.4
    out.body[1][10, 17] = 0.3
    out.body[2][10, 17] = 0.6
    out.body[1][11, 16] = 0.5
    out.body[2][11, 16] = 0.8
    out.body[3][11, 16] = 0.2
    out.body[4][11, 16] = 0.3
    out.body_soil[3][11, 16] = 0.3
    out.body_soil[4][11, 16] = 0.5
    out.body[1][12, 17] = 0.5
    out.body[2][12, 17] = 0.8
    out.body[3][12, 17] = 0.2
    out.body[4][12, 17] = 0.3
    out.body_soil[3][12, 17] = 0.3
    out.body_soil[4][12, 17] = 0.5
    out.body[3][13, 18] = 0.2
    out.body[4][13, 18] = 0.9
    push!(out.body_soil_pos, [1; 10; 15])
    push!(out.body_soil_pos, [3; 10; 15])
    push!(out.body_soil_pos, [1; 11; 15])
    push!(out.body_soil_pos, [3; 9; 16])
    push!(out.body_soil_pos, [3; 10; 16])
    push!(out.body_soil_pos, [3; 11; 16])
    push!(out.body_soil_pos, [3; 12; 17])
    @test_logs (:warn, warning_message) match_mode=:any _move_intersecting_body_soil!(out)
    @test (out.body_soil[1][10, 15] == 0.6) && (out.body_soil[2][10, 15] == 0.7)
    @test (out.body_soil[3][10, 15] == 0.3) && (out.body_soil[4][10, 15] ≈ 0.5)
    @test (out.body_soil[1][11, 15] == 0.5) && (out.body_soil[2][11, 15] == 0.7)
    @test (out.body_soil[3][9, 16] == 0.6) && (out.body_soil[4][9, 16] == 0.9)
    @test (out.body_soil[3][10, 16] == 0.3) && (out.body_soil[4][10, 16] ≈ 0.5)
    @test (out.body_soil[3][11, 16] == 0.3) && (out.body_soil[4][11, 16] == 0.5)
    @test (out.body_soil[3][12, 17] == 0.3) && (out.body_soil[4][12, 17] == 0.5)
    res_body_soil_pos = [
        [1; 10; 15], [3; 10; 15], [1; 11; 15], [3; 9; 16], [3; 10; 16], [3; 11; 16],
        [3; 12; 17]
    ]
    @test all(out.body_soil_pos == res_body_soil_pos)
    # Resetting values
    out.body[1][8:12, 13:17] .= 0.0
    out.body[2][8:12, 13:17] .= 0.0
    out.body[3][8:12, 13:17] .= 0.0
    out.body[4][8:12, 13:17] .= 0.0
    out.body_soil[1][8:12, 13:17] .= 0.0
    out.body_soil[2][8:12, 13:17] .= 0.0
    out.body_soil[3][8:12, 13:17] .= 0.0
    out.body_soil[4][8:12, 13:17] .= 0.0
    out.body[3][13, 18] = 0.0
    out.body[4][13, 18] = 0.0
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

@testset "_locate_intersecting_cells" begin
    # Setting dummy values in body and terrain
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
    out.body[1][5, 10] = 0.0
    out.body[2][5, 10] = 0.0
    out.body[3][6, 10] = 0.0
    out.body[4][6, 10] = 0.0
    out.body[1][7, 10] = 0.0
    out.body[2][7, 10] = 0.0
    out.body[3][7, 10] = 0.0
    out.body[4][7, 10] = 0.0
    out.body[1][10, 11:16] .= 0.0
    out.body[2][10, 11:16] .= 0.0
    out.body[3][10, 11:16] .= 0.0
    out.body[4][10, 11:16] .= 0.0
    out.body[1][11, 11] = 0.0
    out.body[2][11, 11] = 0.0
    out.terrain[10, 11:16] .= 0.0
    out.terrain[11, 11] = 0.0

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

@testset "_move_intersecting_body!" begin
    # Testing for a single intersecting cells in the -X direction
    out.body[1][11:12, 16:18] .= 0.0
    out.body[2][11:12, 16:18] .= 0.5
    out.body[1][10, 16] = 0.0
    out.body[2][10, 16] = 0.5
    out.body[1][10, 18] = 0.0
    out.body[2][10, 18] = 0.5
    out.terrain[11, 17] = 0.1
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
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
    _move_intersecting_body!(out)
    # Checking terrain
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][8:14, 14:20] .= 0.0
    out.body[2][8:14, 14:20] .= 0.0

    # Testing randomness of movement
    set_RNG_seed!(1234)
    out.body[1][11, 17] = -0.4
    out.body[2][11, 17] = 0.6
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[12, 16] ≈ 0.9)
    out.terrain[12, 16] = 0.0
    out.terrain[11, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Second call
    out.terrain[11, 17] = 0.5
    _move_intersecting_body!(out)
    # Checking terrain
    @test (out.terrain[11, 17] ≈ -0.4) && (out.terrain[10, 17] ≈ 0.9)
    out.terrain[10, 17] = 0.0
    out.terrain[11, 17] = 0.0
    @test all(out.terrain[:, :] .== 0.0)
    # Resetting body
    out.body[1][11, 17] = 0.0
    out.body[2][11, 17] = 0.0

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
