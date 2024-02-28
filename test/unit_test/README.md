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

## `test_bucket.cpp`

This file implements unit tests for the functions in the `bucket_pos.cpp` file.

### `_calc_line_pos`

Unit tests for the `_calc_line_pos` function.
Note that the `_calc_line_pos` function does not account well for the case where the line follows a cell border.
It is therefore necessary to solve this potential ambiguity before calling the function.
As a result, a small increment (`1e-8`) is added or removed to the input in order to make sure that the input coordinates do not correspond to a cell border.

For each case, some tests are present to check that the results do not depend on the order where the line vertices are given to the function.

| Test name | Description of the unit test                                                          |
| --------- | ------------------------------------------------------------------------------------- |
| BP-CL-1   | Testing with a line following the X axis.                                             |
| BP-CL-2   | Testing that rounding is done properly with a line following the X axis.              |
| BP-CL-3   | Testing with a line following the Y axis.                                             |
| BP-CL-4   | Testing with an arbitrary line in the XY plane. Results were obtained with a drawing. |
| BP-CL-5   | Testing with an arbitrary line in the XZ plane. Results were obtained with a drawing. |
| BP-CL-6   | Testing the edge case where the line is a point.                                      |

### `_decompose_vector_rectangle`

Unit tests for the `_decompose_vector_rectangle` function.

| Test name | Description of the unit test                                                        |
| --------- | ----------------------------------------------------------------------------------- |
| BP-DVR-1  | Testing with a simple rectangle in the XY plane.                                    |
| BP-DVR-2  | Testing that rounding is done properly with a simple rectangle in the XY plane.     |
| BP-DVR-3  | Testing with an arbitrary rectangle. Results were obtained with a drawing.          |
| BP-DVR-4  | Testing the edge case where the rectangle is a line. No decomposition can be made.  |
| BP-DVR-5  | Testing the edge case where the rectangle is a point. No decomposition can be made. |

### `_decompose_vector_triangle`

Unit tests for the `_decompose_vector_triangle` function.

| Test name | Description of the unit test                                                       |
| --------- | ---------------------------------------------------------------------------------- |
| BP-DVT-1  | Testing with a simple triangle in the XY plane.                                    |
| BP-DVT-2  | Testing that rounding is done properly with a simple triangle in the XY plane.     |
| BP-DVT-3  | Testing with an arbitrary triangle. Results were obtained with a drawing.          |
| BP-DVT-4  | Testing the edge case where the triangle is a line. No decomposition can be made.  |
| BP-DVT-5  | Testing the edge case where the triangle is a point. No decomposition can be made. |

### `_calc_rectangle_pos`

Unit tests for the `_calc_rectangle_pos` function.
Note that the `_calc_rectangle_pos` function does not account for the case where the rectangle follows a cell border.
It is therefore necessary to solve this potential ambiguity before calling the function.
As a result, a small increment (`1e-8`) is added or removed to the input in order to make sure that the input coordinates do not correspond to a cell border.

For each case, some tests are present to check that the results do not depend on the order where the rectangle vertices are given to the function.

| Test name | Description of the unit test                                               |
| --------- | -------------------------------------------------------------------------- |
| BP-CR-1   | Testing with a simple rectangle in the XY plane.                           |
| BP-CR-2   | Testing with a simple rectangle in the XZ plane.                           |
| BP-CR-3   | Testing with an arbitrary rectangle. Results were obtained with a drawing. |
| BP-CR-4   | Testing the edge case where the rectangle is a line.                       |
| BP-CR-5   | Testing the edge case where the rectangle is a point.                      |

### `_calc_triangle_pos`

Unit tests for the `_calc_triangle_pos` function.
Note that the `_calc_triangle_pos` function does not account for the case where the triangle follows a cell border.
It is therefore necessary to solve this potential ambiguity before calling the function.
As a result, a small increment (between `1e-8` and `1e-3`) is added or removed to the input in order to make sure that the input coordinates do not correspond to a cell border.

For each case, some tests are present to check that the results do not depend on the order where the triangle vertices are given to the function.

| Test name | Description of the unit test                                              |
| --------- | ------------------------------------------------------------------------- |
| BP-CT-1   | Testing with a simple triangle in the XY plane.                           |
| BP-CT-2   | Testing with a simple triangle in the XZ plane.                           |
| BP-CT-3   | Testing with an arbitrary triangle. Results were obtained with a drawing. |
| BP-CT-4   | Testing the edge case where the triangle is a line.                       |
| BP-CT-5   | Testing the edge case where the triangle is a point.                      |

