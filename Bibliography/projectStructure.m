function projectStructure()
% PROJECTSTRUCTURE  Generates a directory tree in Markdown format.
%   Runs from wherever the script is located and saves the output there.

scriptDir  = fileparts(mfilename('fullpath'));
rootDir    = scriptDir;
outputFile = fullfile(scriptDir, 'projectStructure.md');

fid = fopen(outputFile, 'w', 'n', 'UTF-8');
if fid == -1
    error('Could not open output file: %s', outputFile);
end

[~, rootName] = fileparts(rootDir);
fprintf(fid, '```\n%s/\n', rootName);
writeTree(fid, rootDir, '');
fprintf(fid, '```\n');

fclose(fid);
fprintf('Tree saved to: %s\n', outputFile);
end

% -------------------------------------------------------------------------
function writeTree(fid, currentDir, prefix)
EXCLUDE = {'.git', '.github', 'node_modules', '__pycache__'};

entries = dir(currentDir);
% Filter out . .. and excluded folders
entries = entries(~ismember({entries.name}, [{'.','..'}, EXCLUDE]));
% Folders first, then files, both alphabetically sorted
dirs  = entries([entries.isdir]);
files = entries(~[entries.isdir]);
[~, idx] = sort({dirs.name});  dirs  = dirs(idx);
[~, idx] = sort({files.name}); files = files(idx);
entries = [dirs; files];

n = numel(entries);
for i = 1:n
    isLast    = (i == n);
    connector = '└── ';
    extender  = '    ';
    if ~isLast
        connector = '├── ';
        extender  = '│   ';
    end

    e = entries(i);
    if e.isdir
        fprintf(fid, '%s%s%s/\n', prefix, connector, e.name);
        writeTree(fid, fullfile(currentDir, e.name), [prefix extender]);
    else
        fprintf(fid, '%s%s%s\n', prefix, connector, e.name);
    end
end
end