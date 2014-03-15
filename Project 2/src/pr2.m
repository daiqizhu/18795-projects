%
% 18-795 Project 2
% Alex Sun Yoo (ayoo), Michael Nye (mnye), Ozan Iskilibli (oiskilib)
% Spring, 2014
%
% This file should run the demo for project 2 by calling functions to 
% perform each action and displaying results between steps
%

% Clean up
clear all
close all
clc

% Define constants
maskSize = 3;
plotting = true;
%Nimages = numel(images);
Nimages = 1;

% Rayleigh limit
rayleighM = 0.61 * 527e-9 / 1.4; % .61*lambda/NA, in m
rayleigh  = rayleighM / 65e-9; % convert to pixels

% Load our image files
disp 'Loading image files...'
imageFiles = dir('../images/*.tif');
images = [];

for ii = 1:Nimages
    image.name = imageFiles(ii).name;
    img = im2double(imread(['../images/' image.name]));
    image.data = img / max(max(img));
    images = [images; image]; %#ok
end


%% B.2.1 Calibration of dark noise
disp 'Calibrating noise...'

% Manually crop a portion of background noise and determine its statistics.
% Choose an arbitrary image for this
img = images(1).data;
[noiseMean, noiseStd] = calibrateBackground(img);


%% B.2.2 Detection of local maxima and local minima
disp 'Detecting minima and maxima...'

% First compute the sigma based on the rayleigh limit
sigma = rayleigh/3;

% For each image, find the extrema and store it
for ii = 1:Nimages
    [maxima, minima] = findLocalExtrema(images(ii).data, maskSize, sigma);
    images(ii).maxima = maxima; %#ok
    images(ii).minima = minima; %#ok
end

% Display extrema of an arbitrary example
if plotting
    image = images(1);
    
    figure;
    imshow(image.data); hold on;
    scatter(images.minima(:,2), images.minima(:,1), 'g.');
    scatter(images.maxima(:,2), images.maxima(:,1), 'rx');
    legend('Minima', 'Maxima');
    title(sprintf('Raw extrema in image with %dx%d mask',maskSize,maskSize));
end


%% B.2.3 Establishing the local association of maxima and minima
disp 'Associating maximas to minimas using Delaunay Triangulation...'

% For each image, calculate delaunay triangulation
for ii = 1:Nimages
    [images(ii).associated visual] = assocLocalExt(images(ii)); %#ok
end

if plotting
    imageIndex = ceil(numel(images)/2);
    image = images(imageIndex);
    tmp = size(image.associated.triAddr,2);
    tmpLocalMax = [];
    for ii = 1:tmp;
        tmpLocalMax = [tmpLocalMax; images.associated.LocalMaxAddr{ii}]; %#ok
    end
   
    figure;
    imshow(image.data); hold on;
    triplot(visual, 'b');
    scatter(tmpLocalMax(:,2), tmpLocalMax(:,1), 'rx');
    legend('Delaunay Triangles', 'Associated local maxima');
    title('Delaunay Triangulation');
end
clear visual imageIndex image tmp tmpLocalmax;


%% Part B.2.4 Statistical selection of local maxima
disp 'Statistically detecting maximas...'

Quantile = 10;
for ii = 1:Nimages
    [images(ii).statMaxima] = statMaxima(images(ii), Quantile, noiseMean, noiseStd);
end

% Display extrema of an arbitrary example
if plotting
    image = images(ceil(numel(images)/2));
    figure;
    imshow(image.data); hold on;
    scatter(images.statMaxima(:,2), images.statMaxima(:,1), 'rx');
    legend('Statistically selected maxima');
    title(['Statistically selected maximas for Q=' num2str(Quantile) ', \sigma_\Delta_I=' num2str(sigma/sqrt(3))]);
end


% Storing the processed image
% Create our image to store
tmpPath = ['../mat_files/' images(1).name(1:end-3) 'mat'];
tmpData = images(1);

% Create a clean directory for output
if exist('../mat_files','dir')
    rmdir('../mat_files', 's');
end
mkdir('../mat_files');

