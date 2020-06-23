module TestMathleticsFiles

# using DataFrames
using MathleticsFiles: dataset
using Test

@testset "Test of single dataset" begin
    df = dataset("rushing")
    @test size(df) == (18, 4)
    df = dataset("nfl_team_totals")
    @test size(df) == (128, 13)
end

end  # module TestMathleticsFiles
