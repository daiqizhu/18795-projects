function out = performSLLS(image, seed, propogationScaling, isoSurfaceValue)
%
% Uses MATITK to perform Laplacian Level Set Segmentation.
%
% Inputs:  image - an image struct
%          seed - a basic segmentation of the image to refine
%          propogationScaling - scaling for level set gradient.
%                               Defaults to 0.
%          isoSurfaceValue - the seed boundary parameter. Defaults to 0.5.
%                            Should be halfway between your two values
%
% Outputs: out - a segmented image
%

if nargin < 3
    propogationScaling = 0;
end
if nargin < 4
    isoSurfaceValue = 0.5;
end

% Input the image as a 3D matrix
in = repmat(image.data, [1 1 3]);
seed = repmat(seed, [1 1 3]);

% Run ITK with recommended parameter values from the documentation
out = matitk('SLLS', [isoSurfaceValue, propogationScaling, 1.0, 0.02, 800], ...
    in, seed);

% Reverse so white is our detected
out = max(max(max(out))) - out;

end