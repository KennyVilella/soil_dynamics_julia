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
        pos::Vector{T}, ori::Quaternion{T}, grid::GridParam{I,T},
        bucket::BucketParam{I,T}, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function is the main entry point for the simulator. 
Currently, the function takes the position and orientation of the bucket and calculates
all the cells where the bucket is located. The position of the soil resting on the bucket
is updated following the bucket movement.

# Note
- This function is a work in progress and its current state does not reflect its
  intended use.

# Inputs
- `pos::Vector{Float64}`: Cartesian coordinates of the bucket origin. [m]
- `ori::Quaternion{Float64}`: Orientation of the bucket. [Quaternion]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `bucket::BucketParam{Float64}`: Struct that stores information related to the
                                  bucket object.
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

    soil_dynamics!(pos, ori, grid, bucket)
"""
function soil_dynamics!(
    pos::Vector{T},
    ori::Quaternion{T},
    grid::GridParam{I,T},
    bucket::BucketParam{T},
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    if (length(pos) != 3)
        throw(DimensionMismatch("position should be a vector of size 3"))
    end

    # Updating bucket position
    _calc_bucket_pos!(out, pos, ori, grid, bucket)

    # Updating position of soil resting on the bucket
    _update_body_soil!(out, pos, ori, grid, bucket)
end
