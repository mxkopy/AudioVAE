function linear_interpolate( A, B, param )

    return A .+ ( ( B .- A ) .* param )

end



# We have continuous, compressed representations of music data. 
# In theory, this allows us to interpolate two songs 
# on a purely sonic level 
# by interpolating their respective representations. 

function interpolate_songs( curr_file1, curr_file2, model, interpolator, param )

    out = []

    encoder, decoder, reconstruct, mean, std = model

    for i in 1: min( size( curr_file1 )[3], size( curr_file2 )[3] )

        _A = curr_file1[:, :, :, i]; _A = reshape( _A, ( size( _A )[1], 1, size( _A )[2], size( _A )[3] ))

        _B = curr_file2[:, :, :, i]; _B = reshape( _B, ( size( _B )[1], 1, size( _B )[2], size( _B )[3] ))

        A  = encoder( _A )
        B  = encoder( _B )

        o  = interpolator( A, B, param )

        unit_gaussians = rand( Normal( 1.0, 0.05 ), latent_vec_size )

        means  = mean( o )
        devs   = std( o )

        latent = means + ( unit_gaussians .* devs )

        output = decoder( latent )

        out = append!( out, output )

    end

    wavwrite( file, string(out_directory, "output.wav"), Fs=AudioIterator.fs )

    return out

end