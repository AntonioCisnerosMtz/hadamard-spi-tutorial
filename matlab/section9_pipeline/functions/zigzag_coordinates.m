function [uList, vList] = zigzag_coordinates(n)
%ZIGZAG_COORDINATES Return the coordinates of an n-by-n zigzag path.
%
% The path starts at the upper-left coordinate. Consecutive diagonals are
% traversed in opposite directions. The first coordinates are:
% (1,1), (1,2), (2,1), (3,1), (2,2), (1,3), ...

N = n^2;
uList = zeros(N, 1);
vList = zeros(N, 1);

i = 1;

for diagonal = 2:(2 * n)
    firstU = max(1, diagonal - n);
    lastU = min(n, diagonal - 1);

    if mod(diagonal, 2) == 1
        uValues = firstU:lastU;
    else
        uValues = lastU:-1:firstU;
    end

    for u = uValues
        v = diagonal - u;

        uList(i) = u;
        vList(i) = v;
        i = i + 1;
    end
end

end
