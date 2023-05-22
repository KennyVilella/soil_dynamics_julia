"""
Copyright, 2023,  Vilella Kenny.
"""

using SoilDynamics
import LinearAlgebra: norm
import ReferenceFrameRotations: vect, angle_to_quat
import Interpolations: LinearInterpolation
import Logging
#==========================================================================================#
#                                                                                          #
#            Starting implementation of an example script to run the simulator             #
#                                                                                          #
#==========================================================================================#
"""
    soil_evolution(
        writing_bucket_files::B=false, writing_soil_files::B=false,
        random_trajectory::B=false, set_RNG::B=false, tol::T=1e-8
    ) where {B<:Bool,T<:Float64}

This function provides an example script to run the simulator.
The example simulates a bucket performing a simple digging scoop in the XZ plane following a
parabolic trajectory. There is an option to randomize the parabolic trajectory by selecting
the initial position (`x_i`, `z_i`) of the bucket and the deepest point of the scoop
(`x_min`, `z_min`) wihtin reasonable ranges.

# Note
- This function is a work in progress.
- The parabolic trajectory assumes that the orientation of the bucket follows the gradient
  of the trajectory. While it may not be fully accurate, it provides a good approximation
  for testing the simulator.
- The stepping should be such that the bucket is moving less than two cells between steps.

# Inputs
- `writing_bucket_files::Bool`: Indicates whether the six bucket corners are written into
                                a file at every step.
- `writing_soil_files::Bool`: Indicates whether the terrain heightmap is written into
                              a file at every step.
- `random_trajectory::Bool`: Indicates whether the default trajectory or a randomized one
                             is used.
- `set_RNG::Bool`: Indicates whether the RNG seed is set or not.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    soil_evolution(false, false, true, false)
"""
function soil_evolution(
    writing_bucket_files::B=false,
    writing_soil_files::B=false,
    random_trajectory::B=false,
    set_RNG::B=false,
    tol::T=1e-8
) where {B<:Bool,T<:Float64}

    if (set_RNG)
        ### RNG seed is set ###
        set_RNG_seed!()
    end

    # Initializing the bucket geometry
    o_pos_init = Vector{Float64}([0.0, 0.0, 0.0])
    j_pos_init = Vector{Float64}([0.0, 0.0, 0.0])
    b_pos_init = Vector{Float64}([0.0, 0.0, -0.5])
    t_pos_init = Vector{Float64}([0.7, 0.0, -0.5])
    bucket_width = 0.5

    # BucketParam struct
    bucket = BucketParam(
        o_pos_init, j_pos_init, b_pos_init, t_pos_init, bucket_width, 
    )

    # Initializing the grid geometry
    grid_size_x = 4.0
    grid_size_y = 4.0
    grid_size_z = 4.0
    cell_size_xy = 0.05
    cell_size_z = 0.05

    # GridParam struct
    grid = GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)

    # Initializing terrain array to zero height
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)

    # SimOut struct
    out = SimOut(terrain, grid)

    if (random_trajectory)
        ### Random parabolic trajectory ###
        # Calculating random parameters within a certain range
        x_i = -3.0 + 2.0 * rand() # Between [-3.0, -1.0]
        z_i = 0.5 + 1.5 * rand() # Between [0.5, 2.0]
        x_min = -0.5 * rand() # Between [-0.5, 0.5]
        z_min = -2.0 * rand() # Between [-2.0, 0.0]

        # Creating the trajectory
        pos, ori = _calc_trajectory(x_i, z_i, x_min, z_min, 100)
    else
        ### Default parabolic trajectory ###
        pos, ori = _calc_trajectory(-2.0, 1.5, 0.1, -0.5, 100)
    end

    # Initializing bucket corner position vectors
    j_r_pos = Vector{Vector{Float64}}()
    j_l_pos = Vector{Vector{Float64}}()
    b_r_pos = Vector{Vector{Float64}}()
    b_l_pos = Vector{Vector{Float64}}()
    t_r_pos = Vector{Vector{Float64}}()
    t_l_pos = Vector{Vector{Float64}}()

    # Iterating over bucket trajectory
    for ii in 1:length(pos)
        # Converting orientation to quaternion
        ori_i = angle_to_quat(-ori[ii][1], -ori[ii][2], -ori[ii][3], :ZYX)

        # Calculating position of bucket points
        j_pos = Vector{Float64}(pos[ii] + vect(ori_i \ j_pos_init * ori_i))
        b_pos = Vector{Float64}(pos[ii] + vect(ori_i \ b_pos_init * ori_i))
        t_pos = Vector{Float64}(pos[ii] + vect(ori_i \ t_pos_init * ori_i))

        # Calculating lateral vector of the bucket
        normal_side = calc_normal(j_pos, b_pos, t_pos)
        half_width = 0.5 * bucket_width * normal_side

        # Populating position of the bucket corners
        push!(j_r_pos, j_pos + half_width)
        push!(j_l_pos, j_pos - half_width)
        push!(b_r_pos, b_pos + half_width)
        push!(b_l_pos, b_pos - half_width)
        push!(t_r_pos, t_pos + half_width)
        push!(t_l_pos, t_pos - half_width)
    end

    # Setting time vector
    total_time = 8.0
    dt = 0.2
    time_vec = LinRange(0.0, total_time, length(pos))

    # Setting pose interpolator
    pos_interp = LinearInterpolation(time_vec, pos)
    ori_interp = LinearInterpolation(time_vec, ori)
    j_r_pos_interp = LinearInterpolation(time_vec, j_r_pos)
    j_l_pos_interp = LinearInterpolation(time_vec, j_l_pos)
    b_r_pos_interp = LinearInterpolation(time_vec, b_r_pos)
    b_l_pos_interp = LinearInterpolation(time_vec, b_l_pos)
    t_r_pos_interp = LinearInterpolation(time_vec, t_r_pos)
    t_l_pos_interp = LinearInterpolation(time_vec, t_l_pos)

    # Initializing
    pos_vec = [pos[1]]
    ori_vec = [angle_to_quat(-ori[1][1], -ori[1][2], -ori[1][3], :ZYX)]
    time_vec = []
    dt_i = dt
    time = dt

    # Creating time evolution
    while (time + dt_i < total_time)
       # Adding time to time vector
       push!(time_vec, time)

       # Adding position and orientation
       append!(pos_vec, [pos_interp(time)])
       ori_i = ori_interp(time)
       append!(ori_vec, [angle_to_quat(-ori_i[1], -ori_i[2], -ori_i[3], :ZYX)])

       # Calculating velocity at bucket corners
       j_l_vel = norm(_calc_vel(
          j_l_pos_interp(time + 0.5 * dt_i), j_l_pos_interp(time - 0.5 * dt_i), dt_i
       ))
       j_r_vel = norm(_calc_vel(
          j_r_pos_interp(time + 0.5 * dt_i), j_r_pos_interp(time - 0.5 * dt_i), dt_i
       ))
       b_l_vel = norm(_calc_vel(
          b_l_pos_interp(time + 0.5 * dt_i), b_l_pos_interp(time - 0.5 * dt_i), dt_i
       ))
       b_r_vel = norm(_calc_vel(
          b_r_pos_interp(time + 0.5 * dt_i), b_r_pos_interp(time - 0.5 * dt_i), dt_i
       ))
       t_l_vel = norm(_calc_vel(
          t_l_pos_interp(time + 0.5 * dt_i), t_l_pos_interp(time - 0.5 * dt_i), dt_i
       ))
       t_r_vel = norm(_calc_vel(
          t_r_pos_interp(time + 0.5 * dt_i), t_r_pos_interp(time - 0.5 * dt_i), dt_i
       ))

       # Calculating the maximum velocity of the bucket
       max_bucket_vel = maximum([
           j_l_vel, j_r_vel, b_l_vel, b_r_vel, t_l_vel, t_r_vel
       ])

       if (max_bucket_vel != 0.0)
           ### Bucket is moving ###
           dt_i = grid.cell_size_xy / max_bucket_vel
       else
           ### No bucket movement ###
           dt_i = dt
       end

       if (dt_i > dt)
           ### Bucket is moving very slowly ###
           time += dt
       else
           ### Bucket is mobing ###
           time += dt_i
       end
    end

    # Adding final step
    push!(time_vec, total_time)
    append!(pos_vec, [pos[end]])
    append!(ori_vec, [angle_to_quat(-ori[end][1], -ori[end][2], -ori[end][3], :ZYX)])

    # Starting the evolution loop
    for ii in 1:length(time_vec)
        @info "Step " * string(ii) * "/" * string(length(time_vec))

        # Stepping the soil dynamics
        soil_dynamics!(out, pos_vec[ii], ori_vec[ii], grid, bucket, tol)

        if (writing_bucket_files)
            ### Writing files giving the bucket position ###
            write_bucket(bucket)
        end

        if (writing_soil_files)
            ### Writing files giving the terrain height ###
            write_soil(out, grid)
        end
    end
