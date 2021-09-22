module AudioIterator

include("Globals.jl")

using FileIO, WAV, Serialization
# import LibSndFile

# Essentially pads the buffer audio array with zeros, so each step in the iteration is guaranteed. 
# I.e you can iterate for i in range: data = buffer[sample_size * batches * i : sample_size * batches * (i + 1)]

# endflag       = false
# current_dir   = 1
# samp_iterator = 1

# dir_iterator  = readdir(wav_directory);

# curr_file     = zeros(1, 1, 1, 1)

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


# Returns an array of Float32 of size (sample_size, channels, 1, batch_size)

function next( io )

    if !eof( io )

        out = deserialize( io )

        out = ( 1.0 .+ out ) ./ 2.0

        return Float32.( out )

    else

        return false

    end

end

function write_songs()

    paths = readdir( wav_directory )

    s = batches * sample_size

    data, _, _, _ = wavread( string(wav_directory, paths[1]), subrange=1:s )

    io = open( "data.mp", "w" )

    for path in paths

        println( path )

        i = 1

        eof = true

        while eof

            try 

                data, _, _, _ = wavread( string(wav_directory, path); subrange=s*i + 1:s * (i+1) )

                data = ( data .+ 1.0 ) ./ 2.0

                data = Float32.( data )

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