### `_include_new_body_pos!`

Unit tests for the `_include_new_body_pos!` function.

| Test name | Description of the unit test                                                                       |
| --------- | -------------------------------------------------------------------------------------------------- |
| BP-INB-1  | Testing to add a new body position where there is no existing position.                            |
| BP-INB-2  | Testing to add a new body position distinct from the existing position on the first bucket layer.  |
| BP-INB-3  | Testing to add a new body position distinct from the existing position on the second bucket layer. |
| BP-INB-4  | Testing to add a new body position overlapping with the top of an existing position on the second bucket layer. |
| BP-INB-5  | Testing to add a new body position overlapping with the bottom of an existing position on the second bucket layer. |
| BP-INB-6  | Testing to add a new body position overlapping with the top of an existing position on the first bucket layer. |
| BP-INB-7  | Testing to add a new body position overlapping with the bottom of an existing position on the first bucket layer. |
| BP-INB-8  | Testing to add a new body position fully overlapping with an existing position on the second bucket layer. |
| BP-INB-9  | Testing to add a new body position overlapping with the two existing positions.            |
| BP-INB-10 | Testing to add a new body position within an existing position on the first bucket layer.  |
| BP-INB-11 | Testing to add a new body position within an existing position on the second bucket layer. |
| BP-INB-12 | Testing to add a new body position distinct from the two existing positions.               |

### `_update_body!`

Unit tests for the `_update_body!` function.

| Test name | Description of the unit test                                          |
| --------- | --------------------------------------------------------------------- |
| BP-UB-1   | Testing to add an arbitrary body wall. The case where a new body position is added is tested. |
| BP-UB-2   | Testing to add a second arbitrary body wall. Multiple cases are tested including the addition of a second body position, the addition of a body position overlapping with the top or bottom of an existing position. |
| BP-UB-3   | Testing to add a third arbitrary body wall. The case where two body positions are merged into one is tested. |
| BP-UB-4   | Testing to add a fourth arbitrary body wall. The case where a new body position is added distinct from the two existing positions is tested. |

### `_calc_bucket_pos!`

Unit tests for the `_calc_bucket_pos!` function.

| Test name | Description of the unit test                                           |
| --------- | ---------------------------------------------------------------------- |
| BP-CB-1   | Testing for a simple flat bucket in the XZ plane.                      |
| BP-CB-2   | Testing for a simple flat bucket in the XY plane.                      |
| BP-CB-3   | Testing for an arbitrary bucket. Results were obtained with a drawing. |

### `_update_body_soil!`

Unit tests for the `_update_body_soil!` function.
The tests are separated into two categories:

* Unit tests 1 - 11 are base tests.
* Unit tests 12 - 17 are implementation specific and may need modification when changing the algorithm.

| Test name | Description of the unit test                                           |
| --------- | ---------------------------------------------------------------------- |
| BS-UBS-1  | Testing for a one cell translation following the X axis when `body` and `body_soil` are on the first body layer. |
| BS-UBS-2  | Testing for a one cell translation following the X axis when `body` and `body_soil` are on the first and second body layer, respectively. |
| BS-UBS-3  | Testing for a one cell translation following the X axis when `body` and `body_soil` are on the second and first body layer, respectively. |
| BS-UBS-4  | Testing for a one cell translation following the X axis when `body` and `body_soil` are on the second body layer. |
| BS-UBS-5  | Testing for a pi/2 rotation around the Z axis when `body` and `body_soil` are on the first body layer. |
| BS-UBS-6  | Testing for a pi/4 rotation around the Z axis when `body` and `body_soil` are on the first body layer. |
| BS-UBS-7  | Testing for a one cell translation following the X axis combined to a pi/4 rotation around the Z axis when `body` and `body_soil` are on the first body layer. |
| BS-UBS-8  | Testing for a pi rotation around the X and Z axis when `body_soil` is on the first body layer. Soil is avalanching to the `terrain`. Checking that a warning is issued. |
| BS-UBS-9  | Testing for a pi/2 rotation around the Y axis when `body` and two `body_soil` are on the first body layer. The two `body_soil` are avalanching to the same position. |
| BS-UBS-10 | Testing for a pi/2 rotation around the Y axis when `body` and one `body_soil` are on the first body layer, while a second `body_soil` is on the second body layer. The two `body_soil` are avalanching to the same position. |
| BS-UBS-11 | Testing for a pi/2 rotation around the Y axis when `body` and one `body_soil` are on the second body layer, while a second `body_soil` is on the first body layer. The two `body_soil` are avalanching to the same position. |
| BS-UBS-12 | Testing that soil column shorter than `cell_size_z` is not moved. `body` and `body_soil` are on the first body layer. No movement is applied. |
| BS-UBS-13 | Testing that `h_soil` is properly rounded. `body` and `body_soil` are on the first body layer. No movement is applied. |
| BS-UBS-14 | Testing that the direction in which the neighbouring cells are investigated is correct. To do so, the neighbouring cells are blocked one by one until all the neighbouring cells are investigated. `body` and `body_soil` are on the first body layer. A one cell translation following the X axis is applied. |
| BS-UBS-15 | Testing that the direction in which the neighbouring cells are investigated is correct. To do so, the neighbouring cells are blocked one by one until all the neighbouring cells are investigated. `body` and `body_soil` are on the first body layer. A one cell translation following the -Y axis is applied. |
| BS-UBS-16 | Testing that soil is moved to a neighbouring cell if vertical distance is low enough. `body` and `body_soil` are on the first body layer. A one cell translation following the X axis is applied. |
| BS-UBS-17 | The same as BS-UBS-16 except that the new body location is lower than the previous location. |

