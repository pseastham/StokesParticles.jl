using Documenter, StokesParticles

makedocs(;
    modules=[StokesParticles],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/pseastham/StokesParticles.jl/blob/{commit}{path}#L{line}",
    sitename="StokesParticles.jl",
    authors="Patrick Eastham",
    assets=String[],
)

deploydocs(;
    repo="github.com/pseastham/StokesParticles.jl",
)
