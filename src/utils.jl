"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                       Starting implementation of utility functions                       #
#                                                                                          #
#==========================================================================================#
"""
    _calc_bucket_corner_pos(
        pos::Vector{T}, ori::Quaternion{T}, bucket::BucketParam{T}
    ) where {T<:Float64}

This function calculates the global position of the six corners of the bucket.

# Note
- This function is intended for internal use only.

# Inputs
- `pos::Vector{Float64}`: Cartesian coordinates of the bucket origin. [m]
- `ori::Quaternion{Float64}`: Orientation of the bucket. [Quaternion]
- `bucket::BucketParam{Float64}`: Struct that stores information related to the
                                  bucket object.

# Outputs
- `Vector{Float64}`: Cartesian coordinates of the right side of the bucket joint. [m]
- `Vector{Float64}`: Cartesian coordinates of the left side of the bucket joint. [m]
- `Vector{Float64}`: Cartesian coordinates of the right side of the bucket base. [m]
- `Vector{Float64}`: Cartesian coordinates of the left side of the bucket base. [m]
- `Vector{Float64}`: Cartesian coordinates of the right side of the bucket teeth. [m]
- `Vector{Float64}`: Cartesian coordinates of the left side of the bucket teeth. [m]

# Example

    pos = [0.1, 0.0, 0.2]
    ori = angle_to_quat(0.0, -pi / 2, 0.0, :ZYX)
    o = [0.0, 0.0, 0.0]
    j = [0.0, 0.0, 0.0]
    b = [0.0, 0.0, -0.5]
    t = [1.0, 0.0, -0.5]
    bucket = BucketParam(o, j, b, t, 0.5)

    j_r_pos, j_l_pos, b_r_pos, b_l_pos, t_r_pos, t_l_pos = _calc_bucket_corner_pos(
        pos, ori, bucket
    )
"""
function _calc_bucket_corner_pos(
    pos::Vector{T},
    ori::Quaternion{T},
    bucket::BucketParam{T}
) where {T<:Float64}
    # Calculating position of the bucket vertices
    j_pos = Vector{T}(vect(ori \ bucket.j_pos_init * ori))
    b_pos = Vector{T}(vect(ori \ bucket.b_pos_init * ori))
    t_pos = Vector{T}(vect(ori \ bucket.t_pos_init * ori))

    # Unit vector normal to the side of the bucket
    normal_side = calc_normal(j_pos, b_pos, t_pos)

    # Adding position of the bucket origin
    j_pos += pos
    b_pos += pos
    t_pos += pos

    # Position of each vertex of the bucket
    j_r_pos = j_pos + 0.5 * bucket.width * normal_side
    j_l_pos = j_pos - 0.5 * bucket.width * normal_side
    b_r_pos = b_pos + 0.5 * bucket.width * normal_side
    b_l_pos = b_pos - 0.5 * bucket.width * normal_side
    t_r_pos = t_pos + 0.5 * bucket.width * normal_side
    t_l_pos = t_pos - 0.5 * bucket.width * normal_side

    return j_r_pos, j_l_pos, b_r_pos, b_l_pos, t_r_pos, t_l_pos
end

