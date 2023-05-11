"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#               Starting implementation of functions related to the bucket                 #
#                                                                                          #
#==========================================================================================#
"""
    _calc_bucket_pos(
        position::Vector{T}, ori::Quaternion{T}, grid::GridParam{I,T},
        bucket::BucketParam{I,T}, step_bucket_grid::T=0.5, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function determines all the cells where the bucket is located.
The bucket position is calculated based on its reference pose stored in the `bucket` struct,
as well as the provided position (`position`) and orientation (`ori`).
`position` and `ori` are used to apply the appropriate translation and rotation to the
bucket relative to its reference pose. The center of rotation is assumed to be the bucket
origin. The orientation is provided using the quaternion definition.

# Note
- This function is intended for internal use only.
- This function is a work in progress.

# Inputs
- `position::Vector{Float64}`: Cartesian coordinates of the bucket origin. [m]
- `ori::Quaternion{Float64}`: Orientation of the bucket. [Quaternion]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `bucket::BucketParam{Float64}`: Struct that stores information related to the
                                  bucket object.
- `step_bucket_grid::Float64`: Spatial increment used to decompose the edges of the bucket.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `Vector{Vector{Int64}}`: Collection of cells indices where the bucket is located.
                           Result is sorted and duplicates have been removed.

# Example

    position = [0.5, 0.3, 0.4]
    ori = angle_to_quat(0.0, -pi / 2, 0.0, :ZYX)
    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    o = [0.0, 0.0, 0.0]
    j = [0.0, 0.0, 0.0]
    b = [0.0, 0.0, -0.5]
    t = [1.0, 0.0, -0.5]
    bucket = BucketParam(o, j, b, t, 0.5)

    _calc_bucket_pos(position, ori, grid, bucket)
"""
function _calc_bucket_pos(
    position::Vector{T},
    ori::Quaternion{T},
    grid::GridParam{I,T},
    bucket::BucketParam{T},
    step_bucket_grid::T=0.5,
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Calculating position of the bucker vertices
    j_pos = Vector{T}(vect(ori \ bucket.j_pos_init * ori))
    b_pos = Vector{T}(vect(ori \ bucket.b_pos_init * ori))
    t_pos = Vector{T}(vect(ori \ bucket.t_pos_init * ori))

    # Adding position of the bucket origin
    j_pos += position
    b_pos += position
    t_pos += position

    # Unit vector normal to the side of the bucket
    normal_side = calc_normal(j_pos, b_pos, t_pos)

    # Position of each vertex of the bucket
    j_r_pos = j_pos + 0.5 * bucket.width * normal_side
    j_l_pos = j_pos - 0.5 * bucket.width * normal_side
    b_r_pos = b_pos + 0.5 * bucket.width * normal_side
    b_l_pos = b_pos - 0.5 * bucket.width * normal_side
    t_r_pos = t_pos + 0.5 * bucket.width * normal_side
    t_l_pos = t_pos - 0.5 * bucket.width * normal_side

    # Adding a small increment to all vertices
    # This is to account for the edge case where one of the vertex is at cell border
    # In that case, the increment would remove any ambiguity
    j_r_pos += tol * ((j_l_pos - j_r_pos) + (b_r_pos - j_r_pos) + (t_r_pos - j_r_pos))
    j_l_pos += tol * ((j_r_pos - j_l_pos) + (b_l_pos - j_l_pos) + (t_l_pos - j_l_pos))
    b_r_pos += tol * ((b_l_pos - b_r_pos) + (j_r_pos - b_r_pos) + (t_r_pos - b_r_pos))
    b_l_pos += tol * ((b_r_pos - b_l_pos) + (j_l_pos - b_l_pos) + (t_l_pos - b_l_pos))
    t_r_pos += tol * ((t_l_pos - t_r_pos) + (j_r_pos - t_r_pos) + (b_r_pos - t_r_pos))
    t_l_pos += tol * ((t_r_pos - t_l_pos) + (j_l_pos - t_l_pos) + (b_l_pos - t_l_pos))

    # Determining where each surface of the bucket is located
    base_pos = _calc_rectangle_pos(
        b_r_pos, b_l_pos, t_l_pos, t_r_pos, step_bucket_grid * grid.cell_size_z, grid, tol
    )
    back_pos = _calc_rectangle_pos(
        b_r_pos, b_l_pos, j_l_pos, j_r_pos, step_bucket_grid * grid.cell_size_z, grid, tol
    )
    right_side_pos = _calc_triangle_pos(
        j_r_pos, b_r_pos, t_r_pos, step_bucket_grid * grid.cell_size_z, grid, tol
    )
    left_side_pos = _calc_triangle_pos(
        j_l_pos, b_l_pos, t_l_pos, step_bucket_grid * grid.cell_size_z, grid, tol
    )

    return unique([base_pos; back_pos; right_side_pos; left_side_pos], dims=1)
end

"""
    _calc_rectangle_pos(
        a::Vector{T}, b::Vector{T}, c::Vector{T}, d::Vector{T},
        delta::T, grid::GridParam{I,T}, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function determines the cells where a rectangle surface is located. The rectangle is
defined by providing the Cartesian coordinates of its four vertices in the proper order.

To optimize performance, the function iterates over a portion of the horizontal grid where
the rectangle is located. For each cell, the function calculates the height of the plane
formed by the rectangle at the top right corner of the cell. If the cell is within the
rectangle area, the calcualted height is added to the results for the four neighboring
cells.

This method works because when a plane intersects with a rectangular cell, the minimum and
maximum height of the plane within the cell occurs at one of the cell corners.
By iterating through all the cells, the function ensures that all the corners of each cell
are investigated.

However, this approach does not work when the rectangle is perpendicular to the XY plane.
To handle this case, the function uses the `_calc_line_pos` function to include the cells
that lie on the four edges of the rectangle.

# Note
- This function is intended for internal use only.
- The iteration is performed over the top right corner of each cell, but any other corner
  could have been chosen without affecting the results.
- Not all cells are provided, since, at a given XY position, only the cells with the
  minimum and maximum height are important.
- When the rectangle follows a cell border, the exact location of the rectangle
  becomes ambiguous. It is assumed that the caller resolves this ambiguity.

# Inputs
- `a::Vector{Float64}`: Cartesian coordinates of one vertex of the rectangle. [m]
- `b::Vector{Float64}`: Cartesian coordinates of one vertex of the rectangle. [m]
- `c::Vector{Float64}`: Cartesian coordinates of one vertex of the rectangle. [m]
- `d::Vector{Float64}`: Cartesian coordinates of one vertex of the rectangle. [m]
- `delta::Float64`: Spatial increment used to decompose the edges of the rectangle. [m]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `Vector{Vector{Int64}}`: Collection of cells indices where the rectangle is located.
                           Result is not sorted and duplicates may be present.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    a = [1.0, 0.0, 0.7]
    b = [0.0, 1.0, 0.7]
    c = [0.0, 1.0, 0.9]
    d = [1.0, 0.0, 0.9]

    rect_pos = _calc_rectangle_pos(a, b, c, d, 0.01, grid)
"""
function _calc_rectangle_pos(
    a::Vector{T},
    b::Vector{T},
    c::Vector{T},
    d::Vector{T},
    delta::T,
    grid::GridParam{I,T},
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Converting the four rectangle vertices from position to indices
    cell_size = [grid.cell_size_xy; grid.cell_size_xy; grid.cell_size_z]
    grid_size = [grid.half_length_x + 1; grid.half_length_y + 1; grid.half_length_z + 1]
    a_ind = a ./ cell_size .+ grid_size
    b_ind = b ./ cell_size .+ grid_size
    c_ind = c ./ cell_size .+ grid_size
    d_ind = d ./ cell_size .+ grid_size

    # Calculating the bounding box of the rectangle
    area_min_x = floor(Int64, minimum([a_ind[1], b_ind[1], c_ind[1], d_ind[1]]))
    area_max_x = ceil(Int64, maximum([a_ind[1], b_ind[1], c_ind[1], d_ind[1]]))
    area_min_y = floor(Int64, minimum([a_ind[2], b_ind[2], c_ind[2], d_ind[2]]))
    area_max_y = ceil(Int64, maximum([a_ind[2], b_ind[2], c_ind[2], d_ind[2]]))

    # Calculating the lateral extent of the bounding box
    area_length_x = area_max_x - area_min_x
    area_length_y = area_max_y - area_min_y

    # Calculating the basis formed by the rectangle
    ab = b - a
    ad = d - a

    # Converting the basis from position to indices
    ab_ind = ab ./ cell_size
    ad_ind = ad ./ cell_size

    # Listing the cells inside the rectangle area
    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y, tol
    )

    # Allocating memory
    rect_pos = [Vector{Int64}(undef,3) for _ in 1:n_cell]

    nn_cell = 1
    # Determining all cells where the inner portion of the rectangle area is located
    for ii in area_min_x:area_max_x-1
        for jj in area_min_y:area_max_y-1
            # Calculating the indices corresponding to the previously calculated matrix
            ii_s = ii - area_min_x + 1
            jj_s = jj - area_min_y + 1

            if (in_rectangle[ii_s, jj_s])
                ### Cell is inside the rectangle area ###
                # Calculating the height index of the rectangle at this corner
                kk = ceil(Int64,
                    a_ind[3] + c_ab[ii_s, jj_s] * ab_ind[3] + c_ad[ii_s, jj_s] * ad_ind[3]
                )

                # Adding the four neighboring cells with the calculated height
                rect_pos[nn_cell][1] = ii
                rect_pos[nn_cell][2] = jj
                rect_pos[nn_cell][3] = kk
                rect_pos[nn_cell + 1][1] = ii + 1
                rect_pos[nn_cell + 1][2] = jj
                rect_pos[nn_cell + 1][3] = kk
                rect_pos[nn_cell + 2][1] = ii
                rect_pos[nn_cell + 2][2] = jj + 1
                rect_pos[nn_cell + 2][3] = kk
                rect_pos[nn_cell + 3][1] = ii + 1
                rect_pos[nn_cell + 3][2] = jj + 1
                rect_pos[nn_cell + 3][3] = kk

                # Incrementing the index
                nn_cell += 4
            end
        end
    end

    # Determining the cells where the four edges of the rectangle are located
    ab_pos = _calc_line_pos(a, b, delta, grid)
    bc_pos = _calc_line_pos(b, c, delta, grid)
    cd_pos = _calc_line_pos(c, d, delta, grid)
    da_pos = _calc_line_pos(d, a, delta, grid)

    return [rect_pos; ab_pos; bc_pos; cd_pos; da_pos]
end

"""
    _decompose_vector_rectangle(
        ab_ind::Vector{T}, ad_ind::Vector{T}, a_ind::Vector{T},
        area_min_x::I, area_min_y::I, area_length_x::I, area_length_y::I, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function performs a vector decomposition on a portion of the horizontal plane where
a rectangle ABCD is located. The position of the rectangle is defined by its edges AB and AD
, while the specified area extends over [`area_min_x`, `area_min_x + area_length_x`]
on the X direction and [`area_min_y`, `area_min_y + area_length_y`] on the Y direction.

For each cell in the specified area, the function decomposes it into the basis formed by
the vectors AB and AD. Let O be the name of a cell, it can then be decomposed as

    AO = c_ab * AB + c_ad * AD.

This decomposition leads to a system of 2 equations with 2 unknowns (c_ab and c_ad)

    AO[1] = c_ab * AB[1] + c_ad * AD[1] {1},
    AO[2] = c_ab * AB[2] + c_ad * AD[2] {2}.

One may note that AB[1] * {2} - AB[2] * {1} implies that

    AB[1] * AO[2] - AB[2] * AO[1] = c_ad * AD[2] * AB[1] - c_ad * AD[1] * AB[2]

that can be further rewritten as

    c_ad = (AB[1] * AO[2] - AB[2] * AO[1]) / (AD[2] * AB[1] - AD[1] * AB[2]).

Similarly, AD[1] * {2} - AD[2] * {1} implies that

    c_ab = -(AD[1] * AO[2] - AD[2] * AO[1]) / (AD[2] * AB[1] - AD[1] * AB[2]).

This decomposition allows us to determine whether the cell O is inside the rectangle area,
since this requires c_ab and c_ad to be between 0 and 1.

# Note
- This function is intended for internal use only.
- By convention, the decomposition is done at the top right corner of each cell.

# Inputs
- `ab_ind::Vector{Float64}`: Indices representing the edge AB of the rectangle.
- `ad_ind::Vector{Float64}`: Indices representing the edge AD of the rectangle.
- `a_ind::Vector{Float64}`: Indices of the vertex A from which the edges AB and AD start.
- `area_min_x::Int64`: Minimum index in the X direction of the specified area.
- `area_min_y::Int64`: Minimum index in the Y direction of the specified area.
- `area_length_x::Int64`: Number of grid elements in the X direction of the specified area.
- `area_length_y::Int64`: Number of grid elements in the Y direction of the specified area.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `c_ab::Matrix{Float64}`: Results of the vector decomposition in terms of the AB component.
- `c_ad::Matrix{Float64}`: Results of the vector decomposition in terms of the AD component.
- `in_rectangle::Matrix{Bool}`: Indicates whether the cell is inside the rectangle area.
- `n_cell::Int64`: Number of cells inside the rectangle area.

# Example

    ab_ind = [0, 4, 0]
    ad_ind = [3, 0, 0]
    a_ind = [10, 8, 25]

    c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
        ab_ind, ad_ind, a_ind, 15, 12, 8, 7
    )
"""
function _decompose_vector_rectangle(
    ab_ind::Vector{T},
    ad_ind::Vector{T},
    a_ind::Vector{T},
    area_min_x::I,
    area_min_y::I,
    area_length_x::I,
    area_length_y::I,
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Allocating memory
    c_ab = Matrix{Float64}(undef, area_length_x, area_length_y)
    c_ad = Matrix{Float64}(undef, area_length_x, area_length_y)
    in_rectangle = Matrix{Bool}(undef, area_length_x, area_length_y)

    # Setting constants for decomposing the cell position into the reference basis
    c_ab_x = ad_ind[2] / (ab_ind[1] * ad_ind[2] - ab_ind[2] * ad_ind[1])
    c_ab_y = ad_ind[1] / (ab_ind[1] * ad_ind[2] - ab_ind[2] * ad_ind[1])
    c_ad_x = ab_ind[2] / (ab_ind[1] * ad_ind[2] - ab_ind[2] * ad_ind[1])
    c_ad_y = ab_ind[1] / (ab_ind[1] * ad_ind[2] - ab_ind[2] * ad_ind[1])

    # Preparation for the determination of the rectangle position
    # Iterating over the top right corner of all cells in the specified area
    n_cell = 0
    for ii_s in 1:area_length_x
        for jj_s in 1:area_length_y
            # Calculating the indices corresponding to the simulation grid
            ii = area_min_x - 0.5 + ii_s
            jj = area_min_y - 0.5 + jj_s

            # Decomposing the cell corner position into the basis formed by the rectangle
            c_ab[ii_s, jj_s] = c_ab_x * (ii - a_ind[1]) - c_ab_y * (jj - a_ind[2])
            c_ad[ii_s, jj_s] = -c_ad_x * (ii - a_ind[1]) + c_ad_y * (jj - a_ind[2])

            if (
                (c_ab[ii_s, jj_s] > tol) && (c_ab[ii_s, jj_s] < 1 - tol) &&
                (c_ad[ii_s, jj_s] > tol) && (c_ad[ii_s, jj_s] < 1 - tol)
            )
                ### Cell is inside the rectangle area ###
                in_rectangle[ii_s, jj_s] = true
                n_cell += 4
            else
                ### Cell is outside the rectangle area ###
                in_rectangle[ii_s, jj_s] = false
            end
        end
    end

    return c_ab, c_ad, in_rectangle, n_cell
end

"""
    _calc_triangle_pos(
        a::Vector{T}, b::Vector{T}, c::Vector{T},
        delta::T, grid::GridParam{I,T}, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function determines the cells where a triangle surface is located. The triangle is
defined by providing the Cartesian coordinates of its three vertices in the proper order.

To optimize performance, the function iterates over a portion of the horizontal grid where
the triangle is located. For each cell, the function calculates the height of the plane
formed by the triangle at the top right corner of the cell. If the cell is within the
triangle area, the calcualted height is added to the results for the four neighboring
cells.

This method works because when a plane intersects with a rectangular cell, the minimum and
maximum height of the plane within the cell occurs at one of the cell corners.
By iterating through all the cells, the function ensures that all the corners of each cell
are investigated.

However, this approach does not work when the triangle is perpendicular to the XY plane.
To handle this case, the function uses the `_calc_line_pos` function to include the cells
that lie on the three edges of the triangle.

# Note
- This function is intended for internal use only.
- The iteration is performed over the top right corner of each cell, but any other corner
  could have been chosen without affecting the results.
- Not all cells are provided, since, at a given XY position, only the cells with the
  minimum and maximum height are important.
- When the triangle follows a cell border, the exact location of the triangle
  becomes ambiguous. It is assumed that the caller resolves this ambiguity.

# Inputs
- `a::Vector{Float64}`: Cartesian coordinates of one vertex of the triangle. [m]
- `b::Vector{Float64}`: Cartesian coordinates of one vertex of the triangle. [m]
- `c::Vector{Float64}`: Cartesian coordinates of one vertex of the triangle. [m]
- `delta::Float64`: Spatial increment used to decompose the edges of the triangle. [m]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `Vector{Vector{Int64}}`: Collection of cells indices where the triangle is located.
                           Result is not sorted and duplicates may be present.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    a = [1.0, 0.0, 0.7]
    b = [0.0, 1.0, 0.7]
    c = [0.0, 1.0, 0.9]

    tri_pos = _calc_triangle_pos(a, b, c, 0.01, grid)
"""
function _calc_triangle_pos(
    a::Vector{T},
    b::Vector{T},
    c::Vector{T},
    delta::T,
    grid::GridParam{I,T},
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Converting the three triangle vertices from position to indices
    cell_size = [grid.cell_size_xy; grid.cell_size_xy; grid.cell_size_z]
    grid_size = [grid.half_length_x + 1; grid.half_length_y + 1; grid.half_length_z + 1]
    a_ind = a ./ cell_size .+ grid_size
    b_ind = b ./ cell_size .+ grid_size
    c_ind = c ./ cell_size .+ grid_size

    # Calculating the bounding box of the triangle
    area_min_x = floor(Int64, minimum([a_ind[1], b_ind[1], c_ind[1]]))
    area_max_x = ceil(Int64, maximum([a_ind[1], b_ind[1], c_ind[1]]))
    area_min_y = floor(Int64, minimum([a_ind[2], b_ind[2], c_ind[2]]))
    area_max_y = ceil(Int64, maximum([a_ind[2], b_ind[2], c_ind[2]]))

    # Calculating the lateral extent of the bounding box
    area_length_x = area_max_x - area_min_x
    area_length_y = area_max_y - area_min_y

    # Calculating the basis formed by the triangle
    ab = b - a
    ac = c - a

    # Converting the basis from position to indices
    ab_ind = ab ./ cell_size
    ac_ind = ac ./ cell_size

    # Listing the cells inside the triangle area 
    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y, tol
    )

    # Allocating memory
    tri_pos = [Vector{Int64}(undef,3) for _ in 1:n_cell]

    nn_cell = 1
    # Determining all cells where the inner portion of the triangle area is located
    for ii in area_min_x:area_max_x-1
        for jj in area_min_y:area_max_y-1
            # Calculating the indices corresponding to the previously calculated matrix
            ii_s = ii - area_min_x + 1
            jj_s = jj - area_min_y + 1

            if (in_triangle[ii_s, jj_s])
                ### Cell is inside the triangle area ###
                # Calculating the height index of the triangle at this corner
                kk = ceil(Int64,
                    a_ind[3] + c_ab[ii_s, jj_s] * ab_ind[3] + c_ac[ii_s, jj_s] * ac_ind[3]
                )

                # Adding the four neighboring cells with the calculated height
                tri_pos[nn_cell][1] = ii
                tri_pos[nn_cell][2] = jj
                tri_pos[nn_cell][3] = kk
                tri_pos[nn_cell + 1][1] = ii + 1
                tri_pos[nn_cell + 1][2] = jj
                tri_pos[nn_cell + 1][3] = kk
                tri_pos[nn_cell + 2][1] = ii
                tri_pos[nn_cell + 2][2] = jj + 1
                tri_pos[nn_cell + 2][3] = kk
                tri_pos[nn_cell + 3][1] = ii + 1
                tri_pos[nn_cell + 3][2] = jj + 1
                tri_pos[nn_cell + 3][3] = kk

                # Incrementing the index
                nn_cell += 4
            end
        end
    end

    # Determining the cells where the three edges of the triangle are located
    ab_pos = _calc_line_pos(a, b, delta, grid)
    bc_pos = _calc_line_pos(b, c, delta, grid)
    ca_pos = _calc_line_pos(c, a, delta, grid)

    return [tri_pos; ab_pos; bc_pos; ca_pos]
end

"""
    _decompose_vector_triangle(
        ab_ind::Vector{T}, ac_ind::Vector{T}, a_ind::Vector{T},
        area_min_x::I, area_min_y::I, area_length_x::I, area_length_y::I, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function performs a vector decomposition on a portion of the horizontal plane where
a triangle ABC is located. The position of the triangle is defined by its edges AB and AC
, while the specified area extends over [`area_min_x`, `area_min_x + area_length_x`]
on the X direction and [`area_min_y`, `area_min_y + area_length_y`] on the Y direction.

For each cell in the specified area, the function decomposes it into the basis formed by
the vectors AB and AC. Let O be the name of a cell, it can then be decomposed as

    AO = c_ab * AB + c_ac * AC.

This decomposition leads to a system of 2 equations with 2 unknowns (c_ab and c_ac)

    AO[1] = c_ab * AB[1] + c_ac * AC[1] {1},
    AO[2] = c_ab * AB[2] + c_ac * AC[2] {2}.

One may note that AB[1] * {2} - AB[2] * {1} implies that

    AB[1] * AO[2] - AB[2] * AO[1] = c_ac * AC[2] * AB[1] - c_ac * AC[1] * AB[2]

that can be further rewritten as

    c_ac = (AB[1] * AO[2] - AB[2] * AO[1]) / (AC[2] * AB[1] - AC[1] * AB[2]).

Similarly, AC[1] * {2} - AC[2] * {1} implies that

    c_ab = -(AC[1] * AO[2] - AC[2] * AO[1]) / (AC[2] * AB[1] - AC[1] * AB[2]).

This decomposition allows us to determine whether the cell O is inside the triangle area,
since this requires c_ab and c_ac to be between 0 and 1, and the sum of c_ab and c_ac to be
lower than 1.

# Note
- This function is intended for internal use only.
- By convention, the decomposition is done at the top right corner of each cell.

# Inputs
- `ab_ind::Vector{Float64}`: Indices representing the edge AB of the triangle.
- `ac_ind::Vector{Float64}`: Indices representing the edge AC of the triangle.
- `a_ind::Vector{Float64}`: Indices of the vertex A from which the edges AB and AC start.
- `area_min_x::Int64`: Minimum index in the X direction of the specified area.
- `area_min_y::Int64`: Minimum index in the Y direction of the specified area.
- `area_length_x::Int64`: Number of grid elements in the X direction of the specified area.
- `area_length_y::Int64`: Number of grid elements in the Y direction of the specified area.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `c_ab::Matrix{Float64}`: Results of the vector decomposition in terms of the AB component.
- `c_ac::Matrix{Float64}`: Results of the vector decomposition in terms of the AC component.
- `in_triangle::Matrix{Bool}`: Indicates whether the cell is inside the triangle area.
- `n_cell::Int64`: Number of cells inside the triangle area.

# Example

    ab_ind = [0, 4, 0]
    ac_ind = [3, 0, 0]
    a_ind = [10, 8, 25]

    c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
        ab_ind, ac_ind, a_ind, 15, 12, 8, 7
    )
"""
function _decompose_vector_triangle(
    ab_ind::Vector{T},
    ac_ind::Vector{T},
    a_ind::Vector{T},
    area_min_x::I,
    area_min_y::I,
    area_length_x::I,
    area_length_y::I,
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Allocating memory
    c_ab = Matrix{Float64}(undef, area_length_x, area_length_y)
    c_ac = Matrix{Float64}(undef, area_length_x, area_length_y)
    in_triangle = Matrix{Bool}(undef, area_length_x, area_length_y)

    # Setting constants for decomposing the cell position into the reference basis
    c_ab_x = ac_ind[2] / (ab_ind[1] * ac_ind[2] - ab_ind[2] * ac_ind[1])
    c_ab_y = ac_ind[1] / (ab_ind[1] * ac_ind[2] - ab_ind[2] * ac_ind[1])
    c_ac_x = ab_ind[2] / (ab_ind[1] * ac_ind[2] - ab_ind[2] * ac_ind[1])
    c_ac_y = ab_ind[1] / (ab_ind[1] * ac_ind[2] - ab_ind[2] * ac_ind[1])

    # Preparation for the determination of the triangle position
    # Iterating over the top right corner of all cells in the specified area
    n_cell = 0
    for ii_s in 1:area_length_x
        for jj_s in 1:area_length_y
            # Calculating the indices corresponding to the simulation grid
            ii = area_min_x - 0.5 + ii_s
            jj = area_min_y - 0.5 + jj_s

            # Decomposing the cell corner position into the basis formed by the triangle
            c_ab[ii_s, jj_s] = c_ab_x * (ii - a_ind[1]) - c_ab_y * (jj - a_ind[2])
            c_ac[ii_s, jj_s] = -c_ac_x * (ii - a_ind[1]) + c_ac_y * (jj - a_ind[2])

            if (
                (c_ab[ii_s, jj_s] > tol) && (c_ac[ii_s, jj_s] > tol) &&
                (c_ab[ii_s, jj_s] + c_ac[ii_s, jj_s] < 1 - tol)
            )
                ### Cell is inside the triangle area ###
                in_triangle[ii_s, jj_s] = true
                n_cell += 4
            else
                ### Cell is outside the triangle area ###
                in_triangle[ii_s, jj_s] = false
            end
        end
    end

    return c_ab, c_ac, in_triangle, n_cell
end

"""
    _calc_line_pos(
        a::Vector{T}, b::Vector{T}, delta::T, grid::GridParam{I,T}
    ) where {I<:Int64,T<:Float64}

This function determines all the cells that lie on a straight line between two Cartesian
coordinates.

For the sake of accuracy, the line is divided into smaller segments using a spatial
increment `delta`.

The coordinates of each sub-point (ab_i) along the line can then be calculated as

    ab_i = a + ab * i * delta / norm(ab)

where i is the increment number and ab = b - a.
The Cartesian coordinates can then be converted into indices

    ab_i_ind = ab_i / cell_size + grid_half_length + 1

Finally, the floating-point values are rounded to obtain the cell indices in the X, Y, Z
directions.
As the center of each cell is considered to be on the center of the top surface,
`round` should be used for getting the cell indices in the X and Y direction,
while `ceil` should be used for the Z direction.

# Note
- This function is intended for internal use only.
- When the line follows a cell border, the exact location of the line becomes ambiguous.
  It is assumed that the caller resolves this ambiguity.

# Inputs
- `a::Vector{Float64}`: Cartesian coordinates of the first extremity of the line. [m]
- `b::Vector{Float64}`: Cartesian coordinates of the second extremity of the line. [m]
- `delta::Float64`: Spatial increment used to decompose the line. [m]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.

# Outputs
- `line_pos::Vector{Vector{Int64}}`: Collection of cells indices where the line is located.
                                     Result is not sorted and duplicates should be expected.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    a = [1.0, 0.5, 0.7]
    b = [0.7, 0.8, -0.3]

    line_pos = _calc_line_pos(a, b, 0.01, grid)
"""
function _calc_line_pos(
    a::Vector{T},
    b::Vector{T},
    delta::T,
    grid::GridParam{I,T}
) where {I<:Int64,T<:Float64}

    # Line vector
    ab = b - a

    # Creating the unit vector
    nn = max(2, round(Int64, norm(ab) / delta) + 1)
    unit_vec = LinRange(0.0, 1.0, nn)

    # Initialization
    line_pos = [Vector{Int64}(undef,3) for _ in 1:nn]

    # Setting constants used for the vectorial decomposition
    c_x = a[1] / grid.cell_size_xy + grid.half_length_x + 1
    c_y = a[2] / grid.cell_size_xy + grid.half_length_y + 1
    c_z = a[3] / grid.cell_size_z + grid.half_length_z + 1
    d_x = ab[1] / grid.cell_size_xy
    d_y = ab[2] / grid.cell_size_xy
    d_z = ab[3] / grid.cell_size_z

    # Determining the cells where the line is located
    for ii in 1:nn
        line_pos[ii][1] = round(Int64, c_x + d_x * unit_vec[ii])
        line_pos[ii][2] = round(Int64, c_y + d_y * unit_vec[ii])
        line_pos[ii][3] = ceil(Int64, c_z + d_z * unit_vec[ii])
    end

    return line_pos
end
