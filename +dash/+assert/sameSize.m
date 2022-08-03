function[] = sameSize(A, B, nameA, nameB, header)
%% dash.assert.sameSize  Throw error if two arrays are not the same size
% ----------
%   dash.assert.sameSize(A, B)
%   Throws an error if A and B are arrays with different sizes.
%
%   dash.assert.sameSize(A, B, nameA, nameB, header)
%   Customize error messages and headers.
% ----------
%   Inputs:
%       A: The first array
%       B: The second array
%       nameA (string scalar): A name for A in error messages
%       nameB (string scalar): A name of B in error messages
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('dash.assert.sameSize')">Documentation Page</a>

% Defaults
if ~exist('nameA','var')
    nameA = 'the first array';
end
if ~exist('nameB','var')
    nameB = 'the second array';
end
if ~exist('header','var')
    header = "DASH:assert:sameSize";
end

% Get sizes
sizeA = size(A);
sizeB = size(B);

% Error if not the same
if ~isequal(sizeA, sizeB)
    id = sprintf('%s:differentSizes', header);
    ME = MException(id, 'The size of %s (%s) is different than the size of %s (%s).',...
        nameA, dash.string.size(sizeA), nameB, dash.string.size(sizeB));
    throwAsCaller(ME);
end

end