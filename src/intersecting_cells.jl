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
        out::SimOut{B,I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function moves all soil cells in `terrain` and in `body_soil` that intersect with the
bucket or with another soil cell.

# Note
- This function is intended for internal use only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _move_intersecting_cells!(out)
"""
function _move_intersecting_cells!(
    out::SimOut{B,I,T},
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Moving terrain intersecting with the bucket
    _move_intersecting_body!(out, tol)

    # Moving bucket soil intersecting with the bucket
    _move_intersecting_body_soil!(out, tol)
end

"""
    _move_intersecting_body!(
        out::SimOut{B,I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

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
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _move_intersecting_body!(out)
"""
function _move_intersecting_body!(
    out::SimOut{B,I,T},
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Locating soil cells intersecting with the bucket
    intersecting_cells = _locate_intersecting_cells(out, tol)

    if isempty(intersecting_cells)
        ### No intersecting cells ###
        return
    end

    # Storing all possible directions
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
            ### Intersecting soil column has already been moved ###
            continue
        end

        # Randomizing direction to avoid asymmetry
        shuffle!(directions)

        # Calculating vertical extension of intersecting soil column
        h_soil = out.terrain[ii, jj] - out.body[ind][ii, jj]

        nn = 0
        # Investigating farther and farther until all the soil has been moved
        while (h_soil > tol)
            nn += 1
            # Iterating over the eight lateral directions
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
    _move_intersecting_body_soil!(
        out::SimOut{B,I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function moves the soil cells resting on the bucket that intersect with another bucket
layer. It checks the eight lateral directions surrounding the intersecting soil column and
moves the soil to available spaces.

It is assumed that the adjacent neighbors always have enough space to accomodate the
intersecting soil. This is to avoid the complexity of checking farther cells, which would
require considering the potential presence of bucket walls blocking the movement.

In situations where there is insufficient space to accommodate all the intersecting soil,
the algorithm currently handles it by allowing the excess soil to simply disappear.
This compromise seems to be reasonable as long as the amount of soil disappearing remains
negligible.

# Note
- This function is intended for internal use only.
- This function is a work in progress. Additional modifications may be required to improve
  efficiency and simplicity.
- The order in which the directions are checked is randomized in order to avoid
  asymmetrical results.
- By convention, the soil can be moved from the bucket to the terrain even if the bucket is
  underground.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _move_intersecting_body_soil!(out)
"""
function _move_intersecting_body_soil!(
    out::SimOut{B,I,T},
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Storing all possible directions
    directions = [
        [1, 0], [-1, 0], [0, 1], [0, -1],
        [1, 1], [1, -1], [-1, 1], [-1, -1]
    ]

    # Iterating over bucket soil cells
    for cell in out.body_soil_pos
        ind = cell[1]
        ii = cell[2]
        jj = cell[3]

        if (ind == 1)
            ### First bucket soil layer ###
            ind_t = 3
        else
            ### Second bucket soil layer ###
            ind_t = 1
        end

        if (out.body[ind_t][ii, jj] == 0.0) && (out.body[ind_t+1][ii, jj] == 0.0)
            ### No additionnal bucket layer ###
            continue
        end

        if (
            (out.body_soil[ind+1][ii, jj] - tol > out.body[ind_t][ii, jj]) &&
            (out.body[ind_t+1][ii, jj] - tol > out.body_soil[ind][ii, jj])
        )
            ### Bucket soil intersects with bucket ###
            h_soil = out.body_soil[ind+1][ii, jj] - out.body[ind_t][ii, jj]
        else
            ### No intersection between bucket soil and bucket ###
            continue
        end

        # Randomizing direction to avoid asymmetry
        shuffle!(directions)

        # Iterating over the eight lateral directions
        for xy in directions
            nn = 0
            wall_presence = false
            ind_p = ind
            ind_t_p = ind_t
            

            # Exploring the direction until reaching a wall or all soil has been moved
            while (!wall_presence && h_soil > tol)
                # Calculating considered position
                nn += 1
                ii_n = ii + nn * xy[1]
                jj_n = jj + nn * xy[2]

                # Calculating previous position
                ii_p = ii + (nn - 1) * xy[1]
                jj_p = jj + (nn - 1) * xy[2]
                # Need to update ind_t_p and ind_p as well...

                _move_body_soil!(
                    out, ind_p, ind_t_p, ii_p, jj_p, ii_n, jj_n, h_soil, wall_presence, tol
                )
            end
            if (h_soil < tol)
                ### No more soil to move ###
                break
            end
        end

        if (h_soil > tol)
            @warn "Not all soil intersecting with a bucket layer could be moved\n" *
                "The extra soil has been arbitrarily removed"
        end

        # Updating bucket soil
        out.body_soil[ind+1][ii, jj] = out.body[ind_t][ii, jj]
    end
end

"""
    _locate_intersecting_cells(
        out::SimOut{B,I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function identifies all the soil cells in the `terrain` that intersect with the bucket.

# Note
- This function is intended for internal use only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `Vector{Vector{Int64}}`: Collection of cells indices from the terrain intersecting with
                           the bucket.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _locate_intersecting_cells(out)
"""
function _locate_intersecting_cells(
    out::SimOut{B,I,T},
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

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

function _move_body_soil!(
    out::SimOut{B,I,T},
    ind_p::I,
    ind_t_p::I,
    ii_p::I,
    jj_p::I,
    ii_n::I,
    jj_n::I,
    h_soil::T,
    wall_presence::B,
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

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
    elseif (bucket_absence_1)
        ### Only the second bucket layer ###
        if (out.body[3][ii_n, jj_n] - tol > out.body[ind_p+1][ii_p, jj_p])
            ### Soil avalanche below the second bucket layer to the terrain ###
            # Calculating available space
            delta_h = out.body[3][ii_n, jj_n] - out.terrain[ii_n, jj_n]

            if (delta_h < h_soil)
                ### Not enough space ###
                h_soil -= delta_h
                out.terrain[ii_n, jj_n] += delta_h
                return
            else
                ### More space than soil ###
                out.terrain[ii_n, jj_n] += h_soil
                h_soil = 0.0
                return
            end
        elseif (out.body[4][ii_n, jj_n] + tol > out.body[ind_t_p][ii_p, jj_p])
            ### Bucket is blocking the movement ###
            wall_presence = true
            return
        end

        bucket_soil_presence_3 = (
            (out.body_soil[3][ii_n, jj_n] != 0.0) || (out.body_soil[4][ii_n, jj_n] != 0.0)
        )

        if (
            bucket_soil_presence_3 &&
            (out.body_soil[4][ii_n, jj_n] + tol > out.body[ind_t_p][ii_p, jj_p])
        )
            ### Soil is blocking the movement ###
            return
        end

        # The only option left is that there is space for the intersecting soil
        # Note that there is necessarily enough space for all the soil, otherwise the soil
        # column would block the movement
        if (bucket_soil_presence_3)
            ### Soil should go into the existing bucket soil layer ###
            out.body_soil[4][ii_n, jj_n] += h_soil
        else
            ### Soil should create a new bucket soil layer ###
            out.body_soil[3][ii_n, jj_n] = out.body[4][ii_n, jj_n]
            out.body_soil[4][ii_n, jj_n] = out.body[4][ii_n, jj_n] + h_soil

            # Adding new bucket soil position to body_soil_pos
            push!(out.body_soil_pos, [3; ii_n; jj_n])
        end

        h_soil = 0.0
    elseif (bucket_absence_3)
        ### Only the first bucket layer ###
        if (out.body[1][ii_n, jj_n] - tol > out.body[ind_p+1][ii_p, jj_p])
            ### Soil avalanche below the first bucket layer to the terrain ###
            # Calculating available space
            delta_h = out.body[1][ii_n, jj_n] - out.terrain[ii_n, jj_n]

            if (delta_h < h_soil)
                ### Not enough space ###
                h_soil -= delta_h
                out.terrain[ii_n, jj_n] += delta_h
            else
                ### More space than soil ###
                out.terrain[ii_n, jj_n] += h_soil
                h_soil = 0.0
                return
            end
        elseif (out.body[2][ii_n, jj_n] + tol > out.body[ind_t_p][ii_p, jj_p])
            ### Bucket is blocking the movement ###
            wall_presence = true
            return
        end

        bucket_soil_presence_1 = (
            (out.body_soil[1][ii_n, jj_n] != 0.0) || (out.body_soil[2][ii_n, jj_n] != 0.0)
        )

        if (
            bucket_soil_presence_1 &&
            (out.body_soil[2][ii_n, jj_n] + tol > out.body[ind_t_p][ii_p, jj_p])
        )
            ### Soil is blocking the movement ###
            return
        end

        # The only option left is that there is space for the intersecting soil
        # Note that there is necessarily enough space for all the soil, otherwise the soil
        # column would block the movement
        if (bucket_soil_presence_1)
            ### Soil should go into the existing bucket soil layer ###
            out.body_soil[2][ii_n, jj_n] += h_soil
        else
            ### Soil should create a new bucket soil layer ###
            out.body_soil[1][ii_n, jj_n] = out.body[2][ii_n, jj_n]
            out.body_soil[2][ii_n, jj_n] = out.body[2][ii_n, jj_n] + h_soil

            # Adding new bucket soil position to body_soil_pos
            push!(out.body_soil_pos, [1; ii_n; jj_n])
        end

        h_soil = 0.0
    else
        ### Both bucket layers are present ###
        if (out.body[1][ii_n, jj_n] < out.body[3][ii_n, jj_n])
            ### First layer at bottom ###
            ind_b_n = 1
            ind_t_n = 3
        else
            ### Second layer at bottom ###
            ind_b_n = 3
            ind_t_n = 1
        end

        bucket_soil_presence = (
            (out.body_soil[ind_b_n][ii_n, jj_n] != 0.0) ||
            (out.body_soil[ind_b_n+1][ii_n, jj_n] != 0.0)
        )

        if (bucket_soil_presence)
            ### Bucket soil is present between the two bucket layers ###
            if (out.body_soil[ind_b_n+1][ii_n, jj_n] + tol > out.body[ind_t_n][ii_n, jj_n])
                ### Bucket and soil blocking the movement ###
                return
            elseif (
                out.body_soil[ind_b_n+1][ii_n, jj_n] + tol > out.body[ind_t_p][ii_p, jj_p]
            )
                ### Bucket and soil blocking the movement ###
                return
            end
        else
            if (out.body[ind_b_n+1][ii_n, jj_n] + tol > out.body[ind_t_p][ii_p, jj_p])
                ### Bucket is blocking the movement ###
                wall_presence = true
                return
            end
        end

        # Only option left is that there is some space for the intersecting soil
        if (bucket_soil_presence)
            ### Soil should go into the existing bucket soil layer ###
            # Calculating available space
            delta_h = out.body[ind_t_n][ii_n, jj_n] - out.body_soil[ind_b_n+1][ii_n, jj_n]

            if (delta_h < h_soil)
                ### Not enough space ###
                h_soil -= delta_h

                # Adding soil to the bucket soil layer
                out.body_soil[ind_b_n+1][ii_n, jj_n] += delta_h
            else
                ### More space than soil ###
                # Adding soil to the bucket soil layer
                out.body_soil[ind_b_n+1][ii_n, jj_n] += h_soil

                h_soil = 0.0
            end
        else
            ### Soil should create a new bucket soil layer ###
            # Calculating available space
            delta_h = out.body[ind_t_n][ii_n, jj_n] - out.body[ind_b_n+1][ii_n, jj_n]

            if (delta_h < h_soil)
                ### Not enough space ###
                h_soil -= delta_h

                # Creating a new bucket soil layer
                out.body_soil[ind_b_n][ii_n, jj_n] = out.body[ind_b_n+1][ii_n, jj_n]
                out.body_soil[ind_b_n+1][ii_n, jj_n] = (
                    out.body[ind_b_n+1][ii_n, jj_n] + delta_h
                )

                # Adding new bucket soil position to body_soil_pos
                push!(out.body_soil_pos, [ind_b_n; ii_n; jj_n])
            else
                ### More space than soil ###
                # Creating a new bucket soil layer
                out.body_soil[ind_b_n][ii_n, jj_n] = out.body[ind_b_n+1][ii_n, jj_n]
                out.body_soil[ind_b_n+1][ii_n, jj_n] = (
                    out.body[ind_b_n+1][ii_n, jj_n] + h_soil
                )

                # Adding new bucket soil position to body_soil_pos
                push!(out.body_soil_pos, [ind_b_n; ii_n; jj_n])

                h_soil = 0.0
            end
        end
    end
end
