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

% Input the image as a square 3D matrix. The square is to override a bug in
% the indexing for MATITK
in = image.data;
in = padarray(in, max(size(in)) - size(in), 'post');
in = repmat(in, [1 1 3]);

% Run ITK for each seed
out = zeros(size(in));
for ii=1:size(seed,1)
    out = out + matitk('SCT', threshold, in, [], [seed(ii,:) 1]);
end

% Convert to 1D, crop, and clip
out = out(:,:,1);
out = out(1:size(image.data,1), 1:size(image.data,2));
out(out > 255) = 255;

end