"""
    check_bucket_movement(
        pos::Vector{T}, ori::Quaternion{T}, grid::GridParam{I,T}, bucket::BucketParam{T}
    ) where {I<:Int64,T<:Float64}

This function calculates the maximum distance travelled by any part of the bucket since the
last soil update. The position of the bucket during the last soil update is stored in the
`BucketParam` struct.

# Note
- If the maximum distance travelled is lower than 50% of the cell size, the function
  returns `false` otherwise it returns `true`.
- If the distance travelled exceeds twice the cell size, a warning is issued to indicate
  a potential problem with the soil update.

# Inputs
- `pos::Vector{Float64}`: Cartesian coordinates of the bucket origin. [m]
- `ori::Quaternion{Float64}`: Orientation of the bucket. [Quaternion]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `bucket::BucketParam{Float64}`: Struct that stores information related to the
                                  bucket object.

# Outputs
- `Bool`: Flag indicating whether the bucket has moved enough for conducting a soil update.

# Example

    pos = [0.1, 0.0, 0.2]
    ori = angle_to_quat(0.0, -pi / 2, 0.0, :ZYX)
    o = [0.0, 0.0, 0.0]
    j = [0.0, 0.0, 0.0]
    b = [0.0, 0.0, -0.5]
    t = [1.0, 0.0, -0.5]
    bucket = BucketParam(o, j, b, t, 0.5)
    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)

    soil_update = check_bucket_movement(pos, ori, grid, bucket)
"""
function check_bucket_movement(
    pos::Vector{T},
    ori::Quaternion{T},
    grid::GridParam{I,T},
    bucket::BucketParam{T}
) where {I<:Int64,T<:Float64}
    # Calculating new position of bucket corners
    j_r_pos_n, j_l_pos_n, b_r_pos_n, b_l_pos_n, t_r_pos_n, t_l_pos_n = (
        _calc_bucket_corner_pos(pos, ori, bucket)
    )

    # Calculating former position of bucket corners
    j_r_pos_f, j_l_pos_f, b_r_pos_f, b_l_pos_f, t_r_pos_f, t_l_pos_f = (
        _calc_bucket_corner_pos(bucket.pos, Quaternion(bucket.ori), bucket)
    )

    # Calculating distance travelled
    j_r_dist = sqrt(
        (j_r_pos_f[1] - j_r_pos_n[1])^2 + (j_r_pos_f[2] - j_r_pos_n[2])^2 +
        (j_r_pos_f[3] - j_r_pos_n[3])^2
    )
    j_l_dist = sqrt(
        (j_l_pos_f[1] - j_l_pos_n[1])^2 + (j_l_pos_f[2] - j_l_pos_n[2])^2 +
        (j_l_pos_f[3] - j_l_pos_n[3])^2
    )
    b_r_dist = sqrt(
        (b_r_pos_f[1] - b_r_pos_n[1])^2 + (b_r_pos_f[2] - b_r_pos_n[2])^2 +
        (b_r_pos_f[3] - b_r_pos_n[3])^2
    )
    b_l_dist = sqrt(
        (b_l_pos_f[1] - b_l_pos_n[1])^2 + (b_l_pos_f[2] - b_l_pos_n[2])^2 +
        (b_l_pos_f[3] - b_l_pos_n[3])^2
    )
    t_r_dist = sqrt(
        (t_r_pos_f[1] - t_r_pos_n[1])^2 + (t_r_pos_f[2] - t_r_pos_n[2])^2 +
        (t_r_pos_f[3] - t_r_pos_n[3])^2
    )
    t_l_dist = sqrt(
        (t_l_pos_f[1] - t_l_pos_n[1])^2 + (t_l_pos_f[2] - t_l_pos_n[2])^2 +
        (t_l_pos_f[3] - t_l_pos_n[3])^2
    )

    # Calculating max distance travelled
    max_dist = maximum(
        [j_r_dist, j_l_dist, b_r_dist, b_l_dist, t_r_dist, t_l_dist]
    )

    # Calculating min cell size
    min_cell_size = min(grid.cell_size_xy, grid.cell_size_z)

    if (max_dist < 0.5 * min_cell_size)
        # Bucket has only slightly moved since last update
        return false
    elseif (max_dist > 2 * min_cell_size)
        @warn  "Movement made by the bucket is larger than two cell size.\n"
               "The validity of the soil update is not ensured."
    end

    return true
end

