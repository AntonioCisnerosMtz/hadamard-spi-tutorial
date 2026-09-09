function dmdFrame = make_centered_dmd_frame( ...
    logicalMask, q, dmdResolution)
%MAKE_CENTERED_DMD_FRAME Expand and center a binary mask in a DMD frame.

if q < 1 || mod(q, 1) ~= 0
    error('q must be a positive integer.');
end

activeMask = repelem(logical(logicalMask), q, q);

dmdRows = dmdResolution(1);
dmdColumns = dmdResolution(2);
activeRows = size(activeMask, 1);
activeColumns = size(activeMask, 2);

if activeRows > dmdRows || activeColumns > dmdColumns
    error('The expanded pattern does not fit inside the DMD frame.');
end

firstRow = floor((dmdRows - activeRows) / 2) + 1;
firstColumn = floor((dmdColumns - activeColumns) / 2) + 1;

lastRow = firstRow + activeRows - 1;
lastColumn = firstColumn + activeColumns - 1;

dmdFrame = false(dmdRows, dmdColumns);
dmdFrame(firstRow:lastRow, firstColumn:lastColumn) = activeMask;

end
