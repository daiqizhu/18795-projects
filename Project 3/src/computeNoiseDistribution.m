function [noise, nmean, nstd] = computeNoiseDistribution(image, nregion)
%
% Used for Part B.2
%
% computeNoiseDistribution: computes normal distribution characteristics 
%   for background noise
%
% Inputs:  image   - an image structure containing data
%          nregion - a rectangle containing a region of noise in the image
%                    of form [xlow, ylow, width, height]
%
% Outputs: noise - a cropped region containing noise only
%          nmean - the mean of the noise data
%          nstd  - the standard deviation of the noise data
%

% Compute noise statistics
noise = imcrop(image.data, nregion);
nmean = mean(noise(:));
nstd  = std(noise(:));

end