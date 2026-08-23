function Hseq = sequency_hadamard(n)
%SEQUENCY_HADAMARD Build H_n^seq used throughout the tutorial scripts.
%
% The Sylvester Hadamard matrix is generated recursively and its rows are
% then ordered by increasing number of sign changes (sequency). The original
% row index is used only to make ties deterministic.

assert(n >= 1 && abs(log2(n) - round(log2(n))) < 10*eps, ...
    'n must be a positive power of two.');

% Sylvester recursion.
Hnatural = 1;
while size(Hnatural, 1) < n
    Hnatural = [Hnatural Hnatural; Hnatural -Hnatural]; %#ok<AGROW>
end

% Sequency order: fewest sign changes first.
signChanges = sum(Hnatural(:,1:end-1) ~= Hnatural(:,2:end), 2);
originalIndex = (1:n).';
[~, permutation] = sortrows([signChanges originalIndex], [1 2]);
Hseq = Hnatural(permutation, :);

% H_n^seq must preserve Hadamard orthogonality.
orthogonalityError = norm(Hseq*Hseq.' - n*eye(n), 'fro') / n;
assert(orthogonalityError <= 1e-12, ...
    'Sequency Hadamard orthogonality validation failed.');
end
