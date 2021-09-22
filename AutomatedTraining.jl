include("Globals.jl")
include("Autoencoder.jl")
include("AudioIterator.jl")


using .Autoencoder, .AudioIterator, ArgParse, Serialization

if ! (data_file in readdir("/"))

    write_songs()

end

if ! (savename in readdir("/"))

    init_model()

end

train_iterations( 10 )