## `test_intersecting_cells.jl`

This file implements unit tests for the function in the `intersecting_cells.jl` file.

### `_move_body_soil!`

Unit tests for the `_move_body_soil!` function.
For all the unit tests, the same initial state is considered.
This initial state corresponds to two body layers with soil, where the soil resting on the second body layer (bottom) intersects with the first (top) body layer.

The tested function moves the intersecting soil to a different location.
The purpose of these tests is to check all possible movements depending on the configuration where the soil should be moved.
The description of the unit tests can therefore be done with a simple table describing the configuration at the new soil location.

| Test name | Bottom layer | Soil    | Top layer    | Soil    | Avalanche    | Enough space | Blocked |
| --------- | ------------ | ------- | ------------ | ------- | ------------ | ------------ | ------- |
| IC-MBS-1  | &cross;      | &cross; | &cross;      | &cross; | Terrain      | &check;      | &cross; |
| IC-MBS-2  | First layer  | &cross; | &cross;      | &cross; | &cross;      | &cross;      | &check; |
| IC-MBS-3  | First layer  | &cross; | &cross;      | &cross; | Terrain      | &check;      | &cross; |
| IC-MBS-4  | First layer  | &cross; | &cross;      | &cross; | First layer  | &check;      | &cross; |
| IC-MBS-5  | First layer  | &check; | &cross;      | &cross; | First layer  | &check;      | &cross; |
| IC-MBS-6  | Second layer | &check; | &cross;      | &cross; | &cross;      | &cross;      | &check; |
| IC-MBS-7  | Second layer | &cross; | &cross;      | &cross; | Terrain      | &check;      | &cross; |
| IC-MBS-8  | Second layer | &cross; | &cross;      | &cross; | Second layer | &check;      | &cross; |
| IC-MBS-9  | Second layer | &check; | &cross;      | &cross; | Second layer | &check;      | &cross; |
| IC-MBS-10 | First layer  | &check; | Second layer | &cross; | &cross;      | &cross;      | &cross; |
| IC-MBS-11 | First layer  | &cross; | Second layer | &cross; | First layer  | &check;      | &cross; |
| IC-MBS-12 | First layer  | &cross; | Second layer | &cross; | First layer  | &cross;      | &cross; |
| IC-MBS-13 | First layer  | &check; | Second layer | &cross; | First layer  | &check;      | &cross; |
| IC-MBS-14 | First layer  | &check; | Second layer | &cross; | First layer  | &cross;      | &cross; |
| IC-MBS-15 | Second layer | &check; | First layer  | &cross; | &cross;      | &cross;      | &cross; |
| IC-MBS-16 | Second layer | &cross; | First layer  | &cross; | Second layer | &check;      | &cross; |
| IC-MBS-17 | Second layer | &cross; | First layer  | &cross; | Second layer | &cross;      | &cross; |
| IC-MBS-18 | Second layer | &check; | First layer  | &cross; | Second layer | &check;      | &cross; |
| IC-MBS-19 | Second layer | &check; | First layer  | &cross; | Second layer | &cross;      | &cross; |

Below a short description for some cases:

* When "Blocked" is &check;, a wall is blocking the movement.
* When "Avalanche", "Enough space" and "Blocked" are &cross;, the soil is fully filling the space between the two body layers. Soil cannot avalanche but the investigation in this direction can pursue.
* When "Avalanche" is &check; and "Enough space" is &cross;, the soil can partially avalanche.

