% Save plots
%------------
timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd_HH-mm'));
baseDir   = fullfile('utils', 'results', timestamp);
outputDir = fullfile(baseDir, 'plots');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

figHandles = findall(0, 'Type', 'figure');
for i = 1:length(figHandles)
    fig = figHandles(i);
    figure(fig);
    figName = get(fig, 'Name');
    if isempty(figName)
        figName = ['figure_' num2str(i)];
    end
    figName = regexprep(figName, '[^\w\d_-]', '_');
    saveas(fig, fullfile(outputDir, [figName '.fig']));
end

disp(['Plots have been saved in: ' outputDir]);

% Save variables values
%-----------------------
vars = whos;

% Keep only non-graphical variables (numbers, structs, cells, functions, etc.)
isGraphical = startsWith({vars.class}, {'matlab.graphics', 'matlab.ui'});
keptVars    = {vars(~isGraphical).name};

save(fullfile(baseDir, [mfilename '.mat']), keptVars{:});