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
    startP = image.lineCoords(ii,:);
    if visited(startP(2), startP(1))
        continue;
    end
    
    % Search in both directions starting from here
    startDir = [-1 1] .* round(image.lineDirs(ii,:)); % get normal dir
    for m=[-1 1]
        dir = m*startDir;
        p = startP;
        foundNodes = 0;
        while p
            % Mark this node as visited
            visited(p(2), p(1)) = 1;
            
            % First determine the stronger direction
            [~,strong] = max(abs(dir));
            weak = setdiff([1 2], strong);
            
            % Travel up to the specified direction out
            found = false;
            for s = 1:searchStrength
                % Walk out
                strength = abs(floor(dir(weak)*s/dir(strong)));
                if strength == 0
                    strength = s;
                end
                newP = p;
                newP(strong) = newP(strong) + sign(dir(strong))*strength;
                newP(weak)   = newP(weak) + sign(dir(weak))*s;
                
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
                foundNodes = foundNodes + 1;
                
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
            end
        end
    end
end

end