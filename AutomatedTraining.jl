include("Autoencoder.jl")
include("Globals.jl")

using .Autoencoder, ArgParse, Serialization

if ! (savename in readdir("/"))

    init_model()

end

train_iterations( 1000 )
