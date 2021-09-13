const batches       = 4
const sample_size   = 4096 * 2
const out_channels  = 8
const throttle      = 16
const num_states    = 8
const num_symbols   = 32

# Since the symbols are essentially the clusters of the kmeans, we can define the number of clusters to be the number of symbols

const checkpoint    = 1000

const data_file     = "data.mp"

const wav_directory = string(pwd(), "/data/wav/")

const savename      = "model4.bson"


const output_shape = 1024
const latent_vec_size = 512

# for i in size( proportions )[1]

#     println( proportions[i, :])

# end