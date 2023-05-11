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
o_pos_init = Vector{Float64}([0.0, 0.0, 0.5])
j_pos_init = Vector{Float64}([0.0, 0.0, 0.5])
b_pos_init = Vector{Float64}([0.0, 0.0, -0.5])
t_pos_init = Vector{Float64}([1.0, 0.0, -0.5])
bucket_width = 0.5


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

@testset "BucketParam struct" begin
    # Creating dummy BucketParam by using the inner constructor
    bucket = BucketParam(o_pos_init, j_pos_init, b_pos_init, t_pos_init, bucket_width)

    # Testing the type of the struct
    @test bucket isa BucketParam

    # Testing properties of the struct
    @test bucket.j_pos_init == j_pos_init - o_pos_init
    @test bucket.b_pos_init == b_pos_init - o_pos_init
    @test bucket.t_pos_init == t_pos_init - o_pos_init
    @test bucket.width == bucket_width

    # Testing that incorrect vector size throws an error
    @test_throws DimensionMismatch BucketParam(
            [1.0, 2.0, 3.1, 531], j_pos_init, b_pos_init, t_pos_init, bucket_width
        )
    @test_throws DimensionMismatch BucketParam(
            o_pos_init, [2.0, 4.5], b_pos_init, t_pos_init, bucket_width
        )
    @test_throws DimensionMismatch BucketParam(
            o_pos_init, j_pos_init, [1.0], t_pos_init, bucket_width
        )
    @test_throws DimensionMismatch BucketParam(
            o_pos_init, j_pos_init, b_pos_init, [1.0, 2.0, 3.0, 4.0], bucket_width
        )

    # Testing that incorrect bucket geometry throws an error
    @test_throws ErrorException BucketParam(
            o_pos_init, j_pos_init, j_pos_init, t_pos_init, bucket_width
        )
    @test_throws ErrorException BucketParam(
            o_pos_init, j_pos_init, b_pos_init, j_pos_init, bucket_width
        )
    @test_throws ErrorException BucketParam(
            o_pos_init, j_pos_init, b_pos_init, b_pos_init, bucket_width
        )

    # Testing that bucket_width lower than or equal to zero throws an error
    @test_throws DomainError BucketParam(
            o_pos_init, j_pos_init, b_pos_init, t_pos_init, 0.0
        )
    @test_throws DomainError BucketParam(
            o_pos_init, j_pos_init, b_pos_init, t_pos_init, -0.1
        )
end
