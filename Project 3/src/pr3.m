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


%% B.1 Read Image Data
% Load our image files
disp 'Loading image files...'
imageFiles = dir('../images/*.tif');
images = [];

NimagesB = numel(imageFiles);
NimagesB = 1;

for ii = 1:NimagesB
    image.name = imageFiles(ii).name;
    img = im2double(imread(['../images/' image.name]));
    image.data = img / max(max(img));
    images = [images; image]; %#ok
end
clear img;


%% B.2 Characterizing fluorescence image background noise


%% B.3 Characterizing illumination uniformity


%% B.4 Microscope pixel calibration


%% B.5 Implementation of a directional anisotropic filter


%% C.0 Read Image Data


%% C.1 Implementation of the Steger?s algorithm


%% C.2 Implementation of the pixel linking operation
