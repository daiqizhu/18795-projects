function [ uniformity ] = computeUniformIllumination( image, noise_min, noise_max )
%
% Used for Part B.3
%
% displayNoiseHistogram: calculates the uniformity of illumination
%
% Inputs:  image - a normal 2D image to calculate uniformity for
%          noise_min - minimum value of a segment of noisy background
%          noise_max - maximum value of a segment of noisy background
%
% Outputs: a scalar representing the uniformity of illuminatoin of image
%

% Parameters
sigma = 10;

% Filter with a large low-pass kernel
kernel = fspecial('gaussian', round([sigma sigma]), sigma);
blurred_image = filter2(kernel, image);

% Find the global max and min of the blurred image
global_max = max(max(blurred_image));
global_min = min(min(blurred_image));

% Calculate the respective differences between the max & min
global_difference = abs(global_max - global_min);
noise_difference = abs(noise_max - noise_min);

% Calculate a scalar using global_difference and noise_difference that
% characterizes the image's uniformity of illumination
uniformity = global_difference / noise_difference; % closer to 1 = more uniform

end

