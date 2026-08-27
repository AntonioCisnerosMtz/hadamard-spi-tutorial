%% Install the external solver dependencies from downloaded repository ZIPs
%
% This reader-facing installer does NOT use any internal project package.
%
% Download the repository ZIPs in your browser first:
%
% L1-Magic public mirror:
%   https://github.com/scgt/l1magic
%
% FDRI:
%   https://github.com/KMCzajkowski/FDRI-single-pixel-imaging
%
% On GitHub, choose Code -> Download ZIP.
%
% Then run this script and select the two ZIP files when requested.
%
% L1-Magic is not redistributed by this tutorial package. The installer copies
% only the five Optimization files used by DCT-l1 and TV-QC.
%
% FDRI is also installed from the reader's downloaded ZIP. The original
% private/fdri.m is preserved; this tutorial adds only a thin local wrapper.

clear;
clc;

config = section7_8_config();

fprintf('External dependency installer\n');
fprintf('=============================\n\n');
fprintf('You will be asked for two repository ZIP files:\n');
fprintf('  1. L1-Magic\n');
fprintf('  2. FDRI-single-pixel-imaging\n\n');

%% ---------------------------------------------------------------------
% 1. L1-Magic
% ----------------------------------------------------------------------
[l1ZipName, l1ZipFolder] = uigetfile('*.zip', ...
    'Select the L1-Magic repository ZIP');

if isequal(l1ZipName, 0)
    fprintf('L1-Magic selection cancelled. DCT-l1 and TV-QC will remain unavailable.\n\n');
else
    l1Zip = fullfile(l1ZipFolder, l1ZipName);
    tempFolder = tempname;
    mkdir(tempFolder);
    cleanupL1 = onCleanup(@() safeRemoveFolder(tempFolder));

    fprintf('Installing L1-Magic from:\n%s\n', l1Zip);
    unzip(l1Zip, tempFolder);

    matches = dir(fullfile(tempFolder, '**', ...
        'Optimization', 'l1qc_logbarrier.m'));

    sourceOptimization = "";

    for k = 1:numel(matches)
        candidate = matches(k).folder;
        required = { ...
            'l1qc_logbarrier.m', ...
            'l1qc_newton.m', ...
            'tvqc_logbarrier.m', ...
            'tvqc_newton.m', ...
            'cgsolve.m'};

        complete = true;
        for j = 1:numel(required)
            complete = complete && ...
                exist(fullfile(candidate, required{j}), 'file') == 2;
        end

        if complete
            sourceOptimization = string(candidate);
            break;
        end
    end

    if strlength(sourceOptimization) == 0
        error(['The selected ZIP does not contain the expected L1-Magic ' ...
            'Optimization files. Download the L1-Magic repository ZIP and try again.']);
    end

    destination = fullfile(config.l1magicFolder, 'Optimization');
    if ~exist(destination, 'dir')
        mkdir(destination);
    end

    required = { ...
        'l1qc_logbarrier.m', ...
        'l1qc_newton.m', ...
        'tvqc_logbarrier.m', ...
        'tvqc_newton.m', ...
        'cgsolve.m'};

    for j = 1:numel(required)
        copyfile(fullfile(sourceOptimization, required{j}), ...
            fullfile(destination, required{j}));
    end

    %% Apply the narrow MATLAB compatibility patch used by the tutorial
    tvqcFile = fullfile(destination, 'tvqc_newton.m');
    sourceText = fileread(tvqcFile);

    if contains(sourceText, 'applyH11p') && ...
            contains(sourceText, 'H11pMatrix')
        fprintf('TV-QC compatibility patch: already present\n');
    else
        patchedText = sourceText;

        patchedText = strrep(patchedText, ...
            'h11pfun = @(z) H11p(z,', ...
            'h11pfun = @(z) applyH11p(z,');

        patchedText = strrep(patchedText, ...
            '    H11p =  Dh''*sparse', ...
            '    H11pMatrix =  Dh''*sparse');

        patchedText = strrep(patchedText, ...
            '[dx,hcond] = linsolve(H11p, w1p, opts);', ...
            '[dx,hcond] = linsolve(H11pMatrix, w1p, opts);');

        patchedText = strrep(patchedText, ...
            'function y = H11p(v, A, At, Dh, Dv, Dhx, Dvx, sigb, ft, fe, atr)', ...
            'function y = applyH11p(v, A, At, Dh, Dv, Dhx, Dvx, sigb, ft, fe, atr)');

        if strcmp(patchedText, sourceText) || ...
                ~contains(patchedText, 'applyH11p') || ...
                ~contains(patchedText, 'H11pMatrix')
            error(['The selected tvqc_newton.m does not match the expected ' ...
                'L1-Magic source. The compatibility patch was not applied.']);
        end

        fid = fopen(tvqcFile, 'w');
        assert(fid ~= -1, 'Could not write patched tvqc_newton.m.');
        fwrite(fid, patchedText);
        fclose(fid);

        fprintf('TV-QC compatibility patch: applied\n');
    end

    sourceRecord = fullfile(config.l1magicFolder, 'INSTALLATION_SOURCE.txt');
    fid = fopen(sourceRecord, 'w');
    if fid ~= -1
        fprintf(fid, 'Source ZIP: %s\n', l1ZipName);
        fprintf(fid, 'Files copied from: %s\n', sourceOptimization);
        fprintf(fid, 'TV-QC MATLAB compatibility patch: applied or already present\n');
        fclose(fid);
    end

    fprintf('L1-Magic: installed\n\n');

    clear cleanupL1
