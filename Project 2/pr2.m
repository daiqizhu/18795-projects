%
% 18-795 Project 2
% Alex Sun Yoo (ayoo), Michael Nye (mnye), Ozan Iskilibli (oiskilib)
% Spring, 2014
%
% This file should run the demo for project 2 by calling functions to 
% perform each action and displaying results between steps
%

% Define constants
maskSize = 3;
plotting = true;

% Rayleigh limit
rayleighM = 0.61 * 527e-9 / 1.4; % .61*lambda/NA, in m
rayleigh  = rayleighM / 65e-9; % convert to pixels

% Load our image files
disp 'Loading image files...'
imageFiles = dir('images/*.tif');
images = [];

% For testing purposes, only load first image
for ii = 1:1 %numel(imageFiles)
    image.name = imageFiles(ii).name;
    img = im2double(imread(['images/' image.name]));
    image.data = img / max(max(img));
    images = [images; image]; %#ok
end


%% B.2.1 Calibration of dark noise
disp 'Calibrating noise...'

% Manually crop a portion of background noise and determine its statistics.
% Choose an arbitrary image for this
img = images(ceil(numel(images)/2)).data;
[noiseMean, noiseStd] = calibrateBackground(img);


%% B.2.2 Detection of local maxima and local minima
disp 'Detecting minima and maxima...'

% First compute the sigma based on the rayleigh limit
sigma = rayleigh/3;

% For each image, find the extrema and store it
for ii = 1:numel(images)
    [maxima, minima] = findLocalExtrema(images(ii).data, maskSize, sigma);
    images(ii).maxima = maxima; %#ok
    images(ii).minima = minima; %#ok
end

% Display extrema of an arbitrary example
if plotting
    image = images(ceil(numel(images)/2));
    
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
for ii = 1:numel(images)
    [images(ii).associated visual] = assocLocalExt(images(ii));
end

if plotting
    imageIndex = ceil(numel(images)/2);
    image = images(imageIndex);
    tmp = size(image.associated.triAddr,2);
    tmpLocalMax = [];
    for ii = 1:tmp;
        tmpLocalMax = [tmpLocalMax; images.associated.LocalMaxAddr{ii}];
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
% TODO


%% Part B.3.1 Generating Synthetic Images
disp 'Generating synthetic image...'

% Use first image
% TODO: make sure this uses the maxima found in part B.2.4, NOT in B.2.2
sigma = rayleigh*2/3;
syntheticImage = generateSyntheticImage(images(1), sigma, ...
    noiseMean, noiseStd);

figure;
subplot(2,1,1), imagesc(syntheticImage), title('Synthetic image');
colormap gray, axis image;
subplot(2,1,2), imagesc(images(1).data), title('Actual image');
colormap gray, axis image;


%% Part B.3.2 Sub pixel resolution detection using oversampling
% TODO - Create Gaussian Kernel and do the detection
%
% Gaussian Kernel stuff is on Lectures 11 and 12 (same content)

% Scale to oversample by.
oversample_pixel = 13e-9;
oversample_scale = 65e-9 / oversample_pixel;

% Sub-pixel particle detection using Gaussian Kernel Fitting Algorithm
% on each image in the sequence
for ii = 1:numel(images)
    
    % Oversample current image via interpolation
    interpolated_image = interpolateImage(images(ii).data,oversample_scale);
    
    % Create the 2D Gaussian kernel
    
    
    
    
end