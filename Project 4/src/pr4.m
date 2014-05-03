%
% 18-795 Project 4
% Alex Sun Yoo (ayoo), Michael Nye (mnye), Ozan Iskilibli (oiskilib)
% Spring, 2014
%
% This file should run the demo for project 4 by calling functions to 
% perform each action and displaying results between steps
%

% Clean up
clear all;
close all;
clc;

% Create a clean directory for output
if exist('../outputs','dir')
    rmdir('../outputs', 's');
end
mkdir('../outputs');

% Add matitk to you search path
% matitk.dll or matitk.mex must be placed in ../matitk
addpath('../matitk');
% Add directory containing GVF functions
addpath('../gvf');
% Add directory containing GVF functions
addpath('../drlse');

% Define parameters
plotting = true;
processImageSeries = false; % disable because it is slow

% Suppress image resizing warning
warning('off',  'images:initSize:adjustingMag'); 


%% B.1 Read Image Data
disp 'PART 1', disp 'Loading image files...'

imagesDir = '../images/';
images(1).name = '60x_02.tif';
images(1).data = double(imread([imagesDir images(1).name]));

images(2).name = 'Blue0001.tif';
images(2).data = double(imread([imagesDir images(2).name]));

clear imagesDir;

seriesDir = '../Mito_GFP_a01/';
seriesFile = dir([seriesDir '*.tif']);
seriesImages = [];

N = numel(seriesFile); % N = 1; %#ok only first
for ii = 1:N
    image.name = seriesFile(ii).name;
    image.data = double(imread([seriesDir image.name]));
    seriesImages = [seriesImages; image]; %#ok append
end
clear ii image N seriesDir seriesFile;


%% B.2.1 Segmentation of static images
disp 'Segmenting static images with SCT...'

% Hardcode values for first image
% TODO: fix the values that don't work
threshold = [400 800]; %#ok used
seeds = [400 69; 400 160; 400 250; 400 350; 400 440; 400 535; 400 720; ...
    400 900; 400 1000; 400 1090; 400 1180; 400 1280; 400 1370; 40 700; ...
    134 700; 230 700; 602 700; 692 700; 785 700; 875 700; 971 700]; %#ok used

% Use evalc to supress output
[~,images(1).sctSegment] = evalc('performSCT(images(1), threshold, seeds)');


% Hardcode values for second image
threshold = [50 256]; %#ok used
seeds = [133 91; 19 187; 5 420; 188 413; 332 210; 337 436; 508 78; ...
    439 555; 510 664]; %#ok used

% Use evalc to supress output
[~,images(2).sctSegment] = evalc('performSCT(images(2), threshold, seeds)');


disp 'Segmenting static images with SLLS...'

% Seed with a naive threshold
seed = double(images(1).data < 700); %#ok used
[~,images(1).sllsSegment] = evalc('performSLLS(images(1), seed)');

seed = double(images(2).data > 60); %#ok used
[~,images(2).sllsSegment] = evalc('performSLLS(images(2), seed)');


% Display results
if plotting
    figure();
    subplot(1,2,1), imshow(images(1).sctSegment);
    title('SCT segmentation for image 1');
    subplot(1,2,2), imshow(images(1).sllsSegment);
    title('SLLS segmentation for image 1');
    
    figure();
    subplot(1,2,1), imshow(images(2).sctSegment);
    title('SCT segmentation for image 1');
    subplot(1,2,2), imshow(images(2).sllsSegment);
    title('SLLS segmentation for image 2');
end


% Save results
for ii = 1:length(images)
    sct = ['../outputs/' images(ii).name(1:end-4) '_sct.tif'];
    imwrite(images(ii).sctSegment, sct, 'tif', 'Compression', 'none');

    slls = ['../outputs/' images(ii).name(1:end-4) '_slls.tif'];
    imwrite(images(ii).sllsSegment, slls, 'tif', 'Compression', 'none');
end


clear ii threshold sct seed seeds slls;


%% B.2.2 Segmentation of image series
disp 'Segmenting image series...'

% Hard code thresholds for two methods
sctThresh = [150 1024]; sctPeakThresh = 200; %#ok used
sllsThresh = 200;

for ii = 1:max(1, length(seriesImages) * processImageSeries)
    fprintf('    Processing image %d...\n', ii);
    
    % Construct seed points from maxima and perform SCT
    [rows cols] = find(seriesImages(ii).data > sctPeakThresh);
    seeds = [rows cols]; %#ok used
    
    [~,seriesImages(ii).sctSegment] = ...
        evalc('performSCT(seriesImages(ii), sctThresh, seeds)'); %#ok
    
    % Perform SLLS
    seed = double(seriesImages(ii).data > sllsThresh); %#ok used
    [~,seriesImages(ii).sllsSegment] = ...
        evalc('performSLLS(seriesImages(ii), seed)'); %#ok
    
    % Save image
    sct = ['../outputs/' seriesImages(ii).name(1:end-4) '_sct.tif'];
    imwrite(seriesImages(ii).sctSegment, sct, 'tif', 'Compression', 'none');

    slls = ['../outputs/' seriesImages(ii).name(1:end-4) '_slls.tif'];
    imwrite(seriesImages(ii).sllsSegment, slls, 'tif', 'Compression', 'none');
end


% Display sample output
if plotting
    figure();
    subplot(2,1,1), imshow(seriesImages(1).sctSegment);
    title('Sample SCT segmentation for image series');
    subplot(2,1,2), imshow(seriesImages(1).sllsSegment);
    title('Sample SLLS segmentation for image series');
end


