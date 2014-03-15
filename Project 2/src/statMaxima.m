function [statisticalMaxima] = statMaxima(img, Q, noiseMean, noiseStd)

%
% Used for Part B.2.3 Association of local extremum points
%
% statMaxima: Finds all local maximas that pass t-test
%
% Input:    img        - image structure, including data & extremum points
%           Q          - t-test quantile
%           noiseMean  - average background noise level, obtained in part B.2.1
%           noiseStd   - std dev of the background noise, obtained in part B.2.1
%
% Output: statisticalMaxima  - List of the coordinates of the statistically
%                              selected local maxima
%

%% Statistically select local maximas

% Initialization
Ntriangles = size(img.associated.triAddr,2);
statisticalMaxima = [];
intensities = [];

% Sweep all the triangles
for i = 1:Ntriangles
    % in order to find their associated local maximas
    if isempty(img.associated.LocalMaxAddr{i}) == 0
        % If maxima is trustworthy
        if img.data(img.associated.LocalMaxAddr{i}(1), img.associated.LocalMaxAddr{i}(2))...
                                >= (Q*1/sqrt(3)*noiseStd + noiseMean)
            % Store it gladly
            statisticalMaxima = [statisticalMaxima; img.associated.LocalMaxAddr{i}];
        end
    end    
end

end