% Store
for ii = 1:Nimages
    tmpPath = ['../mat_files/' images(ii).name(1:end-3) 'mat'];
    tmpData = images(ii);
    save(tmpPath, 'tmpData' );
end
clear tmpPath tmpData;


%% Part B.3.1 Generating Synthetic Images
disp 'Generating synthetic image...'

% Use first image
sigma = rayleigh*2/3;
syntheticImage = generateSyntheticImage(images(1), sigma, ...
    noiseMean, noiseStd);

if plotting
    figure;
    subplot(2,1,1), imagesc(syntheticImage), title('Synthetic image');
    colormap gray, axis image;
    subplot(2,1,2), imagesc(images(1).data), title('Actual image');
    colormap gray, axis image;
end


%% Part B.3.2 Sub pixel resolution detection using oversampling

disp 'Detecting sub-pixel particles using Gaussian fitting...'

% Gaussian Kernel stuff is on Lectures 11 and 12 (same content)

% Scale to oversample by.
oversample_pixel = 13e-9;
oversample_scale = 65e-9 / oversample_pixel;

% Sigma for the gaussian kernel (airy disc)
sigma = 0.61 * 527e-9 / (1.4 * 3); % .61*lambda/(NA*3)

% Sub-pixel particle detection using Gaussian Kernel Fitting Algorithm
% on each image in the sequence
for ii = 1:Nimages
    
    % Oversample current image via interpolation
    interpolated_image = interpolateImage(images(ii).data,oversample_scale);
    
    % Create the 2D Gaussian kernel
    gauss_kernel = fspecial('gaussian', 11, 0.5);
    
    % Set up some variables for error calculation
    max_num = size(images(ii).maxima,1);
    subpixel_particles = zeros(max_num,2);
    
    % Iterate through each maximum from Section B.2.2
    for m = 1:max_num
        current_maxima = images(ii).maxima(m,:);
        current_errors = zeros(11*11,1);
        
        % Iterate through each pixel in a 5x5 box around current_maxima
        for i = -5:5
            for j = -5:5
                current_errors((i+5)*11 + j + 6) =...
                    kernelError(interpolated_image,...
                    (current_maxima(1,2) - 1) * 5 + 1 + i,...
                    (current_maxima(1,1) - 1) * 5 + 1 + j,...
                    gauss_kernel);
            end
        end
        
        % Find the subpixel with the minimum error, with respect to
        % the position of the current maxima
        [e,index] = min(current_errors);
        subpixel = [floor((index-1)/11)-5, mod(index-1,11)-5];
        
        % Scale the subpixel back
        subpixel_particles(m,:) = (subpixel)./5;
        
        % Location of the subpixel
        subpixel_particles(m,:) = subpixel_particles(m,:) + current_maxima;
        
    end
    
    % Show the particles on the image
    figure
    imshow(images(ii).data);
    hold on;
    scatter(round(subpixel_particles(:,2)),...
        round(subpixel_particles(:,1)), 'rx');
    title('Subpixel Detection using Gaussian Fit')
    legend('Sub-pixel Detected Particles');
    
end


%% Part B.3.3 Benchmarking subpixel resolution particle detection
disp 'Benchmarking subpixel performance using synthetic image...'

% First perform subpixel detection on the synthetic image
% TODO: plug in code
syntheticMaxima = [];

% For each maxima, find its nearest maxima and compute the error distance
% TODO: modify this to search for the maxima found in B.2.4
errors = [];
image = images(1);
for ii = 1:size(syntheticMaxima,1)
    maximum = syntheticMaxima(ii,:);
    
    lowestDistance = Inf;
    for jj = 1:size(image.maxima,1)
        
        distance = norm(image.maxima(jj,:) - maximum);
        if distance < lowestDistance
            lowestDistance = distance;
        end
    end
    
    errors = [errors lowestDistance]; %#ok append
end

% Compute the statistics and display
errorMean = mean(errors);
errorStd = std(errors);

disp(['    Subpixel detection had an average error of: ' num2str(errorMean)]);
disp(['    and a standard deviation of: ' num2str(errorStd)]);
