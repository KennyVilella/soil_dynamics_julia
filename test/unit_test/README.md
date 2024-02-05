# Description of unit tests

## Introduction

The description for all unit tests are given below separated by files and functions.
The order in which the unit tests appear in this file is consistent with the order in which they are run, and this order is selected such as the fucntionalities of the simulator are tested step by step.
This helps to identify more precisely the location of potential bugs.

Note that a custom name is associated with each unit test in order to make their identification easier.

## `test_types.jl`

This file implements unit tests for the structs in the `types.jl` file.
It should be tested first as mostly all functions in the simulator rely on these structs.

### `GridParam`

Unit tests for the `GridParam` struct and its inner constructor.

| Test name | Description of the unit test                                                             |
| --------- | ---------------------------------------------------------------------------------------- |
| TY-G-1    | Testing that all members of the `GridParam` struct are present and properly initialized. |
| TY-G-2    | Testing that an exception is raised when `cell_size_z <= 0.0`.                           |
| TY-G-3    | Testing that an exception is raised when `cell_size_xy <= 0.0`.                          |
| TY-G-4    | Testing that an exception is raised when `grid_size_x <= 0.0`.                           |
| TY-G-5    | Testing that an exception is raised when `grid_size_y <= 0.0`.                           |
| TY-G-6    | Testing that an exception is raised when `grid_size_z <= 0.0`.                           |
| TY-G-7    | Testing that an exception is raised when `cell_size_z > cell_size_xy`.                   |
| TY-G-8    | Testing that an exception is raised when `grid_size_x < cell_size_xy`.                   |
| TY-G-9    | Testing that an exception is raised when `grid_size_y < cell_size_xy`.                   |
| TY-G-10   | Testing that an exception is raised when `grid_size_z < cell_size_z`.                    |

### `BucketParam`

Unit tests for the `BucketParam` struct and its inner constructor.

| Test name | Description of the unit test                                                               |
| --------- | ------------------------------------------------------------------------------------------ |
| TY-Bu-1   | Testing that all members of the `BucketParam` struct are present and properly initialized. |
| TY-Bu-2   | Testing that an exception is raised when size of `o_pos_init` is not 3.                    |
| TY-Bu-3   | Testing that an exception is raised when size of `j_pos_init` is not 3.                    |
| TY-Bu-4   | Testing that an exception is raised when size of `b_pos_init` is not 3.                    |
| TY-Bu-5   | Testing that an exception is raised when size of `t_pos_init` is not 3.                    |
| TY-Bu-6   | Testing that an exception is raised when `j_pos_init` and `b_pos_init` are the same.       |
| TY-Bu-7   | Testing that an exception is raised when `j_pos_init` and `t_pos_init` are the same.       |
| TY-Bu-8   | Testing that an exception is raised when `b_pos_init` and `t_pos_init` are the same.       |
| TY-Bu-9   | Testing that an exception is raised when `bucket_width <= 0.0`.                            |

### `SimParam`

Unit tests for the `SimParam` struct and its inner constructor.

| Test name | Description of the unit test                                                            |
| --------- | --------------------------------------------------------------------------------------- |
| TY-SP-1   | Testing that all members of the `SimParam` struct are present and properly initialized. |
| TY-SP-2   | Testing that an exception is raised when `repose_angle > pi/2` or `repose_angle < 0.0`. |
| TY-SP-3   | Testing that an exception is raised when `max_iterations <= 0.0`.                       |
| TY-SP-4   | Testing that an exception is raised when `cell_buffer < 2`.                             |

### `SimOut`

Unit tests for the `SimOut` struct and its inner constructor.

| Test name | Description of the unit test                                                                         |
| --------- | ---------------------------------------------------------------------------------------------------- |
| TY-SO-1   | Testing that all members of the `SimOut` struct are present and properly initialized.                |
| TY-SO-2   | Testing that an exception is raised when the size of `terrain` is not consistent with the grid size. |

