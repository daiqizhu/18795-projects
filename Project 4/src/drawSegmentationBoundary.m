function drawSegmentationBoundary(segmentImage, color)
%
% Given an image of a segmentation, draws just the boundary on top of the
% current figure
%
% Inputs: segmentImage - an image matrix that with segments given as
%                        different intensities
%         color - either 'r', 'g', or 'b' for the color of the line.
%                 Defaults to red.
%
% Outputs: a drawing on the current figure
%

if nargin < 2
    color = 'r';
end

% Generate a color plane
img = zeros([size(segmentImage) 3]);
if color == 'r'
    img(:,:,1) = 1;
elseif color == 'g'
    img(:,:,2) = 1;
else
    img(:,:,3) = 1;
end

% Get the gradient image
g = computeGradientImage(segmentImage);

% Draw on our figure
h = imshow(img);
set(h, 'AlphaData', g);

end