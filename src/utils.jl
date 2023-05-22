"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                       Starting implementation of utility functions                       #
#                                                                                          #
#==========================================================================================#
"""
    _init_sparse_array!(
        sparse_array::Vector{SparseMatrixCSC{T,I}},
        grid::GridParam{I,T}
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

    # Compiling all positions
    non_zeros_pos = [[1; cell] for cell in non_zeros_1]
    append!(non_zeros_pos, [[3; cell] for cell in non_zeros_3])

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
    calc_normal(a::Vector{T}, b::Vector{T}, c::Vector{T}) where {T<:Float64}

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
    set_RNG_seed!(seed::I=1234) where {I<:Int64}

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
    write_soil(
        out::SimOut{I,T}, grid::GridParam{I,T}
    ) where {S<:String,I<:Int64,T<:Float64}

This function writes the terrain and the bucket soil into a csv located in the "results"
directory. `terrain` and `body_soil` are saved into files named "terrain" and "body_soil",
respectively, followed by the file number.

# Inputs
- `out::SimOut{Int64,Float64}`: Struct that stores simulation outputs.
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
    out::SimOut{I,T},
    grid::GridParam{I,T}
) where {S<:String,I<:Int64,T<:Float64}

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

        # Iterating over all bucket soil
        for cell in body_soil_pos
            ii = cell[2]
            jj = cell[3]
            ind = cell[1]

            _write_vector(io, grid.vect_x[ii], grid.vect_y[jj], out.body_soil[ind][ii][jj])
            _write_vector(
                io, grid.vect_x[ii], grid.vect_y[jj], out.body_soil[ind+1][ii][jj]
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

    # Calcualting position of bucket corners
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
- `io`: Used as a refrence to the writing file.
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

    # Writing vector to file
    writedlm(io, [string(x, ", ", y, ", ", z)])
end
