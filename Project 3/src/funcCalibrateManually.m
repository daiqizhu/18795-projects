function  [pixSize, rectangle] = funcCalibrateManually(image, plotting, ...
    region, distance)
%
% funcCalPixSize: Calibrates pixel size manually by cropping a rectangle
% and counting the how many bars wide the selection is
%
% Inputs:  image - an image struct
%          plotting - a boolean indicating whether to manually crop or not
%          region - a hard coded region to use if we are no plotting
%          distance - a hardcoded number of bars to 
% 
% Outputs: pixSize - pixel size
%

if plotting 
    img = image.data;
    img = img - min(min(img));
    img = img/max(max(img));
    [~, rectangle] = imcrop(img);
    microns = input('How many bars have you cropped along the x-axis? ');
    pixSize = microns*10e-6/floor(rectangle(3));
else
    rectangle = region;
    pixSize = distance/rectangle(3);
end

end
