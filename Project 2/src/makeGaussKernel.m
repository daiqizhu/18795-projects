function [ kernel ] = makeGaussKernel( image )
%
% Used for Part B.3.2 Sub-Pixel Resolution Detection Algorithm
%
% Generates a gaussian kernel for sub-pixel resolution detection, given the
% image to detect particles on
%
% Inputs:  image - an image to make the kernel for (not the data struct)
%
% Outputs: kernel - the gaussian kernel
%

% TODO: Fill this out!
kernel = 0;

sigma = 0.61 * 527e-9 / (1.4 * 3); % .61*lambda/(NA*3), the airy disk

end