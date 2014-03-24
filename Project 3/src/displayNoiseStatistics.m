function displayNoiseStatistics(images)
%
% Used for Part B.2
%
% displayNoiseHistogram: displays statistics on our data over time and
%     space
%
% Inputs:  images - a vector of image structs containing noise data
%
% Outputs: figures of data
%

% First display the mean and variance over time
figure();
ax = plotyy(1:numel(images), [images.nmean],  ...
            1:numel(images), [images.nstd]);
set(get(ax(1),'Ylabel'),'String','Noise mean');
set(get(ax(2),'Ylabel'),'String','Noise variance');
xlabel('Time')
legend('Noise mean', 'Noise variance');
title('Noise mean and variance over time');

% Then display over space
summed = zeros(size(images(1).cropped,1), size(images(1).cropped,2));
for ii=1:numel(images)
    summed = summed + images(ii).cropped;
end
summed = summed/numel(images);

% Plot x position against average intensity
figure();
subplot(2,1,1), plot(1:size(summed,2), mean(summed));
xlabel('x position'); ylabel('Average intensity');
title('Average intensity over the x-axis');

% Plot y position against average intensity
subplot(2,1,2), plot(mean(summed,2),   1:size(summed,1));
ylabel('y position'); xlabel('Average intensity');
title('Average intensity over the y-axis');

end
