function h = funcNormalityTest(image)
%
% Used for Part B.2
%
% determines whether
%
% Inputs:  image   - an image structure containing data%
%
% Outputs: h       - a boolean that returns true when the data is normal

% Use kstest to classify its likelihood of being normal
% First seed the noise with small random data to account for quantization
noise = image.cropped(:);
data = noise + 0.1*std(noise)*randn(size(noise,1),1);
h = kstest((data - mean(data))/std(data));
h = ~h; % flip because of MATLAB convention...

end