## `test_utils.cpp`

This file implements unit tests for the functions in the `utils.cpp` file.
It should be tested before the main functionalities of the simulator since the utility functions are used throughout the simulator.

### `_calc_bucket_corner_pos`

Unit tests for the `_calc_bucket_corner_pos` function.

| Test name | Description of the unit test                                              |
| --------- | ------------------------------------------------------------------------- |
| UT-CBC-1  | Testing for a bucket in its reference pose.                               |
| UT-CBC-2  | Testing for a bucket with a simple translation applied.                   |
| UT-CBC-3  | Testing for a bucket with a simple rotation applied.                      |
| UT-CBC-4  | Testing for a bucket with both a simple rotation and translation applied. |

### `check_bucket_movement`

Unit tests for the `check_bucket_movement` function.

| Test name | Description of the unit test                                                    |
| --------- | ------------------------------------------------------------------------------- |
| UT-CBM-1  | Testing for a one cell translation following the X axis.                        |
| UT-CBM-2  | Testing for an arbitrary translation.                                           |
| UT-CBM-3  | Testing for a 8 degrees rotation around the Y axis.                             |
| UT-CBM-4  | Testing for a 8 degrees rotation around the Y axis combined with a half cell translation following the X axis. |
| UT-CBM-5  | Testing for a translation much shorter than the cell size following the X axis. |
| UT-CBM-6  | Testing for an arbitrary translation much shorter than cell size.               |
| UT-CBM-7  | Testing for a 0.33 degree rotation around the Y axis.                           |
| UT-CBM-8  | Testing for a 0.33 degree rotation around the Y axis combined with a translation much shorter than the cell size following the X axis. |
| UT-CBM-9  | Testing that a warning is issued for a large movement.                          |

### `_init_sparse_array!`

Unit tests for the `_init_sparse_array!` function.

| Test name | Description of the unit test                                     |
| --------- | ---------------------------------------------------------------- |
| UT-IS-1   | Testing that non zeros values of `body` are properly reset.      |
| UT-IS-2   | Testing that non zeros values of `body_soil` are properly reset. |

### `_locate_non_zeros`

Unit tests for the `_locate_non_zeros` function.

| Test name | Description of the unit test                                      |
| --------- | ----------------------------------------------------------------- |
| UT-LN-1   | Testing that non-empty value in `body` are properly located.      |
| UT-LN-2   | Testing that zero values in `body` are properly ignored.          |
| UT-LN-3   | Testing that non-empty value in `body_soil` are properly located. |
| UT-LN-4   | Testing that zero values in `body_soil` are properly ignored.     |

### `_locate_all_non_zeros`

Unit tests for the `_locate_all_non_zeros` function.

| Test name | Description of the unit test                                                                     |
| --------- | ------------------------------------------------------------------------------------------------ |
| UT-LA-1   | Testing that all non-empty value in `body` are properly located for various configurations.      |
| UT-LA-2   | Testing that all zero values in `body` are properly ignored.                                     |
| UT-LA-3   | Testing that all non-empty value in `body_soil` are properly located for various configurations. |
| UT-LA-4   | Testing that all zero values in `body_soil` are properly ignored.                                |

### `calc_normal`

Unit tests for the `calc_normal` function.
Note that for each unit test, two different input orders are investigated in order to ensure that the direction of the normal is properly calculated.

| Test name | Description of the unit test                                                                   |
| --------- | ---------------------------------------------------------------------------------------------- |
| UT-CN-1   | Testing for a triangle in the XY plane resulting in a unit normal vector following the Z axis. |
| UT-CN-2   | Testing for a triangle in the XZ plane resulting in a unit normal vector following the Y axis. |
| UT-CN-3   | Testing for a triangle in the YZ plane resulting in a unit normal vector following the X axis. |
| UT-CN-4   | Testing for a triangle in a 45 degrees inclined plane resulting in unit normal vector with a 45 degrees slope in the three axis. |

