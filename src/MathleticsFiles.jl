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
    # Taro.readxl requres write access; copy the path to a temporary location with write access.
    temppath = tempname()
    df = try
        cp(fp, temppath)
        chmod(temppath, 0o664)
        taroinit(init)
        DataFrame(Taro.readxl(temppath, args[2:end]...))
    finally
        rm(temppath)
    end
    return df
end


end # module