"""
    _calc_bucket_frame_pos(
        ii::I, jj::I, z::T, grid::GridParam{I,T}, bucket::BucketParam{T}
    ) where {I<:Int64,T<:Float64}

This function calculates the position of a considered cell in the bucket frame assuming
that the bucket is in its reference position.

# Note
- This function is intended for internal use only.

# Inputs
- `ii::Int64`: Index of the considered cell in the X direction.
- `jj::Int64`: Index of the considered cell in the Y direction.
- `z::Float64`: Height of the considered position. [m]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `bucket::BucketParam{Float64}`: Struct that stores information related to the
                                  bucket object.

# Outputs
- `Vector{Float64}`: Cartesian coordinates of the considered position in the reference
                     bucket frame. [m]

# Example

    o = [0.0, 0.0, 0.0]
    j = [0.0, 0.0, 0.0]
    b = [0.0, 0.0, -0.5]
    t = [1.0, 0.0, -0.5]
    bucket = BucketParam(o, j, b, t, 0.5)
    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)

    cell_local_pos = _calc_bucket_frame_pos(10, 15, 0.5, grid, bucket)
"""
function _calc_bucket_frame_pos(
    ii::I,
    jj::I,
    z::T,
    grid::GridParam{I,T},
    bucket::BucketParam{T}
) where {I<:Int64,T<:Float64}
    # Calculating cell's position in bucket frame
    cell_pos = [
        grid.vect_x[ii] - bucket.pos[1], grid.vect_y[jj] - bucket.pos[2], z - bucket.pos[3]
    ]

    # Inversing rotation
    inv_ori = Quaternion(bucket.ori[1], -bucket.ori[2], -bucket.ori[3], -bucket.ori[4])

    # Calculating reference position of cell in bucket frame
    cell_local_pos = Vector{T}(vect(inv_ori \ cell_pos * inv_ori))

    return cell_local_pos
end

"""
    _init_sparse_array!(
        sparse_array::Vector{SparseMatrixCSC{T,I}}, grid::GridParam{I,T}
    ) where {I<:Int64,T<:Float64}

This function reinitializes `sparse_array`.
`sparse_array` is expected to be either `body` or `body_soil`.

# Note
- This function is intended for internal use only.

# Inputs
- `sparse_array::Vector{SparseMatrixCSC{Float64,Int64}}`: Either `body` or `body_soil`.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _init_sparse_array!(out.body, grid)
"""
function _init_sparse_array!(
    sparse_array::Vector{SparseMatrixCSC{T,I}},
    grid::GridParam{I,T}
) where {I<:Int64,T<:Float64}

    for ii in 1:length(sparse_array)
        droptol!(sparse_array[ii], 2*grid.half_length_z+1)
    end
end

"""
    _locate_all_non_zeros(
        sparse_array::Vector{SparseMatrixCSC{T,I}}
    ) where {I<:Int64,T<:Float64}

This function returns the indices of all non-zero values in `sparse_array`.
`sparse_array` is expected to be either `body` or `body_soil`.

# Note
- This function is intended for internal use only.
- The first index in the returned vector corresponds to the bucket layer, while the second
  and third indices are the indices in the X and Y direction, respectively.

# Inputs
- `sparse_array::Vector{SparseMatrixCSC{Float64,Int64}}`: Either `body` or `body_soil`.

# Outputs
- `Vector{Vector{Int64}}`:: Collection of cells indices where `sparse_array` is non-zero.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    body_soil_pos = _locate_all_non_zeros(out.body_soil)
"""
function _locate_all_non_zeros(
    sparse_array::Vector{SparseMatrixCSC{T,I}}
) where {I<:Int64,T<:Float64}

    # Locating all XY positions where sparse_array is nonzero
    non_zeros_1 = _locate_non_zeros(sparse_array[1])
    non_zeros_2 = _locate_non_zeros(sparse_array[2])
    non_zeros_3 = _locate_non_zeros(sparse_array[3])
    non_zeros_4 = _locate_non_zeros(sparse_array[4])

    # Aggregating by bucket layer
    non_zeros_1 = cat(non_zeros_1, non_zeros_2, dims=1)
    non_zeros_3 = cat(non_zeros_3, non_zeros_4, dims=1)

    # Removing duplicates
    unique!(non_zeros_1)
    unique!(non_zeros_3)

    non_zeros_pos = Vector{Vector{Int64}}()
    # Compiling all positions
    for cell in non_zeros_1
        if (
            (sparse_array[1][cell[1], cell[2]] != 0.0) ||
            (sparse_array[2][cell[1], cell[2]] != 0.0)
        )
            push!(non_zeros_pos, [1; cell])
        end
    end
    for cell in non_zeros_3
        if (
            (sparse_array[3][cell[1], cell[2]] != 0.0) ||
            (sparse_array[4][cell[1], cell[2]] != 0.0)
        )
            push!(non_zeros_pos, [3; cell])
        end
    end

    return non_zeros_pos
