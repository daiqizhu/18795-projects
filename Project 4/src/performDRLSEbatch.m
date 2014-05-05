function [initialLSF, finalLSF] = performDRLSE(img, timestep, ...
    iter_inner, iter_outer, lambda, alpha, epsilon, numRegions, plotting)
%
% Performs Distance Regularized Level Set Evolution (DRLSE)
%
% Inputs:  img          - an img struct
%          timestep     - time step for evolution
%          iter_inner   - contour updated per iter_inner cycle
%          lambda       - coefficient of the weighted length term L(phi)
%          alpha        - coefficient of the weighted area term A(phi)
%          epsilon      - the width of the DiracDelta function
%          numRegions    - number of rectangles to be drawn to choose
%                         initial contour
%          plotting     - plotting on or off
%
% Outputs: initialLSF   - initially selected snake
%          finalLSF     - converged snake
%

disp('   Performing DRLSE...');

% Normalize the image and scale it back to 8 bits
tmp = img;
tmp2 = ( tmp - min(min(tmp)) ) / (max(max(tmp)) - min(min(tmp)));
img = round(double(tmp2(:,:,1))*255); 
clear tmp tmp2;

% Coefficient for distance regularization term R(phi)
mu=0.2/timestep;

disp('   Building edge indicator function...');
% Evaluating the edge indicator function, g
sigma=1;    % scale parameter in Gaussian kernel
G=fspecial('gaussian',15,sigma); % Caussian kernel
img_smooth=conv2(img,G,'same');  % smooth image by Gaussiin convolution
[Ix,Iy]=gradient(img_smooth);
f=Ix.^2+Iy.^2;
g=1./(1+f);  

% Initialization of level set function (LSF), phi
c0=2;
[row, col] = size(img);
initialLSF = c0*ones(row,col);
warning('off', 'MATLAB:colon:nonIntegerIndex');
if false
    h = figure; imshow(img,[]);
    disp('   Please select the initial snake as a region on the image');
    for i = 1:numRegions
        title(['Please select the area to initialize LSF region #' ...
        num2str(i) ]);
        rect=getrect;
        initialLSF(rect(2):rect(2)+rect(4), ...
            rect(1):rect(1)+rect(3)) = -c0;
    end
    clear i;
else
        rect = [ 5.0000   80.0000  col-5   15.0000];
        initialLSF(rect(2):rect(2)+rect(4), ...
            rect(1):rect(1)+rect(3)) = -c0;
end
warning('on', 'MATLAB:colon:nonIntegerIndex');
phi=initialLSF;

disp('   Initial level set has been built.');

% Choosing the potential function
potentialFunction = 'double-well';

% Evolution of level set
if plotting
    figure(h); imshow(img,[]); axis off; axis equal; colormap(gray);
    hold on;  contour(phi, [0,0], 'r');
    title('DRLSE contour, iteration 0');
end

disp('   Evolving the level set...');
for n=1:iter_outer
    phi = drlse_edge(phi, g, lambda, mu, alpha, epsilon, ...
                        timestep, iter_inner, potentialFunction);    
    if plotting && mod(n,2)==0
        figure(h); hold on;  [~,h3] = contour(phi, [0,0], 'r');
        title(['DRLSE contour, iteration ' num2str(n*iter_inner)]);
    end
end

% Evolution for 10 iterations for no line integral weight, in order to
% deal with boundary leakage during the segmentation
iter_refine = 10;
phi = drlse_edge(phi, g, lambda, mu, 0, epsilon, ...
                        timestep, iter_refine, potentialFunction);
finalLSF=phi;

if plotting
    figure(h);
    axis off; axis equal; colormap(gray); 
    hold on;  [~,h1] = contour(initialLSF, [0,0], 'c');
    hold on;  [~,h2] = contour(finalLSF, [0,0], 'y');
    str=['Final zero level contour in DRLSE, ', ...
        num2str(iter_outer*iter_inner+iter_refine), ' iterations'];
    title(str);
    legend([h1 h3 h2], 'Initial snake', 'Interim snakes', 'Final snake')
end

disp('   DRLSE converged!');


end


