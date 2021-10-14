module MathleticsFiles

using  DataFrames
using  Downloads: Downloads
using  Logging
using  Pkg.Artifacts: artifact_exists, artifact_hash, @artifact_str, bind_artifact!, create_artifact
using  Taro: Taro
using  ZipFile: ZipFile

export dataset

const URL = "https://excelwithwayne.com/wp-content/uploads/2019/05/MathleticsFiles.zip"
const ARTIFACT_TOML = joinpath(@__DIR__, "..", "Artifacts.toml")


function __init__()
    @info "Initializing Taro"
    Taro.init()
    try
        download_artifact()
    catch e
        @warn "Unable to download requisite artifacts; functionality will be limited until you run MathleticsFiles.download_artifact()"
    end
end


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

function download_artifact(; sourceurl::AbstractString=URL)
    artifacthash = artifact_hash("mathletics_files", ARTIFACT_TOML)

    if isnothing(artifacthash) || !artifact_exists(artifacthash)
        @info "Generating MathleticsFiles artifact..."
        artifacthash = create_artifact() do artifactpath
            extractall(Downloads.download(sourceurl), artifactpath)
        end
        bind_artifact!(ARTIFACT_TOML, "mathletics_files", artifacthash, force=true)
        @info "MathleticsFiles artifact generated."
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


function openartifact(f::Function, filename::AbstractString)
    # Taro.readxl requres write access; copy the path to a temporary location with write access.
    astemp(f, joinpath(artifact"mathletics_files", filename), 0o664)
end


"""
Retrieves a dataset by file name, sheetname, and range
"""
function dataset(filename::AbstractString, sheetname::AbstractString, range::AbstractString)::DataFrame
    openartifact(filename) do temppath
        return DataFrame(Taro.readxl(temppath, sheetname, range))
    end
end


"""
Retrieves a dataset by file name and range
"""
function dataset(filename::AbstractString, range::AbstractString)::DataFrame
    openartifact(filename) do temppath
        return DataFrame(Taro.readxl(temppath, range))
    end
end


"""
Retrieves a dataset (as a DataFrame) by alias.
"""
function dataset(alias::AbstractString)::DataFrame
    lookup = Dict{String,Tuple{Vararg{String}}}(
        "nfl_team_totals" => ("nflregression.xls", "data", "A5:M133"),
        "rushing" => ("firstdown.xls", "B4:E22"),
        "passing" => ("firstdown.xls", "B24:E42"),
    )
    args = lookup[alias]
    return dataset(args...)
end


end # module
