function out = performSCT(image, threshold, seed)
%
% Uses MATITK to perform Connected Threshold Segmentation.
%
% Inputs:  image - an image struct
%          threshold - a pair of [lower, upper] for thresholding
%          seed - the starting locations, with each starting coordinate as
%                 its own row [x y]
%
% Outputs: out - a segmented image
%

% Input the image as a 3D matrix
in = repmat(image.data, [1 1 3]);

% Run ITK for each seed
out = zeros(size(in));
for ii=1:size(seed,1)
    out = out + matitk('SCT', threshold, in, [], [seed(ii,:) 1]);
end

% Convert to 1D and clip
out = out(:,:,1);
out(out > 255) = 255;

end