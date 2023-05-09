"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#
grid_size_x = 0.1
grid_size_y = 0.1
grid_size_z = 1.0
cell_size_xy = 0.1
cell_size_z = 0.1
grid_half_length_x =  round(Int64, grid_size_x / cell_size_xy)
grid_half_length_y =  round(Int64, grid_size_y / cell_size_xy)
grid_half_length_z =  round(Int64, grid_size_z / cell_size_z)
cell_area = cell_size_xy * cell_size_xy
cell_volume = cell_area * cell_size_z


#==========================================================================================#
#                                                                                          #
#                                         Testing                                          #
#                                                                                          #
#==========================================================================================#
@testset "GridParam struct" begin
    # Creating dummy GridParam by using the inner constructor
    grid = GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)

    # Testing the type of the struct
    @test grid isa GridParam

    # Testing properties of the struct
    @test grid.half_length_x == grid_half_length_x
    @test grid.half_length_y == grid_half_length_y
    @test grid.half_length_z == grid_half_length_z
    @test grid.cell_size_xy == cell_size_xy
    @test grid.cell_size_z == cell_size_z
    @test grid.cell_area == cell_area
    @test grid.cell_volume == cell_volume

    # Testing that cell_size_z greater than cell_size_xy throws an error
    @test_throws ErrorException GridParam(grid_size_x, grid_size_y, grid_size_z, 0.09, 0.1)

    # Testing that cell_size_z or cell_size_xy lower than 0 throws an error
    @test_throws DomainError GridParam(
            grid_size_x, grid_size_y, grid_size_z, 0.0, cell_size_z
        )
    @test_throws DomainError GridParam(
            grid_size_x, grid_size_y, grid_size_z, -0.2, cell_size_z
        )
    @test_throws DomainError GridParam(
            grid_size_x, grid_size_y, grid_size_z, cell_size_xy, 0.0
        )
    @test_throws DomainError GridParam(
            grid_size_x, grid_size_y, grid_size_z, cell_size_xy, -0.31
        )

    # Testing that grid size lower than 0 throws an error
    @test_throws DomainError GridParam(
            0.0, grid_size_y, grid_size_z, cell_size_xy, cell_size_z
        )
    @test_throws DomainError GridParam(
            -0.25, grid_size_y, grid_size_z, cell_size_xy, cell_size_z
        )
    @test_throws DomainError GridParam(
            grid_size_x, 0.0, grid_size_z, cell_size_xy, cell_size_z
        )
    @test_throws DomainError GridParam(
            grid_size_x, -0.06, grid_size_z, cell_size_xy, cell_size_z
        )
    @test_throws DomainError GridParam(
            grid_size_x, grid_size_y, 0.0, cell_size_xy, cell_size_z
        )
    @test_throws DomainError GridParam(
            grid_size_x, grid_size_y, -0.14, cell_size_xy, cell_size_z
        )

    # Testing that cell size greater than the grid size throws an error
    @test_throws ErrorException GridParam(
            0.05, grid_size_y, grid_size_z, cell_size_xy, cell_size_z
        )
    @test_throws ErrorException GridParam(
            grid_size_x, 0.05, grid_size_z, cell_size_xy, cell_size_z
        )
    @test_throws ErrorException GridParam(
            grid_size_x, grid_size_y, 0.05, cell_size_xy, cell_size_z
        )
end
