function coords = stegerLineDetection(image, sigma)
%
% Used for part C.1
%
% stegerLineDetection detects the points that lie on lines in the given
% image
%
% Inputs:  image - an image structure
%          sigma - the sigma used for the gaussian kernel to blur the image
%
% Outputs: coords - a matrix containing coordinates to points that are on a
%                   line. The first column is xs, the second is ys
%

% First blur the image
kernel = fspecial('gaussian', round([6*sigma+1 6*sigma+1]), sigma);
img = filter2(kernel, image.data);

% Compute the partial derivatives
dx = padarray(diff(img,1,2), [0 1], 'post');
dy = padarray(diff(img,1,1), [1 0], 'post');

% Any reason you don't use 'post' for dxdx and dydy?
dxdx = padarray(diff(img, 2, 2), [0 1]);
dydy = padarray(diff(img, 2, 1), [1 0]);
dxdy = padarray(diff(diff(img, 1, 2), 1, 1), [1 1], 'post');
dydx = padarray(diff(diff(img, 1, 1), 1, 2), [1 1], 'post');

% Perform computation on each pixel
coords = [];
for y=1:size(img,1)
    for x=1:size(img,2)
        
        % 0. Pack the hessian matrix and gradient
        hessian = [dxdx(y,x) dxdy(y,x); dydx(y,x), dydy(y,x)];
        grad = [dx(y,x); dy(y,x)];
        
        % 1. Pick the direction from the hessian's eigenvector
        [V,~] = eigs(hessian, 1);
        dir = V.'; % convert to row
        
        % 2. Compute first/second directional derivative
        r1 = dir * grad;
        r2 = dir * hessian * dir.';
        
        % 3. Determine local intensity
        xstar = -1 * r1 / r2;
        
        % 4. Classify the point based on xstar
        if abs(xstar) < 1/2
            coords = [coords; x y]; %#ok append
        end
    end
end

end