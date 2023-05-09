"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#
grid_size_x = 1.0
grid_size_y = 1.0
grid_size_z = 1.0
cell_size_xy = 0.1
cell_size_z = 0.1
grid = GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)


#==========================================================================================#
#                                                                                          #
#                                       Benchmarking                                       #
#                                                                                          #
#==========================================================================================#
# Setting benchmarking properties
BenchmarkTools.DEFAULT_PARAMETERS.gcsample = true
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 60
BenchmarkTools.DEFAULT_PARAMETERS.samples = 100

# Benchmarking for _calc_rectangle_pos function
a = [0.0, 0.0, 0.0]
b = [3.0, 0.0, 1.0]
c = [3.0, 2.0, 1.0]
d = [0.0, 2.0, 0.0]
delta = 0.01
println("_calc_rectangle_pos")
display(
    @benchmark rect_pos = _calc_rectangle_pos(a, b, c, d, delta, grid)
)
println("")

# Benchmarking for _decompose_vector_rectangle function
a_ind = [110.0, 110.0, 110.0]
ab_ind = [200.0, 20.0, 0.0]
ad_ind = [35.0, 180.0, 0.0]
area_min_x = 100
area_min_y = 100
area_length_x = 130
area_length_y = 130
delta = 0.01
println("_decompose_vector_rectangle")
display(
    @benchmark c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
            ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
        )
)
println("")

# Benchmarking for _calc_line_pos function
a = [0.34, 0.56, 0.0]
b = [0.74, 0.97, 0.0]
delta = 0.01
println("_calc_line_pos")
display(
    @benchmark line_pos = _calc_line_pos(a, b, delta, grid)
)
println("")
