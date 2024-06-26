"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                          Starting implementation of new types                            #
#                                                                                          #
#==========================================================================================#
"""
    GridParam{I<:Int64,T<:Float64}

Store all parameters related to the simulation grid.

# Convention
- The simulation grid is centred at 0, that is, if the extent of the grid is 10.0,
  the grid would then extend from -5.0 to 5.0, this applies to all direction.
- The grid is composed of regular 3D cells

                H-----------G
               /           /|
              /     O     / |
             /           /  |
            E-----------F   C
            |           |  /
            |           | /
            |           |/
            A-----------B

- The cells have the same size in both lateral direction

    AB = BC = CD = DA = EF = FG = GH = HE,

  while their height can potentially be lower

    AE = BF = CG = DH <= AB.

- The center of each cell (O) is considered to be at the center of the top surface.
- The considered reference frame follows the right-hand rule,
  with the Z direction pointing upward.

# Fields
- `half_length_x::Int64`: Number of grid elements in the positive (or negative) X direction.
- `half_length_y::Int64`: Number of grid elements in the positive (or negative) Y direction.
- `half_length_z::Float64`: Number of grid elements in the positive (or negative) Z
                            direction. Note that it is a Float.
- `cell_size_xy::Float64`: Size of the cells in the X and Y direction. [m]
- `cell_size_z::Float64`: Height of the cells in the Z direction. [m]
- `cell_area::Float64`: Surface area of one cell in the horizontal plane. [m^2]
- `cell_volume::Float64`: Volume of one cell. [m^3]
- `vect_x::StepRangeLen{Float64}`: Vector providing a conversion between cell's index and
                                   cell's position in the X direction.
- `vect_y::StepRangeLen{Float64}`: Vector providing a conversion between cell's index and
                                   cell's position in the Y direction.
- `vect_z::StepRangeLen{Float64}`: Vector providing a conversion between cell's index and
                                   cell's position in the Z direction.

# Inner constructor

    GridParam(
        grid_size_x::T, grid_size_y::T, grid_size_z::T, cell_size_xy::T,
        cell_size_z::T=cell_size_xy
    ) where {T<:Float64}

Create a new instance of `GridParam` using the grid size in [m].
The actual size of the grid would be:
- [-grid_size_x, grid_size_x] in the X direction.
- [-grid_size_y, grid_size_y] in the Y direction.
- [-grid_size_z, grid_size_z] in the Z direction.

Requirements:
- All inputs should be greater than zero.
- cell_size_xy should be lower than or equal to grid_size_x and grid_size_y.
- cell_size_z should be lower than or equal to grid_size_z.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)

This would create a grid of size [-4, 4] in the X direction, [-4, 4] in the Y direction,
[-3, 3] in the Z direction, and with cells of size 0.05 x 0.05 x 0.01 in the XYZ direction.
"""
struct GridParam{I<:Int64,T<:Float64}
    half_length_x::I
    half_length_y::I
    half_length_z::T
    cell_size_xy::T
    cell_size_z::T
    cell_area::T
    cell_volume::T
    vect_x::StepRangeLen{T}
    vect_y::StepRangeLen{T}
    vect_z::StepRangeLen{T}
    function GridParam(
            grid_size_x::T,
            grid_size_y::T,
            grid_size_z::T,
            cell_size_xy::T,
            cell_size_z::T=cell_size_xy
    ) where {T<:Float64}
        if ((cell_size_z < 0.0) || (cell_size_z ≈ 0.0))
            throw(DomainError(cell_size_z, "cell_size_z should be greater than zero"))
        end
        if ((cell_size_xy < 0.0) || ((cell_size_xy ≈ 0.0)))
            throw(DomainError(cell_size_xy, "cell_size_xy should be greater than zero"))
        end
        if ((grid_size_x < 0.0) || (grid_size_x ≈ 0.0))
            throw(DomainError(grid_size_x, "grid_size_x should be greater than zero"))
        end
        if ((grid_size_y < 0.0) || (grid_size_y ≈ 0.0))
            throw(DomainError(grid_size_y, "grid_size_y should be greater than zero"))
        end
        if ((grid_size_z < 0.0) || (grid_size_z ≈ 0.0))
            throw(DomainError(grid_size_z, "grid_size_z should be greater than zero"))
        end
        if (cell_size_z > cell_size_xy)
            throw(ErrorException(
                "cell_size_z should be lower than or equal to cell_size_xy"
            ))
        end
        if (grid_size_x < cell_size_xy)
            throw(ErrorException(
                "cell_size_xy should be lower than or equal to grid_size_x"
            ))
        end
        if (grid_size_y < cell_size_xy)
            throw(ErrorException(
                "cell_size_xy should be lower than or equal to grid_size_y"
            ))
        end
        if (grid_size_z < cell_size_z)
            throw(ErrorException(
                "cell_size_z should be lower than or equal to grid_size_z"
            ))
        end

        half_length_x = round(Int64, grid_size_x / cell_size_xy)
        half_length_y = round(Int64, grid_size_y / cell_size_xy)
        half_length_z = round(grid_size_z / cell_size_z)

        cell_area = cell_size_xy * cell_size_xy
        cell_volume = cell_area * cell_size_z

        vect_x = cell_size_xy .* range(-half_length_x, half_length_x, step=1)
        vect_y = cell_size_xy .* range(-half_length_y, half_length_y, step=1)
        vect_z = cell_size_z .* range(-half_length_z, half_length_z, step=1)

        new{Int64,T}(
            half_length_x, half_length_y, half_length_z, cell_size_xy, cell_size_z,
            cell_area, cell_volume, vect_x, vect_y, vect_z
        )
    end
