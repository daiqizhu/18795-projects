function subpixel_particles = subpixelGaussianFit(image, rayleigh, oversample)
%
% Used in B.3.2 and B.3.3
%
% Performs a subpixel fitting on an image using gaussian fitting
% Gaussian Kernel stuff is on Lectures 11 and 12 (same content)
%
% Inputs:  image - an image struct containing our data
%          rayleigh - the rayleigh limit size in pixels for our image
%          oversample - the factor to upsample by
%
% Outputs: subpixel_particles - a list of subpixel particle locations, 
%                               where each row is a coordinate
%

% Oversample current image via interpolation
interpolated_image = interpolateImage(image.data, oversample);

% Create the 2D Gaussian kernel
sigma = rayleigh*oversample/3; r = round(2*sigma+1);
gauss_kernel = fspecial('gaussian', [r r], sigma);

% Set up some variables for error calculation
max_num = size(image.maxima,1);
subpixel_particles = zeros(max_num,2);

% Iterate through each maximum from Section B.2.2
for m = 1:max_num
    current_maxima = image.maxima(m,:);
    current_errors = zeros(2*oversample+1,2*oversample+1);

    % Iterate through each pixel in a box around current_maxima
    for i = -oversample:oversample
        for j = -oversample:oversample
            center_point = round([(current_maxima(1)-.5)*oversample + i, ...
                (current_maxima(2)-.5)*oversample + j]);
            center_value = interpolated_image(center_point(1), ...
                center_point(2));
            
            current_errors(i+oversample+1, j+oversample+1) = ...
                kernelError(interpolated_image, ...
                center_point(2), center_point(1), ...
                center_value*gauss_kernel);
        end
    end

    % Find the subpixel with the minimum error, with respect to
    % the position of the current maxima. Take the first one in case of
    % multiples
    [row,col] = find(current_errors == min(min(current_errors)));
    subpixel = [row(1), col(1)] - oversample - 1;

    % Scale the subpixel back and place
    subpixel_particles(m,:) = current_maxima + (subpixel)./oversample;
end
    
end