### `_move_intersecting_body_soil!`

Unit tests for the `_move_intersecting_body_soil!` function.

The tested function moves all the intersecting soil following a set of rules.
The purpose of these tests is to check all possible movements depending on the configuration of the intersecting soil and its surrounding cells.
As for the `_move_body_soil!` function, a simple table is used to describe the configuration investigated.
However, for the `_move_intersecting_body_soil!` function, several movements can be investigated within a single unit test.
By convention, multiples rows are present within a unit test when several movements in the same direction are made, while when a new direction is investigated, the test name of the unit test is repeated in the first column.

By construction, in the previous location, there are necessarily two body layers and soil must be present on the bottom layer, while the presence of soil on the top layer has no impact on the algorithm.
As a result, for the previous location, only the identity of the bottom layer is provided.

<table>
  <tr>
    <td> </td><td>Previous location</td><td colspan="4">New location</td><td colspan="3">Configuration</td>
  </tr>
  <tr><td>Test name </td><td>Bottom layer </td><td>Bottom layer</td><td>Soil </td><td>Top layer     </td><td>Soil  </td><td>Avalanche</td><td>Enough space</td><td>Blocked</td></tr>
  <tr><td>IC-MIBS-1  </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-2  </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-3  </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-4  </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-5  </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-6  </td><td>First layer </td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-7  </td><td>First layer </td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-8  </td><td>First layer </td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-9  </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-10 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-11 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-12 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-13 </td><td>First layer </td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-14 </td><td>First layer </td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-15 </td><td>First layer </td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-16 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-17 </td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-18 </td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-19 </td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-20 </td><td>Second layer</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-21 </td><td>Second layer</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-22 </td><td>Second layer</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-23 </td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-24 </td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-25 </td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-26 </td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-27 </td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-28 </td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-29 </td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-30 </td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-31 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-32 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-33 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-34 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-35 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-36 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-37 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-38 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-39 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-40 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-41 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-42 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-43 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-44 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-45 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-46 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-47 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-48 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-49 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-50 </td><td>First layer </td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-51 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-52 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-53 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-54 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-55 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-56 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-57 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-58 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-59 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-60 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-61 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-62 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-63 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-64 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-65 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-66 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-67 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-68 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-69 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-70 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-71 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-72 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-73 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-74 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-75 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-76 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-77 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-78 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-79 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-80 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-81 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-82 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-83 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-84 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-85 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-86 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-87 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-88 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-89 </td><td>First layer </td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-90 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-91 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-92 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-93 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-94 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-95 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-96 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-97 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-98 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-99 </td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-100</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-101</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-102</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-103</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-104</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-105</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-106</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-107</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-108</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-109</td><td>First layer </td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-110</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-111</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-112</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-113</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-114</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-115</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-116</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-117</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-118</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-119</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-120</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-121</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-122</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-123</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-124</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-125</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-126</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-127</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-128</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-129</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-130</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-131</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-132</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-133</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-134</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-135</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-136</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-137</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-138</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-139</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-140</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-141</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-142</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-143</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-144</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-145</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-146</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-147</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-148</td><td>First layer </td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-149</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-150</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-151</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-152</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-153</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-154</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-155</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-156</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-157</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-158</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-159</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-160</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-161</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-162</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-163</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-164</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-165</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-166</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-167</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-168</td><td>Second layer</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-169</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-170</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-171</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-172</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-173</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-174</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-175</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-176</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-177</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-178</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-179</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-180</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-181</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-182</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-183</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-184</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-185</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-186</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-187</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-188</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-189</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-190</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-191</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-192</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-193</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-194</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-195</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-196</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-197</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-198</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-199</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-200</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-201</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-202</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-203</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-204</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-205</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-206</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-207</td><td>Second layer</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-208</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-209</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-210</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-211</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-212</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-213</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-214</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-215</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-216</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-217</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-218</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-219</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-220</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-221</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-222</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-223</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-224</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-225</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-226</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-227</td><td>Second layer</td><td>Second layer</td><td>&cross;</td><td>First layer </td><td>&cross;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-228</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-229</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-230</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-231</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-232</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-233</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-234</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-235</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-236</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-237</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-238</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-239</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-240</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-241</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-242</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-243</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-244</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-245</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-246</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-247</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>Second layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-248</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-249</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-250</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-251</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-252</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-253</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-254</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-255</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-256</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>&check;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-257</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-258</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-259</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-260</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-261</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>First layer </td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-262</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-263</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&cross;</td><td>First Layer </td><td>&cross;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-264</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-265</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>Second Layer</td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>
  <tr><td>IC-MIBS-266</td><td>Second layer</td><td>Second layer</td><td>&check;</td><td>First layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>Second Layer</td><td>&check;</td><td>First Layer </td><td>&check;</td><td>&cross;     </td><td>&cross;</td><td>&cross;</td></tr>
  <tr><td>           </td><td>Second layer</td><td>&cross;     </td><td>&cross;</td><td>&cross;     </td><td>&cross;</td><td>Terrain     </td><td>&check;</td><td>&cross;</td></tr>