end

"""
    BucketParam{T<:Float64}

Store all parameters related to a bucket object.

# Convention
- The bucket is approximated as a triangular prism

                     A ____________________ D
                    /.                     /|
                   / .                    / |
                  /  .                   /  |
                 /   .                  /   |
                /    .                 /    |
               /     .                /     |
              /      .               /      |
             /       C . . . . . .  / . . . F
            /      .               /        ̸
           /     .                /       ̸
          /    .                 /      ̸
         /   .                  /     ̸
        /  .                   /    ̸
       / .                    /   ̸
      B ____________________ E

- The middle of the segment AD is referred to as the bucket "joint".
- The middle of the segment CF is referred to as the bucket "base".
- The middle of the segment BE is referred to as the bucket "teeth".
- The surface ABED is open and referred to as the bucket "front".
- The surface BCFE is a bucket wall and referred to as the bucket "base".
- The surface ACFD is a bucket wall and referred to as the bucket "back".
- The surface ABC is a bucket wall and referred to as the bucket "right side".
- The surface DEF is a bucket wall and referred to as the bucket "left side".
- The bucket has a constant width, denoted as

    AD = BE = CF = `width`.

- The center of rotation of the bucket is assumed to be at the bucket "origin" (not shown
  in the figure) and the bucket vertices are given relative to this origin.
- The provided coordinates are assumed to be the reference pose of the bucket, from which
  the bucket pose is calculated throughout the code.

# Fields
- `j_pos_init::Vector{Float64}`: Cartesian coordinates of the bucket joint in its
                                 reference pose. [m]
- `b_pos_init::Vector{Float64}`: Cartesian coordinates of the bucket base in its
                                 reference pose. [m]
- `t_pos_init::Vector{Float64}`: Cartesian coordinates of the bucket teeth in its
                                 reference pose. [m]
- `width::Float64`: Width of the bucket. [m]
- `pos::Vector{Float64}`: Cartesian coordinates of the bucket origin. [m]
- `ori::Vector{Float64}`: Orientation of the bucket. Note that it is stored as a Vector,
                          since Quaternions are not mutable. [Quaternion]

# Inner constructor

    BucketParam(
        o_pos_init::Vector{T}, j_pos_init::Vector{T}, b_pos_init::Vector{T},
        t_pos_init::Vector{T}, width::T
    ) where {T<:Float64}

Create a new instance of `BucketParam` using the reference positions of the bucket origin,
joint, base, and teeth as well as the bucket width.
The position of the bucket joint, base, and teeth are given relative to the position of the
bucket origin.

Requirements:
- All provided Cartesian coordinates should be a vector of size 3.
- The bucket joint, base and teeth should have strictly different location.
- The bucket width should be greater than zero.

# Example

    o = [0.0, 0.0, 0.0]
    j = [0.0, 0.0, 0.0]
    b = [0.0, 0.0, -0.5]
    t = [1.0, 0.0, -0.5]

    bucket = BucketParam(o, j, b, t, 0.5)

This would create a bucket ABCDEF with its center of rotation at the bucket joint and with
A = [0.0, -0.25, 0.0], B = [1.0, -0.25, -0.5], C = [0.0, -0.25, -0.5]
D = [0.0, 0.25, 0.0], E = [1.0, 0.25, -0.5], F = [0.0, 0.25, -0.5].
"""
struct BucketParam{T<:Float64}
    j_pos_init::Vector{T}
    b_pos_init::Vector{T}
    t_pos_init::Vector{T}
    width::T
    pos::Vector{T}
    ori::Vector{T}
    function BucketParam(
            o_pos_init::Vector{T},
            j_pos_init::Vector{T},
            b_pos_init::Vector{T},
            t_pos_init::Vector{T},
            width::T
    ) where {T<:Float64}
        if (length(o_pos_init) != 3)
            throw(DimensionMismatch("o_pos_init should be a vector of size 3"))
        end
        if (length(j_pos_init) != 3)
            throw(DimensionMismatch("j_pos_init should be a vector of size 3"))
        end
        if (length(b_pos_init) != 3)
            throw(DimensionMismatch("b_pos_init should be a vector of size 3"))
        end
        if (length(t_pos_init) != 3)
            throw(DimensionMismatch("t_pos_init should be a vector of size 3"))
        end
        if (j_pos_init ≈ b_pos_init)
            throw(ErrorException("j_pos_init should not be equal to b_pos_init"))
        end
        if (j_pos_init ≈ t_pos_init)
            throw(ErrorException("j_pos_init should not be equal to t_pos_init"))
        end
        if (b_pos_init ≈ t_pos_init)
            throw(ErrorException("b_pos_init should not be equal to t_pos_init"))
        end
        if ((width <= 0.0) || (width ≈ 0.0))
            throw(DomainError(width, "width should be greater than zero"))
        end

        pos = [0.0, 0.0, 0.0]
        ori = [1.0, 0.0, 0.0, 0.0]

        new{T}(
            j_pos_init - o_pos_init, b_pos_init - o_pos_init, t_pos_init - o_pos_init,
            width, pos, ori
        )
    end
