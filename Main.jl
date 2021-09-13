include("Autoencoder.jl")
include("Globals.jl")

using .Autoencoder, ArgParse, Serialization

model = deserialize( savename )

s = ArgParseSettings()

@add_arg_table s begin
    
    "--create-model"

        action = :store_true

    "--train-model"

        action = :store_true

    "--autoencode"

        action = :store_true

end

args = parse_args( s )

if args["create-model"]

    model = create_model()

end

if args["train-model"]

    train_model( model )

elseif args["autoencode"]

    autoencode( 20 )

end