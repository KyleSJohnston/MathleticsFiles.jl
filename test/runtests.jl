module TestMathleticsFiles

# using DataFrames
using MathleticsFiles: dataset
using Test

@testset "Test of single dataset" begin
    df = dataset("rushing")
    @test size(df) == (1, 1)
end

end  # module TestMathleticsFiles
