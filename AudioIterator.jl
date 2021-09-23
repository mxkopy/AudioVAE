module AudioIterator

include("Globals.jl")

using FileIO, WAV, Serialization

function load_file( dir )

    curr_file, fs = wavread( dir )

    curr_file     = reshape_file( curr_file )

    return curr_file, fs

end


function replace_runoff( buffer )

    runoff_size = size(buffer)[1] % (sample_size * batches)
    temp        = zeros((sample_size * batches - runoff_size, 2))
    buffer      = cat(buffer, temp, dims=1)

    return buffer

end

# Reshapes the file to size ( sample_size, channels, batches, num_samples )
# elements are accessed by curr_file[:, :, :, i]
# and are supposed to be reshape later to (sample_size, 2, channel_size, batches)
function reshape_file( curr_file )

    num_samples = Int( floor( size( curr_file )[1] / ( sample_size * batches )))
    newsize     = ( sample_size, 2, batches, num_samples + 1 )

    last_sample_index = Int(floor( reduce( *, newsize ) - reduce(*, newsize[1:3]) ) // 2 )

    runoff      = replace_runoff( curr_file[ last_sample_index:size(curr_file)[1], : ] )

    _curr_file  = cat( curr_file[1:last_sample_index, :], runoff, dims=1 )

    _curr_file  = reshape( _curr_file, newsize )
    # curr_file   = copy( convert( Array{Float16}, curr_file) )

    return _curr_file

end

# Everything above is deprecated. 


# Returns an array of Float32 of size (sample_size, 1, channels, batch_size)

function next( io )

    if !eof( io )

        out = deserialize( io )

        out = ( 1.0 .+ out ) ./ 2.0

        return out

    else

        return false

    end

end


# This function serializes all of the .wav files to a pre-batched, pre-parsed "data.mp" file. 
# It should be run any time there is a change in the dataset. 
# It's run only if the "$data_file" file is not present. 

# The file is typically incredibly large and the serialization process is typically very expensive. 
# However, this allows us to skip parsing and reading directly from wav during the training process. 

function write_songs()

    paths = readdir( wav_directory )

    s = batches * sample_size

    data, _, _, _ = wavread( string(wav_directory, paths[1]), subrange=1:s )

    io = open( data_file, "w" )

    for path in paths

        println( path )

        i = 1

        eof = true

        while eof

            try 

                data, _, _, _ = wavread( string(wav_directory, path); subrange=s*i + 1:s * (i+1) )

                data = ( data .+ 1.0 ) ./ 2.0

                i = i + 1

                serialize( io, reshape( data, (sample_size, 1, 2, batches) ) )

            catch y

                eof = false

                break

            end

        end

    end

    close(io)

end

export next, write_songs

end