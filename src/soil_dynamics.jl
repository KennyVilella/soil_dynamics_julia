"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                    Starting implementation of the stepping function                      #
#                                                                                          #
#==========================================================================================#
"""
    soil_dynamics!(
        out::SimOut{B,I,T}, pos::Vector{T}, ori::Quaternion{T}, grid::GridParam{I,T},
        bucket::BucketParam{I,T}, sim::SimParam{I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function is the main entry point for the simulator.
Currently, the function takes the position and orientation of the bucket, calculates all
the cells where the bucket is located and moves the soil resting on the bucket. When a soil
cell in the `terrain` or in `body_soil` intersect with the bucket or with another soil cell,
the soil cell is moved following a set of rules. Lastly, the `terrain` is relaxed in order
to reach a state closer to equilibrium.

# Note
- This function is a work in progress and its current state does not reflect its
  intended use.

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

    soil_dynamics!(out, pos, ori, grid, bucket, sim)
"""
function soil_dynamics!(
    out::SimOut{B,I,T},
    pos::Vector{T},
    ori::Quaternion{T},
    grid::GridParam{I,T},
    bucket::BucketParam{T},
    sim::SimParam{I,T},
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    if (length(pos) != 3)
        throw(DimensionMismatch("position should be a vector of size 3"))
    end

    # Updating bucket position
    _calc_bucket_pos!(out, pos, ori, grid, bucket, 0.5, tol)

    # Updating position of soil resting on the bucket
    _update_body_soil!(out, pos, ori, grid, bucket, tol)

    # Moving intersecting soil cells
    _move_intersecting_cells!(out, grid, tol)

    # Assuming that the terrain is not at equilibrium
    out.equilibrium[1] = false

    # Iterating until equilibrium or the maximum number of iterations is reached
    it = 0
    while (!out.equilibrium[1] && it < sim.max_iterations)
        it += 1

        # Updating impact_area
        out.impact_area[1, 1] = min(out.bucket_area[1, 1], out.relax_area[1, 1])
        out.impact_area[2, 1] = min(out.bucket_area[2, 1], out.relax_area[2, 1])
        out.impact_area[1, 2] = max(out.bucket_area[1, 2], out.relax_area[1, 2])
        out.impact_area[2, 2] = max(out.bucket_area[2, 2], out.relax_area[2, 2])

        # Relaxing the terrain
        _relax_terrain!(out, grid, sim, tol)

        # Relaxing the soil resting on the bucket
        _relax_body_soil!(out, grid, sim, tol)
    end
end
