function Hseq = sequency_hadamard(n)
%SEQUENCY_HADAMARD Build the sequency-ordered Hadamard matrix H_n^seq.
%
% The Sylvester Hadamard matrix is generated recursively. Its rows are then
% sorted by increasing number of sign changes, which is the sequency used in
% the tutorial. The original row index is used only to make ties deterministic.

assert(n >= 1 && abs(log2(n) - round(log2(n))) < 10*eps, ...
    'n must be a positive power of two.');

%% Step 1 - Build the Sylvester Hadamard matrix
Hnatural = 1;
while size(Hnatural, 1) < n
    Hnatural = [Hnatural Hnatural; Hnatural -Hnatural]; %#ok<AGROW>
end

%% Step 2 - Sort rows from low to high sequency
signChanges = sum(Hnatural(:,1:end-1) ~= Hnatural(:,2:end), 2);
originalIndex = (1:n).';
[~, permutation] = sortrows([signChanges originalIndex], [1 2]);
Hseq = Hnatural(permutation, :);

%% Step 3 - Verify Hadamard orthogonality
orthogonalityError = norm(Hseq*Hseq.' - n*eye(n), 'fro') / n;
assert(orthogonalityError <= 1e-12, ...
    'Sequency Hadamard orthogonality validation failed.');
end
