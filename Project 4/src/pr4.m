%
% 18-795 Project 4
% Alex Sun Yoo (ayoo), Michael Nye (mnye), Ozan Iskilibli (oiskilib)
% Spring, 2014
%
% This file should run the demo for project 4 by calling functions to 
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

% Add matitk to you search path
% matitk.dll or matitk.mex must be placed in ../matitk
addpath('../matitk');

% Define parameters
plotting = true;


%% B.1 Read Image Data
disp 'PART 1', disp 'Loading image files...'

imagesDir = '../images/';
images(1).name = [imagesDir '60x_02.tif'];
images(1).data = double(imread(images(1).name));

images(2).name = [imagesDir 'Blue0001.tif'];
images(2).data = double(imread(images(2).name));

clear imagesDir;

seriesDir = '../Mito_GFP_a01/';
seriesFile = dir([seriesDir '*.tif']);
seriesImages = [];

N = numel(seriesFile); % N = 1; %#ok only first
for ii = 1:N
    image.name = seriesFile(ii).name;
    image.data = double(imread([seriesDir image.name]));
    seriesImages = [seriesImages; image]; %#ok append
end
clear ii image N seriesDir seriesFile;


%% B.2.1 Segmentation of static images
disp 'Segmenting static images with SCT...'

% Hardcode values for first image
% TODO: fix the values that don't work
threshold = [400 800]; %#ok used
seeds = [400 69; 400 160; 400 250; 400 350; 400 440; 400 535; 400 720; ...
    400 900; 400 1000; ...% 400 1090; 400 1180; 400 1280; 400 1370];
    40 700; 134 700; 230 700; 602 700; 692 700; 785 700; 875 700; 971 700]; %#ok used

% Use evalc to supress output
[~,images(1).sctSegment] = evalc('performSCT(images(1), threshold, seeds)');


% Hardcode values for second image
threshold = [50 256]; %#ok used
seeds = [133 91; 19 187; 5 420; 188 413; 332 210; 337 436; 508 78]; %#ok used
        %; 439 555; 510 664];

% Use evalc to supress output
[~,images(2).sctSegment] = evalc('performSCT(images(2), threshold, seeds)');


disp 'Segmenting static images with SLLS...'

% Seed with a naive threshold
seed = double(images(1).data < 700); %#ok used
[~,images(1).sllsSegment] = evalc('performSLLS(images(1), seed)');

seed = double(images(2).data > 60); %#ok used
[~,images(2).sllsSegment] = evalc('performSLLS(images(2), seed)');


if plotting
    figure();
    subplot(1,2,1), imshow(images(1).sctSegment);
    title('SCT segmentation for image 1');
    subplot(1,2,2), imshow(images(1).sllsSegment);
    title('SLLS segmentation for image 1');
    
    figure();
    subplot(1,2,1), imshow(images(2).sctSegment);
    title('SCT segmentation for image 1');
    subplot(1,2,2), imshow(images(2).sllsSegment);
    title('SLLS segmentation for image 2');
end

clear threshold seed seeds;


%% B.2.2 Segmentation of image series
disp 'Segmenting image series...'


%% C.1.1 Graph cut based image segmentation
disp 'Performing graph cut segmentation...'


%% C.1.2 Active contour based image segmentation
disp 'Performing active countour segmentation...'


%% Make figures pretty and store them as pdfs
if plotting
    disp 'Saving figures...'
    funcPrettyFigures;
end