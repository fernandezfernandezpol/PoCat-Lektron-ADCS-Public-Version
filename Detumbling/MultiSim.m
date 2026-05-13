% Batch simulation runner for the B-Dot detumbling pipeline.
% Runs Detumbling.m numSims times (each with a fresh random initial quaternion
% and the sensor noise re-drawn) and saves the angular rate time histories.

numSims = 2;
results = cell(numSims, 1);

for i = 1:numSims
    Detumbling;
    results{i,1} = rad2deg(xPlot(11:13,:));
end

timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd_HH-mm'));
baseDir   = fullfile('utils', 'results', timestamp);

if ~exist(baseDir, 'dir')
    mkdir(baseDir);
end

save(fullfile(baseDir, [mfilename '.mat']), 'results');