end

"""
    SimParam{I<:Int64,T<:Float64}

Store all parameters related to the simulation.

# Note
- The value of `max_iterations` should be carefully selected. A higher number will result
  in a `terrain` closer to equilibrium at the end of each time step, but it may impact
  significantly the performance of the simulator. A value of 3 is suggested.

# Fields
- `repose_angle::Float64`: The repose angle of the considered soil. [rad]
- `max_iterations::Int64`: The maximum number of relaxation iterations per step.
- `cell_buffer::Int64`: The number of buffer cells surrounding the bucket and the relaxed
                        terrain where soil equilibrium is checked.

# Inner constructor

    SimParam(
        repose_angle::T, max_iterations::I, cell_buffer::I,
    ) where {I<:Int64,T<:Float64}

Create a new instance of `SimParam`.

Requirements:
- The `repose_angle` should be between 0.0 and pi / 2. The upper limit may be extended in
  the future.
- The `max_iterations` should be greater or equal to zero.
- The `cell_buffer` should be greater or equal to 2.

# Example

    sim = SimParam(0.85, 3, 4)
"""
struct SimParam{I<:Int64,T<:Float64}
    repose_angle::T
    max_iterations::I
    cell_buffer::I
    function SimParam(
            repose_angle::T,
            max_iterations::I,
            cell_buffer::I
    ) where {I<:Int64,T<:Float64}
        if (
            ((repose_angle > pi / 2) && (repose_angle != pi / 2)) ||
            ((repose_angle < 0.0) && (repose_angle != 0.0))
        )
            throw(DomainError(repose_angle, "repose_angle should be betweem 0.0 and pi/2"))
        end
        if ((max_iterations < 0.0) && (max_iterations != 0.0))
            throw(DomainError(
                max_iterations, "max_iterations should be greater or equal" *
                                " to zero"))
        end
        if ((cell_buffer < 2.0) && (cell_buffer != 2.0))
            @warn "cell_buffer too low, setting to 2"
            cell_buffer = 2
        end

        new{I,T}(repose_angle, max_iterations, cell_buffer)
    end
