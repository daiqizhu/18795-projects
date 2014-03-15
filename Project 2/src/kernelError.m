function [ error ] = kernelError( image, x, y, kernel )
%
% Used for Part B.3.2 Sub-Pixel Resolution Detection Algorithm
%
% Generates a gaussian kernel for sub-pixel resolution detection, given the
% image and the point's location to do the fitting at
%
% Inputs:  image - an image to compare the kernel with
%          x - the x coordinate (column number) of the point
%          y - the y coordinate (row number) of the point
%          kernel - a Gaussian kernel for the purposes of this project
%
% Outputs: error - the error between the kernel and image
%

x_min = x; x_max = x+size(kernel,2)-1;
y_min = y; y_max = y+size(kernel,1)-1;

% Determine bounds of the image to extract the subimage for fitting
x_min = x_min - ceil(size(kernel,2)/2);
x_max = x_max - ceil(size(kernel,2)/2);
y_min = y_min - ceil(size(kernel,1)/2);
y_max = y_max - ceil(size(kernel,1)/2);

% kernel_fit will be shaped appropriately to deal with edge cases
% otherwise it is just the same as kernel
kernel_fit = kernel;

% Edge cases
if x_min < 1
    colsToRemove = 1 - x_min;
    kernel_fit = kernel_fit(:,colsToRemove+1:size(kernel,2));
    x_min = 1;
    size(kernel_fit)
end
if x_max > size(image,2)
    colsToRemove = x_max - size(image,2);
    kernel_fit = kernel_fit(:,1:size(kernel_fit,2) - colsToRemove);
    x_max = size(image,2);
end
if y_min < 1
    rowsToRemove = 1 - y_min;
    kernel_fit = kernel_fit(rowsToRemove+1:size(kernel,1),:);
    y_min = 1;
end
if y_max > size(image,1)
    rowsToRemove = y_max - size(image,1);
    kernel_fit = kernel_fit(1:size(kernel_fit,1) - rowsToRemove,:);
    y_max = size(image,1);
end
    
% Calculate the error between the subimage and the kernel_fit
subimage = image(y_min:y_max, x_min:x_max);
error = sum(sum((subimage - kernel_fit).^2));

% Normalize by the  energy
error = error / sum(sum(subimage.^2));
error = error / sum(sum(kernel_fit.^2));

end

