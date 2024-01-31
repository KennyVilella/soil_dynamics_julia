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
