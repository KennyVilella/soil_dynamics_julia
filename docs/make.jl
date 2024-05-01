using Documenter
using SoilDynamics

makedocs(
    sitename = "Soil dynamics simulator",
    authors = "Kenny Vilella",
    pages = [
        "Home" => "index.md",
        "types.jl" => "types.md",
        "Grid" => "grid.md",
        "bucket.jl" => "bucket.md",
        "body_soil.jl" => "body_soil.md",
        "intersecting_cells.jl" => "intersecting_cells.md",
        "relax.jl" => "relax.md",
        "utils.jl" => "utils.md"
    ]
)

deploydocs(repo = "github.com/KennyVilella/soil_dynamics_julia.git")
