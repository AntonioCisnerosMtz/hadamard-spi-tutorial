function x = read_numeric_column(filePath)
%READ_NUMERIC_COLUMN Read whitespace-delimited numeric text as a column vector.
%
% The experimental DAQ files contain one numeric value per line, preceded by
% a tab character. Using readmatrix can interpret that leading tab as an
% empty first column and insert NaN values. fscanf reads numeric tokens while
% safely ignoring tabs, spaces, and line endings.

assert(exist(filePath, 'file') == 2, 'Input file not found: %s', filePath);

fileId = fopen(filePath, 'rt');
assert(fileId ~= -1, 'Could not open input file: %s', filePath);
cleanupObject = onCleanup(@() fclose(fileId)); %#ok<NASGU>

x = fscanf(fileId, '%f');
x = x(:);

assert(~isempty(x), 'Input file does not contain numeric data: %s', filePath);
assert(all(isfinite(x)), 'Input contains non-finite numeric values: %s', filePath);
end
