"""
Copyright, 2023,  Vilella Kenny.
"""

include("soil_evolution.jl")
#==========================================================================================#
#                                                                                          #
#                               Running the example script                                 #
#                                                                                          #
#==========================================================================================#
# Setting parameters
debug = true
random_trajectory = false
set_RNG = true
writing_bucket_files = false
writing_soil_files = false

# Launching the example script
soil_evolution(
    debug, writing_bucket_files, writing_soil_files, random_trajectory, set_RNG
)
