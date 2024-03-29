module SoilDynamics

import DelimitedFiles: writedlm
import LinearAlgebra: cross, norm
import Random: seed!, shuffle!
import ReferenceFrameRotations: vect, Quaternion, inv_rotation
import SparseArrays: SparseMatrixCSC, spzeros, droptol!, nzrange, rowvals

# soil_dynamics.jl
export soil_dynamics!

# types.jl
export GridParam, BucketParam, SimParam, SimOut, BodySoil

# bucket.jl
export _calc_bucket_pos!
export _update_body!, _include_new_body_pos!
export _calc_rectangle_pos, _calc_triangle_pos, _calc_line_pos
export _decompose_vector_rectangle, _decompose_vector_triangle

# body_soil.jl
export _update_body_soil!

# intersecting_cells.jl
export _move_intersecting_cells!
export _move_intersecting_body_soil!, _move_body_soil!
export _move_intersecting_body!, _locate_intersecting_cells

# relax.jl
export _relax_terrain!, _relax_body_soil!
export _locate_unstable_terrain_cell
export _check_unstable_terrain_cell, _relax_unstable_terrain_cell!
export _check_unstable_body_cell, _relax_unstable_body_cell!

# utils.jl
export _calc_bucket_corner_pos, check_bucket_movement, _calc_bucket_frame_pos
export _locate_all_non_zeros, _locate_non_zeros, _init_sparse_array!
export calc_normal, set_RNG_seed!
export check_volume, check_soil
export write_bucket, write_soil, _write_vector

# Files
include("types.jl")
include("bucket.jl")
include("body_soil.jl")
include("intersecting_cells.jl")
include("relax.jl")
include("soil_dynamics.jl")
include("utils.jl")

end