end

"""
    _locate_non_zeros(
        sparse_matrix::SparseMatrixCSC{T,I}
    ) where {I<:Int64,T<:Float64}

This function returns the indices of all non-zero values in a sparse Matrix.

# Note
- This function is intended for internal use only.
- This implementation is faster than a simple loop.

# Inputs
- `sparse_matrix::SparseMatrixCSC{Float64,Int64}`: Input Matrix for which non-zero values
                                                   should be located.

# Outputs
- `Vector{Vector{Int64}}`:: Collection of cells indices where the value of the input Matrix
                            is non-zero.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    non_zeros = _locate_non_zeros(out.body[1])
"""
function _locate_non_zeros(
    sparse_matrix::SparseMatrixCSC{T,I}
) where {I<:Int64,T<:Float64}

    # Intializing
    non_zeros = Vector{Vector{Int64}}()

    # Locating all XY position where the SparseMatrix is nonzero
    for col in 1:size(sparse_matrix, 2)
        for r in nzrange(sparse_matrix, col)
            push!(non_zeros, [rowvals(sparse_matrix)[r], col])
        end
    end

    return non_zeros
end

"""
    calc_normal(
        a::Vector{T}, b::Vector{T}, c::Vector{T}
    ) where {T<:Float64}

This function calculates the unit normal vector of a plane formed by three points using
the right-hand rule.

# Note
- The input order of the points is important as it determines the sign of the unit normal
  vector based on the right-hand rule.

# Inputs
- `a::Vector{Float64}`: Cartesian coordinates of the first point of the plane. [m]
- `b::Vector{Float64}`: Cartesian coordinates of the second point of the plane. [m]
- `c::Vector{Float64}`: Cartesian coordinates of the third point of the plane. [m]

# Outputs
- `Vector{T}`: Unit normal vector of the provided plane. [m]

# Example

    a = [0.0, 0.0, 0.0]
    b = [1.0, 0.5, 0.23]
    c = [0.1, 0.2, -0.5]

    unit_normal = calc_normal(a, b, c)
"""
function calc_normal(
    a::Vector{T},
    b::Vector{T},
    c::Vector{T}
) where {T<:Float64}

    return cross(b - a, c - a) / norm(cross(b - a, c - a))
end

"""
    set_RNG_seed!(
        seed::I=1234
    ) where {I<:Int64}

This function sets the used RNG seed.

# Inputs
- `seed::Int64`: Value of the RNG seed.

# Outputs
- None

# Example

    set_RNG_seed!(1234)
"""
function set_RNG_seed!(
    seed::I=1234
) where {I<:Int64}

    seed!(seed)
end

