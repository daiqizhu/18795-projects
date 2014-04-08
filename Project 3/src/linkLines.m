function [junctions, lines] = linkLines(image, searchStrength)
%
% Used in Part C2
%
% Given an image struct with line points found, links these points into
% lines
%
% Inputs:  image - an image struct
%          searchStrength - how far out to search in each direction
%
% Outputs: junctions - a matrix with junction locations. Each row is a
%                      junction with [x y]
%          lines - a matrix with line locations. Each row is a line with 
%                  format [x1 y1 x2 y2]
%

% Get indices in order from most to least intense
[~,I] = sort(abs(image.deriv2), 'descend');

% Create a lookup matrix of points to their index
points = zeros(size(image.data));
for ii = 1:length(image.lineCoords)
    points(image.lineCoords(ii,2), image.lineCoords(ii,1)) = ii;
end

% Create containers
junctions = [];
lines = [];

% Track whether a point has been visited
visited = zeros(size(image.data));
for ii = I'
    startP = image.lineCoords(ii,:)
    
    % Search in both directions starting from here
    startDir = [-1 1] .* round(image.lineDirs(ii,:)); % get normal dir
    
    for m=[-1 1]
        dir = m*startDir;
        p = startP;
        
        % Keep traversing while we keep finding points
        while p            
            % Stop if we have seen this node, otherwise visit it
            if visited(startP(2), startP(1))
                break;
            else
                visited(p(2), p(1)) = 1;
            end
            
            % First determine the stronger direction
            [~,strong] = max(abs(dir));
            weak = setdiff([1 2], strong);
            
            % Travel out around the corner
            searchDirs = [0 0; 0 0; 0 0];
            if dir(weak) == 0
                searchDirs(:,strong) = sign(dir(strong)) * [1; 1; 1];
                searchDirs(:,weak)   = [-1; 0; 1];
            else
                searchDirs(:,strong) = sign(dir(strong)) * [1; 1; 0];
                searchDirs(:,weak)   = sign(dir(weak)) * [0; 1; 1];
            end
            
            found = false;
            for searchDir = searchDirs'
                % Walk out
                newP = p;
                newP(strong) = newP(strong) + searchDir(strong);
                newP(weak)   = newP(weak) + searchDir(weak);
                
                % If this is a point, break out, we're done
                if newP(1) < 1 || newP(2) < 1 || ...
                        newP(1) > size(points,2) || newP(2) > size(points,1)
                    break;
                end
                if points(newP(2), newP(1))
                    found = true;
                    break;
                end
            end
            
            % If we found a point, we update the stats we found
            % Otherwise, stop searching
            if found                
                % Add this line to the set
                lines = [lines; p newP]; %#ok append
                
                % Add this as a junction if we have seen it before
                if visited(newP(2), newP(1))
                    junctions = [junctions; newP]; %#ok append
                end
                    
                % Update the state
                p = newP;
                idx = points(p(2), p(1));
                
                % Find the closest dir
                image.lineDirs(idx,:);
                newDir = round([-1 1] .* image.lineDirs(idx,:));
                if norm(dir - newDir) > norm(dir + newDir)
                    newDir = -1*newDir;
                end
                dir = newDir;
            else
                p = [];
            end % if found
        end % keep traversing
    end % search in both directions
end

end