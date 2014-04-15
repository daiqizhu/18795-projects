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

% Define parameters
plotting = true;


%% B.1 Read Image Data
disp 'PART 1', disp 'Loading image files...'

imagesDir = '../images/';
images(1).name = [imagesDir '60x_02.tif'];
images(1).data = im2double(imread(images(1).name));

images(2).name = [imagesDir 'Blue0001.tif'];
images(2).data = im2double(imread(images(2).name));

clear imagesDir;

seriesDir = '../Mito_GFP_a01/';
seriesFile = dir([seriesDir '*.tif']);
seriesImages = [];

N = numel(seriesFile); % N = 1; %#ok only first
for ii = 1:N
    image.name = seriesFile(ii).name;
    image.data = im2double(imread([seriesDir image.name]));
    seriesImages = [seriesImages; image]; %#ok append
end
clear ii image N seriesDir seriesFile;


%% B.2.1 Segmentation of static images
disp 'Segmenting static images...'


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