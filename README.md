# MathleticsFiles.jl
Functions to access data from the Mathletics files.

Example usage:

```julia
julia> using MathleticsFiles

julia> df = dataset("nfl_team_totals");

julia> first(df, 3)
3×13 DataFrames.DataFrame
│ Row │ Rk     │ Tm                 │ Margin │ Pts   │ RET_TD │ PENDIF │ PY_A │ RY_A │ TO   │ DPY_A │ DRY_A │ DTO  │ defpts │
│     │ Any    │ Any                │ Any    │ Any   │ Any    │ Any    │ Any  │ Any  │ Any  │ Any   │ Any   │ Any  │ Any    │
├─────┼────────┼────────────────────┼────────┼───────┼────────┼────────┼──────┼──────┼──────┼───────┼───────┼──────┼────────┤
│ 1   │ 2003.0 │ Kansas City Chiefs │ 152.0  │ 484.0 │ 5.0    │ -83.0  │ 7.1  │ 4.3  │ 18.0 │ 5.6   │ 5.2   │ 37.0 │ 332.0  │
│ 2   │ 2003.0 │ Indianapolis Colts │ 111.0  │ 447.0 │ -1.0   │ -343.0 │ 7.1  │ 3.7  │ 20.0 │ 5.9   │ 4.5   │ 30.0 │ 336.0  │
│ 3   │ 2003.0 │ St. Louis Rams     │ 119.0  │ 447.0 │ -2.0   │ -215.0 │ 6.2  │ 3.6  │ 39.0 │ 5.6   │ 4.8   │ 46.0 │ 328.0  │

```
