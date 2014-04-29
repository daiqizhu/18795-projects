function [snakeINIT, snakeFINAL, f] = performGVF(img, sigma, shape, plotting)
%
% Uses MATITK to perform Laplacian Level Set Segmentation.
%
% Inputs:  img - an img struct
%          sigma - Gaussian sigma for Canny Edge Detection
%          shape - snake shape, either 'rect' or 'circ'
%
% Outputs: snakeINIT    - initially selected snake
%          snakeFINAL   - converged snake
%


% Argument check
if nargin < 2
    sigma = 1;
    shape = 'rect';
    plotting = false;
elseif nargin < 3
    shape = 'rect';
    plotting = false;
elseif nargin < 4
    plotting = false;
end

% Argument consolidation
if strcmp(shape, 'rect') || strcmp(shape, 'circ')
else
    shape = 'rect';
end

% Initialization
[row, col] = size(img);


% Normalization and equalization of the image
tmp = img - min(min(img));
tmp = tmp / max(max(tmp));
tmp = imadjust(tmp);
disp('   Computing the edge map ...');

% Edge detection
level = graythresh(tmp);    % The average grayness is stored in level
bw = im2bw(tmp,level*0.8);  % Fully saturated
bw = bwareaopen(bw, 50);    % Remove regions with less than pixels
cc = bwconncomp(bw, 26);    % Finds regions with more than 26 pixels
grain = false(size(bw));    % Removes the rest of the img
for i = 1:cc.NumObjects
    grain(cc.PixelIdxList{i}) = true;
end
f = double(edge(grain,'canny',0.9,sigma)); % Detects edge with Canny method


% Compute the GVF of the edge map f
disp('   Compute GVF ...');
[u,v] = GVF(f, 0.2, 80); % f:edge map, mu: regularization const, ITER: iterations
disp('   Nomalizing the GVF external force ...');
mag = sqrt(u.*u+v.*v);
px = u./(mag+1e-10); py = v./(mag+1e-10);
[fx,fy] = gradient(f);

% Setting up initial snake

% User selection if plotting, predefined if not
if plotting
    disp('   Please select the initial snake as a region on the image');
    figure; imshow(img,[]); title('Please select the initial snake as a region on the image');
    rect = getrect; close gcf;
else    % Select a predefined value 
    %rect = [18.0000e+000    99.0000e+000   132.0000e+000    62.0000e+000];
    %rect = [474.0000e+000   148.0000e+000    38.0000e+000    42.0000e+000];
    rect = [147.0000e+000   257.0000e+000    23.0000e+000 27.0000e+000];
    %rect = [186.0000e+000   289.0000e+000    73.0000e+000    99.0000e+000];
    %rect = [547.0000e+000   378.0000e+000    53.0000e+000   119.0000e+000];
end
disp('   Building the GVF snake');

% Building the initial snake
if strcmp(shape, 'rect')
    x = [rect(1) rect(1)         rect(1)+rect(3) rect(1)+rect(3)];
    y = [rect(2) rect(2)+rect(4) rect(2)+rect(4) rect(2)];
else     % inner circle
    r = round(0.5*min(rect(3),rect(4)));
    x0 = rect(1) + round(0.5*rect(3));
    y0 = rect(2) + round(0.5*rect(4));
    t = linspace(0,2*pi,128);
    x = x0 + r * cos(t);
    y = y0 + r * sin(t);
end
% Interpolate the snake points so that they are at most 2 and
% at least 0.5 distances away 
[x,y] = snakeinterp(x,y,2,0.5);
snakeINIT = [x y];  % Store the inital snake

% Snake deformation
disp('   Starting GVF snake deformation');

if plotting
    figure('units','normalized','position',[.3 .1 .45 .8]);
    subplot(2,1,1); 
    imshow(img,[]); title('Original image');
    subplot(2,1,2); 
    imshow((1-f), []); title('Snake convergence on edge map')
    axis('square', 'off');
    colormap(gray(64));
    snakedisp(x,y,'r');
    pause(1);
    for i=1:25,
        [x,y] = snakedeform(x,y,0.05,0,1,0.6,px,py,5);
%         [x,y] = snakedeform(x,y,alpha,beta,gamma,kappa,fx,fy,ITER)
%         alpha:   elasticity parameter
%         beta:    rigidity parameter
%         gamma:   viscosity parameter
%         kappa:   external force weight
%         fx,fy:   external force field
        [x,y] = snakeinterp(x,y,2,0.5);
        snakedisp(x,y,'r')
        title(['Deformation in progress,  iter = ' num2str(i*5)])
        pause(0.5);
    end

else
    % Make sure that the snake points are at most 2 distances away and at least 0.5
    [x,y] = snakeinterp(x,y,2,0.5); 
    % 125 iterations of snake deformation (i.e. adaptation)
    [x,y] = snakedeform(x,y,0.05,0,1,0.6,px,py,125); 
    % Again compress & decompress snake points for 0.5< distance <2
    [x,y] = snakeinterp(x,y,2,0.5);
end
snakeFINAL = [x y];

% cla; 
% colormap(gray(64)); image(((1-f)+1)*40); axis('square', 'off');
% snakedisp(snakeFINAL(:,1),snakeFINAL(:,2),'r')
% title(['Final result,  iter = ' num2str(125)]);
% disp(' ');

disp('   GVF converged!');

end