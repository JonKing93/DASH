%% dash.metadata  Functions implementing metadata for gridded datasets
% ----------
% Metadata creation:
%   define           - Creates a metadata structure for a gridded dataset
%
% Requirements/Assertions:
%   assert           - Throw error if input is not a valid metadata structure
%   assertField      - Throw error if input is not a valid metadata field
%
% Comparisons:
%   bothNaN          - True if two inputs are both scalar NaN
%   hasDuplicateRows - True if a metadata field has duplicate rows
%
% Tests:
%   tests            - Unit-tests for dash.metadata subpackage
%
% <a href="matlab:dash.doc('dash.metadata')">Documentation Page</a>