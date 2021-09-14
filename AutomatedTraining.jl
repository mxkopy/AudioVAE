include("Autoencoder.jl")
include("Globals.jl")

using .Autoencoder, ArgParse, Serialization

model = create_model()

if savename in readdir("/")

    model = deserialize(savename)

end

train_model(model)