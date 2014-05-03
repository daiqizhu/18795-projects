function labels = performNcut(image, n)
%
% Performs an n-cut graph segmentation on the given image.
%
% Inputs:  image - an image struct
%          n - the number of segments to create
%
% Outputs: labels - a matrix of labels for each segmented region
%

% Resize the image for speed reasons
img = imresize(image.data, 0.2);

% Perform segmentation
labels = NcutImage(img, n);

end