end

%% ---------------------------------------------------------------------
% 2. FDRI
% ----------------------------------------------------------------------
[fdriZipName, fdriZipFolder] = uigetfile('*.zip', ...
    'Select the FDRI-single-pixel-imaging repository ZIP');

if isequal(fdriZipName, 0)
    fprintf('FDRI selection cancelled. FDRI reconstruction will remain unavailable.\n\n');
else
    fdriZip = fullfile(fdriZipFolder, fdriZipName);
    tempFolder = tempname;
    mkdir(tempFolder);
    cleanupFdri = onCleanup(@() safeRemoveFolder(tempFolder));

    fprintf('Installing FDRI from:\n%s\n', fdriZip);
    unzip(fdriZip, tempFolder);

    matches = dir(fullfile(tempFolder, '**', 'private', 'fdri.m'));

    if isempty(matches)
        error(['The selected ZIP does not contain private/fdri.m. ' ...
            'Download the FDRI-single-pixel-imaging repository ZIP and try again.']);
    end

    sourcePrivate = string(matches(1).folder);
    sourceRoot = fileparts(sourcePrivate);

    destinationRoot = config.fdriFolder;
    destinationPrivate = fullfile(destinationRoot, 'private');

    if ~exist(destinationPrivate, 'dir')
        mkdir(destinationPrivate);
    end

    copyfile(fullfile(sourcePrivate, 'fdri.m'), ...
        fullfile(destinationPrivate, 'fdri.m'));

    % Copy upstream descriptive/license files when present.
    optionalFiles = {'LICENSE', 'README.md', 'change history.txt'};
    for j = 1:numel(optionalFiles)
        candidate = fullfile(sourceRoot, optionalFiles{j});
        if exist(candidate, 'file') == 2
            copyfile(candidate, fullfile(destinationRoot, optionalFiles{j}));
        end
    end

    % Install the tutorial's thin wrapper next to the upstream private folder.
    copyfile(fullfile(config.projectFolder, ...
        'support', 'fdri_public_wrapper_cpu_gcss_v01.m'), ...
        fullfile(destinationRoot, 'fdri_public_wrapper_cpu_gcss_v01.m'));

    sourceRecord = fullfile(destinationRoot, 'INSTALLATION_SOURCE.txt');
    fid = fopen(sourceRecord, 'w');
    if fid ~= -1
        fprintf(fid, 'Source ZIP: %s\n', fdriZipName);
        fprintf(fid, 'Upstream root found at: %s\n', sourceRoot);
        fclose(fid);
    end

    fprintf('FDRI: installed\n\n');

    clear cleanupFdri
end

%% Final installation check
fprintf('Running installation check...\n\n');
run(fullfile(config.projectFolder, 'CHECK_INSTALLATION.m'));

%% Local helper
function safeRemoveFolder(folderName)
if exist(folderName, 'dir') == 7
    try
        rmdir(folderName, 's');
    catch
        % A temporary folder left behind is harmless.
    end
end
end
