AudioVAE is an audio variational autoencoder. 

The overall structure is the same as that of an image VAE. 

A typical call stack for this is:


write_songs()                               # preprocesses and writes data to disk

train_iterations( 35000 )                   # evaluates model on data and does backprop


CUDA is disabled by default, and the implementation is serial (i.e. not parallel). 