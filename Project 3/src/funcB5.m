function funcB5

clear all
close all

I{1} = im2double(imread('../images/image01.tiff'));
imginfo = imfinfo('../images/image02.tiff');
I{2} = im2double(imread('../images/image02.tiff', 1, 'Info', imginfo));
I{3} = im2double(imread('../images/image02.tiff', 2, 'Info', imginfo));
imIndex = 1; % image index, images are called I{imIndex}

sigmaU = 10;
sigmaV = 5;
theta = [0 30 60 90 120 150];

% Showing filtered figures 1 by 1
for i = 1:length(theta)
    kernel{i} = anisoGaussian(sigmaU, sigmaV, theta(i));
    y{i} = filter2(kernel{i}, I{imIndex});
    figure;imshow(y{i},[])
    title([', rotation: ' ...
         num2str(theta(i)) '^\circ']);
end

%%  Showing before and after
figure
subplot(2,2,1);imshow(I{imIndex},[]);title('Original image');
subplot(2,2,4);imshow(kernel{2},[]);title('Second kernel, 30^\circ');
subplot(2,2,2);imshow(y{2},[]);title('Filtered image');

%% Showing original figure and all kernels
figure;
subplot(3,1,1);imshow(I{imIndex},[]);title('Original image');
 for i=1:length(theta)
     subplot(3, ceil(length(theta)/2),3+i);
     imshow(kernel{i},[]);title('Second kernel, 30^\circ');
 end


%% Showing all kernels
figure
subFigRows = floor(sqrt(length(theta)));
 for i=1:length(theta)
     subplot(subFigRows, ceil(length(theta)/subFigRows),i);
     imshow(kernel{i},[]);title(['Kernel #' num2str(i) ', rotation: ' ...
         num2str(theta(i)) '^\circ']);
 end
 
%% Showing filtered images
figure
subFigRows = floor(sqrt(length(theta)));
 for i=1:length(theta)
     subplot(subFigRows, ceil(length(theta)/subFigRows),i);
     imshow(y{i},[]);title(['Filtered image #' num2str(i) ', rotation: ' ...
         num2str(theta(i)) '^\circ']);
 end
 
%% Figure manipulation 
set(gca,'LineWidth',1);
set(gca,'FontSize',16);
axis tight
set(gcf,'color','w');
set(gcf,'PaperUnits','inches');
set(gcf,'PaperSize', [8 8]);
set(gcf,'PaperPosition',[0 0 8 8]);
set(gcf,'PaperPositionMode','Manual');
saveas = ['figure_' num2str(gcf)];
%print('-painters', '-dpdf', '-r150', saveas) 



%% Kernel generation
function kernel = anisoGaussian(sigmaU, sigmaV, theta)
%This part, I have asked professor
phi = atand((sigmaV^2*cosd(theta)^2 + sigmaU^2*sind(theta)^2)/...
    ((sigmaU^2-sigmaV^2)*sind(theta)*cosd(theta)));
sigmaX = sigmaU*sigmaV /sqrt( sigmaV^2*cosd(theta)^2 + ...
    sigmaU^2*sind(theta)^2 );
sigmaP = abs(1/sind(phi) *...
    sqrt( sigmaV^2*cosd(theta)^2 + sigmaU^2*sind(theta)^2 ));

% This part I am not sure (probably wrong)
x = -2*round(sigmaU):1:round(sigmaU)*2;
y = -2*round(sigmaP):1:round(sigmaP)*2;
kernel = zeros(length(x),length(y));
for i = 1:length(x)
    for j = 1:length(y)
        kernel(i,j) = 1/(2*pi*sigmaX*sigmaP)*exp(-0.5*( ...
            (x(i)-y(j)/tand(phi))^2/sigmaX^2 + ...
            (y(j)/sind(phi))^2/sigmaP^2 ) );
    end
end


