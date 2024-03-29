%% dash.assert  Functions that assert inputs meet required conditions
% ----------
%   The dash.assert subpackage facilitates the creation of informative
%   error messages and helps provide consistent error ID handling for common
%   input error checks. These functions produce error messages that appear to
%   originate from higher level calling functions.
%
%   Some functions also return inputs converted to specific formats to ensure
%   consistent internal handling of different input types.
% ----------
% Strings:
%   string                  - Throw error if input is not a string array, cellstring array, or character row vector
%   strflag                 - Throw error if input is not a string scalar, cellstring scalar, or character row vector
%   strlist                 - Throw error if input is not a string vector, cellstring vector, or char row vector
%   strsInList              - Throw error if strings are not in a list of allowed strings
%
% Size and Data Type:
%   type                    - Throw error if input is not required type
%   scalarType              - Throw error if input is not a scalar of a required data type
%   vectorTypeN             - Throw error if input is not a vector of required data type and length
%   matrixTypeSize          - Throw error if input is not matrix of required data type and size
%   blockTypeSize           - Throw error if input is not a 3D array of required data type and size
%
% Misc Size:
%   scalarObj               - Throw error if method object is not scalar
%   sameSize                - Throw error if arrays are not the same size
%
% Numeric:
%   integers                - Throw error if numeric array does not consist entirely of integers
%   positiveIntegers        - Throw error if numeric array does not consist entirely of positive integers
%   defined                 - Throw error if numeric array contains NaN, Inf, or complex values
%
% Covariances:
%   symmetricMatrices       - Throw error if element along third dimension are not symmetric matrices
%   positiveDiagonals       - Throw error if diagonal elements of matrices along the third dimension are not positive
%   covariances             - Throw error if matrices along third dimensions are not symmetric with positive diagonals
%
% Indices:
%   indices                 - Throw error if input is neither logical indices nor linear indices
%   indexCollection         - Throw error if input is not a collection of indices
%   additiveIndices         - Throw error if input is not a vector of additive indices
%   additiveIndexCollection - Throw error if input is not a collection of additive indices
%
% Misc:
%   fileExists              - Throw error if a file does not exist
%   nameValue               - Throw error if inputs are not Name,Value pairs
%   uniqueSet               - Throw error if vector has repeated values
%
% Unit tests:
%   tests                   - Unit testing for the dash.assert subpackage
%
% <a href="matlab:dash.doc('dash.assert')">Documentation Page</a>