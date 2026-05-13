function organiseFiles(mainFile)
% Minimum MATLAB version required: R2016b
%
% organiseFiles - Organizes and separates essential and non-essential files for a MATLAB project.
%
% This function performs the following:
%
%   1. Identifies all files required to run the mainFile using MATLAB's dependency analyzer.
%
%   2. Determines the project root as the common ancestor of all dependencies and the mainFile.
%
%   3. Finds all files under the project root directory and its subdirectories.
%
%   4. Separates files into essential and non-essential based on their usage by mainFile.
%
%   5. Saves two text files ("essentialFiles.txt" and "nonEssentialFiles.txt") listing
%      the file hierarchy for essential and non-essential files, respectively. These files
%      are stored in "archivedFiles/logs" inside the project root.
%
%   6. Moves all non-essential files into a new folder "archivedFiles" at the project root,
%      preserving the original folder structure.
%
%   7. Removes any empty directories left under the project root (except archivedFiles).
%
% Usage:
%   organiseFiles(mainFile)
%
% Input:
%   mainFile - The main MATLAB script or function filename (string) to analyze dependencies for.

%% Step 1: Get required files
[filesNeeded, ~] = matlab.codetools.requiredFilesAndProducts(mainFile);
filesNeeded = string(filesNeeded);
mainPath = which(mainFile);
allPaths = [filesNeeded(:); string(mainPath)];

%% Step 2: Compute project root common path
splitPaths = cellfun(@(p) split(p, filesep), cellstr(allPaths), 'UniformOutput', false);
minLen = min(cellfun(@length, splitPaths));
commonSegments = splitPaths{1}(1:minLen);

for i = 2:length(splitPaths)
    segs = splitPaths{i}(1:minLen);
    tempCommon = {};
    for idx = 1:min(length(commonSegments), length(segs))
        if strcmp(commonSegments{idx}, segs{idx})
            tempCommon{end+1} = commonSegments{idx}; %#ok<AGROW>
        else
            break;
        end
    end
    commonSegments = tempCommon;
    if isempty(commonSegments)
        break;
    end
end

projectRoot = fullfile(commonSegments{:});
if isempty(projectRoot)
    projectRoot = fileparts(mainPath);
end

%% Step 3: List all files under projectRoot
allFiles = dir(fullfile(projectRoot, '**', '*'));
allFiles = allFiles(~[allFiles.isdir]); % exclude directories
allFilePaths = string(fullfile({allFiles.folder}, {allFiles.name}));

%% Step 4: Identify non-essential files
% Ensure this script itself is considered essential
scriptPath = which('organiseFiles.m');
if ~isempty(scriptPath)
    filesNeeded(end+1) = string(scriptPath);
end

filesNotNeeded = setdiff(allFilePaths, filesNeeded);

%% Helper: Build folder structure map
function folderStruct = buildFolderStructure(fileList)
    folderStruct = containers.Map('KeyType','char','ValueType','any');
    for k = 1:length(fileList)
        fp = char(fileList(k));
        [fld, nm, ext] = fileparts(fp);
        fn = [nm ext];
        if ~isKey(folderStruct, fld)
            folderStruct(fld) = {fn};
        else
            lst = folderStruct(fld);
            lst{end+1} = fn;
            folderStruct(fld) = lst;
        end
    end
end

%% Helper: Save structure to .txt with hierarchy
function saveStructure(folderStruct, outfile, header)
    fid = fopen(outfile, 'w');
    if fid == -1
        error('Cannot open file %s for writing.', outfile);
    end

    fprintf(fid, '%s\n\n', header);

    [~, rootName] = fileparts(projectRoot);
    fprintf(fid, '📁 %s\n', rootName);

    % Files directly under root
    if isKey(folderStruct, projectRoot)
        filesAtRoot = sort(folderStruct(projectRoot));
        for f = filesAtRoot
            fprintf(fid, '  └─ 📄 %s\n', f{1});
        end
    end

    folders = sort(keys(folderStruct));
    for i = 1:length(folders)
        fld = folders{i};
        if strcmp(fld, projectRoot), continue; end
        rel = extractAfter(fld, [projectRoot filesep]);
        depth = count(rel, filesep) + 1;
        indent = repmat('  ', 1, depth);
        fprintf(fid, '%s📁 %s\n', indent, rel);
        for f = sort(folderStruct(fld))
            fprintf(fid, '%s  └─ 📄 %s\n', indent, f{1});
        end
    end

    fclose(fid);
end

%% Step 5: Build maps and save .txt files
neededMap = buildFolderStructure(filesNeeded);
notNeededMap = buildFolderStructure(filesNotNeeded);

% Destination for non-essential files
destRoot = fullfile(projectRoot, 'archivedFiles');

% Define logs folder inside archivedFiles
logDir = fullfile(destRoot, 'logs');
if ~exist(logDir, 'dir')
    mkdir(logDir);
end

% Save essential and non-essential file lists in logs folder
saveStructure(neededMap, fullfile(logDir, 'essentialFiles.txt'), ['Files needed to run: ', mainFile]);
saveStructure(notNeededMap, fullfile(logDir, 'nonEssentialFiles.txt'), ['Files NOT needed to run: ', mainFile]);

%% Step 6: Move non-essential files, preserve structure
for idx = 1:numel(filesNotNeeded)
    src = char(filesNotNeeded(idx));
    relativePath = erase(src, [projectRoot, filesep]);
    destPath = fullfile(destRoot, relativePath);
    destFolder = fileparts(destPath);

    if ~exist(destFolder, 'dir')
        mkdir(destFolder);
    end

    movefile(src, destPath);
end

%% Step 7: Remove empty directories under projectRoot
dirs = dir(fullfile(projectRoot, '**'));
dirs = dirs([dirs.isdir]);
dirs = sortrows(struct2table(dirs), 'name', 'descend'); % deeper paths first
dirs = table2struct(dirs);

for i = 1:length(dirs)
    d = fullfile(dirs(i).folder, dirs(i).name);
    if strcmp(d, projectRoot) || contains(d, 'archivedFiles')
        continue
    end
    try
        rmdir(d);
    catch
        % not empty, do nothing
    end
end

%% Final message
clc;
fprintf(['All non-essential files to run "%s" have been moved to "archivedFiles".\n' ...
    'See files listed in "archivedFiles/logs/essentialFiles.txt" and ' ...
    '"archivedFiles/logs/nonEssentialFiles.txt".\n'], mainFile);
end