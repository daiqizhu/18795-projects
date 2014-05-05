%
% 18-795 Project 4
%
% performGraphCut2.m
% Part C.1.1 - 2nd Algorithm

% Calls main_CV in the algorithms2 directory, which the code there is
% from http://math.bnu.edu.cn/~liujun/

close all
clear all

addpath('graph_cut_based_algs/algorithm2/');

% Two static images
main_CV('graph_cut_based_algs/static_images/60x_02.tif',...
    '../results/Part C.1.1/60x_02.tif');
pause
main_CV('graph_cut_based_algs/static_images/Blue0001.tif',...
    '../results/Part C.1.1/Blue0001.tif');
pause

% Sequence of images
% Iterate through each image
for i = 2001:2150
    filename = sprintf('graph_cut_based_algs/sequence_images/MitoGFP_LgtGal4_a01r01s0%d.tif',i);
    outputname = sprintf('../results/Part C.1.1/sequence/MitoGFP_LgtGal4_a01r01s0%d.tif',i);
    main_CV(filename,outputname);
end
% The AVI creation was done in ImageJ