function  [pixSize] = funcCalibrateAuto(image, plotting)
%
% funcCalPixSize: Finds pixel size automatically
%
% Inputs:  image     - an image struct
%          plotting  - plotting enable flag
% 
% Outputs: pixSize   - pixel size
%

img = imadjust(image.data);
imgName = num2str(sscanf(image.name, '%d%*c',[1 inf]));
if isempty(imgName)
    imgName = 'stage background';
else
    imgName = ['calibration image for ' imgName 'X magnification'];
end

% Find all edges in the image
BW = edge(img,'canny');

% Standardized Hough Transform of the edges, only vertically searched
[H,T,R] = hough(BW, 'RhoResolution', 1, 'Theta', -1:0.01:1);
P  = houghpeaks(H,1e12); %, 'threshold',ceil(0.5*max(H(:))));

if plotting
    % Shows the image in Hough domain
    figure
    imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal, hold on;
    x = T(P(:,2)); 
    y = R(P(:,1));
    plot(x,y,'s','color','white');
    colorbar
    colormap(hot)
    title(['Hough transform of ' imgName]);
end 

% Finds Hough Transform edges
houghLines = houghlines(BW,T,R,P,'FillGap', 3,'MinLength',35);

% Shows the processed calibration image together with the found edges
if plotting
    figure, imshow(img, []), hold on
    title(['The ' imgName ...
        ', together with the detected vertical Hough edges'])
    for k = 1:length(houghLines)
        xy = [houghLines(k).point1; houghLines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        % Plots beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
    legend('Detected edges', 'Edge start', 'Edge end');
end 

% Assuming the lines are almost vertical, the x-position of only one of the
% Hough line beginning OR end points is necessary. We pick the x coordinate of 
% beginning point

firstPoints = zeros(1,length(houghLines));
firstPoints(1) = houghLines(1).point1(1);
for i = 2:length(firstPoints)
    firstPoints(i) = houghLines(i).point1(1);
end
% Sort them to find relative distances
firstPoints = sort(firstPoints);

% We assume the first line is correctly found. 
sortedPoints =[firstPoints(1)];
% All the rest of the points must be at least 20 pixels away
for i = 2:length(firstPoints)
    if  firstPoints(i) - sortedPoints(end) >= 20
        sortedPoints = [sortedPoints firstPoints(i)];
    end
end
% New list of sortedPoints are statistically examined in terms of the 
% lateral separation.
d_points = diff(sortedPoints);
std_d_points = std(diff(d_points));
mean_d_points = mean(diff(d_points));

% If the difference of 2 points is less than a standard deviation, then
% this must be discarded, otherwise, we assume finding new edges
threshold = mean_d_points + 1*std_d_points;
xpoints = [sortedPoints(1)];
for i = 2:length(sortedPoints)
    if d_points(i-1) > threshold
       xpoints = [xpoints sortedPoints(i)];
    end
end

% For a bar to bar distance of 10um, we can deduce the pixel size 
pixSize = (length(xpoints)*10e-6 ) / (max(xpoints) - min(xpoints) );



end
