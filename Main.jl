include("Autoencoder.jl")
include("Globals.jl")

using .Autoencoder, ArgParse, Serialization

s = ArgParseSettings()

@add_arg_table s begin
    
    "--create-model"

        action = :store_true

    "--autoencode"

        action = :store_true

    "--write-songs"

        action = :store_true

end

args = parse_args( s )

if args["create-model"]

    init_model()

end

if args["write-songs"]

    write_songs()

end

if args["autoencode"]

    autoencode( 20 )

end