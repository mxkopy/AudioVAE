include("Autoencoder.jl")
include("Globals.jl")

using .Autoencoder, ArgParse, Serialization

if ! (data_file in readdir("/"))

    write_songs()

end

if ! (savename in readdir("/"))

    init_model()

end

train_iterations( 1000 )
