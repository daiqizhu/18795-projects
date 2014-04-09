function y = funcPrettyFigures
% Makes figures prettier and stores them as pdfs.

% Create a clean directory for output
pdfPath = './matlab_plots/';
if exist(pdfPath,'dir')
    rmdir(pdfPath, 's');
end
mkdir(pdfPath);

% Get all  figures
y = sort(findobj(0,'Type','figure'), 'ascend');

% For each figure process each axes and store the image
for ii = 1:length(y)
    fig = y(ii);
    ax = findobj(fig,'Type','axes');
    for jj = 1:length(ax)
        set(ax(jj),'LineWidth',1);
        set(ax(jj),'FontSize',12);
        set(get(ax(jj),'xlabel'),'FontSize', 12, 'FontWeight', 'Bold');
        set(get(ax(jj),'ylabel'),'FontSize', 12, 'FontWeight', 'Bold');
        set(get(ax(jj),'title'),'FontSize', 12, 'FontWeight', 'Bold');
        axis tight
    end
    figPos = get(fig,'Position');
    aspectRatio = figPos(4)/figPos(3);
    set(fig,'color','w');
    set(fig,'PaperUnits','inches');
    set(fig,'PaperSize', [(0.5+8) (0.5+8*aspectRatio)]);
    set(fig,'PaperPosition',[0.25 0.25 8 8*aspectRatio]);
    set(fig,'PaperPositionMode','Manual');
    saveas = [pdfPath 'figure_' num2str(y(ii))];
    print(fig, '-painters', '-dpdf', '-r150', saveas)
end

end