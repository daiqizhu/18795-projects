%
% 18-795 Project 3
% Alex Sun Yoo (ayoo), Michael Nye (mnye), Ozan Iskilibli (oiskilib)
% Spring, 2014
%
% This file should run the demo for project 3 by calling functions to 
% perform each action and displaying results between steps
%

% Clean up
clear all;
close all;
clc;

% Create a clean directory for output
if exist('../outputs','dir')
    rmdir('../outputs', 's');
end
mkdir('../outputs');

% Define parameters
plotting = true;
normalityTest = false; % this is slow, so disable it for now
calibrateAuto = true;


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
image_unif_illum_1 = computeUniformIllumination(images(1).data,...
    noise_min, noise_max) %#ok print out
image_unif_illum_2 = computeUniformIllumination(images(2).data,...
    noise_min, noise_max) %#ok print out
image_unif_illum_3 = computeUniformIllumination(images(3).data,...
    noise_min, noise_max) %#ok print out
image_unif_illum_noise_1 = computeUniformIllumination(images(1).cropped,...
    noise_min, noise_max) %#ok print out
image_unif_illum_noise_2 = computeUniformIllumination(images(2).cropped,...
    noise_min, noise_max) %#ok print out
image_unif_illum_noise_3 = computeUniformIllumination(images(3).cropped,...
    noise_min, noise_max) %#ok print out


%% B.4 Microscope pixel calibration
% Manual/ interactive approach to calibrate pixel size.

if  ~calibrateAuto
    % Predefined inputs, in case plotting is off.
    distance = [8 80 40 10 1]*10e-6;
    region = [ 32.0000e+000   366.0000e+000     1.2530e+003   282.0000e+000;
              134.0000e+000   363.0000e+000     1.2340e+003    92.0000e+000;
               26.0000e+000   375.0000e+000     1.2460e+003   177.0000e+000;
              244.0000e+000   237.0000e+000   933.0000e+000   339.0000e+000;
                1.0000e+000     1.0000e+000     1.0000e+000     1.0000e+000 ];

    % Sweep figures and store pixel sizes as well as cropped rectangles        
    for ii=1:(numel(calibrationImages)-1)
        [calibrationImages(ii).pixSize, calibrationImages(ii).rect] = ...
            funcCalibrateManually(calibrationImages(ii), plotting, ...
            region(ii, :), distance(ii));
    end
else 
    % Automated approach to calibrate pixel size.
    for ii=1:(numel(calibrationImages)-1)
         [calibrationImages(ii).autoPixSize] = ...
             funcCalibrateAuto(calibrationImages(ii), plotting);
    end
end
clear ii distance noise_sample noise_min noise_max region;


%% B.5 Implementation of a directional anisotropic filter
disp 'Performing anisotropic filtering...'

angles = [30 60 90 120 150];
sigmaU = 10;
sigmaV = 5;

if plotting
    figure();
    subplot(2,3,1);
    imagesc(images(1).data), colormap gray, axis image;
    title('Original image');
    for ii = 1:numel(angles)
        img = anisotropicGaussianFilter(images(1), angles(ii), sigmaU, ...
            sigmaV, 0.5);
        subplot(2,3,ii+1);
        imagesc(img), colormap gray, axis image;
        title(['Filtered at angle ' num2str(angles(ii)) '^\circ']);
    end
end


clear angles ii sigmaU sigmaV;


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
    [curveImages(ii).lineCoords ...
        curveImages(ii).lineDirs, ...
        curveImages(ii).deriv2] = ...
        stegerLineDetection(curveImages(ii), sigma); %#ok
end
    
% Display the results
for ii=1:numel(curveImages)
    if plotting
        figure();
        imagesc(curveImages(ii).data), colormap gray, axis image;

        xs = curveImages(ii).lineCoords(:,1);
        ys = curveImages(ii).lineCoords(:,2);
        hold on, scatter(xs, ys, 'r.');

        title(['Lines for image ' num2str(ii)]);
    end
end

clear ii sigma xs ys;


%% C.2 Implementation of the pixel linking operation
disp 'Linking line points...'

for ii=1:numel(curveImages)
    fprintf('    Computing for image %d\n', ii);
    
    [curveImages(ii).junctions, curveImages(ii).lines] = ...
        linkLines(curveImages(ii));
end

% Display our results
if plotting
    for ii=1:numel(curveImages)
        % Display image
        figure();
        imagesc(curveImages(ii).data), colormap gray, axis image;
    
        % Display junctions
        xs = curveImages(ii).junctions(:,1);
        ys = curveImages(ii).junctions(:,2);
        hold on, scatter(xs, ys, 'gx');
        
        % Draw lines
        for jj=1:length(curveImages(ii).lines)
            xs = [curveImages(ii).lines(jj,1) curveImages(ii).lines(jj,3)];
            ys = [curveImages(ii).lines(jj,2) curveImages(ii).lines(jj,4)];
            plot(xs, ys, 'r', 'LineWidth', 1.5);
        end
        
        % Label
        title(['Linked lines for image ' num2str(ii)]);
        legend('Junctions', 'Lines');
    end
end

clear ii jj strength;


%% Make figures pretty and store them as pdfs
disp 'Saving figures...'

if plotting
    funcPrettyFigures;
end