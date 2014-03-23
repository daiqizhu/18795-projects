function displayNoiseHistogram(image, bins)
%
% Used for Part B.2
%
% displayNoiseHistogram: displays a histrogram of the noise for an image
%
% Inputs:  image - an image structure containing noise data
%          bins  - the number of bins to use in the histrogram
%
% Outputs: a figure of data
%

figure(); hold on;

% Display a histogram
hist(image.cropped(:), bins);

% Overlay a normal distribution
xs = linspace(min(image.cropped(:)), max(image.cropped(:)), 512);
dist = normpdf(xs, image.nmean, image.nstd);
plot(xs, dist * max(hist(image.cropped(:),bins)) / max(dist), ...
    'r', 'LineWidth', 2);

title('Distribution of noise in image background');
legend('Actual', 'Ideal Gaussian');

hold off;

end