"""
    check_volume(
        out::SimOut{B,I,T}, init_volume::T, grid::GridParam{I,T}
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function checks that the volume of soil is conserved.
The initial volume of soil (`init_volume`) has to be provided.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `init_volume::Float64`: Initial volume of soil in the terrain. [m^3]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)
    init_volume = 0.0

    check_volume(out, init_volume, grid)
"""
function check_volume(
    out::SimOut{B,I,T},
    init_volume::T,
    grid::GridParam{I,T}
) where {B<:Bool,I<:Int64,T<:Float64}

    # Calculating volume of soil in the terrain
    terrain_volume = grid.cell_area * sum(out.terrain)

    # Collecting all body soil
    body_soil_pos = _locate_all_non_zeros(out.body_soil)

    # Copying body_soil location
    old_body_soil = deepcopy(out.body_soil)

    # Calculating volume of soil in body_soil
    body_soil_volume = 0.0
    for cell in body_soil_pos
        ii = cell[2]
        jj = cell[3]
        ind = cell[1]
        body_soil_volume += out.body_soil[ind+1][ii, jj] - out.body_soil[ind][ii, jj]
    end
    body_soil_volume *= grid.cell_area

    # Removing soil from old_body_soil followung body_soil_pos
    for cell in out.body_soil_pos
        ii = cell[2]
        jj = cell[3]
        ind = cell[1]
        h_soil = cell[7]
        old_body_soil[ind+1][ii, jj] -= h_soil
    end

    # Calculating total volume of soil
    total_volume = terrain_volume + body_soil_volume

    # Checking that volume of soil in body_soil_pos_ corresponds to soil in body_soil
    for col in 1:size(old_body_soil, 2)
        for r in nzrange(old_body_soil, col)
            dh_1 = abs(old_body_soil[1][ii, jj] - old_body_soil[2][ii, jj])
            dh_2 = abs(old_body_soil[3][ii, jj] - old_body_soil[4][ii, jj])
            if ((dh_1 > tol) || (dh_2 > tol))
                # Soil in body_soil_pos_ does not correspond to amount of soil in body_soil
                @warn "Volume of soil in body_soil_pos_ is not consistent with " *
                    "the amount of soil in body_soil."
                return false
            end
        end
    end

    if (abs(total_volume - init_volume) > 0.5 * grid.cell_volume)
        @warn "Volume is not conserved! \n" *
            "Initial volume: " * string(init_volume) *
            "   Current volume: " * string(total_volume)
        return false
    end
    return true
end

