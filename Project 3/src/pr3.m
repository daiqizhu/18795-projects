%
% 18-795 Project 3
% Alex Sun Yoo (ayoo), Michael Nye (mnye), Ozan Iskilibli (oiskilib)
% Spring, 2014
%
% This file should run the demo for project 3 by calling functions to 
% perform each action and displaying results between steps
%

% Clean up
clear all
close all
clc

% Create a clean directory for output
if exist('../outputs','dir')
    rmdir('../outputs', 's');
end
mkdir('../outputs');

% Define parameters
plotting = true;
normalityTest = false; % this is slow, so disable it for now



%% B.1 Read Image Data
disp 'PART 1', disp 'Loading image files...'

drosophilaDir = '../microscope_char/DrosophilaVesicleTransport/';
drosophilaFiles = dir([drosophilaDir '*.tif']);
drosophilaImages = [];

N = numel(drosophilaFiles); % N = 1; %#ok only first
for ii = 1:N
    image.name = drosophilaFiles(ii).name;
    image.data = im2double(imread([drosophilaDir image.name]));
    drosophilaImages = [drosophilaImages; image]; %#ok append
end
clear drosophilaDir drosophilaFiles N image;


calibrationDir = '../microscope_char/';
calibrationFiles = dir([calibrationDir '*.tif']);
calibrationImages = [];

N = numel(calibrationFiles); % N = 1; %#ok only first
for ii = 1:N
    image.name = calibrationFiles(ii).name;
    image.data = im2double(imread([calibrationDir image.name]));
    calibrationImages = [calibrationImages; image]; %#ok append
end
clear calibrationDir calibrationFiles N image;


% Hard code these two images (from Project 1)
imagesDir = '../images/';
images(1).name = [imagesDir 'image01.tiff'];
images(1).data = im2double(imread(images(1).name));

images(2).name = [imagesDir 'image02.tiff'];
images(3).name = [imagesDir 'image02.tiff'];

imginfo = imfinfo(images(2).name);
images(2).data = im2double(imread(images(2).name, 1, 'Info', imginfo));
images(3).data = im2double(imread(images(2).name, 2, 'Info', imginfo));

clear ii imagesDir imagesFiles imginfo N;



%% B.2 Characterizing fluorescence image background noise
disp 'Characterizing image background noise...'

% First define a crop region
% Hardcoded set to the entire bottom field of the image below the particles
region = [1 80 695 56];

% Then loop, cropping and computing distributions
for ii=1:numel(drosophilaImages)
    fprintf('    Computing for image %d\n', ii);
    [drosophilaImages(ii).cropped, drosophilaImages(ii).nmean, ...
        drosophilaImages(ii).nstd] = ...
        computeNoiseDistribution(drosophilaImages(ii), region); %#ok
    
    if normalityTest
        drosophilaImages(ii).normal = funcNormalityTest(drosophilaImages(ii));
    end
end


% Save the images
for ii=1:numel(drosophilaImages)
    image = drosophilaImages(ii);
    path = ['../outputs/' image.name(1:end-4) '_noise.tif'];
    imwrite(image.cropped, path, 'tif', 'Compression', 'none');
end


% Display results
if plotting
    % First display sample histogram
    displayNoiseHistogram(drosophilaImages(1), 30);
    
    % Then display the mean and variance over time
    displayNoiseStatistics(drosophilaImages);
end


% Perform analysis on images from pr1
region = [1 200 300 160];
[images(1).cropped, images(1).nmean, images(1).nstd] = ...
    computeNoiseDistribution(images(1), region);

region = [1 1 740 400];
[images(2).cropped, images(2).nmean, images(2).nstd] = ...
    computeNoiseDistribution(images(2), region);
[images(3).cropped, images(3).nmean, images(3).nstd] = ...
    computeNoiseDistribution(images(3), region);

if plotting
    displayNoiseHistogram(images(1), 4);
    displayNoiseHistogram(images(2), 4);
    displayNoiseHistogram(images(3), 4);
end


clear ii image path region;



%% B.3 Characterizing illumination uniformity

disp 'Calculating Illlumination Uniformity...'

% This code tests the computeUniformIllumination function on one image

% Get the noise sample to use for image 1
noise_sample = images(1).cropped;
noise_min = min(min(noise_sample));
noise_max = max(max(noise_sample));

% Calculate the uniformity of illumination
image_unif_illum = computeUniformIllumination(images(1).data,...
    noise_min, noise_max)


%% B.4 Microscope pixel calibration


%% B.5 Implementation of a directional anisotropic filter


%% C.0 Read Image Data
disp ' ', disp 'PART 2', disp 'Loading image files...'

curveDir = '../curve_detection_images/';
curveFiles = dir([curveDir '*.tif']);
curveImages = [];

N = numel(curveFiles); %N = 1; %#ok only first
for ii = 1:N
    image.name = curveFiles(ii).name;
    image.data = im2double(imread([curveDir image.name]));
    curveImages = [curveImages; image]; %#ok append
end
clear curveDir curveFiles ii image N;


%% C.1 Implementation of the Steger's algorithm
disp 'Performing Steger line detection...'

% First set sigma based on the maximum line size, visually estimated to be
% 10 pixels across. This is used for the Gaussian kernel.
sigma = 10/sqrt(3);

for ii=1:numel(curveImages)
    fprintf('    Computing for image %d\n', ii);
    
    % Compute the pixels on the line
    curveImages(ii).lineCoords = ...
        stegerLineDetection(curveImages(ii), sigma); %#ok
    
    %% Display the results
    if plotting
        figure();
        imagesc(curveImages(ii).data), colormap gray, axis image;
        
        xs = curveImages(ii).lineCoords(:,1);
        ys = curveImages(ii).lineCoords(:,2);
        hold on, scatter(xs, ys, 'r.');
        
        title(['Lines for image ' num2str(ii)]);
    end
end

clear sigma xs ys;

%% C.2 Implementation of the pixel linking operation
