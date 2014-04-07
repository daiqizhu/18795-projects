function funcB5

clear all
close all

I = im2double(imread('../images/image01.tiff'));

sigmaU = 10;
sigmaV = 5;
theta = [0 30 60 90 120 150];

for i = 1:length(theta)
    kernel{i} = anisoGaussian(sigmaU, sigmaV, theta(i));
    y = filter2(kernel{i}, I);
    figure;imshow(y,[])
end


function kernel = anisoGaussian(sigmaU, sigmaV, theta)
%This part, I have asked professor
phi = atand((sigmaV^2*cosd(theta)^2 + sigmaU^2*sind(theta)^2)/...
    ((sigmaU^2-sigmaV^2)*sind(theta)*cosd(theta)));
sigmaX = sigmaU*sigmaV /sqrt( sigmaV^2*cosd(theta)^2 + ...
    sigmaU^2*sind(theta)^2 );
sigmaP = abs(1/sind(phi) *...
    sqrt( sigmaV^2*cosd(theta)^2 + sigmaU^2*sind(theta)^2 ));

% This part I am not sure (probably wrong)
x = -round(sigmaU):1:round(sigmaU);
y = -round(sigmaP):1:round(sigmaP);
kernel = zeros(length(x),length(y));
for i = 1:length(x)
    for j = 1:length(y)
        kernel(i,j) = 1/(2*pi*sigmaX*sigmaP)*exp(-0.5*( ...
            (x(i)-y(j)/tand(phi))^2/sigmaX^2 + ...
            (y(j)/sind(phi))^2/sigmaP^2 ) );
    end
end


