"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#
# Grid properties
grid_size_x = 0.2
grid_size_y = 0.2
grid_size_z = 1.0
cell_size_xy = 0.1
cell_size_z = 0.1
grid_half_length_x = round(Int64, grid_size_x / cell_size_xy)
grid_half_length_y = round(Int64, grid_size_y / cell_size_xy)
grid_half_length_z = round(Int64, grid_size_z / cell_size_z)
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
cell_buffer = 4

# Terrain properties
terrain = zeros(2 * grid_half_length_x + 1, 2 * grid_half_length_y + 1)
area = Int64[[2, 2] [4, 4]]

#==========================================================================================#
#                                                                                          #
#                                         Testing                                          #
#                                                                                          #
#==========================================================================================#
@testset "GridParam struct" begin
    # Test: TY-G-1
    @test_nowarn GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)
    grid = GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)
    @test grid isa GridParam
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

    # Test: TY-G-2
    @test_throws DomainError GridParam(
        grid_size_x, grid_size_y, grid_size_z, cell_size_xy, 0.0
    )
    @test_throws DomainError GridParam(
        grid_size_x, grid_size_y, grid_size_z, cell_size_xy, -0.31
    )

    # Test: TY-G-3
    @test_throws DomainError GridParam(
        grid_size_x, grid_size_y, grid_size_z, 0.0, cell_size_z
    )
    @test_throws DomainError GridParam(
        grid_size_x, grid_size_y, grid_size_z, -0.2, cell_size_z
    )

    # Test: TY-G-4
    @test_throws DomainError GridParam(
        0.0, grid_size_y, grid_size_z, cell_size_xy, cell_size_z
    )
    @test_throws DomainError GridParam(
        -0.25, grid_size_y, grid_size_z, cell_size_xy, cell_size_z
    )

    # Test: TY-G-5
    @test_throws DomainError GridParam(
        grid_size_x, 0.0, grid_size_z, cell_size_xy, cell_size_z
    )
    @test_throws DomainError GridParam(
        grid_size_x, -0.06, grid_size_z, cell_size_xy, cell_size_z
    )

    # Test: TY-G-6
    @test_throws DomainError GridParam(
        grid_size_x, grid_size_y, 0.0, cell_size_xy, cell_size_z
    )
    @test_throws DomainError GridParam(
        grid_size_x, grid_size_y, -0.14, cell_size_xy, cell_size_z
    )

    # Test: TY-G-7
    @test_throws ErrorException GridParam(grid_size_x, grid_size_y, grid_size_z, 0.09, 0.1)
    @test_nowarn GridParam(grid_size_x, grid_size_y, grid_size_z, 0.09, 0.09)

    # Test: TY-G-8
    @test_throws ErrorException GridParam(
        0.5 * cell_size_xy, grid_size_y, grid_size_z, cell_size_xy, cell_size_z
    )
    @test_nowarn GridParam(cell_size_xy, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)

    # Test: TY-G-9
    @test_throws ErrorException GridParam(
        grid_size_x, 0.5 * cell_size_xy, grid_size_z, cell_size_xy, cell_size_z
    )
    @test_nowarn GridParam(grid_size_x, cell_size_xy, grid_size_z, cell_size_xy, cell_size_z)

    # Test: TY-G-10
    @test_throws ErrorException GridParam(
        grid_size_x, grid_size_y, 0.5 * cell_size_z, cell_size_xy, cell_size_z
    )
    @test_nowarn GridParam(grid_size_x, grid_size_y, cell_size_xy, cell_size_xy, cell_size_z)
end

