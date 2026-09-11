% measureObjectDimensions.m
% Measure planar object dimensions using perspective projection.
% Assumes the object plane is parallel to the camera sensor.
% groundTruth.csv is in MATLAB Drive root and images are in MATLAB Drive/images.

clear; clc; close all;

baseFolder = fileparts(mfilename("fullpath"));
imgFolder = fullfile(baseFolder, "images");
gtFile = fullfile(baseFolder, "groundTruth.csv");

if ~isfolder(imgFolder)
    error("Could not find images folder at: %s", imgFolder);
end

if ~isfile(gtFile)
    error("Could not find groundTruth.csv at: %s", gtFile);
end

Tgt = readtable(gtFile, TextType="string");

requiredVars = ["filename", "trueWidth_m", "trueLength_m"];
if ~all(ismember(requiredVars, string(Tgt.Properties.VariableNames)))
    error("groundTruth.csv must contain columns: filename, trueWidth_m, trueLength_m");
end

n = height(Tgt);
if n ~= 20
    warning("Expected 20 measurements, but found %d rows in groundTruth.csv.", n);
end

% Replace these with your camera's approximate intrinsics in pixels.
fx = 2850;
fy = 2850;

% Use image center as principal point.
cx = NaN;
cy = NaN;

% Known camera-to-object distance in meters.
% Set this to your measured distance, greater than 2 m.
Z_m = 2.50;

estWidth_m = zeros(n, 1);
estLength_m = zeros(n, 1);

for i = 1:n
    imgFile = fullfile(imgFolder, Tgt.filename(i));

    if ~isfile(imgFile)
        error("Missing image file: %s", imgFile);
    end

    I = imread(imgFile);

    if isnan(cx) || isnan(cy)
        [h, w, ~] = size(I);
        cx = (w + 1) / 2;
        cy = (h + 1) / 2;
    end

    figure(1); clf;
    imshow(I);
    title("Click 4 corners in order: top-left, top-right, bottom-right, bottom-left");

    [u, v] = ginput(4);
    uv = [u v];

    XY = pixelToWorldPlane(uv, fx, fy, cx, cy, Z_m);

    widthTop = norm(XY(2,:) - XY(1,:));
    widthBottom = norm(XY(3,:) - XY(4,:));
    lengthLeft = norm(XY(4,:) - XY(1,:));
    lengthRight = norm(XY(3,:) - XY(2,:));

    estWidth_m(i) = mean([widthTop, widthBottom]);
    estLength_m(i) = mean([lengthLeft, lengthRight]);
end

widthErr_m = estWidth_m - Tgt.trueWidth_m;
lengthErr_m = estLength_m - Tgt.trueLength_m;

results = table( ...
    Tgt.filename, Tgt.trueWidth_m, Tgt.trueLength_m, ...
    estWidth_m, estLength_m, widthErr_m, lengthErr_m, ...
    'VariableNames', {'filename','trueWidth_m','trueLength_m', ...
    'estWidth_m','estLength_m','widthErr_m','lengthErr_m'});

stats = table( ...
    mean(widthErr_m), mean(abs(widthErr_m)), sqrt(mean(widthErr_m.^2)), std(widthErr_m), max(abs(widthErr_m)), ...
    mean(lengthErr_m), mean(abs(lengthErr_m)), sqrt(mean(lengthErr_m.^2)), std(lengthErr_m), max(abs(lengthErr_m)), ...
    'VariableNames', { ...
    'MeanWidthErr_m','MAEWidth_m','RMSEWidth_m','StdWidthErr_m','MaxAbsWidthErr_m', ...
    'MeanLengthErr_m','MAELength_m','RMSELength_m','StdLengthErr_m','MaxAbsLengthErr_m'});

disp(results);
disp(stats);

writetable(results, fullfile(baseFolder, "measurementResults.csv"));
writetable(stats, fullfile(baseFolder, "errorStatistics.csv"));

function XY = pixelToWorldPlane(uv, fx, fy, cx, cy, Z)
u = uv(:,1);
v = uv(:,2);

X = (u - cx) .* Z ./ fx;
Y = (v - cy) .* Z ./ fy;

XY = [X Y];
end
