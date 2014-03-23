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
if exist('../mat_files','dir')
    rmdir('../mat_files', 's');
end
mkdir('../mat_files');

% Define parameters
plotting = true;


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


imagesDir = '../images/';
imagesFiles = dir([imagesDir '*.tiff']);
images = [];

N = numel(imagesFiles); % N = 1; %#ok only first
for ii = 1:N
    image.name = imagesFiles(ii).name;
    image.data = im2double(imread([imagesDir image.name]));
    images = [images; image]; %#ok append
end
clear imagesDir imagesFiles N image;


%% B.2 Characterizing fluorescence image background noise
disp 'Characterizing image background noise...'
% First define a crop region
% Hardcoded set to the entire bottom field of the image below the particles
region = [1 80 695 56];

% Then loop, cropping and computing distributions
for ii=1:numel(drosophilaImages)
    [drosophilaImages(ii).cropped, drosophilaImages(ii).nmean, ...
        drosophilaImages(ii).nvar] = ...
        computeNoiseDistribution(drosophilaImages(ii), region); %#ok
end

% Display results
if plotting
    % First display sample histogram
    noise = drosophilaImages(1).cropped(:);
    bins = 30;
    
    figure(); hold on;
    hist(noise, bins);
    
    % Overlay a normal distribution
    xs = linspace(min(noise), max(noise), 512);
    dist = normpdf(xs, drosophilaImages(1).nmean, ...
        sqrt(drosophilaImages(1).nvar));
    plot(xs, dist * max(hist(noise,bins)) / max(dist), 'r', 'LineWidth', 2);
    
    title('Distribution of noise in image background');
    legend('Actual', 'Ideal Gaussian');
    
    % Then display the mean and variance over time
    figure();
    ax = plotyy(1:numel(drosophilaImages), [drosophilaImages.nmean], ...
        1:numel(drosophilaImages), [drosophilaImages.nvar]);
    set(get(ax(1),'Ylabel'),'String','Noise mean');
    set(get(ax(2),'Ylabel'),'String','Noise variance');
    legend('Noise mean', 'Noise variance');
    title('Noise mean and variance over time');
end


clear region noise bins xs dist ax;


%% B.3 Characterizing illumination uniformity


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
clear curveDir curveFiles N image;


%% C.1 Implementation of the Steger?s algorithm


%% C.2 Implementation of the pixel linking operation
