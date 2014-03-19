function [fx, fy] = funcDeriv(image)
%
% funcDeriv: finds the partial derivatives of an image
%
% Inputs:  image - an image struct
% 
% Outputs: fx    - partial derivative with respect to x
%          fy    - partial derivative with respect to y
%

% Extract data
img = image.data;

% Compute x partial
tmpX = [img(:,1) img img(:,end)];
tmpSize = size(tmpX);
tmpdX = tmpX*0;
for j=1:tmpSize(2)
    for i=2:tmpSize(1)-1
        tmpdX(i,j)= 0.5* (tmpX(i+1,j)-tmpX(i-1,j));
    end
end
fx = tmpdX(:,2:end-1);

% Compute y partial
tmpY = [img(1,:); img; img(end,:)];
tmpSize = size(tmpY);
tmpdY = tmpY*0;
for i=1:tmpSize(1)
    for j=2:tmpSize(2)-1
        tmpdY(i,j)= 0.5* (tmpY(i,j+1)-tmpY(i,j-1));
    end
end
fy = tmpdY(2:end-1,:);            

end
