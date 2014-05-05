function labels = performNcut(image, n, rescaleFactor)
%
% Performs an n-cut graph segmentation on the given image.
%
% Inputs:  image - an image struct
%          n - the number of segments to create
%          rescaleFactor - how much to shrink the image before processing.
%                          Defaults to 0.2
%
% Outputs: labels - a matrix of labels for each segmented region
%

if nargin < 3
    rescaleFactor = 0.2;
end

% Resize the image for speed reasons
img = imresize(image.data, rescaleFactor);

% Perform segmentation
labels = NcutImage(img, n);

end