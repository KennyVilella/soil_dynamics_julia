module SoilDynamics

import LinearAlgebra: cross, norm
import ReferenceFrameRotations: vect, Quaternion
import SparseArrays: SparseMatrixCSC, spzeros, droptol!

# soil_dynamics.jl
export soil_dynamics!

# types.jl
export GridParam, BucketParam, SimOut

# bucket.jl
export _calc_bucket_pos!
export _init_body!, _update_body!, _include_new_body_pos!
export _calc_rectangle_pos, _calc_triangle_pos, _calc_line_pos
export _decompose_vector_rectangle, _decompose_vector_triangle

# utils.jl
export calc_normal

# Files
include("types.jl")
include("bucket.jl")
include("soil_dynamics.jl")
include("utils.jl")

end