@testset "BucketParam struct" begin
    # Test: TY-Bu-1
    @test_nowarn BucketParam(o_pos_init, j_pos_init, b_pos_init, t_pos_init, bucket_width)
    bucket = BucketParam(o_pos_init, j_pos_init, b_pos_init, t_pos_init, bucket_width)
    @test bucket isa BucketParam
    @test bucket.j_pos_init == j_pos_init - o_pos_init
    @test bucket.b_pos_init == b_pos_init - o_pos_init
    @test bucket.t_pos_init == t_pos_init - o_pos_init
    @test bucket.width == bucket_width
    @test bucket.pos == [0.0, 0.0, 0.0]
    @test bucket.ori == [1.0, 0.0, 0.0, 0.0]

    # Test: TY-Bu-2
    @test_throws DimensionMismatch BucketParam(
        [1.0, 2.0, 3.1, 531], j_pos_init, b_pos_init, t_pos_init, bucket_width
    )

    # Test: TY-Bu-3
    @test_throws DimensionMismatch BucketParam(
        o_pos_init, [2.0, 4.5], b_pos_init, t_pos_init, bucket_width
    )

    # Test: TY-Bu-4
    @test_throws DimensionMismatch BucketParam(
        o_pos_init, j_pos_init, [1.0], t_pos_init, bucket_width
    )

    # Test: TY-Bu-5
    @test_throws DimensionMismatch BucketParam(
        o_pos_init, j_pos_init, b_pos_init, [1.0, 2.0, 3.0, 4.0], bucket_width
    )

    # Test: TY-Bu-6
    @test_throws ErrorException BucketParam(
        o_pos_init, j_pos_init, j_pos_init, t_pos_init, bucket_width
    )

    # Test: TY-Bu-7
    @test_throws ErrorException BucketParam(
        o_pos_init, j_pos_init, b_pos_init, j_pos_init, bucket_width
    )

    # Test: TY-Bu-8
    @test_throws ErrorException BucketParam(
        o_pos_init, j_pos_init, b_pos_init, b_pos_init, bucket_width
    )

    # Test: TY-Bu-9
    @test_throws DomainError BucketParam(
        o_pos_init, j_pos_init, b_pos_init, t_pos_init, 0.0
    )
    @test_throws DomainError BucketParam(
        o_pos_init, j_pos_init, b_pos_init, t_pos_init, -0.1
    )
end

@testset "SimParam struct" begin
    # Test: TY-SP-1
    @test_nowarn SimParam(repose_angle, max_iterations, cell_buffer)
    sim_param = SimParam(repose_angle, max_iterations, cell_buffer)
    @test sim_param isa SimParam
    @test sim_param.repose_angle == repose_angle
    @test sim_param.max_iterations == max_iterations
    @test sim_param.cell_buffer == cell_buffer

    # Test: TY-SP-2
    @test_throws DomainError SimParam(-0.1, max_iterations, cell_buffer)
    @test_throws DomainError SimParam(3.14, max_iterations, cell_buffer)
    @test_nowarn SimParam(0.0, max_iterations, cell_buffer)
    @test_nowarn SimParam(pi / 2, max_iterations, cell_buffer)

    # Test: TY-SP-3
    @test_throws DomainError SimParam(repose_angle, -1, cell_buffer)
    @test_throws DomainError SimParam(repose_angle, -10, cell_buffer)
    @test_nowarn SimParam(repose_angle, 0, cell_buffer)

    # Test: TY-SP-4
    warning_message = "cell_buffer too low, setting to 2"
    @test_logs (:warn, warning_message) SimParam(repose_angle, max_iterations, 1)
    @test_logs (:warn, warning_message) SimParam(repose_angle, max_iterations, 0)
    @test_nowarn SimParam(repose_angle, max_iterations, 2)
end

@testset "SimOut struct" begin
    # Test: TY-SO-1
    @test_nowarn GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)
    grid = GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)
    @test_nowarn SimOut(terrain, grid)
    out = SimOut(terrain, grid)
    @test out isa SimOut
    @test out.equilibrium == [false]
    @test out.terrain == terrain
    @test out.body isa Vector{SparseMatrixCSC{Float64, Int64}}
    @test out.body_soil isa Vector{SparseMatrixCSC{Float64, Int64}}
    @test out.body_soil_pos isa Vector{BodySoil{Int64, Float64}}
    @test out.bucket_area == area
    @test out.relax_area == area
    @test out.impact_area == area

    # Test: TY-SO-2
    @test_throws DimensionMismatch SimOut(zeros(10, 3), grid)
    @test_throws DimensionMismatch SimOut(zeros(3, 10), grid)
end
