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
    current_errors = zeros(11*11,1);

    % Iterate through each pixel in a 5x5 box around current_maxima
    for i = -oversample:oversample
        for j = -oversample:oversample
            current_errors((i+oversample)*r + j + oversample + 1) =...
                kernelError(interpolated_image,...
                (current_maxima(1,2) - 1) * oversample + 1 + i,...
                (current_maxima(1,1) - 1) * oversample + 1 + j,...
                gauss_kernel);
        end
    end

    % Find the subpixel with the minimum error, with respect to
    % the position of the current maxima
    [~,index] = min(current_errors);
    subpixel = [floor((index-1)/r)-oversample, mod(index-1,r)-oversample];

    % Scale the subpixel back
    subpixel_particles(m,:) = (subpixel)./oversample;

    % Location of the subpixel
    subpixel_particles(m,:) = subpixel_particles(m,:) + current_maxima;
end
    
end