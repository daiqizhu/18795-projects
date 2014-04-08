function outImg = anisotropicGaussianFilter(image, angle, ...
    sigmaU, sigmaV, a)
%
% Used in part B5
%
% Given an image struct, and filter parameters, returns an image that has
% been anisotropically filtered with the given parameters
%
% Inputs:  image - an image struct containing data
%          angle - the angle, in degrees, at which to filter
%          sigmaU - the filter sigma on the primary axis
%          sigmaV - the filter sigma normal to the primary axis
%          a - the interpolation constant used in the off axis filter
%
% Outputs: outImg - a filtered image matrix
%

% Convert angle to radians
theta = angle*pi/180;

% Compute intermediate values for filter coefficients
a11 = (sigmaU * cos(theta))^2 + (sigmaV * sin(theta))^2;
a12 = (sigmaU^2 - sigmaV^2)*cos(theta)*sin(theta);
a22 = (sigmaV * cos(theta))^2 + (sigmaU * sin(theta))^2;


% First perform an isotropic, 1D filter along the x-axis
sigmaX = sqrt(a11 - a12^2/a22);
N = floor(3*sigmaX);
kernel = 1/(2*pi*sigmaX) * exp(-1/2 * (-N:N).^2 / sigmaX^2);
tmpImg = filter2(kernel, image.data);


% Next perform a 1D filter along the primary axis
sigmaPhi = sqrt(a22);
if mod(angle,90) == 0
    mu = 0;
else
    mu = a12/a22;
end
N = floor(3*sigmaPhi);

% Pad the tmp img with zeros for convenience
outImg = zeros(size(tmpImg));
xpad = ceil(abs(mu)*N+1);
tmpImg = padarray(tmpImg, [N xpad]);
for x = 1:size(outImg, 2)
    for y = 1:size(outImg,1)
        out = 1/(2*pi*sigmaPhi) * tmpImg(y+N,x+xpad);
        for ii = 1:N
            kernel = 1/(2*pi*sigmaPhi) * ...
                exp(-1/2 * (1+mu^2)*ii^2 / sigmaPhi^2);
            out = out + kernel * ...
                (a * (tmpImg(y-ii+N, floor(x-mu*ii)+xpad) + ...
                      tmpImg(y+ii+N, floor(x+mu*ii)+xpad)) + ...
                 (1-a) * (tmpImg(y-ii+N, floor(x-mu*ii)-1+xpad) + ...
                          tmpImg(y+ii+N, floor(x+mu*ii)+1+xpad)));
        end
        outImg(y,x) = out;
    end
end

end