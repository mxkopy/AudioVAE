include("Autoencoder.jl")
include("Globals.jl")

using .Autoencoder, ArgParse, Serialization

if savename in readdir("/")

    train_model( deserialize(savename) )

else

    train_model(create_model())

end