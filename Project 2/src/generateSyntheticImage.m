function output = generateSyntheticImage(image, sigma, noiseMean, noiseStd)
%
% Used for Part B.3.1 Generate Synthetic Image
%
% Generates a synthetic test image from a given set of maxima by applying a
% point spread kernel and adding noise
%
% Inputs:  image - an image structure as used by the rest of the project
%          sigma - the sigma to use for our point spread gaussian
%          noiseMean - the mean intensity to be used for our background
%                      noise
%          noiseStd - the standard deviation of the intensity for our
%                     background noise
%
% Outputs: img - a synthetic test image
%

% First create our images and place our points using the original intensity
output = zeros(size(image.data,1), size(image.data,2));
for ii = 1:size(image.maxima,1)
    maximum = image.maxima(ii,:);
    output(maximum(1), maximum(2)) = image.data(maximum(1),maximum(2));
end

% Convolve with a point spread gaussian function
kernel = fspecial('gaussian', round([6*sigma+1 6*sigma+1]), sigma);
kernel = kernel/max(max(kernel));
output = filter2(kernel, output);

% Add gaussian random noise
noise = noiseMean + noiseStd*randn(size(image.data,1), size(image.data,2));
noise(noise < 0) = 0;
output = output + noise;

end