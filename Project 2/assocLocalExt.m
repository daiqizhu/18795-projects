function [associated visual] = assocLocalExt(img)

%
% Used for Part B.2.3 Association of local extremum points
%
% assocLocExt: finds triangles with maximized minimum angles
%              (Delaunay triangles), that has no vertices from other
%              triangles in its circumcircle and associates its corners as
%              local minimas for the brightest local maxima inside each
%              triangle
%
% Input:  img         - image structure, including data & extremum points
%
% Output: associated  - the data structure that includes the Delaunay
%                       triangles & associated local maximas' vector 
%                       indices as well as the mean value and the standard 
%                       deviation of the background. Respectively, 
%
%                               associated.triAddr  : Triangle addresses
%                               associated.LocalMax : Local max addresses
%                               associated.BGmu     : Background mean
%                               associated.BGstd    : Background std dev
%
%             visual  - the data structure for visualization of Delaunay
%                       triangles on the image
%

%% Triangulate all local minimas
visual = DelaunayTri(img.minima(:,2),img.minima(:,1));
tri = visual.Triangulation;

%% Sweep all triangles to match a local maxima to a background

% Initialization for searching throughout all triangles
tmpMax = 0; tmpIndex = 0;
for i = 1:size(tri,1)
    
    % Convert triangle corners' vector indices into minima matrix's indices
    tmp = img.minima(tri(i,:),:);
    Xtri = tmp(:,2);
    Ytri = tmp(:,1);
    % Find all maximas that fall into current triangle
    [IN ON] = inpolygon(img.maxima(:,2),img.maxima(:,1),Xtri, Ytri);
    % Get the row numbers of maximas that fell into current triangle
    indices = find(IN+ON);

    % If there is any maxima existent in current triangle
    if isempty(indices) == 0
        % Save their values and indices
        tmpMax = img.data(img.maxima(indices(1),1), ...
                                                img.maxima(indices(1),2));
        tmpIndex = indices(1);
        % If there are more than 1, store index and value of the maximum
        for j = 2:length(indices)
            if tmpMax < img.data(indices(j))
                tmpIndex = indices(j);
                tmpMax = img.data(img.maxima(indices(j),1), ...
                                                img.maxima(indices(j),2));
            end
        end
    else
    % Otherwise, just associate an empty cell for the maxima index
        tmpIndex = [];
    end
    
    %% The output data structure is defined here
    associated.triAddr{i} = [Xtri Ytri];
    associated.LocalMaxAddr{i} = [img.maxima(tmpIndex, 1) img.maxima(tmpIndex, 2)];
    associated.BGmu{i} = mean(img.minima(tri(i,:),:));
    associated.BGstd{i} = std(img.minima(tri(i,:),:));
end


end


