using Plots

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
const enc_directory = string(pwd(), "/data/enc/")
const map_directory = string(pwd(), "/data/map/")
const cen_directory = string(pwd(), "/data/cen/")
const std_directory = string(pwd(), "/data/std/")
const out_directory = string(pwd(), "/data/out/")

const savename      = "model4.bson"

const output_shape = 1024
const latent_vec_size = 512


const vals = [

    Dict("k" => (3, 1), "s" => 1, "c" => (2 => 4),                         "p" => 0), 
    Dict("k" => (3, 1), "s" => 2, "c" => (4 => 4),                         "p" => 0),
    Dict("k" => (3, 1), "s" => 1, "c" => (4 => 8),                         "p" => 2)
    # Dict("k" => (3, 1), "s" => 2, "c" => (8 => 8),                        "p" => 0),
    # Dict("k" => (3, 1), "s" => 1, "c" => (8 => 16),                       "p" => 0),
    # Dict("k" => (3, 1), "s" => 2, "c" => (16 => 16),                       "p" => 0),
    # Dict("k" => (3, 1), "s" => 1, "c" => (16 => 16),                        "p" => 0),
    # Dict("k" => (3, 1), "s" => 2, "c" => (16 => 32),                       "p" => 1),
    # Dict("k" => (3, 1), "s" => 1, "c" => (32 => out_channels),             "p" => 2)

]

