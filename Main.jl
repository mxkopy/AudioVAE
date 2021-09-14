include("Autoencoder.jl")
include("Globals.jl")

using .Autoencoder, ArgParse, Serialization

model = create_model()

s = ArgParseSettings()

@add_arg_table s begin
    
    "--create-model"

        action = :store_true

    "--train-model"

        action = :store_true

    "--autoencode"

        action = :store_true


    "--write-songs"

        action = :store_true


end

args = parse_args( s )

if args["create-model"]

    model = create_model()

else

    model = deserialize( savename )

end

if args["write-songs"]

    write_songs()

end

if args["train-model"]

    train_model( model )

elseif args["autoencode"]

    autoencode( 20 )

end