clear cols ii jj N rows sct sctPeakThresh sctThresh seed seeds slls sllsThresh;


%% C.1.1 Graph cut based image segmentation
disp 'Performing graph cut segmentation...'

% Add directories from graph_cut_based_algs to search path
addpath('graph_cut_based_algs/Ncut_9')

% Test first algorithm
disp 'Testing Ncut algorithm...'
images(1).ncutLabels = performNcut(images(1), 25);
images(2).ncutLabels = performNcut(images(2), 15);
seriesImages(1).ncutLabels = performNcut(seriesImages(1), 25);


if plotting
    figure();
    imagesc(images(1).ncutLabels); colormap jet;
    title('Image 1 ncut segmentation');
    
    figure();
    imagesc(images(2).ncutLabels); colormap jet;
    title('Image 2 ncut segmentation');
    
    figure();
    imagesc(seriesImages(1).ncutLabels); colormap jet;
    title('Image series sample ncut segmentation');
end


%% C.1.2 Active contour based image segmentation
disp 'Performing active countour segmentation...'
fprintf('\nStarting Gradient Vector Flow (GVF) segmentation...\n')

fprintf('   Processing static images...\n');

for ii = 1:numel(images) 
    [images(ii).GVFfirst, images(ii).GVFlast, images(ii).edgeMap] = ...
        performGVF(images(ii).data, 1,'rect',true);
    
    if plotting
        figure; imshow(images(ii).data,[]);
        snakedisp(images(ii).GVFfirst(:,1),images(ii).GVFfirst(:,2),'--y');
        snakedisp(images(ii).GVFlast(:,1),images(ii).GVFlast(:,2),'c');
        legend('Initial snake', 'Final snake')
        title('GVF snake convergence on the real image')
        
        figure; imshow((1-images(ii).edgeMap),[]);
        snakedisp(images(ii).GVFfirst(:,1),images(ii).GVFfirst(:,2),'--r');
        snakedisp(images(ii).GVFlast(:,1),images(ii).GVFlast(:,2),'b');
        legend('Initial snake', 'Final snake')
        title('GVF snake convergence on the edge map')
    end
end

fprintf('   Processing batch images...\n');
for ii = 1:max(1, length(seriesImages) * processImageSeries)
    fprintf('      Processing image %d...\n', ii);
    [seriesImages(ii).GVFfirst, seriesImages(ii).GVFlast, seriesImages(ii).edgeMap] = ...
        performGVFbatch(seriesImages(ii).data, [],'rect',true);
    
    if plotting
        figure; imshow(seriesImages(ii).data,[]);
        snakedisp(seriesImages(ii).GVFfirst(:,1),seriesImages(ii).GVFfirst(:,2),'--y');
        snakedisp(seriesImages(ii).GVFlast(:,1),seriesImages(ii).GVFlast(:,2),'c');
        legend('Initial snake', 'Final snake');
        h = title(['GVF snake convergence on the batch image ' seriesImages(ii).name]);
        set(h,'interpreter','none');
        
        figure; imshow((1-seriesImages(ii).edgeMap),[]);
        snakedisp(seriesImages(ii).GVFfirst(:,1),seriesImages(ii).GVFfirst(:,2),'--r');
        snakedisp(seriesImages(ii).GVFlast(:,1),seriesImages(ii).GVFlast(:,2),'b');
        legend('Initial snake', 'Final snake')
        h = title(['GVF snake convergence on the edge map of batch image '...
            seriesImages(ii).name]); set(h,'interpreter','none');
    end
end


fprintf('Starting Distance Regularized Level Set Evolution (DRLSE) segmentation...\n')
fprintf('   Processing static images...\n');

iter_in = 5;
iter_out = (250-10)/5;
for ii = 1:numel(images) 
    c1 = (numel(images(ii).data)/numel(images(2).data))^1.5; % Hand tuning
    [images(ii).LSFfirst, images(ii).LSFlast] = ...
        performDRLSE(images(ii).data, 10*c1, iter_in, iter_out, ...
                                5*c1, 2*c1, 1.5, 2, plotting);    
    if  plotting
        figure;
        imshow(images(ii).data,[]);
        axis off; axis equal; colormap(gray);
        hold on;  [~,h1] = contour(images(ii).LSFfirst, [0,0], 'y');
        hold on;  [~,h2] = contour(images(ii).LSFlast, [0,0], 'c');
        str=['Final zero level contour, ', ...
            num2str(iter_in*iter_out+10), ' iterations'];
        title(str);
        legend([h1  h2], 'Initial snake', 'Final snake')
    end
end

fprintf('   Processing batch images...\n');

for ii = 1:max(1, length(seriesImages) * processImageSeries)
    [seriesImages(ii).LSFfirst, seriesImages(ii).LSFlast] = ...
        performDRLSE(seriesImages(ii).data, 10, iter_in, iter_out, ...
                     5, 1.5, 1.5, 1, plotting);
     if  plotting
         figure;
         imshow(seriesImages(ii).data, []);
         axis off; axis equal; colormap(gray);
         hold on;  [~,h1] = contour(seriesImages(ii).LSFfirst, [0,0], 'y');
         hold on;  [~,h2] = contour(seriesImages(ii).LSFlast, [0,0], 'c');
         str=['Final zero level contour, ', ...
             num2str(iter_in*iter_out+10), ' iterations'];
         title(str);
         legend([h1  h2], 'Initial snake', 'Final snake')
     end
end





%% Make figures pretty and store them as pdfs
if plotting
    disp 'Saving figures...'
    funcPrettyFigures;
end
disp 'Done!'
