% createGroundTruthCSV.m
% Creates groundTruth.csv for all images in the current folder.
% Assumes the same true object dimensions for every image.

clear; clc;

imgFolder = "/MATLAB Drive/images";   % /MATLAB Drive/images/

% Set the real object dimensions here (in meters)
trueWidth_m = 0.635;
trueLength_m = 1.117;

% Collect image files
files = [ ...
    dir(fullfile(imgFolder, "*.JPG")); ...
    ];

if isempty(files)
    error("No image files found in: %s", imgFolder);
end

% Sort by filename for consistent ordering
[~, idx] = sort({files.name});
files = files(idx);

filename = string({files.name})';
trueWidth_m = repmat(trueWidth_m, numel(files), 1);
trueLength_m = repmat(trueLength_m, numel(files), 1);

T = table(filename, trueWidth_m, trueLength_m);

% Save groundTruth.csv in the parent folder so your main script can find it
outFile = fullfile(fileparts(imgFolder), "groundTruth.csv");
writetable(T, outFile);

disp("groundTruth.csv created successfully.");
