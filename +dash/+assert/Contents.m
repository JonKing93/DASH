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
%   strflag         - Throw error if input is not a string flag.
%   strlist         - Throw error if input is not a string vector, cellstring vector, or char row vector
%   strsInList      - Throw error if strings are not in a list of allowed strings
%
% Size and Data Type:
%   type            - Throw error if input is not required type
%   scalarType      - Throw error if input is not a scalar of a required data type
%   vectorTypeN     - Throw error if input is not a vector of required data type and length
%
% Indices:
%   indices         - Throw error if inputs are neither logical indices nor linear indices
%   indexCollection - Throw error if input is not a collection of indices
%
% Misc:
%   fileExists      - Throw error if a file does not exist
%   nameValue       - Throw error if inputs are not Name,Value pairs
%   uniqueSet       - Throw error if vector has repeated values
%
% Tests:
%   tests           - Implement unit testing for the dash.assert subpackage
%
% <a href="matlab:dash.doc('dash.assert')">Documentation Page</a>