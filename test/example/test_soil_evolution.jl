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
random_trajectory = false
set_RNG = true
writing_bucket_files = true
writing_soil_files = true

# Launching the example script
soil_evolution(
    writing_bucket_files, writing_soil_files, random_trajectory, set_RNG
)
