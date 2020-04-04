module MathleticsFiles

using DataFrames
using Pkg.Artifacts
using Taro
using ZipFile

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
    dirhash = Artifacts.artifact_hash(artifactname, ARTIFACT_TOML)

    if isnothing(dirhash) || !Artifacts.artifact_exists(dirhash)
        @info "Generating MathleticsFiles artifact..."
        dirhash = Artifacts.create_artifact() do artifactpath
            zippath = download(sourceurl)
            extractall(zippath, artifactpath)
        end
        Artifacts.bind_artifact!(ARTIFACT_TOML, artifactname, dirhash)
        @info "MathleticsFiles artifact generated."
    end

    return joinpath(Artifacts.artifact_path(dirhash), filename)
end

_INIT_ = false  # Bool

function taroinit(init::Union{Bool,Nothing})
    global _INIT_
    if (isnothing(init) && !_INIT_) || init
        Taro.init()
        _INIT_ = true
    end
end

function dataset(name::AbstractString; sourceurl::AbstractString=URL, init::Union{Bool,Nothing}=nothing)::DataFrame
    lookup = Dict{String,Tuple{String, String}}(
        "rushing" => ("firstdown.xls", "B4:E22"),
        "passing" => ("firstdown.xls", "B24:E42")
    )
    args = lookup[name]
    fp = filepath(args[1], sourceurl=sourceurl)
    taroinit(init)
    return DataFrame(Taro.readxl(fp, args[2:end]...))
end


end # module
