%
% 18-795 Project 2
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


% Load our image files
disp 'Loading image files...'
imageFiles = dir('../images/*.tif');
images = [];

Nimages = numel(imageFiles);
Nimages = 1;

for ii = 1:Nimages
    image.name = imageFiles(ii).name;
    img = im2double(imread(['../images/' image.name]));
    image.data = img / max(max(img));
    images = [images; image]; %#ok
end
clear img;


% Compute image gradients
[images(1).dx images(1).dy] = funcDeriv(images(1).data);
