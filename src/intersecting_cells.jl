"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#   Starting implementation of functions related to the movement of intersecting cells     #
#                                                                                          #
#==========================================================================================#
"""
    _move_intersecting_cells!(
        out::SimOut{I,T}, grid::GridParam{I,T}, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function moves the soil cells that intersect with the bucket or bucket soil.
Since only one bucket is considered, the soil in `body_soil` is currently not moved.
When the simulator supports multiple buckets, this function should account for the possible
intersection between the bucket soil and other buckets.

# Note
- This function is a work in progress.
- This function is intended for internal use only.

# Inputs
- `out::SimOut{Int64,Float64}`: Struct that stores simulation outputs.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _move_intersecting_cells!(out, grid)
"""
function _move_intersecting_cells!(
    out::SimOut{I,T},
    grid::GridParam{I,T},
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Moving terrain intersecting with the bucket
    _move_intersecting_body!(out, grid)
end

"""
    _move_intersecting_body!(
        out::SimOut{I,T}, grid::GridParam{I,T}, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function moves the soil cells in the `terrain` that intersect with a bucket.
It checks the eight lateral directions surrounding the intersecting soil column and moves
the soil to available spaces. If there is insufficient space for all the soil, it
incrementally checks the eight directions farther from the intersecting soil column until
all the soil has been moved. The process can be illustrated as follows

                 ↖   ↑   ↗
                   ↖ ↑ ↗
                 ← ← O → →
                   ↙ ↓ ↘
                 ↙   ↓   ↘

# Note
- This function is intended for internal use only.
- The order in which the directions are checked is randomized in order to avoid
  asymmetrical results.

# Inputs
- `out::SimOut{Int64,Float64}`: Struct that stores simulation outputs.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _move_intersecting_cells!(out, grid)
"""
function _move_intersecting_body!(
    out::SimOut{I,T},
    grid::GridParam{I,T},
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Locating soil cells intersecting with the bucket
    intersecting_cells = _locate_intersecting_cells(out, tol)

    if isempty(intersecting_cells)
        ### No intersecting cells ###
        return
    end

    # Storing all possible direction
    directions = [
        [1, 0], [-1, 0], [0, 1], [0, -1],
        [1, 1], [1, -1], [-1, 1], [-1, -1]
    ]

    # Iterating over intersecting cells
    for cell in intersecting_cells
        ind = cell[1]
        ii = cell[2]
        jj = cell[3]

        if (out.terrain[ii, jj] - tol < out.body[ind][ii, jj])
            ### Intersecting cells have already been moved ###
            continue
        end

        # Randomizing direction to avoid asymmetry
        shuffle!(directions)

        # Calculating vertical extension of intersecting soil column
        h_soil = out.terrain[ii, jj] - out.body[ind][ii, jj]

        nn = 0
        while (h_soil > tol)
            nn += 1
            for xy in directions
                # Calculating considered position
                ii_n = ii + xy[1] * nn
                jj_n = jj + xy[2] * nn

                # Determining presence of bucket
                bucket_absence_1 = (
                    (out.body[1][ii_n, jj_n] == 0.0) && (out.body[2][ii_n, jj_n] == 0.0)
                )
                bucket_absence_3 = (
                    (out.body[3][ii_n, jj_n] == 0.0) && (out.body[4][ii_n, jj_n] == 0.0)
                )

                if (bucket_absence_1 && bucket_absence_3)
                    ### No bucket ###
                    out.terrain[ii_n, jj_n] += h_soil
                    h_soil = 0.0
                else
                    ### Bucket is present ###
                    # Calculating minimum height of bucket
                    if (bucket_absence_1)
                        bucket_bot = out.body[3][ii_n, jj_n]
                    elseif (bucket_absence_3)
                        bucket_bot = out.body[1][ii_n, jj_n]
                    else
                        bucket_bot = min(out.body[1][ii_n, jj_n], out.body[3][ii_n, jj_n])
                    end

                    if out.terrain[ii_n, jj_n] + tol < bucket_bot
                        ### Space under the bucket ###
                        # Calculating available space
                        delta_h = bucket_bot - out.terrain[ii_n, jj_n]

                        if (delta_h < h_soil)
                            ### Not enough space ###
                            out.terrain[ii_n, jj_n] = bucket_bot
                            h_soil -= delta_h
                        else
                            ### More space than soil ###
                            out.terrain[ii_n, jj_n] += h_soil
                            h_soil = 0.0
                        end
                    end
                end
            end
        end

        # Removing intersecting soil
        out.terrain[ii, jj] = out.body[ind][ii, jj]
    end
end

"""
    _locate_intersecting_cells(
        out::SimOut{I,T}, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function identifies all the soil cells in the `terrain` that intersect with the bucket.

# Note
- This function is intended for internal use only.

# Inputs
- `out::SimOut{Int64,Float64}`: Struct that stores simulation outputs.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `Vector{Vector{Int64}}`: Collection of cells indices from the terrain intersecting with
                           the bucket.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _locate_intersecting_cells!(out)
"""
function _locate_intersecting_cells(
    out::SimOut{I,T},
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Initializing
    intersecting_cells = Vector{Vector{I}}()

    # Locating all non-zero values in body
    body_pos = _locate_all_non_zeros(out.body)

    # Iterating over all bucket position
    for cell in body_pos
        if (out.terrain[cell[2], cell[3]] - tol > out.body[cell[1]][cell[2], cell[3]])
            ### Soil intersecting with the bucket ###
            push!(intersecting_cells, cell)
        end
    end

    return intersecting_cells
end
