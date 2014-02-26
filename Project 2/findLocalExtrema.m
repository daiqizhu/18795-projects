function [maxima, minima] = findLocalExtrema(img, maskSize, sigma)
%
% findLocalExtrema: finds all the maxima and minima in a given image
%
% Inputs:  img      - an image matrix
%          maskSize - the width of the box we will search around to 
%                     identify local extrema, in pixels
%          sigma    - the standard deviation of our gaussian kernel used
%                     for smoothing, in pixels
%
% Outputs: maxima   - the set of coordinates where local maxima are found
%          minima   - the set of coordinates where local minima are found;
%     Each row of the output is the [row, col] of the coord, and are in
%     no particular order
%

% Get a gaussian kernel, out to three sigma in all directions,
% then filter our image
kernel = fspecial('gaussian', round([6*sigma+1 6*sigma+1]), sigma);
img = filter2(kernel, img);


% For each pixel in the image, search its surroundings. If it is the
% smallest or largest, record it as such
maskSize = floor(maskSize/2);
minimaLocs = zeros(size(img,1), size(img,2));
maximaLocs = zeros(size(img,1), size(img,2));
for y = 1:size(img,1)
    for x = 1:size(img,2)
        % Get the surrounding region based on the mask size
        ylow = max(1, y-maskSize);  yhi = min(size(img,1), y+maskSize);
        xlow = max(1, x-maskSize);  xhi = min(size(img,2), x+maskSize);
        surroundings = img(ylow:yhi, xlow:xhi);
                
        % If this point is the max or min of all its neighbors, record it
        if max(surroundings(:)) == img(y,x)
            maximaLocs(y,x) = 1;
        elseif min(surroundings(:)) == img(y,x)
            minimaLocs(y,x) = 1;
        end
    end
end


% Extract the coordinates from the boolean matrix
[rows, cols] = find(minimaLocs);
minima = [rows cols];

[rows, cols] = find(maximaLocs);
maxima = [rows cols];

end