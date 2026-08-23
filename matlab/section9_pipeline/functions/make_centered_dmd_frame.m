function dmdFrame = make_centered_dmd_frame( ...
    logicalMask, activeRegionSize, dmdResolution)
%MAKE_CENTERED_DMD_FRAME Resize and center a binary mask in a DMD frame.

activeMask = logical(imresize( ...
    logicalMask, ...
    [activeRegionSize activeRegionSize], ...
    'nearest'));

dmdRows = dmdResolution(1);
dmdColumns = dmdResolution(2);

firstRow = floor((dmdRows - activeRegionSize) / 2) + 1;
firstColumn = floor((dmdColumns - activeRegionSize) / 2) + 1;

lastRow = firstRow + activeRegionSize - 1;
lastColumn = firstColumn + activeRegionSize - 1;

dmdFrame = false(dmdRows, dmdColumns);
dmdFrame(firstRow:lastRow, firstColumn:lastColumn) = activeMask;

end