In addition to these basic unit tests, a few extra edge cases are checked.

| Test name   | Description of the unit test                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------ |
| IC-MIBS-267 | Testing when a lot of soil is present in the first bucket layer but soil is still avalanching.   |
| IC-MIBS-268 | Testing when a lot of soil is present in the second bucket layer but soil is still avalanching.  |
| IC-MIBS-269 | Testing when the bucket is totally underground but the soil is still avalanching on the terrain. |
| IC-MIBS-270 | Testing when the soil column is composed of various layers in `body_soil_pos`.                   |
| IC-MIBS-271 | Testing when there is no intersecting cell                                                       |
| IC-MIBS-    | Testing that all directions are investigated.                                                    |
| IC-MIBS-273 | Testing the randomness of the investigated direction for the soil movement.                      |
| IC-MIBS-274 | Testing that a warning is issued if all soil cannot be moved.                                    |

Test all directions are investigated


### `_locate_intersecting_cells`

Unit test for the `_locate_intersecting_cells` function.

| Test name | Description of the unit test                                                      |
| --------- | --------------------------------------------------------------------------------- |
| IC-LIC-1  | Testing with first bucket layer and no intersecting cell.                         |
| IC-LIC-2  | Testing with first bucket layer and no intersecting cell. (2)                     |
| IC-LIC-3  | Testing with second bucket layer and no intersecting cell.                        |
| IC-LIC-4  | Testing with first and second bucket layer and no intersecting cell.              |
| IC-LIC-5  | Testing with first bucket layer fully intersecting with the terrain.              |
| IC-LIC-6  | Testing with second bucket layer fully intersecting with the terrain.             |
| IC-LIC-7  | Testing with first bucket layer fully intersecting with the terrain and second bucket layer partially intersecting.   |
| IC-LIC-8  | Testing with second bucket layer fully intersecting with the terrain and first bucket layer not intersecting.   |
| IC-LIC-9  | Testing  with first bucket layer fully intersecting with the terrain and second bucket layer not intersecting.  |
| IC-LIC-10 | Testing with first and second bucket layer fully intersecting with the terrain.   |

### `_move_intersecting_body!`

Unit tests for the `_move_intersecting_body!` function.

| Test name | Description of the unit test                                                             |
| --------- | ---------------------------------------------------------------------------------------- |
| IC-MIB-1  | Testing for a single intersecting cell in the -X direction.                              |
| IC-MIB-2  | Testing for a single intersecting cell in the +X direction.                              |
| IC-MIB-3  | Testing for a single intersecting cell in the -Y direction.                              |
| IC-MIB-4  | Testing for a single intersecting cell in the +Y direction.                              |
| IC-MIB-5  | Testing for a single intersecting cell in the -X-Y direction.                            |
| IC-MIB-6  | Testing for a single intersecting cell in the +X-Y direction.                            |
| IC-MIB-7  | Testing for a single intersecting cell in the -X+Y direction.                            |
| IC-MIB-8  | Testing for a single intersecting cell in the +X+Y direction.                            |
| IC-MIB-9  | Testing for a single intersecting cell with the second bucket layer.                     |
| IC-MIB-10 | Testing for a single intersecting cells with various bucket layers.                      |
| IC-MIB-11 | Testing for a single intersecting cell with all the bucket under the terrain.            |
| IC-MIB-12 | Testing for a single intersecting cell under a large bucket.                             |
| IC-MIB-13 | Testing when soil is moved in several steps. All the soil is fitting under the bucket.   |
| IC-MIB-14 | Testing when soil is moved in several steps. Some soil going outside the bucket.         |
| IC-MIB-15 | Testing when soil is moved in several steps. Soil is perfectly fitting under the bucket. |
| IC-MIB-16 | Testing when there is no intersecting cell.                                              |
| IC-MIB-17 | Testing the randomness of the investigated direction for the soil movement.              |