### `set_RNG_seed!`

Unit tests for the `set_RNG_seed!` function.
As it is difficult to retrieve the seed, instead of checking that the seed is properly set, we rather test the reproducibility of the result.

| Test name | Description of the unit test                                       |
| --------- | ------------------------------------------------------------------ |
| UT-SR-1   | Testing with the default seed that the results are reproducible.   |
| UT-SR-2   | Testing with an aribitrary seed that the results are reproducible. |

### `_calc_bucket_frame_pos`

Unit tests for the `_calc_bucket_frame_pos` function.

| Test name | Description of the unit test                                       |
| --------- | ------------------------------------------------------------------ |
| UT-CBF-1  | Testing for a bucket in its reference position and orientation. Input cell has an arbitrary position. |
| UT-CBF-2  | Testing for a bucket in its reference orientation and an arbitrary position. Input cell has an arbitrary position. |
| UT-CBF-3  | Testing for a bucket in its reference position and rotated by pi/2 around the Z axis. Input cell has an arbitrary position. |
| UT-CBF-4  | Testing for a bucket in its reference position and rotated by pi/2 around the Y axis. Input cell has an arbitrary position. |
| UT-CBF-5  | Testing for a bucket in its reference position and rotated by pi/2 around the X axis. Input cell has an arbitrary position. |
| UT-CBF-6  | Testing for a bucket rotated by pi/2 around the Z axis and an arbitrary position. Input cell has an arbitrary position. |

### `check_volume`

Unit tests for the `check_volume` function.
Note that for unit tests 1 to 3, results with correct and incorrect initial volumes are investigated to ensure that warning is sent only when an inconsistent initial volume is given.

| Test name | Description of the unit test                                       |
| --------- | ------------------------------------------------------------------ |
| UT-CV-1   | Testing with a `terrain` everywhere at 0.0 and no `body_soil`.   |
| UT-CV-2   | Testing with a `terrain` everywhere at 0.0 except at one location and no `body_soil`. |
| UT-CV-3   | Testing with a `terrain` everywhere at 0.0 and some `body_soil` present at various locations. |
| UT-CV-4   | Testing with the setup of UT-CV-3 that inconsistent amount of soil in `body_soil_pos` results into a warning. It can be either not enough or too much soil. |

### `check_soil`

Unit tests for the `check_soil` function.
The unit tests 1 to 4 correspond to the building of the environment setup.
The subsequent unit tests check that improper environment setup yields a warning.
At the end of each unit test, the environment is set to a proper setup and it is checked that no warning is sent.

| Test name | Description of the unit test                                          |
| --------- | --------------------------------------------------------------------- |
| UT-CS-1   | Testing when everything is at zero.                                   |
| UT-CS-2   | Testing for an arbitrary `terrain` setup.                             |
| UT-CS-3   | Testing for an arbitrary `terrain` and `body` setup.                  |
| UT-CS-4   | Testing for an arbitrary `terrain`, `body`, and `body_soil` setup.    |
| UT-CS-5   | Testing when the `terrain` is above the `body`.                       |
| UT-CS-6   | Testing when `body` is not set properly, that is the maximum height of a body layer is not strictly higher than its minimum height. |
| UT-CS-7   | Testing when `body_soil` is not set properly, that is the maximum height of a body soil layer is not strictly higher than its minimum height. |
| UT-CS-8   | Testing when `body` is intersecting with its `body_soil`.                                   |
| UT-CS-9   | Testing when there is a gap between `body` and `body_soil`.                                 |
| UT-CS-10  | Testing when `body_soil` is present but `body` is not present.                              |
| UT-CS-11  | Testing when two `body` layers are intersecting.                                            |
| UT-CS-12  | Testing when the `body_soil` on the bottom layer is intersecting with the top `body` layer. |
