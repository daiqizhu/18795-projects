function  [pixSize, rectangle] = funcCalibrateAuto(image, plotting, region, distance)
%
% funcCalPixSize: Calibrates pixel size manually
%
% Inputs:  image   - an image struct
% 
% Outputs: pixSize - pixel size
%

if plotting 
    [sample, rectangle] = imcrop(image.data, []);
    disp('How many bars have you cropped?')
    microns = input('');
    pixSize = microns*10e-6/floor(rectangle(3));
else
    sample = imcrop(image.data,region); 
    rectangle = region;
    pixSize = distance/rectangle(3);
end

end
