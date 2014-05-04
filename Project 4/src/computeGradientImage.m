function gradientImage = computeGradientImage(image)
%
% Computes the gradient edge image of an input image
%
% Inputs:  image - an image matrix
%
% Outputs: gradientImage - an color image matrix that is the gradient magnitude
%                          of the input matrix
%

[Fx,Fy] = gradient(image);
gradientImage = Fx.^2 + Fy.^2 > 0;

end