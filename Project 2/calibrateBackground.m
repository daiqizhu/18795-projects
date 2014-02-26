function [noiseMean, noiseStd] = calibrateBackground(img)
%
% calibrateBackground: finds the mean and standard deviation of background
%                      noise in an image. Asks the user to manually box a
%                      region of background.
%
% Inputs:  img - an image matrix
%
% Outputs: mean - the mean of selected noise
%          std  - the standard deviation of selected noise
%

% Display the image and ask for a box
figure, imshow(img), title('Select a rectangle of background...');
rect = getrect; close;

% Crop out the specified region
xmin = ceil(rect(1));          ymin = ceil(rect(2));
xmax = xmin + floor(rect(3));  ymax = ymin + floor(rect(4));
background = img(ymin:ymax, xmin:xmax);

% Calculate statistics
noiseMean = mean(background(:));
noiseStd = std(background(:));

end