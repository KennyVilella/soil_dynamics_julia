using Documenter
using SoilDynamics

makedocs(
  sitename = "Soil dynamics simulator",
  authors = "Kenny Vilella",
  pages    = [
    "Home" => "index.md",
#   "Quickstart" => "quickstart.md",
#   "Section 1" => ["Subsection 1" => "subsection1.md",
#                   "Subsection 2" => "subsection2.md",
#                   "Subsection 3" => "subsection3.md",],
  ]
)

deploydocs(
  repo = "github.com/KennyVilella/soil_dynamics_julia.git"
)