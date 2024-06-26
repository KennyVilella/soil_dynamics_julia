"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#               Starting implementation of functions related to the bucket                 #
#                                                                                          #
#==========================================================================================#
"""
    _calc_bucket_pos!(
        out::SimOut{B,I,T}, pos::Vector{T}, ori::Quaternion{T}, grid::GridParam{I,T},
        bucket::BucketParam{T}, sim::SimParam{I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function determines all the cells where the bucket is located.
The bucket position is calculated based on its reference pose stored in the `bucket` struct,
as well as the provided position (`pos`) and orientation (`ori`).
`pos` and `ori` are used to apply the appropriate translation and rotation to the
bucket relative to its reference pose. The center of rotation is assumed to be the bucket
origin. The orientation is provided using the quaternion definition.

# Note
- This function is intended for internal use only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `pos::Vector{Float64}`: Cartesian coordinates of the bucket origin. [m]
- `ori::Quaternion{Float64}`: Orientation of the bucket. [Quaternion]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `bucket::BucketParam{Float64}`: Struct that stores information related to the
                                  bucket object.
- `sim::SimParam{Int64,Float64}`: Struct that stores information related to the
                                  simulation.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    pos = [0.5, 0.3, 0.4]
    ori = angle_to_quat(0.0, -pi / 2, 0.0, :ZYX)
    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    o = [0.0, 0.0, 0.0]
    j = [0.0, 0.0, 0.0]
    b = [0.0, 0.0, -0.5]
    t = [1.0, 0.0, -0.5]
    bucket = BucketParam(o, j, b, t, 0.5)
    sim = SimParam(0.85, 3, 4)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _calc_bucket_pos!(out, pos, ori, grid, bucket, sim)
"""
function _calc_bucket_pos!(
        out::SimOut{B,I,T},
        pos::Vector{T},
        ori::Quaternion{T},
        grid::GridParam{I,T},
        bucket::BucketParam{T},
        sim::SimParam{I,T},
        tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Reinitializing bucket position
    _init_sparse_array!(out.body, grid)

    # Calculating position of the bucket corners
    j_r_pos, j_l_pos, b_r_pos, b_l_pos, t_r_pos, t_l_pos = _calc_bucket_corner_pos(
        pos, ori, bucket
    )

    # Adding a small increment to all vertices
    # This is to account for the edge case where one of the vertex is at cell border
    # In that case, the increment would remove any ambiguity
    j_r_pos += tol * ((j_l_pos - j_r_pos) + (b_r_pos - j_r_pos) + (t_r_pos - j_r_pos))
    j_l_pos += tol * ((j_r_pos - j_l_pos) + (b_l_pos - j_l_pos) + (t_l_pos - j_l_pos))
    b_r_pos += tol * ((b_l_pos - b_r_pos) + (j_r_pos - b_r_pos) + (t_r_pos - b_r_pos))
    b_l_pos += tol * ((b_r_pos - b_l_pos) + (j_l_pos - b_l_pos) + (t_l_pos - b_l_pos))
    t_r_pos += tol * ((t_l_pos - t_r_pos) + (j_r_pos - t_r_pos) + (b_r_pos - t_r_pos))
    t_l_pos += tol * ((t_r_pos - t_l_pos) + (j_l_pos - t_l_pos) + (b_l_pos - t_l_pos))

    # Calculating the 2D bounding box of the bucket
    bucket_x_min = minimum([
        j_r_pos[1], j_l_pos[1], b_r_pos[1], b_l_pos[1], t_r_pos[1], t_l_pos[1]
    ])
    bucket_x_max = maximum([
        j_r_pos[1], j_l_pos[1], b_r_pos[1], b_l_pos[1], t_r_pos[1], t_l_pos[1]
    ])
    bucket_y_min = minimum([
        j_r_pos[2], j_l_pos[2], b_r_pos[2], b_l_pos[2], t_r_pos[2], t_l_pos[2]
    ])
    bucket_y_max = maximum([
        j_r_pos[2], j_l_pos[2], b_r_pos[2], b_l_pos[2], t_r_pos[2], t_l_pos[2]
    ])

    # Updating bucket_area
    out.bucket_area[1, 1] = max(
        round(Int64,
            bucket_x_min / grid.cell_size_xy + grid.half_length_x + 1 - sim.cell_buffer
        ), 2
    )
    out.bucket_area[1, 2] = min(
        round(Int64,
            bucket_x_max / grid.cell_size_xy + grid.half_length_x + 1 + sim.cell_buffer
        ), 2 * grid.half_length_x
    )
    out.bucket_area[2, 1] = max(
        round(Int64,
            bucket_y_min / grid.cell_size_xy + grid.half_length_y + 1 - sim.cell_buffer
        ), 2
    )
    out.bucket_area[2, 2] = min(
        round(Int64,
            bucket_y_max / grid.cell_size_xy + grid.half_length_y + 1 + sim.cell_buffer
        ), 2 * grid.half_length_y
    )

    # Determining where each surface of the bucket is located
    base_pos = _calc_rectangle_pos(b_r_pos, b_l_pos, t_l_pos, t_r_pos, grid, tol)
    back_pos = _calc_rectangle_pos(b_r_pos, b_l_pos, j_l_pos, j_r_pos, grid, tol)
    right_side_pos = _calc_triangle_pos(j_r_pos, b_r_pos, t_r_pos, grid, tol)
    left_side_pos = _calc_triangle_pos(j_l_pos, b_l_pos, t_l_pos, grid, tol)

    # Sorting all list of cells indices where the bucket is located
    sort!(base_pos)
    sort!(back_pos)
    sort!(right_side_pos)
    sort!(left_side_pos)

    # Updating the bucket position
    _update_body!(base_pos, out, grid, tol)
    _update_body!(back_pos, out, grid, tol)
    _update_body!(right_side_pos, out, grid, tol)
    _update_body!(left_side_pos, out, grid, tol)
end

"""
    _calc_rectangle_pos(
        a::Vector{T}, b::Vector{T}, c::Vector{T}, d::Vector{T},
        grid::GridParam{I,T}, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function determines the cells where a rectangle surface is located. The rectangle is
defined by providing the Cartesian coordinates of its four vertices in the proper order.

To optimize performance, the function iterates over a portion of the horizontal grid where
the rectangle is located. For each cell, the function calculates the height of the plane
formed by the rectangle at the top right corner of the cell. If the cell is within the
rectangle area, the calculated height is added to the results for the four neighboring
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

    rect_pos = _calc_rectangle_pos(a, b, c, d, grid)
"""
function _calc_rectangle_pos(
        a::Vector{T},
        b::Vector{T},
        c::Vector{T},
        d::Vector{T},
        grid::GridParam{I,T},
        tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Converting the four rectangle vertices from position to indices
    cell_size = [grid.cell_size_xy; grid.cell_size_xy; grid.cell_size_z]
    grid_size = [grid.half_length_x + 1; grid.half_length_y + 1; grid.half_length_z]
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
    rect_pos = [Vector{Int64}(undef, 3) for _ in 1:n_cell]

    nn_cell = 1
    # Determining all cells where the inner portion of the rectangle area is located
    for ii in area_min_x:(area_max_x-1)
        for jj in area_min_y:(area_max_y-1)
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
                rect_pos[nn_cell+1][1] = ii + 1
                rect_pos[nn_cell+1][2] = jj
                rect_pos[nn_cell+1][3] = kk
                rect_pos[nn_cell+2][1] = ii
                rect_pos[nn_cell+2][2] = jj + 1
                rect_pos[nn_cell+2][3] = kk
                rect_pos[nn_cell+3][1] = ii + 1
                rect_pos[nn_cell+3][2] = jj + 1
                rect_pos[nn_cell+3][3] = kk

                # Incrementing the index
                nn_cell += 4
            end
        end
    end

    # Determining the cells where the four edges of the rectangle are located
    ab_pos = _calc_line_pos(a, b, grid)
    bc_pos = _calc_line_pos(b, c, grid)
    cd_pos = _calc_line_pos(c, d, grid)
    da_pos = _calc_line_pos(d, a, grid)

    return [rect_pos; ab_pos; bc_pos; cd_pos; da_pos]
end

"""
    _decompose_vector_rectangle(
        ab_ind::Vector{T}, ad_ind::Vector{T}, a_ind::Vector{T},
        area_min_x::I, area_min_y::I, area_length_x::I, area_length_y::I, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function performs a vector decomposition on a portion of the horizontal plane where
a rectangle ABCD is located. The position of the rectangle is defined by its edges AB
and AD, while the specified area extends over [`area_min_x`, `area_min_x + area_length_x`]
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
- `Matrix{Float64}`: Results of the vector decomposition in terms of the AB component.
- `Matrix{Float64}`: Results of the vector decomposition in terms of the AD component.
- `Matrix{Bool}`: Indicates whether the cell is inside the rectangle area.
- `Int64`: Number of cells inside the rectangle area.

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
        a::Vector{T}, b::Vector{T}, c::Vector{T}, grid::GridParam{I,T}, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function determines the cells where a triangle surface is located. The triangle is
defined by providing the Cartesian coordinates of its three vertices in the proper order.

To optimize performance, the function iterates over a portion of the horizontal grid where
the triangle is located. For each cell, the function calculates the height of the plane
formed by the triangle at the top right corner of the cell. If the cell is within the
triangle area, the calculated height is added to the results for the four neighboring
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

    tri_pos = _calc_triangle_pos(a, b, c, grid)
"""
function _calc_triangle_pos(
        a::Vector{T},
        b::Vector{T},
        c::Vector{T},
        grid::GridParam{I,T},
        tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Converting the three triangle vertices from position to indices
    cell_size = [grid.cell_size_xy; grid.cell_size_xy; grid.cell_size_z]
    grid_size = [grid.half_length_x + 1; grid.half_length_y + 1; grid.half_length_z]
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
    tri_pos = [Vector{Int64}(undef, 3) for _ in 1:n_cell]

    nn_cell = 1
    # Determining all cells where the inner portion of the triangle area is located
    for ii in area_min_x:(area_max_x-1)
        for jj in area_min_y:(area_max_y-1)
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
                tri_pos[nn_cell+1][1] = ii + 1
                tri_pos[nn_cell+1][2] = jj
                tri_pos[nn_cell+1][3] = kk
                tri_pos[nn_cell+2][1] = ii
                tri_pos[nn_cell+2][2] = jj + 1
                tri_pos[nn_cell+2][3] = kk
                tri_pos[nn_cell+3][1] = ii + 1
                tri_pos[nn_cell+3][2] = jj + 1
                tri_pos[nn_cell+3][3] = kk

                # Incrementing the index
                nn_cell += 4
            end
        end
    end

    # Determining the cells where the three edges of the triangle are located
    ab_pos = _calc_line_pos(a, b, grid)
    bc_pos = _calc_line_pos(b, c, grid)
    ca_pos = _calc_line_pos(c, a, grid)

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
- `Matrix{Float64}`: Results of the vector decomposition in terms of the AB component.
- `Matrix{Float64}`: Results of the vector decomposition in terms of the AC component.
- `Matrix{Bool}`: Indicates whether the cell is inside the triangle area.
- `Int64`: Number of cells inside the triangle area.

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
        a::Vector{T}, b::Vector{T}, grid::GridParam{I,T}
    ) where {I<:Int64,T<:Float64}

This function determines all the cells that lie on a straight line between two Cartesian
coordinates.

The algorithm implemented in this function comes from the article:
"A Fast Voxel Traversal Algorithm for Ray Tracing" by J. Amanatides and A. Woo.

The floating-point values are rounded to obtain the cell indices in the X, Y, Z directions.
As the centre of each cell is considered to be on the centre of the top surface, `round`
should be used for getting the cell indices in the X and Y direction, while `ceil`
should be used for the Z direction.

# Note
- This function is intended for internal use only.
- When the line follows a cell border, the exact location of the line becomes ambiguous.
  It is assumed that the caller resolves this ambiguity.

# Inputs
- `a::Vector{Float64}`: Cartesian coordinates of the first extremity of the line. [m]
- `b::Vector{Float64}`: Cartesian coordinates of the second extremity of the line. [m]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.

# Outputs
- `Vector{Vector{Int64}}`: Collection of cells indices where the line is located.
                           Result is not sorted and duplicates should be expected.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    a = [1.0, 0.5, 0.7]
    b = [0.7, 0.8, -0.3]

    line_pos = _calc_line_pos(a, b, grid)
"""
function _calc_line_pos(
        a::Vector{T},
        b::Vector{T},
        grid::GridParam{I,T}
) where {I<:Int64,T<:Float64}

    # Converting to indices
    x1 = a[1] / grid.cell_size_xy + grid.half_length_x + 1.0
    y1 = a[2] / grid.cell_size_xy + grid.half_length_y + 1.0
    z1 = a[3] / grid.cell_size_z + grid.half_length_z
    x2 = b[1] / grid.cell_size_xy + grid.half_length_x + 1.0
    y2 = b[2] / grid.cell_size_xy + grid.half_length_y + 1.0
    z2 = b[3] / grid.cell_size_z + grid.half_length_z

    # Determining direction of line
    step_x = (x1 < x2) ? 1 : -1
    step_y = (y1 < y2) ? 1 : -1
    step_z = (z1 < z2) ? 1 : -1

    # Spatial difference between a and b
    dx = x2 - x1
    dy = y2 - y1
    dz = z2 - z1

    # Avoiding issue when line is 2D
    if (dx == 0.0)
        dx = 1e-10
    end
    if (dy == 0.0)
        dy = 1e-10
    end
    if (dz == 0.0)
        dz = 1e-10
    end

    # Determining the offset to first cell boundary
    if (step_x == 1)
        t_max_x = round(x1) + 0.5 - x1
    else
        t_max_x = x1 - round(x1) + 0.5
    end
    if (step_y == 1)
        t_max_y = round(y1) + 0.5 - y1
    else
        t_max_y = y1 - round(y1) + 0.5
    end
    if (step_z == 1)
        t_max_z = ceil(z1) - z1
    else
        t_max_z = z1 - floor(z1)
    end

    # Determining how long on the line to cross the cell
    t_delta_x = sqrt(1.0 + (dy * dy + dz * dz) / (dx * dx))
    t_delta_y = sqrt(1.0 + (dx * dx + dz * dz) / (dy * dy))
    t_delta_z = sqrt(1.0 + (dx * dx + dy * dy) / (dz * dz))

    # Determining the distance along the line until the first cell boundary
    t_max_x *= t_delta_x
    t_max_y *= t_delta_y
    t_max_z *= t_delta_z

    # Calculating norm of the vector AB
    ab_norm = sqrt(dx * dx + dy * dy + dz * dz)

    # Creating line_pos and adding the starting point
    line_pos = Vector{Vector{I}}()
    push!(line_pos, [round(Int64, x1), round(Int64, y1), ceil(Int64, z1)])

    # Iterating along the line until reaching the end
    while ((t_max_x < ab_norm) || (t_max_y < ab_norm) || (t_max_z < ab_norm))
        if (t_max_x < t_max_y)
            if (t_max_x < t_max_z)
                x1 = x1 + step_x
                t_max_x += t_delta_x
            else
                z1 = z1 + step_z
                t_max_z += t_delta_z
            end
        else
            if (t_max_y < t_max_z)
                y1 = y1 + step_y
                t_max_y += t_delta_y
            else
                z1 = z1 + step_z
                t_max_z += t_delta_z
            end
        end
        push!(line_pos, [round(Int64, x1), round(Int64, y1), ceil(Int64, z1)])
    end

    return line_pos
end

"""
    _update_body!(
        area_pos::Vector{Vector{I}}, out::SimOut{B,I,T}, grid::GridParam{I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function updates the bucket position in `body` following the cells composing
`area_pos`. For each XY position, the first cell found in `area_pos` corresponds to
the minimum height of the bucket, while the last one provides the maximum height.
As a result, this function must be called separately for each bucket wall.

# Note
- This function is intended for internal use only.
- `area_pos` must be sorted and not be empty.

# Inputs
- `area_pos::Vector{Vector{Int64}}`: A collection of cell indices specifying where a bucket
                                     wall is located.
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)
    a = [1.0, 0.0, 0.7]
    b = [0.0, 1.0, 0.7]
    c = [0.0, 1.0, 0.9]
    tri_pos = _calc_triangle_pos(a, b, c, 0.01, grid)

    _update_body!(tri_pos, out, grid)
"""
function _update_body!(
        area_pos::Vector{Vector{I}},
        out::SimOut{B,I,T},
        grid::GridParam{I,T},
        tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Initializing cell position and height
    ii = area_pos[1][1]
    jj = area_pos[1][2]
    min_h = grid.vect_z[area_pos[1][3]+1] - grid.cell_size_z
    max_h = grid.vect_z[area_pos[1][3]+1]

    # Iterating over all cells in area_pos
    for cell in area_pos
        if ((ii != cell[1]) || (jj != cell[2]))
            ### New XY position ###
            # Updating bucket position for the previous XY position
            _include_new_body_pos!(out, ii, jj, min_h, max_h, tol)

            # Initializing new cell position and height
            min_h = grid.vect_z[cell[3]+1] - grid.cell_size_z
            max_h = grid.vect_z[cell[3]+1]
            ii = cell[1]
            jj = cell[2]
        else
            ### New height for the XY position ###
            # Updating maximum height
            max_h = grid.vect_z[cell[3]+1]
        end
    end

    # Updating bucket position for the last XY position
    _include_new_body_pos!(out, ii, jj, min_h, max_h, tol)
end

"""
    _include_new_body_pos!(
        out::SimOut{B,I,T}, ii::I, jj::I, min_h::T, max_h::T, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function updates the bucket position in `body` at the coordinates (`ii`, `jj`).
The minimum and maximum heights of the bucket at that position are given by `min_h` and
`max_h`, respectively.
If the given position overlaps with an existing position, then the existing position is
updated as the union of the two positions. Otherwise, a new position is added to `body`.
In the case where the given position does not overlap with two existing positions, the
given position is merged with the closest existing position. This case should however not
occur.

# Note
- This function is intended for internal use only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `ii::Int64`: Index of the considered position in the X direction.
- `jj::Int64`: Index of the considered position in the Y direction.
- `min_h::Float64`: Minimum height of the bucket. [m]
- `max_h::Float64`: Maximum height of the bucket. [m]
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _include_new_body_pos!(out, 10, 15, 0.5, 0.6)
"""
function _include_new_body_pos!(
        out::SimOut{B,I,T},
        ii::I,
        jj::I,
        min_h::T,
        max_h::T,
        tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}
    status = Vector{Int64}()
    # Iterating over the two bucket layers and storing their status
    for ind in [1, 3]
        if (iszero(out.body[ind][ii, jj]) && iszero(out.body[ind+1][ii, jj]))
            ### No existing position ###
            push!(status, 0)
        elseif (
            (min_h - tol < out.body[ind][ii, jj]) &&
            (max_h + tol > out.body[ind][ii, jj])
        )
            ### New position is overlapping with an existing position ###
            push!(status, 1)
        elseif (
            (min_h - tol < out.body[ind+1][ii, jj]) &&
            (max_h + tol > out.body[ind+1][ii, jj])
        )
            ### New position is overlapping with an existing position ###
            push!(status, 1)
        elseif (
            (min_h + tol > out.body[ind][ii, jj]) &&
            (max_h - tol < out.body[ind+1][ii, jj])
        )
            ### New position is within an existing position ###
            return
        else
            ### New position is not overlapping with the two existing positions ###
            push!(status, -1)
        end
    end

    # Updating the bucket position
    if (status == [1, 1])
        ### New position is overlapping with the two existing positions ###
        out.body[1][ii, jj] = minimum([out.body[1][ii, jj], out.body[3][ii, jj], min_h])
        out.body[2][ii, jj] = maximum([out.body[2][ii, jj], out.body[4][ii, jj], max_h])

        # Resetting obsolete bucket position
        out.body[3][ii, jj] = 0.0
        out.body[4][ii, jj] = 0.0
    elseif (status[1] == 1)
        ### New position is overlapping with an existing position ###
        out.body[1][ii, jj] = min(out.body[1][ii, jj], min_h)
        out.body[2][ii, jj] = max(out.body[2][ii, jj], max_h)
    elseif (status[2] == 1)
        ### New position is overlapping with an existing position ###
        out.body[3][ii, jj] = min(out.body[3][ii, jj], min_h)
        out.body[4][ii, jj] = max(out.body[4][ii, jj], max_h)
    elseif (status[1] == 0)
        ### No existing position ###
        out.body[1][ii, jj] = min_h
        out.body[2][ii, jj] = max_h
    elseif (status[2] == 0)
        ### No existing position ###
        out.body[3][ii, jj] = min_h
        out.body[4][ii, jj] = max_h
    else
        ### New position is not overlapping with the two existing positions ###
        # This may be due to an edge case, in that case we try to fix the issue
        # Calculating distance to the two bucket layers
        dist_1b = abs(out.body[1][ii, jj] - max_h)
        dist_1t = abs(min_h - out.body[2][ii, jj])
        dist_3b = abs(out.body[3][ii, jj] - max_h)
        dist_3t = abs(min_h - out.body[4][ii, jj])

        # Checking what bucket layer is closer
        if (min(dist_1b, dist_1t) < min(dist_3b, dist_3t))
            # Merging with first bucket layer
            if (dist_1b < dist_1t)
                # Merging down
                out.body[1][ii, jj] = min_h
            else
                # Merging up
                out.body[2][ii, jj] = max_h
            end
        else
            # Merging with second bucket layer
            if (dist_3b < dist_3t)
                # Merging down
                out.body[3][ii, jj] = min_h
            else
                # Merging up
                out.body[4][ii, jj] = max_h
            end
        end
    end
end