end

"""
    _calc_vel(
        pos_1::Vector{T}, pos_2::Vector{T}, dt::T
    ) where {T<:Float64}

This function calculates the velocity of an object given its position (`pos_1`) at
`t = t_i` and its position (`pos_2`) at `t = t_i + dt`.

# Note
- This function is intended for internal use only.

# Inputs
- `pos_1::Vector{Float64}`: Cartesian coordinates of the object at `t = t_i`. [m]
- `pos_2::Vector{Float64}`: Cartesian coordinates of the object at `t = t_i + dt`. [m]
- `dt::Float64`: Time difference between the two positions. [s]

# Outputs
- `Vector{Float64}`: Velocity of the object. [m/s]

# Example

    _calc_vel([0.1, 0.0, 0.2], [0.15, 0.0, 0.25], 0.05)
"""
function _calc_vel(
    pos_1::Vector{T},
    pos_2::Vector{T},
    dt::T
) where {T<:Float64}

    return (pos_2 - pos_1) / dt
end

"""
    _calc_trajectory(
        x_i::T, z_i::T, x_min::T, z_min::T, nn::I
    ) where {I<:Int64,T<:Float64}

This function calculates a parabolic trajectory given the starting position (`x_i`, `z_i`)
and the deepest position (`x_min`, `z_min`) of the trajectory.
The parabolic trajectory is described by

    z(x) = a * x * x + b * x + c.

Knowing that at the starting position

    z(x_i) = z_i

and that at the deepest point of the trajectory

    dz(x_min) / dx = 0.0
    z(x_min) = z_min,

it is possible to calculate the three parameters (a, b, c) of the parabolic equation.
The orientation is assumed to be equal to the gradient of the trajectory. This implies
that the bucket teeth would follow the movement, so that it can somewhat replicate an
actual digging scoop.

# Note
- This function is intended for internal use only.

# Inputs
- `x_i::Float64`: X coordinate of the starting position of the trajectory. [m]
- `z_i::Float64`: Z coordinate of the starting position of the trajectory. [m]
- `x_min::Float64`: X coordinate of the deepest position of the trajectory. [m]
- `z_min::Float64`: Z coordinate of the deepest position of the trajectory. [m]
- `nn::Int64`: Number of increments in the trajectory.

# Outputs
- `Vector{Vector{Float64}}`: Aggregates the position of the bucket with time. [m]
- `Vector{Quaternion{Float64}}`: Aggregates the orientation of the bucket with time.
                                 [Quaternion]

# Example

    _calc_trajectory(-1.5, 0.5, 0.0, -0.7, 100)
"""
function _calc_trajectory(
    x_i::T,
    z_i::T,
    x_min::T,
    z_min::T,
    nn::I
) where {I<:Int64,T<:Float64}

    # Calculating X vector of the trajectory
    x_vec = range(x_i, x_i + 2 * (x_min - x_i), nn)

    # Calculating factor of the parabolic function
    b = 2 * x_min * (z_min - z_i) / ((x_i - x_min) * (x_i - x_min))

    if (x_min == 0)
        a = (zi - zm) / (xi * xi)
        b = 0.0
        c = zm
    else
        b = 2 * x_min * (z_min - z_i) / ((x_i - x_min) * (x_i - x_min))
        a = -b / (2 * x_min)
        c = z_min + b * b / (4 * a)
    end

    # Initializing trajectory vector
    pos = [[x_i, 0.0, z_i]]
    ori = [[0.0, atan((2 * a * x_i) / x_i), 0.0]]

    # Creating trajectory
    for x in x_vec
        # Calculating the trajectory following a parabole
        append!(pos, [[x, 0.0, a * x * x + b * x + c]])

        # Calculating orientation following the gradient of the trajectory
        append!(ori, [[0.0, atan((2 * a * x) / x), 0.0]])
    end

    return pos, ori
end
