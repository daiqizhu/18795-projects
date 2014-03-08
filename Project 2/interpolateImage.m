function [ interpolated_image ] = interpolateImage( image, scale )
%
% Used for Part B.3.2 Sub-Pixel Resolution Detection Algorithm
%
% Interpolates the given 2D image, upscaling it by a given numeric factor
% in both dimensions.
%
% Inputs:  image - a 2D image (not a structure)
%          scale - the integer scalar to scale the interpolation. it is
%               assumed that this is a positive integer.
%
% Outputs: output - the interpolated image
%

x_max = size(image,2);
y_max = size(image,1);
k = 1/scale;

[X,Y] = meshgrid(1:x_max, 1:y_max);
[Xq,Yq] = meshgrid(1:k:x_max, 1:k:y_max);

interpolated_image = interp2(X,Y,im2double(image),Xq,Yq);

end