end

"""
    BodySoil{I<:Int64,T<:Float64}

Store information related to the position of the body soil.

# Note
- This struct is used in the `body_soil_pos` field of the `SimOut` struct.
- All the fields are Vector to make their value mutable.

# Fields
- `ind::Vector{Int64}`: Index of the bucket soil layer.
- `ii::Vector{Int64}`: Index of the bucket soil position in the X direction.
- `jj::Vector{Int64}`: Index of the bucket soil position in the Y direction.
- `x_b::Vector{Float64}`: Cartesian coordinate in the X direction of the bucket soil in
                          the reference bucket frame. [m]
- `y_b::Vector{Float64}`: Cartesian coordinate in the Y direction of the bucket soil in
                          the reference bucket frame. [m]
- `z_b::Vector{Float64}`: Cartesian coordinate in the Z direction of the bucket soil in
                          the reference bucket frame. [m]
- `h_soil::Vector{Float64}`: Vertical extent of the soil column. [m]

# Example

    body_soil_pos = BodySoil(1, 10, 15, 0.1, 0.0, 0.2, 0.5)

This would indicate that 0.5m of soil is present on the first body layer at (10, 15),
which corresponds to the coordinates (0.1, 0.0, 0.2) in the reference bucket frame.
"""
struct BodySoil{I<:Int64,T<:Float64}
    ind::Vector{I}
    ii::Vector{I}
    jj::Vector{I}
    x_b::Vector{T}
    y_b::Vector{T}
    z_b::Vector{T}
    h_soil::Vector{T}
    function BodySoil(
            ind::I,
            ii::I,
            jj::I,
            x_b::T,
            y_b::T,
            z_b::T,
            h_soil::T
    ) where {I<:Int64,T<:Float64}
        new{I,T}([ind], [ii], [jj], [x_b], [y_b], [z_b], [h_soil])
    end
end

