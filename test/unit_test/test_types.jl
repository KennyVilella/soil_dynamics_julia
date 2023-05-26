"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#
# Grid properties
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
grid_vect_x = cell_size_xy .* range(-grid_half_length_x, grid_half_length_x, step=1)
grid_vect_y = cell_size_xy .* range(-grid_half_length_y, grid_half_length_y, step=1)
grid_vect_z = cell_size_z .* range(-grid_half_length_z, grid_half_length_z, step=1)

# Bucket properties
o_pos_init = Vector{Float64}([0.0, 0.0, 0.5])
j_pos_init = Vector{Float64}([0.0, 0.0, 0.5])
b_pos_init = Vector{Float64}([0.0, 0.0, -0.5])
t_pos_init = Vector{Float64}([1.0, 0.0, -0.5])
bucket_width = 0.5

# Simulation properties
repose_angle = 0.85
max_iterations = 3

# Terrain properties
terrain = zeros(2 * grid_half_length_x + 1, 2 * grid_half_length_y + 1)


#==========================================================================================#
#                                                                                          #
#                                         Testing                                          #
#                                                                                          #
#==========================================================================================#
@testset "GridParam struct" begin
    # Creating dummy GridParam by using the inner constructor
    @test_nowarn GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)
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
    @test grid.vect_x == grid_vect_x
    @test grid.vect_y == grid_vect_y
    @test grid.vect_z == grid_vect_z

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
            0.5*cell_size_xy, grid_size_y, grid_size_z, cell_size_xy, cell_size_z
        )
    @test_throws ErrorException GridParam(
            grid_size_x, 0.5*cell_size_xy, grid_size_z, cell_size_xy, cell_size_z
        )
    @test_throws ErrorException GridParam(
            grid_size_x, grid_size_y, 0.5*cell_size_z, cell_size_xy, cell_size_z
        )
end

@testset "BucketParam struct" begin
    # Creating dummy BucketParam by using the inner constructor
    @test_nowarn BucketParam(o_pos_init, j_pos_init, b_pos_init, t_pos_init, bucket_width)
    bucket = BucketParam(o_pos_init, j_pos_init, b_pos_init, t_pos_init, bucket_width)

    # Testing the type of the struct
    @test bucket isa BucketParam

    # Testing properties of the struct
    @test bucket.j_pos_init == j_pos_init - o_pos_init
    @test bucket.b_pos_init == b_pos_init - o_pos_init
    @test bucket.t_pos_init == t_pos_init - o_pos_init
    @test bucket.width == bucket_width
    @test bucket.pos == [0.0, 0.0, 0.0]
    @test bucket.ori == [1.0, 0.0, 0.0, 0.0]

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

@testset "SimParam struct" begin
    # Creating dummy SimParam by using the inner constructor
    @test_nowarn SimParam(repose_angle, max_iterations)
    sim_param = SimParam(repose_angle, max_iterations)

    # Testing the type of the struct
    @test sim_param isa SimParam

    # Testing properties of the struct
    @test sim_param.repose_angle == repose_angle
    @test sim_param.max_iterations == max_iterations

    # Testing that repose_angle outside the allowed range throws an error
    @test_throws DomainError SimParam(-0.1, max_iterations)
    @test_throws DomainError SimParam(3.14, max_iterations)
 
    # Testing that repose_angle on the edge of the allowed range does not throw an error
    @test_nowarn SimParam(0.0, max_iterations)
    @test_nowarn SimParam(pi / 2, max_iterations)

    # Testing that max_iterations lower than zero throws an error
    @test_throws DomainError SimParam(repose_angle, -1)
    @test_throws DomainError SimParam(repose_angle, -10)

    # Testing that max_iterations equal to zero does not throw an error
    @test_nowarn SimParam(repose_angle, 0)
end

@testset "SimOut struct" begin
    # Setting dummy properties
    @test_nowarn GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)
    grid = GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)

    # Creating dummy SimOut by calling the inner constructor
    @test_nowarn SimOut(terrain, grid)
    out = SimOut(terrain, grid)

    # Testing the type of the struct
    @test out isa SimOut

    # Testing properties of the struct
    @test out.terrain == terrain
    @test out.body isa Vector{SparseMatrixCSC{Float64,Int64}}
    @test out.body_soil isa Vector{SparseMatrixCSC{Float64,Int64}}

    # Testing that incorrect terrain size throws an error
    @test_throws DimensionMismatch SimOut(zeros(10, 3), grid)
    @test_throws DimensionMismatch SimOut(zeros(3, 10), grid)
end