"""
    check_soil(
        out::SimOut{B,I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function checks that all the simulation outputs follow the conventions of the
simulator. If any inconsistency is found, a warning is issued.
The conventions that are checked include:
- The terrain should not overlap with the bucket.
- The bucket should be properly defined, with its maximum height higher than its minimum
  height.
- The bucket soil should be properly defined, with its maximum height higher than its
  minimum height.
- The two bucket layers should not overlap or touch each other.
- One bucket layer should not overlap with all bucket soil layer.
- The bucket should not overlap with the corresponding bucket soil layer.
- The bucket soil layer should be resting on the corresponding bucket layer.
- The bucket should be present when there is bucket soil.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    check_soil(out)
"""
function check_soil(
    out::SimOut{B,I,T},
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Collecting all cells where the bucket is located
    bucket_pos = _locate_all_non_zeros(out.body)

    # Iterating over all cells where the bucket is located
    for cell in bucket_pos
        ii = cell[2]
        jj = cell[3]
        ind = cell[1]

        if (out.terrain[ii, jj] > out.body[ind][ii, jj] + tol)
            @warn "Terrain is above the bucket\n" *
                "Location: (" * string(ii) * ", " * string(jj) * ")\n" *
                "Terrain height: " * string(out.terrain[ii, jj]) * "\n" *
                "Bucket minimum height: " * string(out.body[ind][ii, jj])
            return false
        end

        if (out.body[ind][ii, jj] > out.body[ind+1][ii, jj] + tol)
            @warn "Minimum height of the bucket is above its maximum height\n" *
                "Location: (" * string(ii) * ", " * string(jj) * ")\n" *
                "Bucket minimum height: " * string(out.body[ind][ii, jj]) * "\n" *
                "Bucket maximum height: " * string(out.body[ind+1][ii, jj])
            return false
        end

        if (
            ((out.body[1][ii, jj] != 0.0) || (out.body[2][ii, jj] != 0.0)) &&
            ((out.body[3][ii, jj] != 0.0) || (out.body[4][ii, jj] != 0.0)) &&
            (out.body[2][ii, jj] + tol > out.body[3][ii, jj]) &&
            (out.body[4][ii, jj] + tol > out.body[1][ii, jj])
        )
            @warn "The two bucket layers are intersecting\n" *
                "Location: (" * string(ii) * ", " * string(jj) * ")\n" *
                "Bucket 1 minimum height: " * string(out.body[1][ii, jj]) * "\n" *
                "Bucket 1 maximum height: " * string(out.body[2][ii, jj]) * "\n" *
                "Bucket 2 minimum height: " * string(out.body[3][ii, jj]) * "\n" *
                "Bucket 2 maximum height: " * string(out.body[4][ii, jj])
            return false
        end

        if (
            ((out.body[1][ii, jj] != 0.0) || (out.body[2][ii, jj] != 0.0)) &&
            ((out.body_soil[3][ii, jj] != 0.0) || (out.body_soil[4][ii, jj] != 0.0)) &&
            (out.body[2][ii, jj] - tol > out.body_soil[3][ii, jj]) &&
            (out.body_soil[4][ii, jj] - tol > out.body[1][ii, jj])
        )
            @warn "A bucket layer and a bucket soil layer are intersecting\n" *
                "Location: (" * string(ii) * ", " * string(jj) * ")\n" *
                "Bucket 1 minimum height: " * string(out.body[1][ii, jj]) * "\n" *
                "Bucket 1 maximum height: " * string(out.body[2][ii, jj]) * "\n" *
                "Bucket soil 2 minimum height: " * string(out.body_soil[3][ii, jj]) * "\n" *
                "Bucket soil 2 maximum height: " * string(out.body_soil[4][ii, jj])
            return false
        end

        if (
            ((out.body_soil[1][ii, jj] != 0.0) || (out.body_soil[2][ii, jj] != 0.0)) &&
            ((out.body[3][ii, jj] != 0.0) || (out.body[4][ii, jj] != 0.0)) &&
            (out.body_soil[2][ii, jj] - tol > out.body[3][ii, jj]) &&
            (out.body[4][ii, jj] - tol > out.body_soil[1][ii, jj])
        )
            @warn "A bucket layer and a bucket soil layer are intersecting\n" *
                "Location: (" * string(ii) * ", " * string(jj) * ")\n" *
                "Bucket soil 1 minimum height: " * string(out.body_soil[1][ii, jj]) * "\n" *
                "Bucket soil 1 maximum height: " * string(out.body_soil[2][ii, jj]) * "\n" *
                "Bucket 2 minimum height: " * string(out.body[3][ii, jj]) * "\n" *
                "Bucket 2 maximum height: " * string(out.body[4][ii, jj])
            return false
        end

        if ((out.body_soil[ind][ii, jj] == 0.0) && (out.body_soil[ind+1][ii, jj] == 0.0))
            ### Bucket soil is not present ###
            # Stopping the check
            continue
        end

        if (out.body_soil[ind][ii, jj] > out.body_soil[ind+1][ii, jj] + tol)
            @warn "Minimum height of the bucket soil is above its maximum height\n" *
                "Location: (" * string(ii) * ", " * string(jj) * ")\n" *
                "Bucket soil minimum height: " * string(out.body_soil[ind][ii, jj]) * "\n" *
                "Bucket soil maximum height: " * string(out.body_soil[ind+1][ii, jj])
            return false
        end

        if (out.body[ind+1][ii, jj] > out.body_soil[ind][ii, jj] + tol)
            @warn "Bucket is above the bucket soil\n" *
                "Location: (" * string(ii) * ", " * string(jj) * ")\n" *
                "Bucket maximum height: " * string(out.body[ind+1][ii, jj]) * "\n" *
                "Bucket soil minimum height: " * string(out.body_soil[ind][ii, jj])
            return false
        end

        if (out.body_soil[ind][ii, jj] != out.body[ind+1][ii, jj])
            @warn "Bucket soil is not above the bucket\n" *
                "Location: (" * string(ii) * ", " * string(jj) * ")\n" *
                "Bucket maximum height: " * string(out.body[ind+1][ii, jj]) * "\n" *
                "Bucket soil minimum height: " * string(out.body_soil[ind][ii, jj])
            return false
        end
    end

    # Collecting all cells where the bucket soil is located
    body_soil_pos = _locate_all_non_zeros(out.body_soil)

    # Iterating over all cells where bucket soil is located
    for cell in body_soil_pos
        ii = cell[2]
        jj = cell[3]
        ind = cell[1]

        if ((out.body[ind][ii, jj] == 0.0) && (out.body[ind+1][ii, jj] == 0.0))
            ### Bucket is not present ###
            @warn "Bucket soil is present but there is no bucket\n" *
                "Location: (" * string(ii) * ", " * string(jj) * ")\n" *
                "Bucket soil minimum height: " * string(out.body_soil[ind][ii, jj]) * "\n" *
                "Bucket soil maximum height: " * string(out.body_soil[ind+1][ii, jj])
            return false
        end
    end
    return true
end

"""
    write_soil(
        out::SimOut{B,I,T}, grid::GridParam{I,T}
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function writes the terrain and the bucket soil into a csv located in the "results"
directory. `terrain` and `body_soil` are saved into files named "terrain" and "body_soil",
respectively, followed by the file number.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid

    write_soil(out, grid)
"""
function write_soil(
    out::SimOut{B,I,T},
    grid::GridParam{I,T}
) where {B<:Bool,I<:Int64,T<:Float64}

    # Finding next filename for the terrain file
    step = 1
    filename = string(@__DIR__, "/../results/terrain_", lpad(1, 4, "0"), ".csv")

    while isfile(filename)
        step += 1
        filename = string(@__DIR__, "/../results/terrain_", lpad(step, 4, "0"), ".csv")
    end

    # Writing the terrain
    open(filename, "a") do io
        writedlm(io, ["x, y, z"])
        for ii in 1:length(grid.vect_x)
            for jj in 1:length(grid.vect_y)
                _write_vector(io, grid.vect_x[ii], grid.vect_y[jj], out.terrain[ii, jj])
            end
        end
    end

    # Setting filename for the bucket soil
    filename = string(@__DIR__, "/../results/body_soil_", lpad(step, 4, "0"), ".csv")

    # Collecting all bucket soil
    body_soil_pos = _locate_all_non_zeros(out.body_soil)

    # Writing the bucket soil
    open(filename, "a") do io
        writedlm(io, ["x, y, z"])

        if isempty(body_soil_pos)
            ### No soil is resting on the bucket ###
            # Writing a dummy position for paraview
            _write_vector(io, grid.vect_x[1], grid.vect_y[1], grid.vect_z[1])
        end

        # Iterating over all bucket soil
        for cell in body_soil_pos
            ii = cell[2]
            jj = cell[3]
            ind = cell[1]

            _write_vector(
                io, grid.vect_x[ii], grid.vect_y[jj], out.body_soil[ind+1][ii, jj]
            )
        end
    end
end

"""
    write_bucket(
        bucket::BucketParam{T}
    ) where {T<:Float64}

This function writes the position of all bucket faces into a csv located in the
"results" directory. The file is named "bucket" followed by the file number.

# Inputs
- `bucket::BucketParam{Float64}`: Struct that stores information related to the
                                  bucket object.

# Outputs
- None

# Example

    o = [0.0, 0.0, 0.0]
    j = [0.0, 0.0, 0.0]
    b = [0.0, 0.0, -0.5]
    t = [1.0, 0.0, -0.5]
    bucket = BucketParam(o, j, b, t, 0.5)

    write_bucket(bucket)
"""
function write_bucket(
    bucket::BucketParam{T}
) where {T<:Float64}

    # Transforming vector to Quaternion
    ori = Quaternion(bucket.ori)

    # Calculating position of the bucker points
    j_pos = bucket.pos + Vector{T}(vect(ori \ bucket.j_pos_init * ori))
    b_pos = bucket.pos + Vector{T}(vect(ori \ bucket.b_pos_init * ori))
    t_pos = bucket.pos + Vector{T}(vect(ori \ bucket.t_pos_init * ori))

    # Calculating vector normal to the side of the bucket
    normal_side = calc_normal(j_pos, b_pos, t_pos)

    # Calculating position of bucket corners
    j_r_pos = j_pos + 0.5 * bucket.width * normal_side
    j_l_pos = j_pos - 0.5 * bucket.width * normal_side
    b_r_pos = b_pos + 0.5 * bucket.width * normal_side
    b_l_pos = b_pos - 0.5 * bucket.width * normal_side
    t_r_pos = t_pos + 0.5 * bucket.width * normal_side
    t_l_pos = t_pos - 0.5 * bucket.width * normal_side

    # Finding next filename for the bucket file
    step = 1
    filename = string(@__DIR__, "/../results/bucket_", lpad(1, 4, "0"), ".csv")
    while isfile(filename)
        step += 1
        filename = string(@__DIR__, "/../results/bucket_", lpad(step, 4, "0"), ".csv")
    end

    # Writing coordinates of bucket corners
    open(filename, "a") do io
        writedlm(io, ["x, y, z"])
        # Writing bucket right side
        _write_vector(io, b_r_pos[1], b_r_pos[2], b_r_pos[3])
        _write_vector(io, t_r_pos[1], t_r_pos[2], t_r_pos[3])
        _write_vector(io, j_r_pos[1], j_r_pos[2], j_r_pos[3])
        # Writing bucket back
        _write_vector(io, j_r_pos[1], j_r_pos[2], j_r_pos[3])
        _write_vector(io, j_l_pos[1], j_l_pos[2], j_l_pos[3])
        _write_vector(io, b_l_pos[1], b_l_pos[2], b_l_pos[3])
        _write_vector(io, b_r_pos[1], b_r_pos[2], b_r_pos[3])
        # Writing bucket base
        _write_vector(io, b_r_pos[1], b_r_pos[2], b_r_pos[3])
        _write_vector(io, t_r_pos[1], t_r_pos[2], t_r_pos[3])
        _write_vector(io, t_l_pos[1], t_l_pos[2], t_l_pos[3])
        _write_vector(io, b_l_pos[1], b_l_pos[2], b_l_pos[3])
        # Writing bucket left side
        _write_vector(io, b_l_pos[1], b_l_pos[2], b_l_pos[3])
        _write_vector(io, t_l_pos[1], t_l_pos[2], t_l_pos[3])
        _write_vector(io, j_l_pos[1], j_l_pos[2], j_l_pos[3])
    end
end

"""
    _write_vector(
        io, x::T, y::T, z::T
    ) where {T<:Float64}

This is an utility function to write a 3D vector, such as Cartesian coordinates, into
a file.

# Note
- This function is intended for internal use only.

# Inputs
- `io`: Used as a reference to the writing file.
- `x::Float64`: X coordinate of the position to write.
- `y::Float64`: Y coordinate of the position to write.
- `z::Float64`: Z coordinate of the position to write.

# Outputs
- None

# Example

    open("file.txt", "a") do io
        write_vector(io, 0.0, 0.0, 1.0)
    end
"""
function _write_vector(
    io,
    x::T,
    y::T,
    z::T
) where {T<:Float64}

    writedlm(io, [string(x, ", ", y, ", ", z)])
end