"""
    SimOut{B<:Bool,I<:Int64,T<:Float64}

Store all outputs of the simulation.

# Convention
- The `terrain` Matrix stores the height of the terrain at each XY position, see the
  `GridParam` struct for more information on the simulation grid.
- The cells where a bucket wall is located is stored in `body`, which is a vector of sparse
  Matrices. At each XY position, the first sparse Matrix indicates the lowest height where
  a bucket wall is located while the second sparse Matrix indicates the maximum height of
  this bucket wall. If a second bucket wall is located at the same XY position, its
  minimum and maximum height are indicated in the third and fourth sparse Matrix,
  respectively.
- For each bucket, there can be only two distinct bucket walls located at the same
  XY position. As a result, the number of sparse Matrices in the `body` vector should be
  equal to four times the number of bucket.
- Similarly, `body_soil` stores the location of the soil resting on a bucket wall. The
  structure of `body_soil` is identical to `body`. An additional restriction is that the
  minimum height of the soil resting on the bucket must correspond to the maximum height of
  a bucket wall.
- The locations where there is soil resting on the bucket are stored in `body_soil_pos` as 
  `BosySoil` struct, see the `BosySoil` struct for more information on its content.
- The active areas (`bucket_area`, `relax_area` and `impact_area`) are assumed to be
  rectangular and to follow the grid geometry. They are thus stored as 2x2 Matrices where:
  [1, 1] corresponds to the minimum X index. [1, 2] corresponds to the maximum X index.
  [2, 1] corresponds to the minimum Y index. [2, 2] corresponds to the maximum Y index.

# Note
- Currently, only one bucket at a time is supported, but this restriction may be
  removed in the future.
- Sparse Matrices are used to reduce memory allocation and speed up calculation.
- An attempt has been made to use Dicts instead of sparse Matrices, however Dicts seem to be
  prohibitively slow in that context, probably due to the size.
- `equilibrium` is a Vector of Bool instead of a Bool to make its value mutable.

# Fields
- `equilibrium::Vector{Bool}`: Indicates whether the terrain is at equilibrium.
- `terrain::Matrix{Float64}`: Height of the terrain. [m]
- `body::Vector{SparseMatrixCSC{Float64,Int64}}`: Store the vertical extension of all
                                                  bucket walls for each XY position. [m]
- `body_soil::Vector{SparseMatrixCSC{Float64,Int64}}`: Store the vertical extension of all
                                                       soil resting on a bucket wall for
                                                       each XY position. [m]
- `body_soil_pos::Vector{BodySoil{Int64,Float64}}`: Store the indices of locations where
                                                    there is soil resting on the bucket.
- `bucket_area::Matrix{Int64}`: Store the 2D bounding box of the bucket with a buffer
                                determined by the parameter `cell_buffer` of `SimParam`.
- `relax_area::Matrix{Int64}`: Store the 2D bounding box of the area where soil has been
                               relaxed with a buffer determined by the parameter
                               `cell_buffer` of `SimParam`.
- `impact_area::Matrix{Int64}`: Store the union of `bucket_area` and `relax_area`. It
                                corresponds to the area where the soil equilibrium is
                                checked.

# Inner constructor

    SimOut(
        terrain::Matrix{T}, grid::GridParam{I,T}
    ) where {I<:Int64,T<:Float64}

Create a new instance of `SimOut` using the provided `terrain`.

Requirements:
- The `terrain` Matrix should be consistent with the grid size.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)

    out = SimOut(terrain, grid)

This would create a flat terrain located at 0 height.
"""
struct SimOut{B<:Bool,I<:Int64,T<:Float64}
    equilibrium::Vector{B}
    terrain::Matrix{T}
    body::Vector{SparseMatrixCSC{T,I}}
    body_soil::Vector{SparseMatrixCSC{T,I}}
    body_soil_pos::Vector{BodySoil{I,T}}
    bucket_area::Matrix{Int64}
    relax_area::Matrix{Int64}
    impact_area::Matrix{Int64}
    function SimOut(
            terrain::Matrix{T},
            grid::GridParam{I,T}
    ) where {I<:Int64,T<:Float64}
        if (size(terrain, 1) != 2 * grid.half_length_x + 1)
            throw(DimensionMismatch("Dimension of terrain in x (" * string(size(terrain, 1))
                                    * ") does not match with the grid size ("
                                    * string(2 * grid.half_length_x + 1) * ")"
            ))
        end
        if (size(terrain, 2) != 2 * grid.half_length_y + 1)
            throw(DimensionMismatch("Dimension of terrain in y (" * string(size(terrain, 2))
                                    * ") does not match with the grid size ("
                                    * string(2 * grid.half_length_y + 1) * ")"
            ))
        end

        # Initializing the bucket position array
        body = [spzeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)]
        for ii in 2:4
            push!(body, spzeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1))
        end

        # Initializing the bucket soil array
        body_soil = [spzeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)]
        for ii in 2:4
            push!(body_soil, spzeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1))
        end

        # Initalizing body_soil_pos
        body_soil_pos = Vector{BodySoil{I,T}}()

        # Initalizing active areas
        bucket_area = Int64[[2, 2] [2 * grid.half_length_x, 2 * grid.half_length_y]]
        relax_area = Int64[[2, 2] [2 * grid.half_length_x, 2 * grid.half_length_y]]
        impact_area = Int64[[2, 2] [2 * grid.half_length_x, 2 * grid.half_length_y]]

        new{Bool,I,T}(
            [false], terrain, body, body_soil, body_soil_pos, bucket_area, relax_area,
            impact_area
        )
    end
end
