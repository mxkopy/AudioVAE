# Classic generataive neural network. This time, it generates audio.

module Autoencoder

using Flux: output_size
include("Globals.jl")
include("AudioIterator.jl")

using .AudioIterator, Flux, Serialization, WAV, Zygote
using  Distributions

# Model definition

# Note that the left and right channels are defined as the second dimension of the input array, i.e. the input is shaped
# (sample_size, channels, 1, batch_size) 
# while the encoder output has the channels as the third dimensions, i.e. the encoder output is
# (output_shape, 1, out_channels, batch_size)
# This is intentional, because usually the left and right channels are a little bit redundant

function create_model()

    encoder = Chain(

        # Encoding layer
    
        Conv( (3, 1), (2 => 4),  pad=2, stride=1), AdaptiveMeanPool( ( 4096 * 2, 1 ) ),
        Conv( (3, 1), (4 => 8),  pad=2, stride=2), AdaptiveMeanPool( ( 4096 - 1, 1 )  ),
        Conv( (3, 1), (8 => 16), pad=2, stride=2),

        AdaptiveMeanPool( ( output_shape , 1 ) ),
        Dropout(0.5),

    )
    
    decoder = Chain(
    
        # Decoder layer

                                  ConvTranspose( (3, 1), 16 => 8, stride=2 ),
        Upsample( scale=(2, 1) ), ConvTranspose( (3, 1), 8 => 4,  stride=2 ),
        Upsample( scale=(2, 1) ), ConvTranspose( (3, 1), 4 => 2,  stride=2 ),
        
        AdaptiveMeanPool( ( sample_size, 1 ) )
    
    )
    
    mean        = Dense( output_shape, latent_vec_size )
    std         = Dense( output_shape, latent_vec_size )

    reconstruct = Upsample( size=( output_shape, 1) )

    encoder = Flux.mapleaves( Float32, encoder )
    decoder = Flux.mapleaves( Float32, decoder )
    reconstruct = Flux.mapleaves( Float32, reconstruct )
    mean = Flux.mapleaves(Float32, mean)
    std = Flux.mapleaves(Float32, std)

    return encoder, decoder, reconstruct, mean, std

end    

# Evaluates the model. Not attached to gradient.

function eval_model( encoder, decoder, reconstruct, mean, std, param, data)

    # Encoding process
    enc_out    = encoder( data )

    # Learns the probability distribution of the output
    means      = mean( enc_out )
    devs       = std( enc_out )

    # Samples from the distribution generated by the encoder 
    latent     = ( param .* devs ) .+ means
    
    # Reconstructs the input 
    rec_out    = reconstruct( latent )
    dec_out    = decoder( rec_out )

    # dec_out    = ( dec_out .* 2.0 ) .- 1.0

    return enc_out, latent, dec_out

end

# The loss function and model evaluation that should be called within the gradient scope

function loss_function( encoder, decoder, reconstruct, mean, std, param, x )

    enc_out, rec_out, dec_out = eval_model( encoder, decoder, reconstruct, mean, std, param, x )
    
    return Flux.Losses.mse( dec_out, x ) , Flux.Losses.kldivergence( softmax( dec_out ), softmax( x ) )

end


function train_iter( io, model, opt, parameters )

    data = deserialize( io )

    unit_gaussians = rand( Normal( 1.0, 0.1 ), latent_vec_size )

    r_loss, d_loss = 0, 0

    gs = gradient( parameters ) do

        r_loss, d_loss = loss_function( model..., unit_gaussians, data )

        return 2 * r_loss + d_loss

    end

    # println('\n', "r ", string(r_loss)[1:7], " | d ", string(d_loss)[1:7] )

    Flux.Optimise.update!( opt, parameters, gs )

end

# Saving

function save( count, model, parameters, opt )

    serialize( savename, ( count, model, parameters, opt ) )

end


function load()

    count, model, parameters, opt = deserialize( savename )

    io = open( data_file )

    deserialize( io )

    offset = position( io )

    seek( io, count * offset )

    return io, count, model, parameters, opt

end



function init_model()

    count          = 0

    model = create_model()

    opt = ADAM( 0.01 )
    parameters = Flux.params( model[1:2]..., model[3:5] )

    serialize( savename, ( count, model, parameters, opt ) )

end



function train_iterations( num )

    io, count, model, parameters, opt = load()

    for i in 1:num

        if eof( io )

            count = 0
            seek( io, 0 )

        end

        count = count + 1

        train_iter( io, model, opt, parameters )

        println( i / num )

    end

    save( count, model, parameters, opt )

end


function autoencode( num_batches )

    _, model, _, _ = deserialize( savename )

    encoder, decoder, reconstruct, mean, std = model

    out = zeros( sample_size, 1, 2, batches, num_batches )

    io  = open( data_file )

    for i in 1 : num_batches 

        data = next( io )

        unit_gaussians = ones( latent_vec_size )

        _, _, output = eval_model( encoder, decoder, reconstruct, mean, std, unit_gaussians, data )

        out[:, :, :, :, i] = reshape( output, size(output)[ 1:4 ] )

    end
    
    file = reshape( out, ( sample_size * num_batches * batches, 2 ) )

    file = ( file .* 2.0 ) .- 1.0

    wavwrite( file, "output.wav", Fs=22050)

    close( io )

end

# export parameters, create_model, train_model, load_model, encoder, decoder, eval_model, autoencode, init

export init_model, train_iterations, autoencode

end