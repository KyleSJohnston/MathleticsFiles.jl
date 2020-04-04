module MathleticsFiles

using  DataFrames
using  Pkg.Artifacts
using  Taro
using  ZipFile

export dataset

const URL = "https://excelwithwayne.com/wp-content/uploads/2019/05/MathleticsFiles.zip"
const ARTIFACT_TOML = joinpath(@__DIR__, "..", "Artifacts.toml")

function extractall(zippath::AbstractString, dirpath::AbstractString)
    @debug "Extracting all contents of $zippath to $dirpath."
    open(zippath) do io
        reader = ZipFile.Reader(io)
        for file in reader.files
            outpath = joinpath(dirpath, file.name)
            @debug "Extracting $(file.name) to $outpath."
            open(outpath, write=true) do out
                write(out, read(file))
            end;
        end
    end;
end

function filepath(filename::AbstractString; sourceurl::AbstractString=URL)
    artifactname = "mathletics_files"
    artifacthash = Artifacts.artifact_hash(artifactname, ARTIFACT_TOML)

    if isnothing(artifacthash) || !Artifacts.artifact_exists(artifacthash)
        @info "Generating MathleticsFiles artifact..."
        artifacthash = Artifacts.create_artifact() do artifactpath
            zippath = download(sourceurl)
            extractall(zippath, artifactpath)
        end
        Artifacts.bind_artifact!(ARTIFACT_TOML, artifactname, artifacthash)
        @info "MathleticsFiles artifact generated."
    end

    return joinpath(Artifacts.artifact_path(artifacthash), filename)
end

_INIT_ = false  # Bool

"""
If `init` is true, runs Taro.init(); otherwise does nothing.
"""
function taroinit(init::Bool)
    if init
        global _INIT_
        Taro.init()
        _INIT_ = true
    end
end

"""
Runs Taro.init() only if it hasn't already been run by this module.
"""
function taroinit(init::Nothing)
    global _INIT_
    if !_INIT_
        taroinit(true)
    end
end


function astemp(f::Function, path::AbstractString, mode::Integer)
    temppath = tempname()
    return try
        cp(path, temppath)
        chmod(temppath, mode)
        f(temppath)
    finally
        rm(temppath)
    end
end

"""
Retrieves a dataset by file name, sheetname, and range
"""
function dataset(filename::AbstractString, sheetname::AbstractString, range::AbstractString;
                 sourceurl::AbstractString=URL, init::Union{Bool,Nothing}=nothing)::DataFrame
    # Taro.readxl requres write access; copy the path to a temporary location with write access.
    return astemp(filepath(filename, sourceurl=sourceurl), 0o664) do temppath
        taroinit(init)
        return DataFrame(Taro.readxl(temppath, sheetname, range))
    end
end


"""
Retrieves a dataset by file name and range
"""
function dataset(filename::AbstractString, range::AbstractString;
                 sourceurl::AbstractString=URL, init::Union{Bool,Nothing}=nothing)::DataFrame
    # Taro.readxl requres write access; copy the path to a temporary location with write access.
    return astemp(filepath(filename, sourceurl=sourceurl), 0o664) do temppath
        taroinit(init)
        return DataFrame(Taro.readxl(temppath, range))
    end
end


"""
Retrieves a dataset (as a DataFrame) by alias.
"""
function dataset(alias::AbstractString; sourceurl::AbstractString=URL, init::Union{Bool,Nothing}=nothing)::DataFrame
    lookup = Dict{String,Tuple{Vararg{String}}}(
        "nfl_team_totals" => ("nflregression.xls", "data", "A5:M133"),
        "rushing" => ("firstdown.xls", "B4:E22"),
        "passing" => ("firstdown.xls", "B24:E42"),
    )
    args = lookup[alias]
    return dataset(args...)
end


end # module
